using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
	[ExecuteInEditMode]
	[AddComponentMenu("Image Effects/Color Adjustments/Color Correction (Curves, Saturation)")]
	public class ColorCorrectionCurves : MonoBehaviour, IPostprocessModule
	{
		public float saturation = 1f;

		public AnimationCurve redChannel = new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

		public AnimationCurve greenChannel = new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

		public AnimationCurve blueChannel = new AnimationCurve(new Keyframe(0f, 0f), new Keyframe(1f, 1f));

		public Shader simpleColorCorrectionCurvesShader;

		[Space]
		[SerializeField]
		private Renderer applyToRenderer;

		private Material ogMaterial;

		private Material ccMaterial;

		private Texture2D rgbChannelTex;

		private bool updateTexturesOnStartup = true;

		private bool isBloomActive = true;

		private static readonly int _rgbTexId = Shader.PropertyToID("_RgbTex");

		private static readonly int _saturationId = Shader.PropertyToID("_Saturation");

		private Color[] colors = new Color[1024];

		public bool IsBloomActive
		{
			get
			{
				return isBloomActive;
			}
			set
			{
				isBloomActive = value;
				UpdateParameters();
			}
		}

		public string EffectKeyword => "COLOR_CURVES_ENABLED";

		private void OnEnable()
		{
			if ((bool)applyToRenderer && Application.isPlaying)
			{
				ogMaterial = applyToRenderer.sharedMaterial;
				if ((bool)ccMaterial)
				{
					applyToRenderer.material = ccMaterial;
				}
			}
		}

		private void OnDisable()
		{
			if ((bool)applyToRenderer && Application.isPlaying)
			{
				applyToRenderer.material = ogMaterial;
			}
		}

		private void OnDestroy()
		{
			if ((bool)rgbChannelTex)
			{
				Object.Destroy(rgbChannelTex);
			}
			if ((bool)ccMaterial)
			{
				Object.Destroy(ccMaterial);
			}
		}

		private void Start()
		{
			CheckResources();
			updateTexturesOnStartup = true;
			if ((bool)applyToRenderer && Application.isPlaying)
			{
				UpdateParameters();
				UpdateMaterial();
				applyToRenderer.material = ccMaterial;
			}
		}

		public void UpdateMaterial()
		{
			UpdateMaterial(ccMaterial);
		}

		public void UpdateMaterial(Material material)
		{
			if (updateTexturesOnStartup)
			{
				UpdateParameters();
				updateTexturesOnStartup = false;
			}
			material.SetTexture(_rgbTexId, rgbChannelTex);
			material.SetFloat(_saturationId, saturation);
		}

		private Material CheckShaderAndCreateMaterial(Shader s, Material m2Create)
		{
			if (!s)
			{
				Debug.Log("Missing shader in " + ToString());
				base.enabled = false;
				return null;
			}
			if (s.isSupported && (bool)m2Create && m2Create.shader == s)
			{
				return m2Create;
			}
			if (!s.isSupported)
			{
				Debug.Log("The shader " + s?.ToString() + " on effect " + ToString() + " is not supported on this platform!");
				return null;
			}
			m2Create = new Material(s)
			{
				hideFlags = HideFlags.DontSave
			};
			if (!m2Create)
			{
				return null;
			}
			return m2Create;
		}

		private bool CheckResources()
		{
			if (!simpleColorCorrectionCurvesShader.isSupported)
			{
				return false;
			}
			ccMaterial = CheckShaderAndCreateMaterial(simpleColorCorrectionCurvesShader, ccMaterial);
			if (!rgbChannelTex)
			{
				rgbChannelTex = new Texture2D(256, 4, TextureFormat.ARGB32, mipChain: false, linear: true);
				rgbChannelTex.name = $"{this} RGB Channel";
				for (int i = 0; i <= 255; i++)
				{
					colors[i + 768] = default(Color);
				}
			}
			rgbChannelTex.hideFlags = HideFlags.DontSave;
			rgbChannelTex.wrapMode = TextureWrapMode.Clamp;
			rgbChannelTex.filterMode = FilterMode.Point;
			return true;
		}

		public void UpdateParameters()
		{
			CheckResources();
			if (redChannel == null || greenChannel == null || blueChannel == null)
			{
				return;
			}
			for (int i = 0; i <= 255; i++)
			{
				float time = (float)i * 0.003921569f;
				float num = Mathf.Clamp01(redChannel.Evaluate(time));
				float num2 = Mathf.Clamp01(greenChannel.Evaluate(time));
				float num3 = Mathf.Clamp01(blueChannel.Evaluate(time));
				if (!isBloomActive)
				{
					num *= 1.2f;
					num2 *= 1.2f;
					num3 *= 1.2f;
				}
				colors[i] = new Color(num, num, num);
				colors[i + 256] = new Color(num2, num2, num2);
				colors[i + 512] = new Color(num3, num3, num3);
			}
			rgbChannelTex.SetPixels(colors);
			rgbChannelTex.Apply();
		}

		public void UpdateProperties(Material material)
		{
			UpdateMaterial(material);
		}
	}
}
