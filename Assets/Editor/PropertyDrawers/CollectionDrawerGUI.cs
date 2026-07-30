using System;
using UnityEditor;
using UnityEngine;

internal static class CollectionDrawerGUI
{
	public delegate float ElementHeightDelegate(SerializedProperty element, GUIContent label);

	public delegate void ElementGUIDelegate(Rect position, SerializedProperty element, GUIContent label);

	public static float GetHeight(
		SerializedProperty property,
		int fixedSize,
		Func<int, string> elementName,
		ElementHeightDelegate elementHeight)
	{
		if (!IsCollection(property) || !property.isExpanded)
		{
			return EditorGUIUtility.singleLineHeight;
		}

		int count = fixedSize >= 0 ? fixedSize : property.arraySize;
		float height = EditorGUIUtility.singleLineHeight;
		if (fixedSize < 0)
		{
			height += EditorGUIUtility.standardVerticalSpacing + EditorGUIUtility.singleLineHeight;
		}

		for (int i = 0; i < count; i++)
		{
			SerializedProperty element = i < property.arraySize ? property.GetArrayElementAtIndex(i) : null;
			GUIContent label = new GUIContent(GetElementName(elementName, i));
			float rowHeight = element != null && elementHeight != null
				? elementHeight(element, label)
				: EditorGUIUtility.singleLineHeight;
			height += EditorGUIUtility.standardVerticalSpacing + rowHeight;
		}
		return height;
	}

	public static void OnGUI(
		Rect position,
		SerializedProperty property,
		GUIContent label,
		int fixedSize,
		Func<int, string> elementName,
		ElementHeightDelegate elementHeight,
		ElementGUIDelegate drawElement)
	{
		if (!IsCollection(property))
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		if (fixedSize >= 0 && !property.serializedObject.isEditingMultipleObjects && property.arraySize != fixedSize)
		{
			property.arraySize = fixedSize;
		}

		Rect row = new Rect(position.x, position.y, position.width, EditorGUIUtility.singleLineHeight);
		property.isExpanded = EditorGUI.Foldout(row, property.isExpanded, label, toggleOnLabelClick: true);
		if (!property.isExpanded)
		{
			return;
		}

		int oldIndent = EditorGUI.indentLevel;
		EditorGUI.indentLevel++;
		if (fixedSize < 0)
		{
			row.y += row.height + EditorGUIUtility.standardVerticalSpacing;
			SerializedProperty sizeProperty = property.FindPropertyRelative("Array.size");
			EditorGUI.PropertyField(row, sizeProperty);
		}

		int count = fixedSize >= 0 ? Math.Min(fixedSize, property.arraySize) : property.arraySize;
		for (int i = 0; i < count; i++)
		{
			SerializedProperty element = property.GetArrayElementAtIndex(i);
			GUIContent elementLabel = new GUIContent(GetElementName(elementName, i));
			float height = elementHeight != null
				? elementHeight(element, elementLabel)
				: EditorGUIUtility.singleLineHeight;
			row.y += row.height + EditorGUIUtility.standardVerticalSpacing;
			row.height = height;
			if (drawElement != null)
			{
				drawElement(row, element, elementLabel);
			}
			else
			{
				EditorGUI.PropertyField(row, element, elementLabel, includeChildren: true);
			}
		}
		EditorGUI.indentLevel = oldIndent;
	}

	public static bool IsCollection(SerializedProperty property)
	{
		return property != null && property.isArray && property.propertyType != SerializedPropertyType.String;
	}

	private static string GetElementName(Func<int, string> elementName, int index)
	{
		string name = elementName?.Invoke(index);
		return string.IsNullOrEmpty(name) ? $"Element {index}" : name;
	}
}
