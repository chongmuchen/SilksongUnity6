using System;
using GlobalEnums;
using TeamCherry.SharedUtils;
using UnityEngine;

[Serializable]
public class ControllerImage
{
	public GamepadType gamepadType;

	[EnumPickerBitmask(typeof(RuntimePlatform))]
	public long platformSpecific;

	public Sprite sprite;

	public ControllerButtonPositions buttonPositions;

	public float displayScale = 1f;

	public float offsetY;
}
