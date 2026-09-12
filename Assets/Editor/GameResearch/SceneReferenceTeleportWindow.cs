using System;
using System.IO;
using GlobalEnums;
using UnityEditor;
using UnityEditor.AddressableAssets;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace GameResearch
{
    // Editor-only controls: keep the recovered game scripts and scenes untouched.
    public sealed class SceneReferenceTeleportWindow : EditorWindow
    {
        [SerializeField] private string sceneName = "Bone_02";
        [SerializeField] private string gateName = "left1";
        [SerializeField] private bool usePosition;
        [SerializeField] private Vector2 targetPosition;

        private string message;
        private MessageType messageType = MessageType.Info;
        private bool pending;
        private bool waitingForResume;
        private bool moveWithinScene;
        private bool positioned;
        private string requestedScene;
        private string requestedGate;
        private bool requestedUsePosition;
        private Vector2 requestedPosition;
        private double deadline;
        private int startFrame;
        private float positionFixedTime;

        [MenuItem("Tools/Scene Research/场景传送", priority = 90)]
        public static void Open()
        {
            GetWindow<SceneReferenceTeleportWindow>("场景传送").Show();
        }

        [MenuItem("Tools/Scene Research/执行场景传送（使用窗口设置）", priority = 91)]
        public static void TeleportFromMenu()
        {
            GetWindow<SceneReferenceTeleportWindow>("场景传送").BeginTeleport();
        }

        private void OnEnable()
        {
            minSize = new Vector2(430f, 440f);
            EditorApplication.update += UpdateTeleport;
        }

        private void OnDisable()
        {
            EditorApplication.update -= UpdateTeleport;
            pending = false;
        }

        private void OnInspectorUpdate() => Repaint();

        private void OnGUI()
        {
            EditorGUILayout.HelpBox(
                "先按 Play，从菜单进入存档。游戏暂停时可点击“继续游戏并传送”。\n" +
                "传送过程中请保持此窗口打开。",
                MessageType.Info);

            string readiness = GetReadiness();
            HeroController hero = HeroController.UnsafeInstance;
            if (EditorApplication.isPlaying && hero != null)
            {
                EditorGUILayout.LabelField("当前场景", SceneManager.GetActiveScene().name);
                Vector3 current = hero.transform.position;
                EditorGUILayout.LabelField("角色世界坐标", $"X {current.x:F2}    Y {current.y:F2}");
            }

            using (new EditorGUI.DisabledScope(pending))
            {
                sceneName = EditorGUILayout.TextField("目标场景", sceneName);
                string target = sceneName.Trim();
                var map = SceneTeleportMap.GetTeleportMap();
                string[] gates = map != null && map.TryGetValue(target, out var info)
                    ? info.TransitionGates.ToArray()
                    : Array.Empty<string>();
                if (gates.Length > 0)
                {
                    int index = Array.IndexOf(gates, gateName);
                    if (index < 0)
                        index = Math.Max(0, Array.IndexOf(gates, "left1"));
                    gateName = gates[EditorGUILayout.Popup("进入位置", index, gates)];
                }
                else
                {
                    EditorGUILayout.HelpBox("未找到该场景的入口，请检查场景名。", MessageType.Warning);
                }

                usePosition = EditorGUILayout.Toggle("入场后定位到坐标", usePosition);
                using (new EditorGUI.DisabledScope(!usePosition))
                    targetPosition = EditorGUILayout.Vector2Field("目标世界坐标 X / Y", targetPosition);

                EditorGUILayout.LabelField("坐标使用 Unity 世界单位；首次可不勾选，先到入口。", EditorStyles.wordWrappedMiniLabel);

                using (new EditorGUI.DisabledScope(!CanCapturePosition()))
                {
                    if (GUILayout.Button("读取当前位置到目标"))
                    {
                        sceneName = SceneManager.GetActiveScene().name;
                        targetPosition = hero.transform.position;
                        usePosition = true;
                        message = "已读取当前场景和坐标；点击传送可返回此处。";
                        messageType = MessageType.Info;
                    }
                }
                using (new EditorGUI.DisabledScope(readiness != null || gates.Length == 0))
                {
                    GameManager gm = GameManager.UnsafeInstance;
                    string label = gm != null && gm.isPaused ? "继续游戏并传送" : "传送到目标";
                    if (GUILayout.Button(label, GUILayout.Height(32f)))
                        BeginTeleport();
                }
            }

            if (readiness != null && !pending)
                EditorGUILayout.HelpBox(readiness, MessageType.Info);
            if (!string.IsNullOrEmpty(message))
                EditorGUILayout.HelpBox(message, messageType);
        }

        private static bool CanCapturePosition()
        {
            GameManager gm = GameManager.UnsafeInstance;
            return EditorApplication.isPlaying && gm != null && HeroController.UnsafeInstance != null &&
                   gm.IsGameplayScene() && !gm.IsInSceneTransition &&
                   !gm.IsLoadingSceneTransition && gm.HasFinishedEnteringScene;
        }

        private static string GetReadiness(bool allowResume = true)
        {
            if (!EditorApplication.isPlaying)
                return "请先点击 Unity 的 Play，再从游戏菜单进入存档。";
            if (EditorApplication.isPaused)
                return "Unity 编辑器已暂停：请先关闭顶部的 Pause（Ⅱ）按钮。";
            GameManager gm = GameManager.UnsafeInstance;
            HeroController hero = HeroController.UnsafeInstance;
            if (gm == null || hero == null || gm.cameraCtrl == null || gm.sm == null ||
                gm.inventoryFSM == null || gm.screenFader_fsm == null || gm.ui == null ||
                gm.inputHandler == null || gm.playerData == null || hero.cState == null)
                return "正在等待游戏和角色初始化。";
            if (!gm.IsGameplayScene())
                return "请先从游戏菜单进入存档。";
            if (gm.IsInSceneTransition || gm.IsLoadingSceneTransition ||
                !gm.HasFinishedEnteringScene || hero.cState.transitioning)
                return "场景正在切换或角色尚未完成入场，请稍候。";
            if (hero.cState.dead || hero.cState.hazardDeath || hero.cState.hazardRespawning || gm.RespawningHero)
                return "角色正在死亡或重生，请稍候。";
            if (gm.playerData.isInventoryOpen)
                return "请先关闭游戏背包，再点击传送。";
            if (gm.GameState == GameState.PAUSED && gm.isPaused)
            {
                if (gm.ui.uiState != UIState.PAUSED || gm.ui.menuState != MainMenuState.PAUSE_MENU)
                    return "请先从选项或退出确认返回有“继续”按钮的暂停首页。";
                // CanInput is deliberately false while paused. Resume through the native
                // menu first, then apply the normal gameplay checks before teleporting.
                return allowResume ? null : "正在等待游戏继续。";
            }
            if (gm.ui.IsFadingMenu || !gm.inputHandler.PauseAllowed)
                return "正在等待游戏菜单动画或输入状态恢复。";
            if (gm.GameState != GameState.PLAYING || gm.isPaused || !hero.CanInput())
                return "角色当前不能操作，请等待对话、受击或过场结束。";
            return null;
        }

        private void BeginTeleport()
        {
            if (pending)
                return;
            string reason = GetReadiness();
            if (reason != null)
            {
                Finish(reason, MessageType.Warning);
                return;
            }
            if (usePosition && (float.IsNaN(targetPosition.x) || float.IsInfinity(targetPosition.x) ||
                                float.IsNaN(targetPosition.y) || float.IsInfinity(targetPosition.y)))
            {
                Finish("请输入有效的 X / Y 坐标。", MessageType.Error);
                return;
            }

            requestedScene = sceneName.Trim();
            requestedGate = gateName;
            requestedUsePosition = usePosition;
            requestedPosition = targetPosition;
            moveWithinScene = SceneManager.GetActiveScene().name == requestedScene;
            if (moveWithinScene && !requestedUsePosition)
            {
                Finish("当前已在该场景。如需换位置，请勾选坐标定位并填写 X / Y。", MessageType.Info);
                return;
            }

            if (!moveWithinScene)
            {
                var map = SceneTeleportMap.GetTeleportMap();
                if (map == null || !map.TryGetValue(requestedScene, out var info) ||
                    !info.TransitionGates.Contains(gateName))
                {
                    Finish("目标场景或入口无效。", MessageType.Error);
                    return;
                }
                if (!HasSceneAddress(requestedScene))
                {
                    Finish("没有找到可加载的场景地址 Scenes/" + requestedScene + "。", MessageType.Error);
                    return;
                }
            }

            pending = true;
            waitingForResume = GameManager.instance.isPaused;
            positioned = false;
            deadline = EditorApplication.timeSinceStartup + (waitingForResume ? 10d : 60d);
            startFrame = Time.frameCount;
            message = "正在传送，请等待角色入场…";
            messageType = MessageType.Info;
            try
            {
                if (waitingForResume)
                {
                    message = "正在继续游戏，关闭暂停菜单后将自动传送…";
                    GameManager.instance.ui.TogglePauseGame();
                }
                else
                    StartSceneTransition();
            }
            catch (Exception exception)
            {
                ReportException(exception);
            }
        }

        private void StartSceneTransition()
        {
            startFrame = Time.frameCount;
            deadline = EditorApplication.timeSinceStartup + 60d;
            message = "正在传送，请等待角色入场…";
            if (!moveWithinScene)
            {
                GameManager.instance.BeginSceneTransition(new GameManager.SceneLoadInfo
                {
                    SceneName = requestedScene,
                    EntryGateName = requestedGate,
                    EntrySkip = true
                });
            }
        }

        private static bool HasSceneAddress(string target)
        {
            var settings = AddressableAssetSettingsDefaultObject.Settings;
            if (settings == null)
                return false;
            foreach (var group in settings.groups)
            {
                if (group == null)
                    continue;
                foreach (var entry in group.entries)
                {
                    if (entry.address == "Scenes/" + target &&
                        Path.GetExtension(entry.AssetPath) == ".unity" &&
                        AssetDatabase.LoadAssetAtPath<SceneAsset>(entry.AssetPath) != null)
                        return true;
                }
            }
            return false;
        }

        private void UpdateTeleport()
        {
            if (!pending)
                return;
            if (!EditorApplication.isPlaying)
            {
                Finish("已退出 Play Mode。", MessageType.Info);
                return;
            }
            if (EditorApplication.timeSinceStartup > deadline)
            {
                Finish(waitingForResume
                    ? "继续游戏超时，未开始传送。请回到 Game 视图点击“继续”后重试。"
                    : "等待传送超时，已停止坐标定位。请检查 Console 和游戏是否暂停。", MessageType.Warning);
                return;
            }
            if (EditorApplication.isPaused || Time.frameCount <= startFrame)
                return;

            try
            {
                if (waitingForResume)
                {
                    string reason = GetReadiness(allowResume: false);
                    if (reason != null)
                    {
                        message = reason;
                        return;
                    }
                    waitingForResume = false;
                    StartSceneTransition();
                    return;
                }
                GameManager gm = GameManager.UnsafeInstance;
                HeroController hero = HeroController.UnsafeInstance;
                if (gm == null || hero == null || gm.cameraCtrl == null ||
                    gm.IsInSceneTransition || gm.IsLoadingSceneTransition ||
                    !gm.HasFinishedEnteringScene || hero.cState.transitioning ||
                    gm.GameState != GameState.PLAYING || hero.IsPaused())
                    return;
                if (SceneManager.GetActiveScene().name != requestedScene)
                {
                    Finish("目标场景尚未成功进入，已停止坐标定位。请检查 Console。", MessageType.Error);
                    return;
                }
                if (!requestedUsePosition)
                {
                    Finish("已进入 " + requestedScene + "。", MessageType.Info);
                    return;
                }
                if (hero.cState.dead || hero.cState.hazardDeath || hero.cState.hazardRespawning)
                {
                    Finish("角色正在死亡或重生，已停止坐标定位。", MessageType.Warning);
                    return;
                }
                if (!positioned)
                {
                    hero.ResetVelocity();
                    hero.transform.position = new Vector3(
                        requestedPosition.x, requestedPosition.y, hero.transform.position.z);
                    // Avoid a collision check using the position before teleporting.
                    for (int i = 0; i < hero.PositionHistory.Length; i++)
                        hero.PositionHistory[i] = requestedPosition;
                    Physics2D.SyncTransforms();
                    positionFixedTime = Time.fixedTime;
                    positioned = true;
                    return;
                }
                // Let trigger callbacks update camera lock areas before framing the hero.
                if (Time.fixedTime <= positionFixedTime)
                    return;
                gm.cameraCtrl.PositionToHeroInstant(false);
                Finish($"已定位到 {requestedScene}：X {requestedPosition.x:F2}，Y {requestedPosition.y:F2}。", MessageType.Info);
            }
            catch (Exception exception)
            {
                ReportException(exception);
            }
        }

        private void ReportException(Exception exception)
        {
            Debug.LogException(exception);
            Finish("传送失败：" + exception.Message + "。详情见 Console。", MessageType.Error);
        }

        private void Finish(string text, MessageType type)
        {
            pending = false;
            waitingForResume = false;
            message = text;
            messageType = type;
            Repaint();
        }
    }
}
