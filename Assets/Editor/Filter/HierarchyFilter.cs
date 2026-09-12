#if UNITY_EDITOR
using System;
using UnityEditor;
using UnityEditor.Search;
using UnityEditor.Search.Providers;
using UnityEngine;
using UnityEngine.Search;

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

    // ===== 想显示哪些列、先后顺序和宽度，直接修改这里。 =====
    // 参数依次为：列标题、数据字段、列宽（像素）。位置使用世界坐标。
    public static SearchColumn[] CreateColumns()
    {
        return new[]
        {
            CreateColumn("对象名称", "objectName", 200),
            CreateColumn("Sprite", "sprite", 170),
            CreateColumn("材质", "material", 190),
            CreateColumn("位置 X", "positionX", 90),
            CreateColumn("位置 Y", "positionY", 90),
            CreateColumn("Sorting Layer", "sortingLayer", 130),
            CreateColumn("Order in Layer", "sortingOrder", 120),
        };
    }

    private static SearchColumn CreateColumn(string title, string field, float width)
    {
        return new SearchColumn("Hierarchy Filter/" + field, field,
            "HierarchyFilter", new GUIContent(title)) { width = width };
    }

    // 注册列的数据读取方式，让 Unity 在重新加载列配置后仍能读取数据。
    // 新增一种数据字段时，在下面的 switch 中加一个 case 即可。
    [SearchColumnProvider("HierarchyFilter")]
    public static void InitializeColumn(SearchColumn column)
    {
        column.getter = args =>
        {
            GameObject gameObject = args.item.ToObject<GameObject>();
            if (gameObject == null)
                return null;

            switch (args.column.selector)
            {
                case "objectName": return gameObject.name;
                case "positionX": return gameObject.transform.position.x;
                case "positionY": return gameObject.transform.position.y;
            }

            SpriteRenderer renderer = gameObject.GetComponent<SpriteRenderer>();
            if (renderer == null)
                return null;

            switch (args.column.selector)
            {
                case "sprite": return renderer.sprite != null ? renderer.sprite.name : "（无）";
                case "material": return renderer.sharedMaterial != null ? renderer.sharedMaterial.name : "（无）";
                case "sortingLayer": return renderer.sortingLayerName;
                case "sortingOrder": return renderer.sortingOrder;
                default: return null;
            }
        };
    }

    // ===== 一个菜单：打开筛选结果，并在汇总查询完成后打印一次。 =====
    [MenuItem("Tools/Hierarchy Filter")]
    public static void OpenSearch()
    {
        const string query = "customfilter=true";

        var viewState = new SearchViewState(
            SearchService.CreateContext("scene", query),
            new SearchTable("Hierarchy Filter", CreateColumns()),
            SearchViewFlags.TableView);
        SearchService.ShowWindow(viewState);

        // 显示和汇总分别查询；Matches 只判断条件，不累加计数或打印。
        SearchService.Request(
            SearchService.CreateContext("scene", query),
            (context, results) =>
            {
                // 想在检查结束后打印什么，直接修改这里。
                Debug.Log($"筛选完成，匹配 {results.Count} 个对象。");
                context.Dispose();
            });
    }
}
#endif
