using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(SortingLayerAttribute))]
public sealed class SortingLayerDrawer : PropertyDrawer
{
	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		if (property.propertyType != SerializedPropertyType.Integer)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		SortingLayer[] layers = SortingLayer.layers;
		string[] names = layers.Select(layer => layer.name).ToArray();
		int[] ids = layers.Select(layer => layer.id).ToArray();
		int selected = Array.IndexOf(ids, property.intValue);
		if (selected < 0)
		{
			List<string> displayNames = new List<string> { $"[Missing ID] {property.intValue}" };
			displayNames.AddRange(names);
			int result = EditorGUI.Popup(position, label.text, 0, displayNames.ToArray(), EditorStyles.popup);
			if (result > 0)
			{
				property.intValue = ids[result - 1];
			}
			return;
		}

		int newIndex = EditorGUI.Popup(position, label.text, selected, names, EditorStyles.popup);
		if (newIndex >= 0 && newIndex < ids.Length)
		{
			property.intValue = ids[newIndex];
		}
	}
}

[CustomPropertyDrawer(typeof(AssetNamePickerAttribute))]
public sealed class AssetNamePickerDrawer : PropertyDrawer
{
	private static readonly Dictionary<string, string[]> assetNamesByFilter = new Dictionary<string, string[]>();

	static AssetNamePickerDrawer()
	{
		EditorApplication.projectChanged += assetNamesByFilter.Clear;
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		if (property.propertyType != SerializedPropertyType.String)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		AssetNamePickerAttribute picker = (AssetNamePickerAttribute)attribute;
		string[] names = GetAssetNames(picker.SearchFilter);
		List<string> displayNames = new List<string> { "<None>" };
		List<string> values = new List<string> { string.Empty };
		string current = property.stringValue ?? string.Empty;
		if (!string.IsNullOrEmpty(current) && Array.IndexOf(names, current) < 0)
		{
			displayNames.Add($"[Missing] {current}");
			values.Add(current);
		}
		displayNames.AddRange(names);
		values.AddRange(names);

		int selected = Math.Max(0, values.IndexOf(current));
		EditorGUI.BeginChangeCheck();
		selected = EditorGUI.Popup(position, label.text, selected, displayNames.ToArray(), EditorStyles.popup);
		if (EditorGUI.EndChangeCheck())
		{
			property.stringValue = values[selected];
		}
	}

	private static string[] GetAssetNames(string searchFilter)
	{
		searchFilter ??= string.Empty;
		if (assetNamesByFilter.TryGetValue(searchFilter, out string[] names))
		{
			return names;
		}

		names = AssetDatabase.FindAssets(searchFilter)
			.Select(AssetDatabase.GUIDToAssetPath)
			.Where(path => !string.IsNullOrEmpty(path))
			.Select(path => Path.GetFileNameWithoutExtension(path))
			.Distinct()
			.OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
			.ToArray();
		assetNamesByFilter[searchFilter] = names;
		return names;
	}
}
