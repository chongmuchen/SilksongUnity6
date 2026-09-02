using System.Collections.Generic;
using TeamCherry.SharedUtils;
using UnityEngine;

[AddComponentMenu("2D Toolkit/Sprite/tk2dSprite")]
[RequireComponent(typeof(MeshRenderer))]
[RequireComponent(typeof(MeshFilter))]
[ExecuteAlways]
public class tk2dSprite : tk2dBaseSprite
{
	private Mesh mesh;

	private Vector3[] meshVertices;

	private Vector3[] meshNormals;

	private Vector4[] meshTangents;

	private Color32[] meshColors;

	private List<string> materialKeywords;

	private Dictionary<int, float> materialFloats;

	private Dictionary<Material, Material> instancedMaterials;

	public bool HasKeywordsDefined
	{
		get
		{
			if (materialKeywords != null)
			{
				return materialKeywords.Count > 0;
			}
			return false;
		}
	}

	private new void Awake()
	{
		base.Awake();
		mesh = new Mesh();
		mesh.MarkDynamic();
		mesh.hideFlags = HideFlags.DontSave;
		GetComponent<MeshFilter>().sharedMesh = mesh;
		if ((bool)base.Collection)
		{
			if (_spriteId < 0 || _spriteId >= base.Collection.Count)
			{
				_spriteId = 0;
			}
			Build();
		}
	}

	protected void OnDestroy()
	{
		if ((bool)mesh)
		{
			Object.Destroy(mesh);
		}
		if ((bool)meshColliderMesh)
		{
			Object.Destroy(meshColliderMesh);
		}
	}

	public void EnableKeyword(string keyword)
	{
		if (materialKeywords == null)
		{
			materialKeywords = new List<string>();
		}
		materialKeywords.AddIfNotPresent(keyword);
		UpdateMaterial();
	}

	public void DisableKeyword(string keyword)
	{
		if (materialKeywords == null)
		{
			return;
		}
		materialKeywords.Remove(keyword);
		if (instancedMaterials == null)
		{
			return;
		}
		foreach (KeyValuePair<Material, Material> instancedMaterial in instancedMaterials)
		{
			if (instancedMaterial.Value.IsKeywordEnabled(keyword))
			{
				instancedMaterial.Value.DisableKeyword(keyword);
			}
		}
	}

	public bool HasKeyword(string keyword)
	{
		if (materialKeywords == null)
		{
			return false;
		}
		return materialKeywords.Contains(keyword);
	}

	public void MoveKeywords(tk2dSprite otherSprite)
	{
		otherSprite.materialKeywords = materialKeywords;
		materialKeywords = null;
		otherSprite.instancedMaterials = instancedMaterials;
		instancedMaterials = null;
		UpdateMaterial();
	}

	public void SetFloat(int propId, float value)
	{
		if (materialFloats == null)
		{
			materialFloats = new Dictionary<int, float>();
		}
		materialFloats[propId] = value;
		UpdateMaterial();
	}

	public override void Build()
	{
		tk2dSpriteDefinition tk2dSpriteDefinition2 = collectionInst.spriteDefinitions[base.spriteId];
		meshVertices = new Vector3[tk2dSpriteDefinition2.positions.Length];
		meshColors = new Color32[tk2dSpriteDefinition2.positions.Length];
		meshNormals = new Vector3[0];
		meshTangents = new Vector4[0];
		if (tk2dSpriteDefinition2.normals != null && tk2dSpriteDefinition2.normals.Length != 0)
		{
			meshNormals = new Vector3[tk2dSpriteDefinition2.normals.Length];
		}
		if (tk2dSpriteDefinition2.tangents != null && tk2dSpriteDefinition2.tangents.Length != 0)
		{
			meshTangents = new Vector4[tk2dSpriteDefinition2.tangents.Length];
		}
		SetPositions(meshVertices, meshNormals, meshTangents);
		SetColors(meshColors);
		if (mesh == null)
		{
			mesh = new Mesh();
			mesh.MarkDynamic();
			mesh.hideFlags = HideFlags.DontSave;
			GetComponent<MeshFilter>().sharedMesh = mesh;
		}
		mesh.Clear();
		mesh.vertices = meshVertices;
		mesh.normals = meshNormals;
		mesh.tangents = meshTangents;
		mesh.colors32 = meshColors;
		mesh.uv = tk2dSpriteDefinition2.uvs;
		mesh.triangles = tk2dSpriteDefinition2.indices;
		mesh.bounds = tk2dBaseSprite.AdjustedMeshBounds(GetBounds(), renderLayer);
		UpdateMaterial();
		CreateCollider();
	}

	public static tk2dSprite AddComponent(GameObject go, tk2dSpriteCollectionData spriteCollection, int spriteId)
	{
		return tk2dBaseSprite.AddComponent<tk2dSprite>(go, spriteCollection, spriteId);
	}

	public static tk2dSprite AddComponent(GameObject go, tk2dSpriteCollectionData spriteCollection, string spriteName)
	{
		return tk2dBaseSprite.AddComponent<tk2dSprite>(go, spriteCollection, spriteName);
	}

	public static GameObject CreateFromTexture(Texture texture, tk2dSpriteCollectionSize size, Rect region, Vector2 anchor)
	{
		return tk2dBaseSprite.CreateFromTexture<tk2dSprite>(texture, size, region, anchor);
	}

	protected override void UpdateGeometry()
	{
		UpdateGeometryImpl();
	}

	protected override void UpdateColors()
	{
		UpdateColorsImpl();
	}

	protected override void UpdateVertices()
	{
		UpdateVerticesImpl();
	}

	protected void UpdateColorsImpl()
	{
		if (!(mesh == null) && meshColors != null && meshColors.Length != 0)
		{
			SetColors(meshColors);
			mesh.colors32 = meshColors;
		}
	}

	protected void UpdateVerticesImpl()
	{
		tk2dSpriteDefinition tk2dSpriteDefinition2 = collectionInst.spriteDefinitions[base.spriteId];
		if (!(mesh == null) && meshVertices != null && meshVertices.Length != 0)
		{
			if (tk2dSpriteDefinition2.normals.Length != meshNormals.Length)
			{
				meshNormals = ((tk2dSpriteDefinition2.normals != null && tk2dSpriteDefinition2.normals.Length != 0) ? new Vector3[tk2dSpriteDefinition2.normals.Length] : new Vector3[0]);
			}
			if (tk2dSpriteDefinition2.tangents.Length != meshTangents.Length)
			{
				meshTangents = ((tk2dSpriteDefinition2.tangents != null && tk2dSpriteDefinition2.tangents.Length != 0) ? new Vector4[tk2dSpriteDefinition2.tangents.Length] : new Vector4[0]);
			}
			SetPositions(meshVertices, meshNormals, meshTangents);
			mesh.vertices = meshVertices;
			mesh.normals = meshNormals;
			mesh.tangents = meshTangents;
			mesh.uv = tk2dSpriteDefinition2.uvs;
			mesh.bounds = tk2dBaseSprite.AdjustedMeshBounds(GetBounds(), renderLayer);
		}
	}

	protected void UpdateGeometryImpl()
	{
		if (!(mesh == null))
		{
			tk2dSpriteDefinition tk2dSpriteDefinition2 = collectionInst.spriteDefinitions[base.spriteId];
			if (meshVertices == null || meshVertices.Length != tk2dSpriteDefinition2.positions.Length)
			{
				meshVertices = new Vector3[tk2dSpriteDefinition2.positions.Length];
				meshColors = new Color32[tk2dSpriteDefinition2.positions.Length];
			}
			if (meshNormals == null || (tk2dSpriteDefinition2.normals != null && meshNormals.Length != tk2dSpriteDefinition2.normals.Length))
			{
				meshNormals = new Vector3[tk2dSpriteDefinition2.normals.Length];
			}
			else if (tk2dSpriteDefinition2.normals == null)
			{
				meshNormals = new Vector3[0];
			}
			if (meshTangents == null || (tk2dSpriteDefinition2.tangents != null && meshTangents.Length != tk2dSpriteDefinition2.tangents.Length))
			{
				meshTangents = new Vector4[tk2dSpriteDefinition2.tangents.Length];
			}
			else if (tk2dSpriteDefinition2.tangents == null)
			{
				meshTangents = new Vector4[0];
			}
			SetPositions(meshVertices, meshNormals, meshTangents);
			SetColors(meshColors);
			mesh.Clear();
			mesh.vertices = meshVertices;
			mesh.normals = meshNormals;
			mesh.tangents = meshTangents;
			mesh.colors32 = meshColors;
			mesh.uv = tk2dSpriteDefinition2.uvs;
			mesh.bounds = tk2dBaseSprite.AdjustedMeshBounds(GetBounds(), renderLayer);
			mesh.triangles = tk2dSpriteDefinition2.indices;
		}
	}

	protected override void UpdateMaterial()
	{
		Material material = collectionInst.spriteDefinitions[base.spriteId].materialInst;
		bool num = materialKeywords != null && materialKeywords.Count > 0;
		bool flag = materialFloats != null && materialFloats.Count > 0;
		if (num || flag)
		{
			if (instancedMaterials == null)
			{
				instancedMaterials = new Dictionary<Material, Material>();
			}
			if (instancedMaterials.ContainsKey(material))
			{
				material = instancedMaterials[material];
			}
			else
			{
				Material key = material;
				material = new Material(material);
				material.name += " (using keywords)";
				instancedMaterials[key] = material;
			}
			if (materialKeywords != null)
			{
				foreach (string materialKeyword in materialKeywords)
				{
					if (!material.IsKeywordEnabled(materialKeyword))
					{
						material.EnableKeyword(materialKeyword);
					}
				}
			}
			if (materialFloats != null)
			{
				foreach (KeyValuePair<int, float> materialFloat in materialFloats)
				{
					material.SetFloat(materialFloat.Key, materialFloat.Value);
				}
			}
		}
		Renderer component = GetComponent<Renderer>();
		if (component.sharedMaterial != material)
		{
			component.material = material;
		}
	}

	protected override int GetCurrentVertexCount()
	{
		if (meshVertices == null)
		{
			return 0;
		}
		return meshVertices.Length;
	}

	public override void ForceBuild()
	{
		base.ForceBuild();
		GetComponent<MeshFilter>().sharedMesh = mesh;
	}

	public override void ReshapeBounds(Vector3 dMin, Vector3 dMax)
	{
		float num = 0.1f;
		tk2dSpriteDefinition currentSprite = base.CurrentSprite;
		Vector3 b = new Vector3(Mathf.Abs(_scale.x), Mathf.Abs(_scale.y), Mathf.Abs(_scale.z));
		Vector3 vector = Vector3.Scale(currentSprite.untrimmedBoundsData[0], _scale) - 0.5f * Vector3.Scale(currentSprite.untrimmedBoundsData[1], b);
		Vector3 vector2 = Vector3.Scale(currentSprite.untrimmedBoundsData[1], b) + dMax - dMin;
		vector2.x /= currentSprite.untrimmedBoundsData[1].x;
		vector2.y /= currentSprite.untrimmedBoundsData[1].y;
		if (currentSprite.untrimmedBoundsData[1].x * vector2.x < currentSprite.texelSize.x * num && vector2.x < b.x)
		{
			dMin.x = 0f;
			vector2.x = b.x;
		}
		if (currentSprite.untrimmedBoundsData[1].y * vector2.y < currentSprite.texelSize.y * num && vector2.y < b.y)
		{
			dMin.y = 0f;
			vector2.y = b.y;
		}
		Vector2 vector3 = new Vector3(Mathf.Approximately(b.x, 0f) ? 0f : (vector2.x / b.x), Mathf.Approximately(b.y, 0f) ? 0f : (vector2.y / b.y));
		Vector3 vector4 = new Vector3(vector.x * vector3.x, vector.y * vector3.y);
		Vector3 position = dMin + vector - vector4;
		position.z = 0f;
		base.transform.position = base.transform.TransformPoint(position);
		base.scale = new Vector3(_scale.x * vector3.x, _scale.y * vector3.y, _scale.z);
	}
}
