using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

[CustomPropertyDrawer(typeof(NamedArrayAttribute))]
public sealed class NamedArrayDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		NamedArrayAttribute namedArray = (NamedArrayAttribute)attribute;
		return CollectionDrawerGUI.GetHeight(
			property,
			fixedSize: -1,
			index => PropertyDrawerReflection.GetNameFromMethod(property, namedArray.MethodName, index),
			(element, elementLabel) => EditorGUI.GetPropertyHeight(element, elementLabel, includeChildren: true));
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		NamedArrayAttribute namedArray = (NamedArrayAttribute)attribute;
		EditorGUI.BeginProperty(position, label, property);
		CollectionDrawerGUI.OnGUI(
			position,
			property,
			label,
			fixedSize: -1,
			index => PropertyDrawerReflection.GetNameFromMethod(property, namedArray.MethodName, index),
			(element, elementLabel) => EditorGUI.GetPropertyHeight(element, elementLabel, includeChildren: true),
			(elementPosition, element, elementLabel) =>
				EditorGUI.PropertyField(elementPosition, element, elementLabel, includeChildren: true));
		EditorGUI.EndProperty();
	}
}

[CustomPropertyDrawer(typeof(ArrayForEnumAttribute))]
public sealed class ArrayForEnumDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		ArrayForEnumAttribute arrayForEnum = (ArrayForEnumAttribute)attribute;
		int fixedSize = arrayForEnum.IsValid ? arrayForEnum.EnumLength : -1;
		return CollectionDrawerGUI.GetHeight(
			property,
			fixedSize,
			index => GetEnumElementName(arrayForEnum.EnumType, index),
			(element, elementLabel) => EditorGUI.GetPropertyHeight(element, elementLabel, includeChildren: true));
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		ArrayForEnumAttribute arrayForEnum = (ArrayForEnumAttribute)attribute;
		PlayerDataFieldAttribute playerData = fieldInfo?
			.GetCustomAttributes(typeof(PlayerDataFieldAttribute), inherit: true)
			.Cast<PlayerDataFieldAttribute>()
			.FirstOrDefault();
		int fixedSize = arrayForEnum.IsValid ? arrayForEnum.EnumLength : -1;

		EditorGUI.BeginProperty(position, label, property);
		CollectionDrawerGUI.OnGUI(
			position,
			property,
			label,
			fixedSize,
			index => GetEnumElementName(arrayForEnum.EnumType, index),
			(element, elementLabel) => EditorGUI.GetPropertyHeight(element, elementLabel, includeChildren: true),
			(elementPosition, element, elementLabel) =>
			{
				if (playerData != null && element.propertyType == SerializedPropertyType.String)
				{
					PlayerDataFieldGUI.Draw(elementPosition, element, elementLabel, playerData);
				}
				else
				{
					EditorGUI.PropertyField(elementPosition, element, elementLabel, includeChildren: true);
				}
			});
		EditorGUI.EndProperty();
	}

	internal static string GetEnumElementName(Type enumType, int index)
	{
		if (enumType == null || !enumType.IsEnum)
		{
			return $"Element {index}";
		}

		string name = Enum.GetName(enumType, index);
		return string.IsNullOrEmpty(name)
			? $"Element {index}"
			: $"{index}: {ObjectNames.NicifyVariableName(name)}";
	}
}

[CustomPropertyDrawer(typeof(PlayerDataFieldAttribute))]
public sealed class PlayerDataFieldDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		ArrayForEnumAttribute arrayForEnum = GetArrayForEnum();
		if (CollectionDrawerGUI.IsCollection(property))
		{
			int fixedSize = arrayForEnum != null && arrayForEnum.IsValid ? arrayForEnum.EnumLength : -1;
			return CollectionDrawerGUI.GetHeight(
				property,
				fixedSize,
				index => arrayForEnum != null
					? ArrayForEnumDrawer.GetEnumElementName(arrayForEnum.EnumType, index)
					: $"Element {index}",
				(element, elementLabel) => EditorGUIUtility.singleLineHeight);
		}
		return EditorGUIUtility.singleLineHeight;
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		PlayerDataFieldAttribute playerData = (PlayerDataFieldAttribute)attribute;
		ArrayForEnumAttribute arrayForEnum = GetArrayForEnum();

		EditorGUI.BeginProperty(position, label, property);
		if (CollectionDrawerGUI.IsCollection(property))
		{
			int fixedSize = arrayForEnum != null && arrayForEnum.IsValid ? arrayForEnum.EnumLength : -1;
			CollectionDrawerGUI.OnGUI(
				position,
				property,
				label,
				fixedSize,
				index => arrayForEnum != null
					? ArrayForEnumDrawer.GetEnumElementName(arrayForEnum.EnumType, index)
					: $"Element {index}",
				(element, elementLabel) => EditorGUIUtility.singleLineHeight,
				(elementPosition, element, elementLabel) =>
					PlayerDataFieldGUI.Draw(elementPosition, element, elementLabel, playerData));
		}
		else
		{
			PlayerDataFieldGUI.Draw(position, property, label, playerData);
		}
		EditorGUI.EndProperty();
	}

	private ArrayForEnumAttribute GetArrayForEnum()
	{
		return fieldInfo?
			.GetCustomAttributes(typeof(ArrayForEnumAttribute), inherit: true)
			.Cast<ArrayForEnumAttribute>()
			.FirstOrDefault();
	}
}

internal static class PlayerDataFieldGUI
{
	private static readonly Dictionary<Type, string[]> namesByType = new Dictionary<Type, string[]>();

	public static void Draw(Rect position, SerializedProperty property, GUIContent label, PlayerDataFieldAttribute playerData)
	{
		if (property.propertyType != SerializedPropertyType.String)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		string[] validNames = GetNames(playerData.FieldType);
		List<string> displayNames = new List<string>(validNames.Length + 2);
		List<string> values = new List<string>(validNames.Length + 2);

		displayNames.Add(playerData.IsRequired ? "<Select PlayerData field>" : "<None>");
		values.Add(string.Empty);

		string current = property.stringValue ?? string.Empty;
		if (!string.IsNullOrEmpty(current) && Array.IndexOf(validNames, current) < 0)
		{
			displayNames.Add($"[Missing] {current}");
			values.Add(current);
		}

		displayNames.AddRange(validNames);
		values.AddRange(validNames);
		int selectedIndex = Math.Max(0, values.IndexOf(current));

		EditorGUI.BeginChangeCheck();
		selectedIndex = EditorGUI.Popup(position, label.text, selectedIndex, displayNames.ToArray(), EditorStyles.popup);
		if (EditorGUI.EndChangeCheck())
		{
			property.stringValue = values[selectedIndex];
		}
	}

	private static string[] GetNames(Type fieldType)
	{
		if (fieldType == null)
		{
			return Array.Empty<string>();
		}
		if (namesByType.TryGetValue(fieldType, out string[] names))
		{
			return names;
		}

		const BindingFlags flags = BindingFlags.Instance | BindingFlags.Public;
		IEnumerable<string> fieldNames = typeof(PlayerData)
			.GetFields(flags)
			.Where(field => field.FieldType == fieldType)
			.Select(field => field.Name);
		IEnumerable<string> propertyNames = typeof(PlayerData)
			.GetProperties(flags)
			.Where(property =>
				property.PropertyType == fieldType &&
				property.GetIndexParameters().Length == 0 &&
				property.GetGetMethod() != null)
			.Select(property => property.Name);

		names = fieldNames
			.Concat(propertyNames)
			.Distinct()
			.OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
			.ToArray();
		namesByType[fieldType] = names;
		return names;
	}
}

[CustomPropertyDrawer(typeof(TagSelectorAttribute))]
public sealed class TagSelectorDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		return CollectionDrawerGUI.IsCollection(property)
			? CollectionDrawerGUI.GetHeight(
				property,
				fixedSize: -1,
				index => $"Element {index}",
				(element, elementLabel) => EditorGUIUtility.singleLineHeight)
			: EditorGUIUtility.singleLineHeight;
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		EditorGUI.BeginProperty(position, label, property);
		if (CollectionDrawerGUI.IsCollection(property))
		{
			CollectionDrawerGUI.OnGUI(
				position,
				property,
				label,
				fixedSize: -1,
				index => $"Element {index}",
				(element, elementLabel) => EditorGUIUtility.singleLineHeight,
				DrawTag);
		}
		else
		{
			DrawTag(position, property, label);
		}
		EditorGUI.EndProperty();
	}

	private static void DrawTag(Rect position, SerializedProperty property, GUIContent label)
	{
		if (property.propertyType != SerializedPropertyType.String)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		string currentTag = property.stringValue;
		string[] tags = InternalEditorUtility.tags;
		int selected = Array.IndexOf(tags, currentTag);
		if (selected < 0)
		{
			List<string> display = new List<string> { $"[Missing] {currentTag}" };
			display.AddRange(tags);
			int newIndex = EditorGUI.Popup(position, label.text, 0, display.ToArray(), EditorStyles.popup);
			if (newIndex > 0)
			{
				property.stringValue = tags[newIndex - 1];
			}
			return;
		}

		int result = EditorGUI.Popup(position, label.text, selected, tags, EditorStyles.popup);
		if (result >= 0 && result < tags.Length)
		{
			property.stringValue = tags[result];
		}
	}
}
