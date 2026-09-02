namespace GlobalEnums
{
	public enum ActorStates
	{
		grounded = 0,		// 角色已经落地。会被立刻切换状态
		idle = 1,			// 角色在地面上静止
		running = 2,		// 角色在地面上进行水平移动
		airborne = 3,		// 角色处于空中
		wall_sliding = 4,	// 它表示角色贴着墙向下滑动，没有实际使用
		hard_landing = 5,	// 重落地硬直
		dash_landing = 6,	// 角色向下冲刺后撞到地面时的落地恢复状态
		no_input = 7,		// 角色暂时不接受正常玩家控制
		previous = 8		// 恢复进入当前状态之前的那个状态
	}
}
