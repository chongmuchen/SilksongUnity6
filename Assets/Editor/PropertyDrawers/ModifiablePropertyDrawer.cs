using System;
using System.Linq;
using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(ModifiablePropertyAttribute), useForChildren: true)]
public sealed class ModifiablePropertyDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		if (ShouldHide(property))
		{
			return -EditorGUIUtility.standardVerticalSpacing;
		}
		return EditorGUI.GetPropertyHeight(property, label, includeChildren: true);
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		if (ShouldHide(property))
		{
			return;
		}

		bool oldEnabled = GUI.enabled;
		Color oldColor = GUI.color;
		try
		{
			GUI.enabled = oldEnabled && ShouldEnable(property);
			ApplyValidationColor(property, oldColor);

			EditorGUI.BeginProperty(position, label, property);
			MultiPropRangeAttribute range = GetAttributes<MultiPropRangeAttribute>().FirstOrDefault();
			if (range != null && property.propertyType == SerializedPropertyType.Float)
			{
				EditorGUI.Slider(position, property, range.Min, range.Max, label);
			}
			else if (range != null && property.propertyType == SerializedPropertyType.Integer)
			{
				EditorGUI.IntSlider(position, property, Mathf.RoundToInt(range.Min), Mathf.RoundToInt(range.Max), label);
			}
			else
			{
				EditorGUI.PropertyField(position, property, label, includeChildren: true);
			}
			EditorGUI.EndProperty();
		}
		finally
		{
			GUI.color = oldColor;
			GUI.enabled = oldEnabled;
		}
	}

	private bool ShouldHide(SerializedProperty property)
	{
		foreach (ConditionalAttribute conditional in GetModifiers<ConditionalAttribute>())
		{
			if (conditional.HideCompletely && !EvaluateConditional(property, conditional))
			{
				return true;
			}
		}
		return false;
	}

	private bool ShouldEnable(SerializedProperty property)
	{
		foreach (ConditionalAttribute conditional in GetModifiers<ConditionalAttribute>())
		{
			if (!conditional.HideCompletely && !EvaluateConditional(property, conditional))
			{
				return false;
			}
		}
		return true;
	}

	private static bool EvaluateConditional(SerializedProperty property, ConditionalAttribute conditional)
	{
		object parent = PropertyDrawerReflection.GetParentObject(property);
		if (parent == null)
		{
			return true;
		}

		object result;
		if (conditional.IsMethod)
		{
			result = PropertyDrawerReflection.Invoke(
				parent,
				conditional.TargetName,
				PropertyDrawerReflection.GetPropertyValue(property),
				preferValueParameter: false);
		}
		else if (!PropertyDrawerReflection.TryGetMemberValue(parent, conditional.TargetName, out result))
		{
			return true;
		}

		return PropertyDrawerReflection.ToBoolean(result) == conditional.ExpectedResult;
	}

	private void ApplyValidationColor(SerializedProperty property, Color originalColor)
	{
		InspectorValidationAttribute validation = GetModifiers<InspectorValidationAttribute>().FirstOrDefault();
		if (validation == null)
		{
			return;
		}

		bool? result = EvaluateValidation(property, validation);
		if (!result.HasValue)
		{
			return;
		}

		Color target = result.Value ? new Color(0.55f, 1f, 0.55f, originalColor.a) : new Color(1f, 0.45f, 0.45f, originalColor.a);
		GUI.color = Color.Lerp(originalColor, target, 0.55f);
	}

	private static bool? EvaluateValidation(SerializedProperty property, InspectorValidationAttribute validation)
	{
		object parent = PropertyDrawerReflection.GetParentObject(property);
		object value = PropertyDrawerReflection.GetPropertyValue(property);
		if (!string.IsNullOrEmpty(validation.MethodName))
		{
			object result = PropertyDrawerReflection.Invoke(parent, validation.MethodName, value, preferValueParameter: true);
			return result is bool boolean ? boolean : (bool?)null;
		}

		switch (property.propertyType)
		{
			case SerializedPropertyType.ObjectReference:
				return property.objectReferenceValue != null;
			case SerializedPropertyType.String:
				return !string.IsNullOrEmpty(property.stringValue);
			case SerializedPropertyType.ExposedReference:
				return property.exposedReferenceValue != null;
			default:
				if (CollectionDrawerGUI.IsCollection(property))
				{
					return property.arraySize > 0;
				}
				return null;
		}
	}

	private T[] GetModifiers<T>() where T : PropertyModifierAttribute
	{
		return fieldInfo == null
			? Array.Empty<T>()
			: fieldInfo.GetCustomAttributes(typeof(T), inherit: true).Cast<T>().OrderBy(item => item.order).ToArray();
	}

	private T[] GetAttributes<T>() where T : Attribute
	{
		return fieldInfo == null
			? Array.Empty<T>()
			: fieldInfo.GetCustomAttributes(typeof(T), inherit: true).Cast<T>().ToArray();
	}
}
