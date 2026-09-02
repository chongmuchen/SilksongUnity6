using System.Collections;
using UnityEngine;

[AddComponentMenu("2D Toolkit/Deprecated/GUI/tk2dButton")]
public class tk2dButton : MonoBehaviour
{
	public delegate void ButtonHandlerDelegate(tk2dButton source);

	public Camera viewCamera;

	public string buttonDownSprite = "button_down";

	public string buttonUpSprite = "button_up";

	public string buttonPressedSprite = "button_up";

	private int buttonDownSpriteId = -1;

	private int buttonUpSpriteId = -1;

	private int buttonPressedSpriteId = -1;

	public AudioClip buttonDownSound;

	public AudioClip buttonUpSound;

	public AudioClip buttonPressedSound;

	public GameObject targetObject;

	public string messageName = "";

	private tk2dBaseSprite sprite;

	private bool buttonDown;

	public float targetScale = 1.1f;

	public float scaleTime = 0.05f;

	public float pressedWaitTime = 0.3f;

	public event ButtonHandlerDelegate ButtonPressedEvent;

	public event ButtonHandlerDelegate ButtonAutoFireEvent;

	public event ButtonHandlerDelegate ButtonDownEvent;

	public event ButtonHandlerDelegate ButtonUpEvent;

	private void OnEnable()
	{
		buttonDown = false;
	}

	private void Start()
	{
		if (viewCamera == null)
		{
			Transform parent = base.transform;
			while ((bool)parent && parent.GetComponent<Camera>() == null)
			{
				parent = parent.parent;
			}
			if ((bool)parent && parent.GetComponent<Camera>() != null)
			{
				viewCamera = parent.GetComponent<Camera>();
			}
			if (viewCamera == null && (bool)tk2dCamera.Instance)
			{
				viewCamera = tk2dCamera.Instance.GetComponent<Camera>();
			}
			if (viewCamera == null)
			{
				viewCamera = Camera.main;
			}
		}
		sprite = GetComponent<tk2dBaseSprite>();
		if ((bool)sprite)
		{
			UpdateSpriteIds();
		}
		if (GetComponent<Collider>() == null)
		{
			BoxCollider boxCollider = base.gameObject.AddComponent<BoxCollider>();
			Vector3 size = boxCollider.size;
			size.z = 0.2f;
			boxCollider.size = size;
		}
		if ((buttonDownSound != null || buttonPressedSound != null || buttonUpSound != null) && GetComponent<AudioSource>() == null)
		{
			base.gameObject.AddComponent<AudioSource>().playOnAwake = false;
		}
	}

	public void UpdateSpriteIds()
	{
		buttonDownSpriteId = ((buttonDownSprite.Length > 0) ? sprite.GetSpriteIdByName(buttonDownSprite) : (-1));
		buttonUpSpriteId = ((buttonUpSprite.Length > 0) ? sprite.GetSpriteIdByName(buttonUpSprite) : (-1));
		buttonPressedSpriteId = ((buttonPressedSprite.Length > 0) ? sprite.GetSpriteIdByName(buttonPressedSprite) : (-1));
	}

	private void PlaySound(AudioClip source)
	{
		if ((bool)GetComponent<AudioSource>() && (bool)source)
		{
			GetComponent<AudioSource>().PlayOneShot(source);
		}
	}

	private IEnumerator coScale(Vector3 defaultScale, float startScale, float endScale)
	{
		float t0 = Time.realtimeSinceStartup;
		for (float num = 0f; num < scaleTime; num = Time.realtimeSinceStartup - t0)
		{
			float t = Mathf.Clamp01(num / scaleTime);
			float num2 = Mathf.Lerp(startScale, endScale, t);
			Vector3 localScale = defaultScale * num2;
			base.transform.localScale = localScale;
			yield return 0;
		}
		base.transform.localScale = defaultScale * endScale;
	}

	private IEnumerator LocalWaitForSeconds(float seconds)
	{
		float t0 = Time.realtimeSinceStartup;
		for (float num = 0f; num < seconds; num = Time.realtimeSinceStartup - t0)
		{
			yield return 0;
		}
	}

	private IEnumerator coHandleButtonPress(int fingerId)
	{
		buttonDown = true;
		bool buttonPressed = true;
		Vector3 defaultScale = base.transform.localScale;
		if (targetScale != 1f)
		{
			yield return StartCoroutine(coScale(defaultScale, 1f, targetScale));
		}
		PlaySound(buttonDownSound);
		if (buttonDownSpriteId != -1)
		{
			sprite.spriteId = buttonDownSpriteId;
		}
		if (this.ButtonDownEvent != null)
		{
			this.ButtonDownEvent(this);
		}
		while (true)
		{
			Vector3 pos = Vector3.zero;
			bool flag = true;
			if (fingerId != -1)
			{
				bool flag2 = false;
				for (int i = 0; i < Input.touchCount; i++)
				{
					Touch touch = Input.GetTouch(i);
					if (touch.fingerId == fingerId)
					{
						if (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled)
						{
							break;
						}
						pos = touch.position;
						flag2 = true;
					}
				}
				if (!flag2)
				{
					flag = false;
				}
			}
			else
			{
				if (!Input.GetMouseButton(0))
				{
					flag = false;
				}
				pos = Input.mousePosition;
			}
			if (!flag)
			{
				break;
			}
			Ray ray = viewCamera.ScreenPointToRay(pos);
			RaycastHit hitInfo;
			bool flag3 = GetComponent<Collider>().Raycast(ray, out hitInfo, float.PositiveInfinity);
			if (buttonPressed && !flag3)
			{
				if (targetScale != 1f)
				{
					yield return StartCoroutine(coScale(defaultScale, targetScale, 1f));
				}
				PlaySound(buttonUpSound);
				if (buttonUpSpriteId != -1)
				{
					sprite.spriteId = buttonUpSpriteId;
				}
				if (this.ButtonUpEvent != null)
				{
					this.ButtonUpEvent(this);
				}
				buttonPressed = false;
			}
			else if (!buttonPressed && flag3)
			{
				if (targetScale != 1f)
				{
					yield return StartCoroutine(coScale(defaultScale, 1f, targetScale));
				}
				PlaySound(buttonDownSound);
				if (buttonDownSpriteId != -1)
				{
					sprite.spriteId = buttonDownSpriteId;
				}
				if (this.ButtonDownEvent != null)
				{
					this.ButtonDownEvent(this);
				}
				buttonPressed = true;
			}
			if (buttonPressed && this.ButtonAutoFireEvent != null)
			{
				this.ButtonAutoFireEvent(this);
			}
			yield return 0;
		}
		if (buttonPressed)
		{
			if (targetScale != 1f)
			{
				yield return StartCoroutine(coScale(defaultScale, targetScale, 1f));
			}
			PlaySound(buttonPressedSound);
			if (buttonPressedSpriteId != -1)
			{
				sprite.spriteId = buttonPressedSpriteId;
			}
			if ((bool)targetObject)
			{
				targetObject.SendMessage(messageName);
			}
			if (this.ButtonUpEvent != null)
			{
				this.ButtonUpEvent(this);
			}
			if (this.ButtonPressedEvent != null)
			{
				this.ButtonPressedEvent(this);
			}
			if (base.gameObject.activeInHierarchy)
			{
				yield return StartCoroutine(LocalWaitForSeconds(pressedWaitTime));
			}
			if (buttonUpSpriteId != -1)
			{
				sprite.spriteId = buttonUpSpriteId;
			}
		}
		buttonDown = false;
	}

	private void Update()
	{
		if (buttonDown)
		{
			return;
		}
		bool flag = false;
		if (Input.multiTouchEnabled)
		{
			for (int i = 0; i < Input.touchCount; i++)
			{
				Touch touch = Input.GetTouch(i);
				if (touch.phase == TouchPhase.Began)
				{
					Ray ray = viewCamera.ScreenPointToRay(touch.position);
					if (GetComponent<Collider>().Raycast(ray, out var hitInfo, 100000000f) && !Physics.Raycast(ray, hitInfo.distance - 0.01f))
					{
						StartCoroutine(coHandleButtonPress(touch.fingerId));
						flag = true;
						break;
					}
				}
			}
		}
		if (!flag && Input.GetMouseButtonDown(0))
		{
			Ray ray2 = viewCamera.ScreenPointToRay(Input.mousePosition);
			if (GetComponent<Collider>().Raycast(ray2, out var hitInfo2, 100000000f) && !Physics.Raycast(ray2, hitInfo2.distance - 0.01f))
			{
				StartCoroutine(coHandleButtonPress(-1));
			}
		}
	}
}
