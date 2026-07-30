using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace SilksongStudy.Editor
{
	public sealed class SilksongCodeStudyWindow : EditorWindow
	{
		private readonly struct Entry
		{
			public readonly string Name;
			public readonly string Path;
			public readonly string Description;

			public Entry(string name, string path, string description)
			{
				Name = name;
				Path = path;
				Description = description;
			}
		}

		private sealed class Section
		{
			public readonly string Name;
			public readonly Entry[] Entries;

			public Section(string name, params Entry[] entries)
			{
				Name = name;
				Entries = entries;
			}
		}

		private const string ScriptRoot = "Assets/Scripts/Assembly-CSharp/";

		private static readonly Section[] Sections =
		{
			new Section(
				"启动与场景",
				EntryFor("GameManager", "全局生命周期、场景切换、保存和游戏状态。"),
				EntryFor("StartManager", "启动、语言选择、核心 Manager 和主菜单加载。"),
				EntryFor("QuitToMenu", "核心 Manager 预载及返回主菜单流程。"),
				EntryFor("SceneLoad", "Addressables 场景加载阶段机。"),
				EntryFor("TransitionPoint", "场景出口、入口和玩家出生点。"),
				EntryFor("CustomSceneManager", "单场景配置及场景初始化。"),
				EntryFor("SceneData", "跨场景持久状态。"),
				EntryFor("GameConfig", "构建和平台功能开关。")),
			new Section(
				"玩家与输入",
				EntryFor("HeroController", "玩家移动、攻击、受伤和状态的核心大类。"),
				EntryFor("HeroControllerConfig", "动作参数和不同配置组。"),
				EntryFor("HeroControllerStates", "玩家运行状态数据。"),
				EntryFor("HeroAnimationController", "玩家动画驱动。"),
				EntryFor("InputHandler", "InControl、菜单输入和游戏输入的桥。"),
				EntryFor("HeroActions", "所有玩家 Input Action 定义。"),
				EntryFor("HeroAudioController", "玩家动作音频。"),
				EntryFor("HeroVibrationController", "玩家手柄反馈。")),
			new Section(
				"战斗与敌人",
				EntryFor("HitInstance", "一次命中的数据载体。"),
				EntryFor("DamageEnemies", "对敌人造成伤害的入口。"),
				EntryFor("DamageHero", "对玩家造成伤害的入口。"),
				EntryFor("HealthManager", "敌人生命、受击、死亡和掉落。"),
				EntryFor("DamageTag", "标签式持续或特殊伤害。"),
				EntryFor("NailSlash", "近战攻击碰撞体。"),
				EntryFor("EnemyDeathEffects", "敌人死亡表现。"),
				EntryFor("Walker", "常见地面敌人行为模板。"),
				EntryFor("RangeAttacker", "常见远程攻击模板。")),
			new Section(
				"存档与长期状态",
				EntryFor("PlayerData", "玩家永久和会话数据总表。"),
				EntryFor("PlayerDataBase", "PlayerData 反射访问与单例基础。"),
				EntryFor("SaveGameData", "存档序列化容器。"),
				EntryFor("SaveGame", "存档流程。"),
				EntryFor("SaveGameV2", "新版存档流程。"),
				EntryFor("SaveDataUpgradeHandler", "旧版本存档迁移。"),
				EntryFor("PersistentBoolItem", "场景布尔状态桥。"),
				EntryFor("PersistentIntItem", "场景整数状态桥。")),
			new Section(
				"工具、纹章与任务",
				EntryFor("ToolItemManager", "工具与纹章装备中枢。"),
				EntryFor("ToolItem", "工具数据模型。"),
				EntryFor("ToolCrest", "纹章与槽位数据模型。"),
				EntryFor("ToolItemsData", "玩家工具存档数据。"),
				EntryFor("SilkSpool", "丝资源的消耗和恢复。"),
				EntryFor("QuestManager", "任务查询、更新和提示。"),
				EntryFor("FullQuestBase", "完整任务状态流程。"),
				EntryFor("QuestTargetCounter", "任务目标计数基础。")),
			new Section(
				"UI、地图与表现",
				EntryFor("UIManager", "菜单、暂停、画布与淡入淡出中枢。"),
				EntryFor("GameMap", "地图区域、缓存和显示数据。"),
				EntryFor("DialogueBox", "对话展示和文本推进。"),
				EntryFor("GameCameras", "游戏摄像机集合。"),
				EntryFor("CameraController", "跟随、边界和镜头锁定。"),
				EntryFor("AudioManager", "全局音频管理。"),
				EntryFor("InventoryItemManager", "背包物品视图基础。"),
				EntryFor("QuestItemManager", "任务物品 UI 管理。"))
		};

		private Vector2 scrollPosition;
		private string search = string.Empty;

		[MenuItem("Silksong Study/Code Study Hub")]
		private static void OpenWindow()
		{
			SilksongCodeStudyWindow window = GetWindow<SilksongCodeStudyWindow>();
			window.titleContent = new GUIContent("Silksong Code");
			window.minSize = new Vector2(620f, 420f);
			window.Show();
		}

		private void OnGUI()
		{
			EditorGUILayout.LabelField("Silksong C# 学习入口", EditorStyles.largeLabel);
			EditorGUILayout.HelpBox(
				"这是不移动原文件的虚拟分类。先沿核心调用链阅读；PlayMaker、设备配置和旧 TMPro 按需再看。",
				MessageType.Info);

			using (new EditorGUILayout.HorizontalScope())
			{
				if (GUILayout.Button("定位启动场景", GUILayout.Width(110f)))
				{
					PingAsset("Assets/Scenes/Pre_Menu_Loader.unity");
				}
				if (GUILayout.Button("打开学习文档", GUILayout.Width(110f)))
				{
					string docsPath = Path.GetFullPath(Path.Combine(Application.dataPath, "../Docs"));
					EditorUtility.RevealInFinder(docsPath);
				}
			}

			EditorGUILayout.Space();
			search = EditorGUILayout.TextField("搜索", search);
			scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

			foreach (Section section in Sections)
			{
				bool hasMatch = false;
				foreach (Entry entry in section.Entries)
				{
					if (Matches(entry, search))
					{
						hasMatch = true;
						break;
					}
				}
				if (!hasMatch)
				{
					continue;
				}

				EditorGUILayout.Space();
				EditorGUILayout.LabelField(section.Name, EditorStyles.boldLabel);
				foreach (Entry entry in section.Entries)
				{
					if (!Matches(entry, search))
					{
						continue;
					}

					using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
					{
						using (new EditorGUILayout.HorizontalScope())
						{
							EditorGUILayout.LabelField(entry.Name, EditorStyles.boldLabel);
							if (GUILayout.Button("打开", GUILayout.Width(64f)))
							{
								OpenScript(entry.Path);
							}
							if (GUILayout.Button("定位", GUILayout.Width(64f)))
							{
								PingAsset(entry.Path);
							}
						}
						EditorGUILayout.LabelField(entry.Description, EditorStyles.wordWrappedLabel);
						EditorGUILayout.LabelField(entry.Path, EditorStyles.miniLabel);
					}
				}
			}

			EditorGUILayout.EndScrollView();
		}

		private static Entry EntryFor(string className, string description)
		{
			return new Entry(className, ScriptRoot + className + ".cs", description);
		}

		private static bool Matches(Entry entry, string filter)
		{
			if (string.IsNullOrWhiteSpace(filter))
			{
				return true;
			}
			return entry.Name.IndexOf(filter, StringComparison.OrdinalIgnoreCase) >= 0
				|| entry.Description.IndexOf(filter, StringComparison.OrdinalIgnoreCase) >= 0
				|| entry.Path.IndexOf(filter, StringComparison.OrdinalIgnoreCase) >= 0;
		}

		private static void OpenScript(string path)
		{
			MonoScript script = AssetDatabase.LoadAssetAtPath<MonoScript>(path);
			if (script != null)
			{
				AssetDatabase.OpenAsset(script);
			}
			else
			{
				Debug.LogWarning("Code Study Hub 找不到脚本: " + path);
			}
		}

		private static void PingAsset(string path)
		{
			UnityEngine.Object asset = AssetDatabase.LoadMainAssetAtPath(path);
			if (asset != null)
			{
				Selection.activeObject = asset;
				EditorGUIUtility.PingObject(asset);
			}
			else
			{
				Debug.LogWarning("Code Study Hub 找不到资源: " + path);
			}
		}
	}
}

