using GlobalEnums;
using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class SuperJumpRaycast : FsmStateAction
	{
		[ActionSection("Setup")]
		public FsmOwnerDefault FromGameObject;

		public FsmVector2 FromPosition;

		public FsmVector2 Direction;

		public Space Space;

		public FsmFloat Distance;

		[ActionSection("Result")]
		public FsmEvent HitEvent;

		public FsmEvent NoHitEvent;

		[UIHint(UIHint.Variable)]
		public FsmBool StoreDidHit;

		[UIHint(UIHint.Variable)]
		public FsmGameObject StoreHitObject;

		[UIHint(UIHint.Variable)]
		public FsmVector2 StoreHitPoint;

		[UIHint(UIHint.Variable)]
		public FsmFloat StoreDistance;

		[UIHint(UIHint.Variable)]
		public FsmBool StoreIsTransitionGate;

		[UIHint(UIHint.Variable)]
		public FsmBool StoreHitSpikes;

		private Transform trans;

		private static readonly RaycastHit2D[] _hitStore = new RaycastHit2D[50];

		public override void Reset()
		{
			FromGameObject = null;
			FromPosition = null;
			Direction = null;
			Space = Space.World;
			Distance = null;
			HitEvent = null;
			NoHitEvent = null;
			StoreDidHit = null;
			StoreHitObject = null;
			StoreHitPoint = null;
			StoreDistance = null;
			StoreIsTransitionGate = null;
			StoreHitSpikes = null;
		}

		public override void OnEnter()
		{
			GameObject ownerDefaultTarget = base.Fsm.GetOwnerDefaultTarget(FromGameObject);
			trans = ((ownerDefaultTarget != null) ? ownerDefaultTarget.transform : null);
			StoreDidHit.Value = false;
			StoreHitObject.Value = null;
			StoreIsTransitionGate.Value = false;
			StoreHitSpikes.Value = false;
			DoRaycast();
			Finish();
		}

		private void DoRaycast()
		{
			if (Mathf.Abs(Distance.Value) < Mathf.Epsilon)
			{
				return;
			}
			Vector2 value = FromPosition.Value;
			if (trans != null)
			{
				value.x += trans.position.x;
				value.y += trans.position.y;
			}
			float distance = float.PositiveInfinity;
			if (Distance.Value > 0f)
			{
				distance = Distance.Value;
			}
			Vector2 normalized = Direction.Value.normalized;
			if (trans != null && Space == Space.Self)
			{
				Vector3 vector = trans.TransformDirection(new Vector3(Direction.Value.x, Direction.Value.y, 0f));
				normalized.x = vector.x;
				normalized.y = vector.y;
			}
			ContactFilter2D contactFilter = new ContactFilter2D
			{
				useLayerMask = true,
				layerMask = 8448,
				useTriggers = true
			};
			RaycastHit2D raycastHit2D = default(RaycastHit2D);
			float num = float.MaxValue;
			try
			{
				int a = Physics2D.Raycast(value, normalized, contactFilter, _hitStore, distance);
				for (int i = 0; i < Mathf.Min(a, _hitStore.Length); i++)
				{
					RaycastHit2D raycastHit2D2 = _hitStore[i];
					bool value2 = false;
					if (raycastHit2D2.collider.isTrigger)
					{
						TransitionPoint component = raycastHit2D2.collider.GetComponent<TransitionPoint>();
						if (!component || component.GetGatePosition() != GatePosition.top)
						{
							continue;
						}
						value2 = true;
					}
					if (!(raycastHit2D2.distance > num))
					{
						raycastHit2D = raycastHit2D2;
						num = raycastHit2D2.distance;
						StoreIsTransitionGate.Value = value2;
					}
				}
			}
			finally
			{
				for (int j = 0; j < _hitStore.Length; j++)
				{
					_hitStore[j] = default(RaycastHit2D);
				}
			}
			bool flag = raycastHit2D.collider != null;
			StoreDidHit.Value = flag;
			if (flag)
			{
				try
				{
					ref LayerMask layerMask = ref contactFilter.layerMask;
					layerMask = (int)layerMask | 0x420000;
					int a2 = Physics2D.Raycast(value, normalized, contactFilter, _hitStore, num);
					for (int k = 0; k < Mathf.Min(a2, _hitStore.Length); k++)
					{
						RaycastHit2D raycastHit2D3 = _hitStore[k];
						DamageHero component2 = raycastHit2D3.collider.GetComponent<DamageHero>();
						if ((bool)component2 && component2.hazardType == HazardType.SPIKES)
						{
							StoreHitSpikes.Value = true;
						}
					}
				}
				finally
				{
					for (int l = 0; l < _hitStore.Length; l++)
					{
						_hitStore[l] = default(RaycastHit2D);
					}
				}
				StoreHitObject.Value = raycastHit2D.collider.gameObject;
				StoreHitPoint.Value = raycastHit2D.point;
				StoreDistance.Value = raycastHit2D.distance;
				base.Fsm.Event(HitEvent);
			}
			else
			{
				base.Fsm.Event(NoHitEvent);
			}
		}
	}
}
