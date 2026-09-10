using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

[InitializeOnLoad]
public static class PlayModeStartSceneConfig
{
    private const string MenuPath =
        "Tools/Play Mode/从 Pre_Menu_Loader 启动";

    private const string StartScenePath =
        "Assets/Scenes/Pre_Menu_Loader.unity";

    private const string PreferenceKey =
        "SilksongUnity6.PlayFromPreMenuLoader";

    private static bool Enabled =>
        EditorPrefs.GetBool(PreferenceKey, true);

    static PlayModeStartSceneConfig()
    {
        EditorApplication.delayCall += ApplySetting;
    }

    [MenuItem(MenuPath)]
    private static void Toggle()
    {
        EditorPrefs.SetBool(PreferenceKey, !Enabled);
        ApplySetting();
    }

    [MenuItem(MenuPath, true)]
    private static bool ValidateMenu()
    {
        Menu.SetChecked(MenuPath, Enabled);
        return !EditorApplication.isPlayingOrWillChangePlaymode;
    }

    private static void ApplySetting()
    {
        Menu.SetChecked(MenuPath, Enabled);

        if (!Enabled)
        {
            // 恢复 Unity 默认行为：播放当前打开的场景
            EditorSceneManager.playModeStartScene = null;
            return;
        }

        SceneAsset startScene =
            AssetDatabase.LoadAssetAtPath<SceneAsset>(StartScenePath);

        if (startScene == null)
        {
            Debug.LogError(
                $"找不到启动场景：{StartScenePath}");
            return;
        }

        EditorSceneManager.playModeStartScene = startScene;
    }
}