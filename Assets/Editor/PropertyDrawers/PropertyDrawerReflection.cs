using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;

internal static class PropertyDrawerReflection
{
	private const BindingFlags InstanceFlags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;

	private static readonly HashSet<string> reportedErrors = new HashSet<string>();

	public static object GetParentObject(SerializedProperty property)
	{
		if (property == null || property.serializedObject.targetObject == null)
		{
			return null;
		}

		object current = property.serializedObject.targetObject;
		string path = property.propertyPath.Replace(".Array.data[", "[");
		string[] elements = path.Split('.');
		for (int i = 0; i < elements.Length - 1 && current != null; i++)
		{
			current = GetPathElementValue(current, elements[i]);
		}
		return current;
	}

	public static object GetPropertyValue(SerializedProperty property, FieldInfo fallbackFieldInfo = null)
	{
		object parent = GetParentObject(property);
		if (parent == null)
		{
			return null;
		}

		string path = property.propertyPath.Replace(".Array.data[", "[");
		string lastElement = path.Split('.').Last();
		object value = GetPathElementValue(parent, lastElement);
		if (value == null && fallbackFieldInfo != null && !lastElement.Contains("["))
		{
			try
			{
				value = fallbackFieldInfo.GetValue(parent);
			}
			catch
			{
				// SerializedProperty paths can point into value-type copies. The path resolver is
				// authoritative in that case, so a failed reflection fallback is harmless.
			}
		}
		return value;
	}

	public static bool TryGetMemberValue(object target, string memberName, out object value)
	{
		value = null;
		if (target == null || string.IsNullOrEmpty(memberName))
		{
			return false;
		}

		for (Type type = target.GetType(); type != null; type = type.BaseType)
		{
			FieldInfo field = type.GetField(memberName, InstanceFlags | BindingFlags.DeclaredOnly);
			if (field != null)
			{
				value = field.GetValue(target);
				return true;
			}

			PropertyInfo property = type.GetProperty(memberName, InstanceFlags | BindingFlags.DeclaredOnly);
			if (property != null && property.GetIndexParameters().Length == 0 && property.GetGetMethod(true) != null)
			{
				value = property.GetValue(target, null);
				return true;
			}
		}
		return false;
	}

	public static bool TrySetMemberValue(object target, string memberName, object value)
	{
		if (target == null || string.IsNullOrEmpty(memberName))
		{
			return false;
		}

		for (Type type = target.GetType(); type != null; type = type.BaseType)
		{
			FieldInfo field = type.GetField(memberName, InstanceFlags | BindingFlags.DeclaredOnly);
			if (field != null)
			{
				field.SetValue(target, ConvertValue(value, field.FieldType));
				return true;
			}

			PropertyInfo property = type.GetProperty(memberName, InstanceFlags | BindingFlags.DeclaredOnly);
			if (property != null && property.GetIndexParameters().Length == 0 && property.GetSetMethod(true) != null)
			{
				property.SetValue(target, ConvertValue(value, property.PropertyType), null);
				return true;
			}
		}
		return false;
	}

	public static object Invoke(object target, string methodName, object currentValue, bool preferValueParameter)
	{
		if (target == null || string.IsNullOrEmpty(methodName))
		{
			return null;
		}

		try
		{
			MethodInfo[] methods = GetMethods(target.GetType(), methodName).ToArray();
			MethodInfo method = null;
			object[] arguments = null;

			if (preferValueParameter)
			{
				method = methods.FirstOrDefault(candidate =>
				candidate.GetParameters().Length == 1 &&
				IsCompatibleArgument(currentValue, candidate.GetParameters()[0].ParameterType));
				if (method != null)
				{
					arguments = new[] { ConvertValue(currentValue, method.GetParameters()[0].ParameterType) };
				}
			}

			if (method == null)
			{
				method = methods.FirstOrDefault(candidate => candidate.GetParameters().Length == 0);
				arguments = Array.Empty<object>();
			}

			if (method == null && !preferValueParameter)
			{
				method = methods.FirstOrDefault(candidate =>
					candidate.GetParameters().Length == 1 &&
					IsCompatibleArgument(currentValue, candidate.GetParameters()[0].ParameterType));
				if (method != null)
				{
					arguments = new[] { ConvertValue(currentValue, method.GetParameters()[0].ParameterType) };
				}
			}

			if (method == null)
			{
				ReportOnce(
					target.GetType().FullName + "." + methodName,
					$"Could not find a compatible method named '{methodName}' on {target.GetType().Name}.");
				return null;
			}
			return method.Invoke(target, arguments);
		}
		catch (TargetInvocationException exception)
		{
			Exception cause = exception.InnerException ?? exception;
			ReportOnce(
				target.GetType().FullName + "." + methodName + ":" + cause.GetType().FullName,
				$"Property drawer failed to invoke {target.GetType().Name}.{methodName}: {cause.Message}");
			return null;
		}
		catch (Exception exception)
		{
			ReportOnce(
				target.GetType().FullName + "." + methodName + ":" + exception.GetType().FullName,
				$"Property drawer failed to invoke {target.GetType().Name}.{methodName}: {exception.Message}");
			return null;
		}
	}

	public static bool ToBoolean(object value)
	{
		if (value == null)
		{
			return false;
		}
		if (value is bool boolean)
		{
			return boolean;
		}
		if (value is UnityEngine.Object unityObject)
		{
			return unityObject != null;
		}
		try
		{
			return Convert.ToBoolean(value);
		}
		catch
		{
			return true;
		}
	}

	public static Type GetFieldElementType(FieldInfo fieldInfo)
	{
		if (fieldInfo == null)
		{
			return typeof(UnityEngine.Object);
		}

		Type fieldType = fieldInfo.FieldType;
		if (fieldType.IsArray)
		{
			return fieldType.GetElementType();
		}
		if (fieldType.IsGenericType && typeof(IEnumerable).IsAssignableFrom(fieldType))
		{
			return fieldType.GetGenericArguments()[0];
		}
		return fieldType;
	}

	public static string GetNameFromMethod(SerializedProperty property, string methodName, int index)
	{
		object parent = GetParentObject(property);
		object result = Invoke(parent, methodName, index, preferValueParameter: true);
		if (result == null && !ReferenceEquals(parent, property.serializedObject.targetObject))
		{
			result = Invoke(property.serializedObject.targetObject, methodName, index, preferValueParameter: true);
		}
		return result as string;
	}

	private static object GetPathElementValue(object source, string element)
	{
		if (source == null)
		{
			return null;
		}

		int bracketIndex = element.IndexOf('[', StringComparison.Ordinal);
		if (bracketIndex < 0)
		{
			return TryGetMemberValue(source, element, out object value) ? value : null;
		}

		string memberName = element.Substring(0, bracketIndex);
		int closingBracketIndex = element.IndexOf(']', bracketIndex + 1);
		if (closingBracketIndex < 0 ||
			!int.TryParse(element.Substring(bracketIndex + 1, closingBracketIndex - bracketIndex - 1), out int index))
		{
			return null;
		}

		if (!TryGetMemberValue(source, memberName, out object collection) || !(collection is IEnumerable enumerable))
		{
			return null;
		}
		return enumerable.Cast<object>().ElementAtOrDefault(index);
	}

	private static IEnumerable<MethodInfo> GetMethods(Type type, string methodName)
	{
		for (Type current = type; current != null; current = current.BaseType)
		{
			foreach (MethodInfo method in current.GetMethods(InstanceFlags | BindingFlags.DeclaredOnly))
			{
				if (method.Name == methodName)
				{
					yield return method;
				}
			}
		}
	}

	private static bool IsCompatibleArgument(object value, Type parameterType)
	{
		if (value == null)
		{
			return !parameterType.IsValueType || Nullable.GetUnderlyingType(parameterType) != null;
		}
		return parameterType.IsInstanceOfType(value) || typeof(IConvertible).IsAssignableFrom(value.GetType());
	}

	private static object ConvertValue(object value, Type targetType)
	{
		if (value == null || targetType.IsInstanceOfType(value))
		{
			return value;
		}

		Type nullableType = Nullable.GetUnderlyingType(targetType);
		if (nullableType != null)
		{
			targetType = nullableType;
		}
		if (targetType.IsEnum)
		{
			return Enum.ToObject(targetType, value);
		}
		return Convert.ChangeType(value, targetType);
	}

	private static void ReportOnce(string key, string message)
	{
		if (reportedErrors.Add(key))
		{
			Debug.LogWarning(message);
		}
	}
}
