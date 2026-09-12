#if UNITY_EDITOR
using System;
using UnityEditor;
using UnityEditor.Search;
using UnityEditor.Search.Providers;
using UnityEngine;

// 放到 Assets/Editor/HierarchyFilter.cs。
// Hierarchy（Advanced 搜索）：customfilter=true
// Search All：h: customfilter=true
public static class HierarchyFilter
{
    // ===== 以后想筛选什么，直接修改这个函数；true 表示保留该对象。 =====
    // 当前：只有 Transform + SpriteRenderer，材质名为 Crossroads_Material。
    [SceneQueryEngineFilter("customfilter", new[] { "=" })]
    public static bool Matches(GameObject gameObject)
    {
        if (gameObject == null)
            return false;

        // 只检查对象自身的组件；额外组件和 Missing Script 都会被排除。
        Component[] components = gameObject.GetComponents<Component>();
        if (components.Length != 2)
            return false;

        SpriteRenderer spriteRenderer = null;
        bool hasTransform = false;
        foreach (Component component in components)
        {
            if (component == null)
                return false;
            if (component.GetType() == typeof(Transform))
                hasTransform = true;
            else if (component.GetType() == typeof(SpriteRenderer))
                spriteRenderer = (SpriteRenderer)component;
            else
                return false;
        }

        if (!hasTransform || spriteRenderer == null)
            return false;

        // 用 sharedMaterial 读取，避免生成材质实例。
        Material material = spriteRenderer.sharedMaterial;
        return material != null && string.Equals(
            material.name, "Crossroads_Material", StringComparison.Ordinal);
    }

    // ===== 以下是固定的搜索入口，通常不需要修改。 =====
    [MenuItem("Tools/Hierarchy Filter")]
    public static void OpenSearch()
    {
        SearchService.ShowWindow(
            SearchService.CreateContext("scene", "customfilter=true"));
    }
}
#endif
