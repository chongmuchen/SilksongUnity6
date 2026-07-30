using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using InControl;
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

[CustomPropertyDrawer(typeof(HexadecimalAttribute))]
public sealed class HexadecimalDrawer : PropertyDrawer
{
	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		SerializedProperty hasValue = property.FindPropertyRelative("hasValue");
		SerializedProperty value = property.FindPropertyRelative("value");
		if (hasValue != null && value != null)
		{
			DrawOptionalHex(position, label, hasValue, value);
			return;
		}

		if (property.propertyType == SerializedPropertyType.Integer)
		{
			DrawHexField(position, label, property, enabled: true);
			return;
		}
		EditorGUI.PropertyField(position, property, label, includeChildren: true);
	}

	private static void DrawOptionalHex(
		Rect position,
		GUIContent label,
		SerializedProperty hasValue,
		SerializedProperty value)
	{
		Rect content = EditorGUI.PrefixLabel(position, label);
		Rect toggleRect = new Rect(content.x, content.y, 18f, content.height);
		Rect valueRect = new Rect(toggleRect.xMax + 2f, content.y, content.width - 20f, content.height);

		EditorGUI.BeginChangeCheck();
		bool enabled = EditorGUI.Toggle(toggleRect, hasValue.boolValue);
		if (EditorGUI.EndChangeCheck())
		{
			hasValue.boolValue = enabled;
		}

		bool oldEnabled = GUI.enabled;
		GUI.enabled = oldEnabled && enabled;
		DrawHexField(valueRect, GUIContent.none, value, enabled);
		GUI.enabled = oldEnabled;
	}

	private static void DrawHexField(
		Rect position,
		GUIContent label,
		SerializedProperty property,
		bool enabled)
	{
		ulong current = unchecked((ulong)property.longValue);
		string text = "0x" + current.ToString("X", CultureInfo.InvariantCulture);
		EditorGUI.BeginChangeCheck();
		string newText = EditorGUI.TextField(position, label, text);
		if (!EditorGUI.EndChangeCheck() || !enabled)
		{
			return;
		}

		string digits = newText.Trim();
		if (digits.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
		{
			digits = digits.Substring(2);
		}
		if (ulong.TryParse(digits, NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out ulong parsed))
		{
			property.longValue = unchecked((long)parsed);
		}
	}
}
