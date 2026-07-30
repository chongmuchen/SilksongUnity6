public static class ToolItemTypeExtensions
{
	public static bool IsAttackType(this ToolItemType type)
	{
		if (type != ToolItemType.Red)
		{
			return type == ToolItemType.Skill;
		}
		return true;
	}
}
