using System.Collections.Generic;
using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory(ActionCategory.Physics)]
	[Tooltip("Detect additional collisions between objects with additional raycasting.")]
	public class CheckCollisionSideV2 : FsmStateAction
	{
		public enum CollisionSide
		{
			top = 0,
			left = 1,
			right = 2,
			bottom = 3,
			other = 4
		}

		private const int TERRAIN_LAYER_MASK = 33554688;

		public FsmOwnerDefault collidingObject;

		[UIHint(UIHint.Variable)]
		public FsmBool topHit;

		[UIHint(UIHint.Variable)]
		public FsmBool rightHit;

		[UIHint(UIHint.Variable)]
		public FsmBool bottomHit;

		[UIHint(UIHint.Variable)]
		public FsmBool leftHit;

		public FsmEvent topHitEvent;

		public FsmEvent rightHitEvent;

		public FsmEvent bottomHitEvent;

		public FsmEvent leftHitEvent;

		public bool otherLayer;

		public int otherLayerNumber;

		public FsmBool ignoreTriggers;

		[Space]
		public FsmBool ignoreBodyVelocity;

		private Collider2D col2d;

		private Rigidbody2D body;

		private int terrainLayerMask;

		private List<Vector2> topRays;

		private List<Vector2> rightRays;

		private List<Vector2> bottomRays;

		private List<Vector2> leftRays;

		private bool checkUp;

		private bool checkDown;

		private bool checkLeft;

		private bool checkRight;

		private static ContactPoint2D[] contactPoint2Ds = new ContactPoint2D[1];

		private CustomPlayMakerCollisionStay2D eventProxy;

		private CustomPlayMakerPhysicsEvent<Collision2D>.EventResponder responder;

		private bool hasBody;

		private Vector3 lastPosition;

		private bool isActive;

		private int lastUpdateCycle;

		private int lastTriggerCycle;

		private int enterCount;

		public override void Reset()
		{
			checkUp = false;
			checkDown = false;
			checkLeft = false;
			checkRight = false;
		}

		public override void Awake()
		{
			base.Fsm.HandleFixedUpdate = true;
			base.Fsm.HandleCollisionExit2D = true;
		}

		public override void OnPreprocess()
		{
			base.Fsm.HandleFixedUpdate = true;
			base.Fsm.HandleCollisionExit2D = true;
		}

		private void RemoveEventProxy()
		{
			if ((bool)eventProxy)
			{
				if (responder != null)
				{
					eventProxy.Remove(responder);
					responder = null;
				}
				else
				{
					eventProxy.Remove(this);
				}
				eventProxy = null;
			}
			else if (responder != null)
			{
				responder.pendingRemoval = true;
				responder = null;
			}
		}

		public override void OnEnter()
		{
			GameObject ownerDefaultTarget = base.Fsm.GetOwnerDefaultTarget(collidingObject);
			isActive = true;
			eventProxy = CustomPlayMakerCollisionStay2D.GetEventSender(ownerDefaultTarget);
			responder = eventProxy.Add(this, DoCollisionStay2D);
			terrainLayerMask = ((ignoreTriggers.Value && ownerDefaultTarget.layer == 9) ? 33562880 : 33554688);
			col2d = ownerDefaultTarget.GetComponent<Collider2D>();
			body = ownerDefaultTarget.GetComponent<Rigidbody2D>();
			hasBody = body != null;
			lastPosition = col2d.transform.position;
			topRays = new List<Vector2>(3);
			rightRays = new List<Vector2>(3);
			bottomRays = new List<Vector2>(3);
			leftRays = new List<Vector2>(3);
			if (!topHit.IsNone || topHitEvent != null)
			{
				checkUp = true;
			}
			else
			{
				checkUp = false;
			}
			if (!rightHit.IsNone || rightHitEvent != null)
			{
				checkRight = true;
			}
			else
			{
				checkRight = false;
			}
			if (!bottomHit.IsNone || bottomHitEvent != null)
			{
				checkDown = true;
			}
			else
			{
				checkDown = false;
			}
			if (!leftHit.IsNone || leftHitEvent != null)
			{
				checkLeft = true;
			}
			else
			{
				checkLeft = false;
			}
			if (topHit.Value || bottomHit.Value || rightHit.Value || leftHit.Value)
			{
				if (!otherLayer)
				{
					CheckTouching(terrainLayerMask);
				}
				else
				{
					CheckTouching(1 << otherLayerNumber);
				}
			}
		}

		public override void OnExit()
		{
			isActive = false;
			RemoveEventProxy();
		}

		public override void OnFixedUpdate()
		{
			if (!isActive || lastUpdateCycle == CustomPlayerLoop.FixedUpdateCycle)
			{
				return;
			}
			bool flag = false;
			if (hasBody && CustomPlayerLoop.FixedUpdateCycle - lastUpdateCycle > 1)
			{
				flag = body.GetContacts(contactPoint2Ds) > 0;
			}
			if (flag || topHit.Value || bottomHit.Value || rightHit.Value || leftHit.Value)
			{
				if (!otherLayer)
				{
					CheckTouching(terrainLayerMask);
				}
				else
				{
					CheckTouching(1 << otherLayerNumber);
				}
			}
		}

		public override void DoCollisionStay2D(Collision2D collision)
		{
			if (!otherLayer)
			{
				if (((1 << collision.gameObject.layer) & terrainLayerMask) != 0)
				{
					CheckTouching(terrainLayerMask, collision.GetSafeContact());
				}
			}
			else
			{
				CheckTouching(1 << otherLayerNumber, collision.GetSafeContact());
			}
		}

		public override void DoCollisionExit2D(Collision2D collision)
		{
			topHit.Value = false;
			rightHit.Value = false;
			bottomHit.Value = false;
			leftHit.Value = false;
		}

		private bool CheckHit(int layerMask, Vector2 origin, Vector2 direction, Color debugColor)
		{
			Collider2D collider = Helper.Raycast2D(origin, direction, 0.08f, layerMask).collider;
			if (collider == null)
			{
				return false;
			}
			if (ignoreTriggers.Value && collider.isTrigger)
			{
				return false;
			}
			lastTriggerCycle = CustomPlayerLoop.FixedUpdateCycle;
			topHit.Value = true;
			base.Fsm.Event(topHitEvent);
			return true;
		}

		private void CheckTouching(int layerMask, Collision2DUtils.Collision2DSafeContact contact = default(Collision2DUtils.Collision2DSafeContact))
		{
			if (lastUpdateCycle == CustomPlayerLoop.FixedUpdateCycle)
			{
				return;
			}
			if (lastUpdateCycle == CustomPlayerLoop.FixedUpdateCycle)
			{
				if (enterCount++ > 1)
				{
					return;
				}
			}
			else
			{
				enterCount = 0;
				lastUpdateCycle = CustomPlayerLoop.FixedUpdateCycle;
			}
			UnityEngine.Bounds bounds = col2d.bounds;
			Vector3 max = bounds.max;
			Vector3 min = bounds.min;
			Vector3 center = bounds.center;
			Vector3 position = col2d.transform.position;
			Vector3 vector = position - lastPosition;
			lastPosition = position;
			bool value = ignoreBodyVelocity.Value;
			if (checkUp && (value || !hasBody || body.linearVelocity.y >= -0.001f || vector.y >= 0f))
			{
				topRays.Clear();
				topRays.Add(new Vector2(min.x, max.y));
				topRays.Add(new Vector2(center.x, max.y));
				topRays.Add(max);
				topHit.Value = false;
				bool flag = false;
				if (contact.IsLegitimate && CheckHit(layerMask, contact.Point, Vector2.up, Color.red))
				{
					flag = true;
				}
				if (!flag)
				{
					for (int i = 0; i < 3 && !CheckHit(layerMask, topRays[i], Vector2.up, Color.red); i++)
					{
					}
				}
			}
			if (checkRight && (value || !hasBody || body.linearVelocity.x >= -0.001f || vector.x >= 0f))
			{
				rightRays.Clear();
				rightRays.Add(max);
				rightRays.Add(new Vector2(max.x, center.y));
				rightRays.Add(new Vector2(max.x, min.y));
				rightHit.Value = false;
				bool flag2 = false;
				if (contact.IsLegitimate && CheckHit(layerMask, contact.Point, Vector2.right, Color.yellow))
				{
					flag2 = true;
				}
				if (!flag2)
				{
					for (int j = 0; j < 3 && !CheckHit(layerMask, rightRays[j], Vector2.right, Color.yellow); j++)
					{
					}
				}
			}
			if (checkDown && (value || !hasBody || body.linearVelocity.y <= 0.001f || vector.y <= 0f))
			{
				bottomRays.Clear();
				bottomRays.Add(new Vector2(max.x, min.y));
				bottomRays.Add(new Vector2(center.x, min.y));
				bottomRays.Add(min);
				bottomHit.Value = false;
				bool flag3 = false;
				if (contact.IsLegitimate && CheckHit(layerMask, contact.Point, Vector2.down, Color.green))
				{
					flag3 = true;
				}
				if (!flag3)
				{
					for (int k = 0; k < 3 && !CheckHit(layerMask, bottomRays[k], Vector2.down, Color.green); k++)
					{
					}
				}
			}
			if (!checkLeft || (!value && hasBody && !(body.linearVelocity.x <= 0.001f) && !(vector.x <= 0f)))
			{
				return;
			}
			leftRays.Clear();
			leftRays.Add(min);
			leftRays.Add(new Vector2(min.x, center.y));
			leftRays.Add(new Vector2(min.x, max.y));
			leftHit.Value = false;
			bool flag4 = false;
			if (contact.IsLegitimate && CheckHit(layerMask, contact.Point, Vector2.left, Color.blue))
			{
				flag4 = true;
			}
			if (!flag4)
			{
				for (int l = 0; l < 3 && !CheckHit(layerMask, leftRays[l], Vector2.left, Color.blue); l++)
				{
				}
			}
		}
	}
}
