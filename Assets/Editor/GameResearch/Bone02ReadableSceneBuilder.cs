using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;

namespace GameResearch.EditorTools
{
	/// <summary>
	/// Creates a study-only copy of Bone_02 and groups only strictly static visual
	/// root trees. The source scene is never saved or modified by this tool.
	/// </summary>
	internal static class Bone02ReadableSceneBuilder
	{
		private const string SourceScenePath = "Assets/Scenes/Hornet/Bone_02.unity";
		private const string TargetScenePath = "Assets/Scenes/Hornet/Bone_02_Readable.unity";
		private const string ReportPath = "Docs/SceneResearch/Bone_02_Readable.md";
		private const string CanonicalSourceSceneBasePath = "Assets/Editor/GameResearch/__Bone_02_CanonicalValidation.unity";
		private const string ArtRootName = "_00_ART";

		private const string BackgroundGroup = "00_Background";
		private const string MidgroundGroup = "10_Midground";
		private const string ArchitectureGroup = "20_Architecture";
		private const string ForegroundGroup = "30_Foreground";
		private const string FogGroup = "40_Fog_Haze";
		private const string MasksGroup = "50_Masks";

		private static readonly string[] VisualGroupNames =
		{
			BackgroundGroup,
			MidgroundGroup,
			ArchitectureGroup,
			ForegroundGroup,
			FogGroup,
			MasksGroup,
		};

		private static readonly string[] ConservedRootNames =
		{
			"TileMap",
			"TileMap Render Data",
			"_SceneManager",
			"_Managers",
			"Music Control",
			"Black Thread States Thread Only Variant",
			"Rock Roller Scene",
		};

		[MenuItem("Tools/Scene Research/Bone 02/Build Readable Copy", priority = 100)]
		private static void BuildReadableCopyMenu()
		{
			RunMenuAction(
				BuildReadableCopy,
				"Bone_02 readable copy created",
				"Bone_02_Readable.unity was created, organized, saved, reopened, and validated."
			);
		}

		[MenuItem("Tools/Scene Research/Bone 02/Reapply Visual Classification", priority = 101)]
		private static void ReapplyVisualClassificationMenu()
		{
			RunMenuAction(
				ReapplyVisualClassification,
				"Bone_02 visual classification reapplied",
				"The readable copy was reclassified from source-scene evidence, saved, reopened, and validated."
			);
		}

		[MenuItem("Tools/Scene Research/Bone 02/Validate Readable Copy", priority = 102)]
		private static void ValidateReadableCopyMenu()
		{
			RunMenuAction(
				ValidateReadableCopy,
				"Bone_02 readable copy validated",
				"The saved readable scene matches the source scene under the Phase 1 invariants."
			);
		}

		/// <summary>Batch-mode entry point for a closed Unity project.</summary>
		public static void BuildReadableCopyBatch()
		{
			RunBatchAction(BuildReadableCopy);
		}

		/// <summary>Batch-mode entry point for a closed Unity project.</summary>
		public static void ValidateReadableCopyBatch()
		{
			RunBatchAction(ValidateReadableCopy);
		}

		private static void BuildReadableCopy()
		{
			RequireCleanOpenScenes();
			RequireAsset(SourceScenePath);

			if (AssetDatabase.LoadAssetAtPath<SceneAsset>(TargetScenePath) != null || File.Exists(AbsolutePath(TargetScenePath)))
			{
				throw new InvalidOperationException(
					$"Refusing to overwrite existing scene '{TargetScenePath}'. " +
					"Use Validate Readable Copy, or remove the study copy explicitly before rebuilding."
				);
			}

			string sourceHashBefore = ComputeSha256(AbsolutePath(SourceScenePath));
			Scene sourceScene = OpenSceneSafely(SourceScenePath);
			Dictionary<string, CandidateInfo> expectedCandidates = FindCandidates(sourceScene);
			Dictionary<string, CandidateInfo> manualReview = FindManualReview(sourceScene);
			SceneSnapshot sourceSnapshot = CaptureCanonicalSourceSnapshot();

			if (expectedCandidates.Count == 0)
			{
				throw new InvalidOperationException("No strict visual root trees were found; refusing to create an empty organization hierarchy.");
			}

			if (!AssetDatabase.CopyAsset(SourceScenePath, TargetScenePath))
			{
				throw new InvalidOperationException($"AssetDatabase.CopyAsset failed for '{TargetScenePath}'.");
			}

			AssetDatabase.ImportAsset(TargetScenePath, ImportAssetOptions.ForceSynchronousImport);
			ClearAssetBundleMetadata(TargetScenePath);
			Scene targetScene = CanonicalizeSceneAssetToFixedPoint(TargetScenePath);
			Dictionary<string, CandidateInfo> targetCandidates = FindCandidates(targetScene);
			AssertCandidateSetsMatch(expectedCandidates, targetCandidates);

			Dictionary<string, Transform> groupTransforms = CreateVisualHierarchy(targetScene);
			MoveCandidates(targetScene, targetCandidates, groupTransforms);

			SceneSnapshot inMemoryTarget = CaptureScene(targetScene);
			ValidationResult inMemoryValidation = ValidateSnapshots(sourceSnapshot, inMemoryTarget, expectedCandidates);
			inMemoryValidation.ThrowIfFailed("in-memory validation before save");

			if (!EditorSceneManager.SaveScene(targetScene, TargetScenePath, saveAsCopy: false))
			{
				throw new InvalidOperationException($"Unity failed to save '{TargetScenePath}'.");
			}

			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

			string sourceHashAfter = ComputeSha256(AbsolutePath(SourceScenePath));
			if (!string.Equals(sourceHashBefore, sourceHashAfter, StringComparison.Ordinal))
			{
				throw new InvalidOperationException("The source Bone_02.unity hash changed while building the readable copy.");
			}

			Scene persistedTargetScene = OpenSceneSafely(TargetScenePath);
			SceneSnapshot persistedTarget = CaptureScene(persistedTargetScene);
			ValidationResult persistedValidation = ValidateSnapshots(sourceSnapshot, persistedTarget, expectedCandidates);
			persistedValidation.ThrowIfFailed("persisted validation after reopen");

			WriteReport(sourceSnapshot, persistedTarget, expectedCandidates, manualReview, persistedValidation, sourceHashBefore);
			AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);

			Selection.activeObject = AssetDatabase.LoadAssetAtPath<SceneAsset>(TargetScenePath);
			EditorGUIUtility.PingObject(Selection.activeObject);
			Debug.Log(
				$"[Bone02Readable] PASS: moved {expectedCandidates.Count} strict visual roots, " +
				$"root count {sourceSnapshot.RootCount} -> {persistedTarget.RootCount}, " +
				$"GameObjects {sourceSnapshot.Objects.Count} -> {persistedTarget.Objects.Count}. " +
				$"Report: {ReportPath}"
			);
		}

		private static void ValidateReadableCopy()
		{
			using (EditorErrorCapture operationErrors = new EditorErrorCapture())
			{
				RequireCleanOpenScenes();
				RequireAsset(SourceScenePath);
				RequireAsset(TargetScenePath);

				string sourceHash = ComputeSha256(AbsolutePath(SourceScenePath));
				Scene sourceScene = OpenSceneSafely(SourceScenePath);
				Dictionary<string, CandidateInfo> expectedCandidates = FindCandidates(sourceScene);
				Dictionary<string, CandidateInfo> manualReview = FindManualReview(sourceScene);
				SceneSnapshot sourceSnapshot = CaptureCanonicalSourceSnapshot();

				Scene targetScene = OpenSceneSafely(TargetScenePath);
				SceneSnapshot targetSnapshot = CaptureScene(targetScene);
				ValidationResult validation = ValidateSnapshots(sourceSnapshot, targetSnapshot, expectedCandidates);
				validation.ThrowIfFailed("independent persisted validation");
				operationErrors.ThrowIfAny();

				WriteReport(sourceSnapshot, targetSnapshot, expectedCandidates, manualReview, validation, sourceHash);
				AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
				operationErrors.ThrowIfAny();
				Debug.Log($"[Bone02Readable] PASS: independent validation succeeded. Report: {ReportPath}");
			}
		}

		private static void ReapplyVisualClassification()
		{
			RequireCleanOpenScenes();
			RequireAsset(SourceScenePath);
			RequireAsset(TargetScenePath);

			byte[] targetBackup = File.ReadAllBytes(AbsolutePath(TargetScenePath));
			bool targetMutationStarted = false;
			using (EditorErrorCapture operationErrors = new EditorErrorCapture())
			{
				try
				{
					string sourceHashBefore = ComputeSha256(AbsolutePath(SourceScenePath));
					Scene sourceScene = OpenSceneSafely(SourceScenePath);
					Dictionary<string, CandidateInfo> expectedCandidates = FindCandidates(sourceScene);
					Dictionary<string, CandidateInfo> manualReview = FindManualReview(sourceScene);
					SceneSnapshot sourceSnapshot = CaptureCanonicalSourceSnapshot();

					ClearAssetBundleMetadata(TargetScenePath);
					Scene targetScene = OpenSceneSafely(TargetScenePath);
					Dictionary<string, Transform> groupTransforms = FindExistingVisualHierarchy(targetScene);
					targetMutationStarted = true;
					MoveCandidates(targetScene, expectedCandidates, groupTransforms);

					SceneSnapshot inMemoryTarget = CaptureScene(targetScene);
					ValidationResult inMemoryValidation = ValidateSnapshots(sourceSnapshot, inMemoryTarget, expectedCandidates);
					inMemoryValidation.ThrowIfFailed("in-memory validation after reclassification");

					if (!EditorSceneManager.SaveScene(targetScene, TargetScenePath, saveAsCopy: false))
					{
						throw new InvalidOperationException($"Unity failed to save '{TargetScenePath}'.");
					}
					AssetDatabase.ImportAsset(TargetScenePath, ImportAssetOptions.ForceSynchronousImport);

					string sourceHashAfter = ComputeSha256(AbsolutePath(SourceScenePath));
					if (!string.Equals(sourceHashBefore, sourceHashAfter, StringComparison.Ordinal))
					{
						throw new InvalidOperationException("The source Bone_02.unity hash changed while reclassifying the readable copy.");
					}

					Scene persistedTargetScene = OpenSceneSafely(TargetScenePath);
					SceneSnapshot persistedTarget = CaptureScene(persistedTargetScene);
					ValidationResult persistedValidation = ValidateSnapshots(sourceSnapshot, persistedTarget, expectedCandidates);
					persistedValidation.ThrowIfFailed("persisted validation after reclassification");

					operationErrors.ThrowIfAny();
					WriteReport(sourceSnapshot, persistedTarget, expectedCandidates, manualReview, persistedValidation, sourceHashBefore);
					AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
					operationErrors.ThrowIfAny();
					Debug.Log($"[Bone02Readable] PASS: visual classification reapplied and validated. Report: {ReportPath}");
				}
				catch (Exception originalException)
				{
					if (targetMutationStarted)
					{
						try
						{
							RestoreTargetSceneBytes(targetBackup);
						}
						catch (Exception restoreException)
						{
							throw new AggregateException(
								"Reclassification failed and the readable scene backup could not be restored cleanly.",
								originalException,
								restoreException
							);
						}
					}
					throw;
				}
			}
		}

		private static Dictionary<string, Transform> CreateVisualHierarchy(Scene scene)
		{
			if (scene.GetRootGameObjects().Any(root => root.name == ArtRootName))
			{
				throw new InvalidOperationException($"The target scene already contains a root named '{ArtRootName}'.");
			}

			GameObject artRoot = CreateOrganizer(ArtRootName, null, scene);
			Dictionary<string, Transform> result = new Dictionary<string, Transform>(StringComparer.Ordinal);
			foreach (string groupName in VisualGroupNames)
			{
				GameObject group = CreateOrganizer(groupName, artRoot.transform, scene);
				result.Add(groupName, group.transform);
			}

			return result;
		}

		private static Dictionary<string, Transform> FindExistingVisualHierarchy(Scene scene)
		{
			GameObject artRoot = scene.GetRootGameObjects().SingleOrDefault(root => root.name == ArtRootName);
			if (artRoot == null)
			{
				throw new InvalidOperationException($"The target scene does not contain the expected root '{ArtRootName}'.");
			}

			Dictionary<string, Transform> result = new Dictionary<string, Transform>(StringComparer.Ordinal);
			foreach (string groupName in VisualGroupNames)
			{
				List<Transform> matches = Enumerable.Range(0, artRoot.transform.childCount)
					.Select(index => artRoot.transform.GetChild(index))
					.Where(child => child.name == groupName)
					.ToList();
				if (matches.Count != 1)
				{
					throw new InvalidOperationException(
						$"Expected exactly one '{ArtRootName}/{groupName}' organizer, found {matches.Count}."
					);
				}
				result.Add(groupName, matches[0]);
			}

			return result;
		}

		private static GameObject CreateOrganizer(string name, Transform parent, Scene scene)
		{
			GameObject organizer = new GameObject(name);
			if (organizer.scene != scene)
			{
				SceneManager.MoveGameObjectToScene(organizer, scene);
			}
			organizer.transform.SetParent(parent, worldPositionStays: false);
			organizer.transform.localPosition = Vector3.zero;
			organizer.transform.localRotation = Quaternion.identity;
			organizer.transform.localScale = Vector3.one;
			organizer.layer = 0;
			organizer.tag = "Untagged";
			organizer.SetActive(true);
			GameObjectUtility.SetStaticEditorFlags(organizer, 0);
			return organizer;
		}

		private static void MoveCandidates(
			Scene scene,
			IReadOnlyDictionary<string, CandidateInfo> candidates,
			IReadOnlyDictionary<string, Transform> groupTransforms)
		{
			Dictionary<string, GameObject> objectsById = GetAllGameObjects(scene)
				.ToDictionary(GetLocalId, gameObject => gameObject, StringComparer.Ordinal);

			foreach (IGrouping<string, CandidateInfo> group in candidates.Values
				.OrderBy(candidate => candidate.OriginalSiblingIndex)
				.GroupBy(candidate => candidate.GroupName))
			{
				Transform parent = groupTransforms[group.Key];
				foreach (CandidateInfo candidate in group.OrderBy(item => item.OriginalSiblingIndex))
				{
					if (!objectsById.TryGetValue(candidate.LocalId, out GameObject gameObject))
					{
						throw new InvalidOperationException($"Could not find copied candidate localID {candidate.LocalId} ({candidate.OriginalPath}).");
					}

					// Organizer transforms are guaranteed identity. Keeping the candidate's
					// local TRS avoids Unity's world-matrix decomposition round trip, which
					// otherwise introduces measurable drift in deep scaled sprite trees.
					gameObject.transform.SetParent(parent, worldPositionStays: false);
					gameObject.transform.SetAsLastSibling();
				}
			}

			EditorSceneManager.MarkSceneDirty(scene);
		}

		private static Dictionary<string, CandidateInfo> FindCandidates(Scene scene)
		{
			Dictionary<string, CandidateInfo> result = new Dictionary<string, CandidateInfo>(StringComparer.Ordinal);
			HashSet<string> referencedSceneObjectIds = FindSerializedSceneReferenceIds(scene);
			foreach (GameObject root in scene.GetRootGameObjects().OrderBy(item => item.transform.GetSiblingIndex()))
			{
				if (!IsStrictStaticVisualTree(root) ||
					RequiresManualReview(root) ||
					TreeContainsReferencedObject(root, referencedSceneObjectIds))
				{
					continue;
				}

				string localId = GetLocalId(root);
				result.Add(localId, new CandidateInfo
				{
					LocalId = localId,
					OriginalPath = GetHierarchyPath(root.transform),
					OriginalSiblingIndex = root.transform.GetSiblingIndex(),
					ObjectCount = root.GetComponentsInChildren<Transform>(includeInactive: true).Length,
					GroupName = ClassifyVisualRoot(root),
				});
			}

			return result;
		}

		private static HashSet<string> FindSerializedSceneReferenceIds(Scene scene)
		{
			HashSet<string> result = new HashSet<string>(StringComparer.Ordinal);
			foreach (GameObject gameObject in GetAllGameObjects(scene))
			{
				foreach (Component component in gameObject.GetComponents<Component>())
				{
					if (component == null || component is Transform)
					{
						continue;
					}

					SerializedObject serializedObject = new SerializedObject(component);
					SerializedProperty property = serializedObject.GetIterator();
					while (property.Next(enterChildren: true))
					{
						if (property.propertyType != SerializedPropertyType.ObjectReference ||
							property.propertyPath == "m_GameObject" ||
							property.objectReferenceValue == null)
						{
							continue;
						}

						Object referencedObject = property.objectReferenceValue;
						GameObject referencedGameObject = referencedObject as GameObject;
						if (referencedGameObject == null && referencedObject is Component referencedComponent)
						{
							referencedGameObject = referencedComponent.gameObject;
						}
						if (referencedGameObject == null || referencedGameObject.scene != scene)
						{
							continue;
						}

						GlobalObjectId referenceId = GlobalObjectId.GetGlobalObjectIdSlow(referencedObject);
						result.Add(referenceId.targetObjectId.ToString(CultureInfo.InvariantCulture));
					}
				}
			}
			return result;
		}

		private static bool TreeContainsReferencedObject(GameObject root, IReadOnlyCollection<string> referencedIds)
		{
			foreach (Transform transform in root.GetComponentsInChildren<Transform>(includeInactive: true))
			{
				foreach (Component component in transform.GetComponents<Component>())
				{
					if (component != null && referencedIds.Contains(GetLocalId(component)))
					{
						return true;
					}
				}
				if (referencedIds.Contains(GetLocalId(transform.gameObject)))
				{
					return true;
				}
			}
			return false;
		}

		private static Dictionary<string, CandidateInfo> FindManualReview(Scene scene)
		{
			Dictionary<string, CandidateInfo> result = new Dictionary<string, CandidateInfo>(StringComparer.Ordinal);
			foreach (GameObject root in scene.GetRootGameObjects().OrderBy(item => item.transform.GetSiblingIndex()))
			{
				if (!IsStrictStaticVisualTree(root) || !RequiresManualReview(root))
				{
					continue;
				}

				string localId = GetLocalId(root);
				result.Add(localId, new CandidateInfo
				{
					LocalId = localId,
					OriginalPath = GetHierarchyPath(root.transform),
					OriginalSiblingIndex = root.transform.GetSiblingIndex(),
					ObjectCount = root.GetComponentsInChildren<Transform>(includeInactive: true).Length,
					GroupName = "ManualReview",
					ReviewReason = GetManualReviewReason(root),
				});
			}

			return result;
		}

		private static bool RequiresManualReview(GameObject root)
		{
			string lowerName = root.name.ToLowerInvariant();
			return (lowerName.Contains("cairn_medium") && root.layer == 19) ||
				(lowerName.Contains("char_grass_sil") && root.layer == 21) ||
				lowerName == "vignette cutout" ||
				lowerName.Contains("boneforest_breakables_");
		}

		private static string GetManualReviewReason(GameObject root)
		{
			string lowerName = root.name.ToLowerInvariant();
			if (lowerName.Contains("cairn_medium") && root.layer == 19)
			{
				return "Layer 19 (Interactive Object)";
			}
			if (lowerName.Contains("char_grass_sil") && root.layer == 21)
			{
				return "Layer 21 (Grass)";
			}
			if (lowerName == "vignette cutout")
			{
				return "Vignette/Over-layer scene presentation object";
			}
			return "Name suggests a state-dependent breakable visual";
		}

		private static bool IsStrictStaticVisualTree(GameObject root)
		{
			if (root == null || root.transform.parent != null || root.name == ArtRootName)
			{
				return false;
			}

			bool foundSpriteRenderer = false;
			foreach (Transform transform in root.GetComponentsInChildren<Transform>(includeInactive: true))
			{
				if (transform.gameObject.tag != "Untagged")
				{
					return false;
				}

				Component[] components = transform.GetComponents<Component>();
				foreach (Component component in components)
				{
					if (component == null)
					{
						return false;
					}

					Type type = component.GetType();
					if (type == typeof(Transform))
					{
						continue;
					}

					if (type == typeof(SpriteRenderer))
					{
						foundSpriteRenderer = true;
						continue;
					}

					return false;
				}
			}

			return foundSpriteRenderer;
		}

		private static string ClassifyVisualRoot(GameObject root)
		{
			string rootName = root.name.ToLowerInvariant();
			SpriteRenderer[] renderers = root.GetComponentsInChildren<SpriteRenderer>(includeInactive: true);

			// Existing compound wrappers carry stronger semantics than any one child
			// sprite. These rules prevent a minority black-fader/mask sprite from
			// classifying an entire architectural or foreground assembly as a mask.
			if (renderers.Length > 1)
			{
				if (rootName == "group" || rootName.StartsWith("group (", StringComparison.Ordinal))
				{
					return FogGroup;
				}
				if (rootName.StartsWith("sc arch set", StringComparison.Ordinal) ||
					rootName == "bonechurch_01_floor_02 (2)")
				{
					return ArchitectureGroup;
				}
				if (ContainsAny(rootName, "foreground", "_fg", "front_piece", "bone_sil", "bone_bush", "char_grass_sil"))
				{
					return ForegroundGroup;
				}
				if (ContainsAny(rootName, "midground", "mid_wall", "mid_plat"))
				{
					return MidgroundGroup;
				}
			}

			StringBuilder searchable = new StringBuilder(rootName);
			foreach (SpriteRenderer renderer in renderers)
			{
				if (renderer.sprite != null)
				{
					searchable.Append(' ').Append(renderer.sprite.name.ToLowerInvariant());
				}
			}

			string text = searchable.ToString();
			if (ContainsAny(text, "mask", "fader", "black_solid", "vignette", "cutout"))
			{
				return MasksGroup;
			}

			if (ContainsAny(text, "fog", "haze", "mist", "smoke", "blur"))
			{
				return FogGroup;
			}

			if (ContainsAny(text, "foreground", " fg", "_fg", "front_piece", "bone_sil", "bone_bush", "char_grass_sil"))
			{
				return ForegroundGroup;
			}

			if (ContainsAny(text, "midground", "mid_wall", "mid_plat"))
			{
				return MidgroundGroup;
			}

			if (ContainsAny(text, "background", "backdrop", " bg", "_bg", "bone_bg", "bg_", "statue", "collapse_chunk"))
			{
				return BackgroundGroup;
			}

			if (text.Contains("deep"))
			{
				float worldZ = root.transform.position.z;
				if (worldZ < -2f)
				{
					return ForegroundGroup;
				}
				if (worldZ >= 20f)
				{
					return BackgroundGroup;
				}
				if (worldZ >= 2f)
				{
					return MidgroundGroup;
				}
			}

			return ArchitectureGroup;
		}

		private static bool ContainsAny(string value, params string[] tokens)
		{
			return tokens.Any(token => value.IndexOf(token, StringComparison.Ordinal) >= 0);
		}

		private static SceneSnapshot CaptureScene(Scene scene)
		{
			if (!scene.IsValid() || !scene.isLoaded)
			{
				throw new InvalidOperationException("Cannot capture an invalid or unloaded scene.");
			}

			SceneSnapshot snapshot = new SceneSnapshot
			{
				ScenePath = scene.path,
				RootCount = scene.rootCount,
				EnvironmentSignature = CaptureEnvironmentSignature(),
			};

			foreach (GameObject gameObject in GetAllGameObjects(scene))
			{
				ObjectSnapshot objectSnapshot = CaptureObject(gameObject);
				if (snapshot.Objects.ContainsKey(objectSnapshot.LocalId))
				{
					throw new InvalidOperationException($"Duplicate scene localID {objectSnapshot.LocalId} while capturing {scene.path}.");
				}

				snapshot.Objects.Add(objectSnapshot.LocalId, objectSnapshot);

				foreach (Component component in gameObject.GetComponents<Component>())
				{
					string typeName = component == null ? "<Missing Script>" : component.GetType().FullName;
					snapshot.ComponentCounts.TryGetValue(typeName, out int count);
					snapshot.ComponentCounts[typeName] = count + 1;
					if (component == null)
					{
						snapshot.MissingScriptCount++;
					}
				}
			}

			return snapshot;
		}

		private static string CaptureEnvironmentSignature()
		{
			StringBuilder result = new StringBuilder();
			AppendHashToken(result, RenderSettings.fog ? "true" : "false");
			AppendHashToken(result, FormatColor(RenderSettings.fogColor));
			AppendHashToken(result, ((int)RenderSettings.fogMode).ToString(CultureInfo.InvariantCulture));
			AppendHashToken(result, FormatFloat(RenderSettings.fogDensity));
			AppendHashToken(result, FormatFloat(RenderSettings.fogStartDistance));
			AppendHashToken(result, FormatFloat(RenderSettings.fogEndDistance));
			AppendHashToken(result, FormatColor(RenderSettings.ambientSkyColor));
			AppendHashToken(result, FormatColor(RenderSettings.ambientEquatorColor));
			AppendHashToken(result, FormatColor(RenderSettings.ambientGroundColor));
			AppendHashToken(result, FormatFloat(RenderSettings.ambientIntensity));
			AppendHashToken(result, ((int)RenderSettings.ambientMode).ToString(CultureInfo.InvariantCulture));
			AppendHashToken(result, FormatColor(RenderSettings.subtractiveShadowColor));
			AppendHashToken(result, NormalizeObjectReference(RenderSettings.skybox));
			AppendHashToken(result, FormatFloat(RenderSettings.haloStrength));
			AppendHashToken(result, FormatFloat(RenderSettings.flareStrength));
			AppendHashToken(result, FormatFloat(RenderSettings.flareFadeSpeed));
			AppendHashToken(result, NormalizeObjectReference(RenderSettings.customReflectionTexture));
			AppendHashToken(result, ((int)RenderSettings.defaultReflectionMode).ToString(CultureInfo.InvariantCulture));
			AppendHashToken(result, RenderSettings.defaultReflectionResolution.ToString(CultureInfo.InvariantCulture));
			AppendHashToken(result, RenderSettings.reflectionBounces.ToString(CultureInfo.InvariantCulture));
			AppendHashToken(result, FormatFloat(RenderSettings.reflectionIntensity));
			AppendHashToken(result, NormalizeObjectReference(RenderSettings.sun));
			AppendHashToken(result, ((int)LightmapSettings.lightmapsMode).ToString(CultureInfo.InvariantCulture));
			AppendHashToken(result, NormalizeObjectReference(LightmapSettings.lightProbes));
			PropertyInfo lightingDataAssetProperty = typeof(Lightmapping).GetProperty(
				"lightingDataAsset",
				BindingFlags.Public | BindingFlags.Static
			);
			AppendHashToken(result, NormalizeObjectReference(lightingDataAssetProperty?.GetValue(null) as Object));
			AppendHashToken(result, NormalizeObjectReference(Lightmapping.lightingSettings));
			foreach (LightmapData lightmap in LightmapSettings.lightmaps)
			{
				AppendHashToken(result, NormalizeObjectReference(lightmap.lightmapColor));
				AppendHashToken(result, NormalizeObjectReference(lightmap.lightmapDir));
				AppendHashToken(result, NormalizeObjectReference(lightmap.shadowMask));
			}
			return ComputeTextSha256(result.ToString());
		}

		private static ObjectSnapshot CaptureObject(GameObject gameObject)
		{
			Transform transform = gameObject.transform;
			Component[] components = gameObject.GetComponents<Component>();
			return new ObjectSnapshot
			{
				LocalId = GetLocalId(gameObject),
				Name = gameObject.name,
				Path = GetHierarchyPath(transform),
				ParentLocalId = transform.parent == null ? string.Empty : GetLocalId(transform.parent.gameObject),
				ChildLocalIds = Enumerable.Range(0, transform.childCount)
					.Select(index => GetLocalId(transform.GetChild(index).gameObject))
					.ToArray(),
				ActiveSelf = gameObject.activeSelf,
				Layer = gameObject.layer,
				Tag = gameObject.tag,
				StaticFlags = (int)GameObjectUtility.GetStaticEditorFlags(gameObject),
				LocalPosition = transform.localPosition,
				LocalRotation = transform.localRotation,
				LocalScale = transform.localScale,
				LocalToWorld = transform.localToWorldMatrix,
				ComponentSignature = string.Join(",", components.Select(component => component == null ? "<Missing Script>" : component.GetType().FullName)),
				SerializedDataCanonical = CaptureSerializedDataCanonical(components),
				ObjectReferenceSignature = CaptureObjectReferenceSignature(components),
				SpriteRendererSignature = CaptureSpriteRendererSignature(gameObject),
			};
		}

		private static string CaptureSerializedDataCanonical(IEnumerable<Component> components)
		{
			StringBuilder data = new StringBuilder();
			int componentIndex = 0;
			foreach (Component component in components)
			{
				if (component == null || component is Transform)
				{
					componentIndex++;
					continue;
				}

				AppendHashToken(data, componentIndex.ToString(CultureInfo.InvariantCulture));
				AppendHashToken(data, component.GetType().FullName);
				SerializedObject serializedObject = new SerializedObject(component);
				serializedObject.UpdateIfRequiredOrScript();
				SerializedProperty property = serializedObject.GetIterator();
				while (property.Next(enterChildren: true))
				{
					if (IsTransientObjectReferenceChild(property.propertyPath))
					{
						continue;
					}
					AppendHashToken(data, property.propertyPath);
					AppendHashToken(data, property.propertyType.ToString());
					AppendHashToken(data, FormatSerializedProperty(property));
				}

				componentIndex++;
			}

			return data.ToString();
		}

		private static bool IsTransientObjectReferenceChild(string propertyPath)
		{
			// Unity 6 exposes an internal instance-id child beneath some PPtr
			// properties (for example m_GameObject.m_FileID). It is process-local and
			// differs between two otherwise identical loaded scenes. The parent PPtr is
			// still hashed through NormalizeObjectReference and independently audited.
			return propertyPath.EndsWith(".m_FileID", StringComparison.Ordinal) ||
				propertyPath.EndsWith(".m_PathID", StringComparison.Ordinal);
		}

		private static string FormatSerializedProperty(SerializedProperty property)
		{
			switch (property.propertyType)
			{
				case SerializedPropertyType.Generic:
					return property.isArray
						? $"array:{property.arraySize.ToString(CultureInfo.InvariantCulture)}:{property.type}"
						: $"generic:{property.type}";
				case SerializedPropertyType.Integer:
					return property.longValue.ToString(CultureInfo.InvariantCulture);
				case SerializedPropertyType.Boolean:
					return property.boolValue ? "true" : "false";
				case SerializedPropertyType.Float:
					return property.doubleValue.ToString("R", CultureInfo.InvariantCulture);
				case SerializedPropertyType.String:
					return property.stringValue ?? string.Empty;
				case SerializedPropertyType.Color:
					return FormatColor(property.colorValue);
				case SerializedPropertyType.ObjectReference:
					return NormalizeObjectReference(property.objectReferenceValue);
				case SerializedPropertyType.LayerMask:
				case SerializedPropertyType.Enum:
				case SerializedPropertyType.ArraySize:
				case SerializedPropertyType.Character:
					return property.intValue.ToString(CultureInfo.InvariantCulture);
				case SerializedPropertyType.Vector2:
					return FormatVector2(property.vector2Value);
				case SerializedPropertyType.Vector3:
					return FormatVector3(property.vector3Value);
				case SerializedPropertyType.Vector4:
					return FormatVector4(property.vector4Value);
				case SerializedPropertyType.Rect:
					return FormatRect(property.rectValue);
				case SerializedPropertyType.AnimationCurve:
					return FormatAnimationCurve(property.animationCurveValue);
				case SerializedPropertyType.Bounds:
					return FormatBounds(property.boundsValue);
				case SerializedPropertyType.Quaternion:
					return FormatQuaternion(property.quaternionValue);
				case SerializedPropertyType.ExposedReference:
					return NormalizeObjectReference(property.exposedReferenceValue);
				case SerializedPropertyType.FixedBufferSize:
					return property.fixedBufferSize.ToString(CultureInfo.InvariantCulture);
				case SerializedPropertyType.Vector2Int:
					return FormatVector2Int(property.vector2IntValue);
				case SerializedPropertyType.Vector3Int:
					return FormatVector3Int(property.vector3IntValue);
				case SerializedPropertyType.RectInt:
					return FormatRectInt(property.rectIntValue);
				case SerializedPropertyType.BoundsInt:
					return FormatBoundsInt(property.boundsIntValue);
				case SerializedPropertyType.ManagedReference:
					return $"{property.managedReferenceFullTypename}:{property.managedReferenceId.ToString(CultureInfo.InvariantCulture)}";
				case SerializedPropertyType.Hash128:
					return property.hash128Value.ToString();
				default:
					try
					{
						return FormatBoxedValue(property.boxedValue);
					}
					catch (Exception)
					{
						return $"unsupported:{property.type}";
					}
			}
		}

		private static void AppendHashToken(StringBuilder builder, string value)
		{
			value = value ?? string.Empty;
			builder.Append(value.Length.ToString(CultureInfo.InvariantCulture))
				.Append(':')
				.Append(value)
				.Append('|');
		}

		private static string ComputeTextSha256(string value)
		{
			using (SHA256 sha256 = SHA256.Create())
			{
				byte[] bytes = Encoding.UTF8.GetBytes(value);
				return BitConverter.ToString(sha256.ComputeHash(bytes)).Replace("-", string.Empty).ToLowerInvariant();
			}
		}

		private static string DescribeFirstTokenDifference(string before, string after)
		{
			List<string> beforeTokens = DecodeHashTokens(before);
			List<string> afterTokens = DecodeHashTokens(after);
			int sharedCount = Math.Min(beforeTokens.Count, afterTokens.Count);
			for (int index = 0; index < sharedCount; index++)
			{
				if (string.Equals(beforeTokens[index], afterTokens[index], StringComparison.Ordinal))
				{
					continue;
				}

				string context = index >= 2 ? beforeTokens[index - 2] : "<start>";
				return $"First token difference at {index.ToString(CultureInfo.InvariantCulture)} near '{context}': " +
					$"'{beforeTokens[index]}' -> '{afterTokens[index]}'.";
			}

			return $"Token count changed: {beforeTokens.Count.ToString(CultureInfo.InvariantCulture)} -> " +
				$"{afterTokens.Count.ToString(CultureInfo.InvariantCulture)}.";
		}

		private static List<string> DecodeHashTokens(string encoded)
		{
			List<string> result = new List<string>();
			int cursor = 0;
			while (cursor < encoded.Length)
			{
				int colon = encoded.IndexOf(':', cursor);
				if (colon < 0 || !int.TryParse(encoded.Substring(cursor, colon - cursor), NumberStyles.None, CultureInfo.InvariantCulture, out int length))
				{
					throw new FormatException("Invalid serialized-data token stream.");
				}

				int valueStart = colon + 1;
				if (length < 0 || valueStart + length >= encoded.Length || encoded[valueStart + length] != '|')
				{
					throw new FormatException("Invalid serialized-data token length.");
				}

				result.Add(encoded.Substring(valueStart, length));
				cursor = valueStart + length + 1;
			}
			return result;
		}

		private static string FormatBoxedValue(object value)
		{
			if (value == null)
			{
				return "null";
			}
			if (value is Gradient gradient)
			{
				StringBuilder result = new StringBuilder($"mode:{(int)gradient.mode};");
				foreach (GradientColorKey key in gradient.colorKeys)
				{
					result.Append("c:").Append(FormatFloat(key.time)).Append(':').Append(FormatColor(key.color)).Append(';');
				}
				foreach (GradientAlphaKey key in gradient.alphaKeys)
				{
					result.Append("a:").Append(FormatFloat(key.time)).Append(':').Append(FormatFloat(key.alpha)).Append(';');
				}
				return result.ToString();
			}
			if (value is IFormattable formattable)
			{
				return formattable.ToString(null, CultureInfo.InvariantCulture);
			}
			return value.ToString();
		}

		private static string CaptureObjectReferenceSignature(IEnumerable<Component> components)
		{
			StringBuilder result = new StringBuilder();
			int componentIndex = 0;
			foreach (Component component in components)
			{
				if (component == null || component is Transform)
				{
					componentIndex++;
					continue;
				}

				try
				{
					SerializedObject serializedObject = new SerializedObject(component);
					SerializedProperty property = serializedObject.GetIterator();
					while (property.Next(enterChildren: true))
					{
						if (property.propertyType != SerializedPropertyType.ObjectReference)
						{
							continue;
						}

						result.Append(componentIndex)
							.Append(':')
							.Append(property.propertyPath)
							.Append('=')
							.Append(NormalizeObjectReference(property.objectReferenceValue))
							.Append(';');
					}
				}
				catch (Exception exception)
				{
					result.Append(componentIndex)
						.Append(":<serialization-error>=")
						.Append(exception.GetType().FullName)
						.Append(';');
				}

				componentIndex++;
			}

			return result.ToString();
		}

		private static string CaptureSpriteRendererSignature(GameObject gameObject)
		{
			StringBuilder result = new StringBuilder();
			foreach (SpriteRenderer renderer in gameObject.GetComponents<SpriteRenderer>())
			{
				result.Append("enabled=").Append(renderer.enabled)
					.Append(";sprite=").Append(NormalizeObjectReference(renderer.sprite))
					.Append(";sortingLayer=").Append(renderer.sortingLayerID)
					.Append(";sortingOrder=").Append(renderer.sortingOrder)
					.Append(";color=").Append(FormatColor(renderer.color))
					.Append(";flipX=").Append(renderer.flipX)
					.Append(";flipY=").Append(renderer.flipY)
					.Append(";drawMode=").Append((int)renderer.drawMode)
					.Append(";size=").Append(FormatVector2(renderer.size))
					.Append(";maskInteraction=").Append((int)renderer.maskInteraction)
					.Append(";spriteSortPoint=").Append((int)renderer.spriteSortPoint)
					.Append(";materials=");
				foreach (Material material in renderer.sharedMaterials)
				{
					result.Append(NormalizeObjectReference(material)).Append(',');
				}
				result.Append('|');
			}

			return result.ToString();
		}

		private static string NormalizeObjectReference(Object value)
		{
			if (value == null)
			{
				return "null";
			}

			GlobalObjectId globalId = GlobalObjectId.GetGlobalObjectIdSlow(value);
			GameObject referencedGameObject = value as GameObject;
			if (referencedGameObject == null && value is Component component)
			{
				referencedGameObject = component.gameObject;
			}

			if (referencedGameObject != null && referencedGameObject.scene.IsValid())
			{
				return $"scene:{globalId.targetObjectId.ToString(CultureInfo.InvariantCulture)}:{value.GetType().FullName}";
			}

			return $"asset:{globalId.assetGUID}:{globalId.targetObjectId.ToString(CultureInfo.InvariantCulture)}:{value.GetType().FullName}";
		}

		private static ValidationResult ValidateSnapshots(
			SceneSnapshot source,
			SceneSnapshot target,
			IReadOnlyDictionary<string, CandidateInfo> expectedCandidates)
		{
			ValidationResult result = new ValidationResult();
			int organizerCount = 1 + VisualGroupNames.Length;
			result.Check(
				target.Objects.Count == source.Objects.Count + organizerCount,
				$"GameObject count: expected {source.Objects.Count + organizerCount}, got {target.Objects.Count}."
			);
			result.Check(
				target.RootCount == source.RootCount - expectedCandidates.Count + 1,
				$"Root count: expected {source.RootCount - expectedCandidates.Count + 1}, got {target.RootCount}."
			);
			result.Check(
				target.MissingScriptCount == source.MissingScriptCount,
				$"Missing script count changed: {source.MissingScriptCount} -> {target.MissingScriptCount}."
			);
			result.Check(
				target.EnvironmentSignature == source.EnvironmentSignature,
				"Scene RenderSettings/LightmapSettings signature changed."
			);

			HashSet<string> componentTypes = new HashSet<string>(source.ComponentCounts.Keys, StringComparer.Ordinal);
			componentTypes.UnionWith(target.ComponentCounts.Keys);
			foreach (string typeName in componentTypes.OrderBy(value => value, StringComparer.Ordinal))
			{
				source.ComponentCounts.TryGetValue(typeName, out int sourceCount);
				target.ComponentCounts.TryGetValue(typeName, out int targetCount);
				int expectedCount = typeName == typeof(Transform).FullName ? sourceCount + organizerCount : sourceCount;
				result.Check(targetCount == expectedCount, $"Component count changed for {typeName}: expected {expectedCount}, got {targetCount}.");
			}

			foreach (KeyValuePair<string, ObjectSnapshot> pair in source.Objects)
			{
				string localId = pair.Key;
				ObjectSnapshot before = pair.Value;
				if (!target.Objects.TryGetValue(localId, out ObjectSnapshot after))
				{
					result.Errors.Add($"Original object missing in target: {before.Path} (localID {localId}).");
					continue;
				}

				string label = $"{before.Path} (localID {localId})";
				result.Check(before.Name == after.Name, $"Name changed for {label}: '{before.Name}' -> '{after.Name}'.");
				result.Check(before.ActiveSelf == after.ActiveSelf, $"activeSelf changed for {label}.");
				result.Check(before.Layer == after.Layer, $"Layer changed for {label}: {before.Layer} -> {after.Layer}.");
				result.Check(before.Tag == after.Tag, $"Tag changed for {label}: {before.Tag} -> {after.Tag}.");
				result.Check(before.StaticFlags == after.StaticFlags, $"Static flags changed for {label}.");
				result.Check(before.ComponentSignature == after.ComponentSignature, $"Component list/order changed for {label}.");
				result.Check(
					ComputeTextSha256(before.SerializedDataCanonical) == ComputeTextSha256(after.SerializedDataCanonical),
					$"Serialized component data changed for {label}. {DescribeFirstTokenDifference(before.SerializedDataCanonical, after.SerializedDataCanonical)}"
				);
				result.Check(before.ObjectReferenceSignature == after.ObjectReferenceSignature, $"Serialized object references changed for {label}.");
				result.Check(before.SpriteRendererSignature == after.SpriteRendererSignature, $"SpriteRenderer settings changed for {label}.");
				result.Check(before.ChildLocalIds.SequenceEqual(after.ChildLocalIds), $"Direct child list/order changed for {label}.");
				result.Check(NearlyEqual(before.LocalPosition, after.LocalPosition), $"Local position changed for {label}.");
				result.Check(NearlyEqual(before.LocalRotation, after.LocalRotation), $"Local rotation changed for {label}.");
				result.Check(NearlyEqual(before.LocalScale, after.LocalScale), $"Local scale changed for {label}.");
				result.Check(NearlyEqual(before.LocalToWorld, after.LocalToWorld), $"World matrix changed for {label}.");

				if (expectedCandidates.TryGetValue(localId, out CandidateInfo candidate))
				{
					result.Check(
						target.Objects.TryGetValue(after.ParentLocalId, out ObjectSnapshot group) &&
						group.Name == candidate.GroupName &&
						target.Objects.TryGetValue(group.ParentLocalId, out ObjectSnapshot artRoot) &&
						artRoot.Name == ArtRootName,
						$"Moved root {label} is not under {ArtRootName}/{candidate.GroupName}."
					);
				}
				else
				{
					result.Check(before.ParentLocalId == after.ParentLocalId, $"Unexpected parent change for {label}.");
				}
			}

			List<ObjectSnapshot> extras = target.Objects.Values
				.Where(item => !source.Objects.ContainsKey(item.LocalId))
				.ToList();
			result.Check(extras.Count == organizerCount, $"Expected {organizerCount} organizer objects, found {extras.Count} extra objects.");
			ValidateOrganizerHierarchy(target, extras, expectedCandidates, result);
			ValidateConservedRoots(target, result);
			return result;
		}

		private static void ValidateOrganizerHierarchy(
			SceneSnapshot target,
			IReadOnlyCollection<ObjectSnapshot> extras,
			IReadOnlyDictionary<string, CandidateInfo> expectedCandidates,
			ValidationResult result)
		{
			ObjectSnapshot artRoot = extras.SingleOrDefault(item => item.Name == ArtRootName);
			result.Check(artRoot != null, $"Missing organizer root '{ArtRootName}'.");
			if (artRoot == null)
			{
				return;
			}

			result.Check(string.IsNullOrEmpty(artRoot.ParentLocalId), $"Organizer '{ArtRootName}' is not a scene root.");
			string[] actualGroupOrder = artRoot.ChildLocalIds
				.Where(target.Objects.ContainsKey)
				.Select(localId => target.Objects[localId].Name)
				.ToArray();
			result.Check(actualGroupOrder.SequenceEqual(VisualGroupNames), $"Organizer group order differs from the declared visual group order.");
			foreach (string groupName in VisualGroupNames)
			{
				ObjectSnapshot group = extras.SingleOrDefault(item => item.Name == groupName);
				result.Check(group != null, $"Missing organizer group '{groupName}'.");
				if (group != null)
				{
					result.Check(group.ParentLocalId == artRoot.LocalId, $"Organizer group '{groupName}' is not parented to '{ArtRootName}'.");
					string[] expectedChildOrder = expectedCandidates.Values
						.Where(candidate => candidate.GroupName == groupName)
						.OrderBy(candidate => candidate.OriginalSiblingIndex)
						.Select(candidate => candidate.LocalId)
						.ToArray();
					result.Check(
						group.ChildLocalIds.SequenceEqual(expectedChildOrder),
						$"Child membership/order differs for organizer group '{groupName}'."
					);
				}
			}

			foreach (ObjectSnapshot organizer in extras)
			{
				result.Check(organizer.ComponentSignature == typeof(Transform).FullName, $"Organizer '{organizer.Name}' has unexpected components.");
				result.Check(organizer.ActiveSelf, $"Organizer '{organizer.Name}' is inactive.");
				result.Check(organizer.Layer == 0, $"Organizer '{organizer.Name}' is not on Default layer.");
				result.Check(organizer.Tag == "Untagged", $"Organizer '{organizer.Name}' is not Untagged.");
				result.Check(organizer.StaticFlags == 0, $"Organizer '{organizer.Name}' has static flags.");
				result.Check(NearlyEqual(organizer.LocalPosition, Vector3.zero), $"Organizer '{organizer.Name}' position is not zero.");
				result.Check(NearlyEqual(organizer.LocalRotation, Quaternion.identity), $"Organizer '{organizer.Name}' rotation is not identity.");
				result.Check(NearlyEqual(organizer.LocalScale, Vector3.one), $"Organizer '{organizer.Name}' scale is not one.");
			}
		}

		private static void ValidateConservedRoots(SceneSnapshot target, ValidationResult result)
		{
			foreach (string rootName in ConservedRootNames)
			{
				List<ObjectSnapshot> matches = target.Objects.Values.Where(item => item.Name == rootName).ToList();
				if (matches.Count == 0)
				{
					continue;
				}

				foreach (ObjectSnapshot match in matches)
				{
					result.Check(string.IsNullOrEmpty(match.ParentLocalId), $"Conserved object '{rootName}' is no longer a scene root.");
				}
			}

			List<ObjectSnapshot> tileMaps = target.Objects.Values.Where(item => item.Name == "TileMap").ToList();
			result.Check(tileMaps.Count == 1, $"Expected exactly one root named TileMap, found {tileMaps.Count}.");
			if (tileMaps.Count == 1)
			{
				result.Check(string.IsNullOrEmpty(tileMaps[0].ParentLocalId), "TileMap is not a scene root.");
				result.Check(tileMaps[0].Tag == "TileMap", $"TileMap tag changed to '{tileMaps[0].Tag}'.");
				result.Check(tileMaps[0].ComponentSignature.Contains("tk2dTileMap"), "TileMap no longer has a tk2dTileMap component.");
			}
		}

		private static void WriteReport(
			SceneSnapshot source,
			SceneSnapshot target,
			IReadOnlyDictionary<string, CandidateInfo> candidates,
			IReadOnlyDictionary<string, CandidateInfo> manualReview,
			ValidationResult validation,
			string sourceHash)
		{
			string absoluteReportPath = AbsolutePath(ReportPath);
			Directory.CreateDirectory(Path.GetDirectoryName(absoluteReportPath) ?? throw new InvalidOperationException("Invalid report directory."));

			StringBuilder report = new StringBuilder();
			report.AppendLine("# Bone_02 可读场景（Phase 0 + Phase 1）");
			report.AppendLine();
			report.AppendLine($"> 生成时间：{DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC  ");
			report.AppendLine($"> 源场景：`{SourceScenePath}`  ");
			report.AppendLine($"> 可读副本：`{TargetScenePath}`  ");
			report.AppendLine($"> 源场景 SHA-256：`{sourceHash}`");
			report.AppendLine();
			report.AppendLine("这是研究用整理副本，不代表 Team Cherry 原始 Hierarchy 或 Prefab 结构。本阶段没有创建或重连 Prefab，也没有移动任何带脚本、Collider、Rigidbody、Animator、ParticleSystem 或 AudioSource 的根树。另有一小批特殊 Layer/命名的纯视觉树被保守留在根层，列入 ManualReview。");
			report.AppendLine();
			report.AppendLine("## 结果");
			report.AppendLine();
			report.AppendLine("| 指标 | 原场景 | 可读副本 |");
			report.AppendLine("| --- | ---: | ---: |");
			report.AppendLine($"| 原有 GameObject | {source.Objects.Count} | {target.Objects.Count - (1 + VisualGroupNames.Length)} |");
			report.AppendLine($"| 整理目录 GameObject | 0 | {1 + VisualGroupNames.Length} |");
			report.AppendLine($"| GameObject 总数 | {source.Objects.Count} | {target.Objects.Count} |");
			report.AppendLine($"| Scene Root 数量 | {source.RootCount} | {target.RootCount} |");
			report.AppendLine($"| 移入 `_00_ART` 的静态视觉根树 | 0 | {candidates.Count} |");
			report.AppendLine($"| 保守留根、等待人工确认的纯视觉树 | {manualReview.Count} | {manualReview.Count} |");
			report.AppendLine($"| Missing Script | {source.MissingScriptCount} | {target.MissingScriptCount} |");
			report.AppendLine();
			report.AppendLine(validation.Errors.Count == 0
				? "验证结果：**PASS**。原对象数量、组件、引用、世界矩阵、内部子节点顺序、SpriteRenderer 设置均保持不变。"
				: $"验证结果：**FAIL**，发现 {validation.Errors.Count} 项差异。"
			);
			report.AppendLine();
			report.AppendLine("## 新层级");
			report.AppendLine();
			report.AppendLine("```text");
			report.AppendLine("_00_ART");
			foreach (string groupName in VisualGroupNames)
			{
				int count = candidates.Values.Count(item => item.GroupName == groupName);
				report.AppendLine($"├─ {groupName} ({count})");
			}
			report.AppendLine("```");
			report.AppendLine();
			report.AppendLine("分类规则是确定性的：以对象名和 Sprite 名为主，世界 Z 只辅助判断名称含 `deep` 的散落视觉根。无法可靠推断语义的对象默认进入 `20_Architecture`。现有多节点视觉树始终整体移动，不拆子节点，也不改名或改组件。");
			report.AppendLine();
			report.AppendLine("## 明确保留在 Scene Root 的对象");
			report.AppendLine();
			report.AppendLine("- `TileMap`、`TileMap Render Data`");
			report.AppendLine("- `_SceneManager`、`_Managers`、`Music Control`");
			report.AppendLine("- 所有敌人、活动机关、PlayMaker FSM、Rigidbody2D、Damage/Breakable 根对象");
			report.AppendLine("- Black Thread、Rock Roller、Chain Drop Platform 等复杂 set piece");
			report.AppendLine();
			report.AppendLine("这些对象没有放进共享父节点，因为工程逻辑会使用 `transform.root`、直接父节点或固定子节点名。`TileMap` 也必须维持 Scene Root，供 `GameManager.RefreshTilemapInfo` 的主路径发现。");
			report.AppendLine();
			report.AppendLine("## Unity 中查看");
			report.AppendLine();
			report.AppendLine($"1. 打开 `{TargetScenePath}`。");
			report.AppendLine("2. 展开 `_00_ART`；六个子目录分别对应背景、中景、建筑、前景、雾霭和遮罩。");
			report.AppendLine("3. 使用 Hierarchy 左侧眼睛图标临时隐藏某个目录，观察该视觉层在 Scene View 中的作用。");
			report.AppendLine("4. 需要核对恢复前结构时，同时参考只读源场景 `Bone_02.unity`；不要把可读副本当作原始 Prefab 证据。");
			report.AppendLine("5. 修改副本后，可执行 `Tools > Scene Research > Bone 02 > Validate Readable Copy` 重新验证 Phase 1 不变量。");
			report.AppendLine();
			report.AppendLine("## 自动验证范围");
			report.AppendLine();
			report.AppendLine("- 每个原 GameObject 的 scene localID 仍存在");
			report.AppendLine("- Active、Layer、Tag、Static Flags 不变");
			report.AppendLine("- Component 类型、顺序以及除 Transform 层级外的全部序列化字段哈希不变；字段基线来自同一 Unity 6 版本临时规范化并重开的源副本，仅新增目录 Transform");
			report.AppendLine("- 所有序列化 ObjectReference 的目标不变");
			report.AppendLine("- Local Transform 与世界矩阵不变");
			report.AppendLine("- 原有直接子节点及顺序不变");
			report.AppendLine("- Sprite、材质、颜色、Sorting Layer/Order、Flip、Draw Mode、Mask 设置不变");
			report.AppendLine("- `TileMap` 和保守管理对象仍为 Scene Root");
			report.AppendLine("- RenderSettings、LightmapSettings 与 LightingSettings 引用不变");
			report.AppendLine("- 研究副本使用独立 GUID，且清空继承来的 legacy AssetBundle 名称");
			report.AppendLine();
			report.AppendLine("## 已知恢复数据边界");
			report.AppendLine();
			report.AppendLine("源 YAML 的 `tk2dTileMap` 含 10 段 `spriteIds` typeless-data，其中共有 7,533 个非十六进制字符 `/`。Unity 6 保存派生副本时会把这些字符规范化成 `0`；若 `/` 原本应为 `f`，它们本应组成 `-1` 空 Tile 哨兵。因此，本报告的严格字段比较证明的是‘同一 Unity 6.5（6000.5.4f1）规范化解释下，层级整理没有引入额外数据变化’，并不证明恢复源文本与原游戏 TileMap 数据逐字节等价。");
			report.AppendLine();
			report.AppendLine("本阶段保留源场景及其 SHA-256，不在层级整理中顺带修复 TileMap。若后续需要编辑或查询 TileMap，应另建派生副本，专项恢复 `/`→`f` 并验证 tile 查询、持久网格与碰撞结果。");
			report.AppendLine();
			report.AppendLine("## ManualReview（本阶段未移动）");
			report.AppendLine();
			foreach (CandidateInfo candidate in manualReview.Values.OrderBy(item => item.OriginalSiblingIndex))
			{
				report.AppendLine($"- `{EscapeMarkdown(candidate.OriginalPath)}` — {candidate.ReviewReason}，{candidate.ObjectCount} GameObject，localID `{candidate.LocalId}`");
			}
			report.AppendLine();

			if (validation.Errors.Count > 0)
			{
				report.AppendLine("## 验证错误");
				report.AppendLine();
				foreach (string error in validation.Errors)
				{
					report.AppendLine($"- {EscapeMarkdown(error)}");
				}
				report.AppendLine();
			}

			report.AppendLine("## 移动清单");
			report.AppendLine();
			foreach (string groupName in VisualGroupNames)
			{
				List<CandidateInfo> groupedCandidates = candidates.Values
					.Where(item => item.GroupName == groupName)
					.OrderBy(item => item.OriginalSiblingIndex)
					.ToList();
				report.AppendLine($"<details><summary>{groupName}（{groupedCandidates.Count} 个根树）</summary>");
				report.AppendLine();
				foreach (CandidateInfo candidate in groupedCandidates)
				{
					report.AppendLine($"- `{EscapeMarkdown(candidate.OriginalPath)}` — {candidate.ObjectCount} GameObject，localID `{candidate.LocalId}`");
				}
				report.AppendLine();
				report.AppendLine("</details>");
				report.AppendLine();
			}

			File.WriteAllText(absoluteReportPath, report.ToString(), new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
		}

		private static void AssertCandidateSetsMatch(
			IReadOnlyDictionary<string, CandidateInfo> source,
			IReadOnlyDictionary<string, CandidateInfo> target)
		{
			HashSet<string> sourceIds = new HashSet<string>(source.Keys, StringComparer.Ordinal);
			HashSet<string> targetIds = new HashSet<string>(target.Keys, StringComparer.Ordinal);
			if (!sourceIds.SetEquals(targetIds))
			{
				throw new InvalidOperationException(
					$"Copied scene candidate set differs from source. Source={sourceIds.Count}, target={targetIds.Count}."
				);
			}
		}

		private static IEnumerable<GameObject> GetAllGameObjects(Scene scene)
		{
			foreach (GameObject root in scene.GetRootGameObjects())
			{
				foreach (Transform transform in root.GetComponentsInChildren<Transform>(includeInactive: true))
				{
					yield return transform.gameObject;
				}
			}
		}

		private static string GetLocalId(Object value)
		{
			GlobalObjectId globalId = GlobalObjectId.GetGlobalObjectIdSlow(value);
			if (globalId.targetObjectId == 0)
			{
				throw new InvalidOperationException($"Object '{value.name}' has no stable scene localID. Save the scene before running the tool.");
			}
			return globalId.targetObjectId.ToString(CultureInfo.InvariantCulture);
		}

		private static string GetHierarchyPath(Transform transform)
		{
			Stack<string> names = new Stack<string>();
			for (Transform current = transform; current != null; current = current.parent)
			{
				names.Push(current.name);
			}
			return string.Join("/", names);
		}

		private static SceneSnapshot CaptureCanonicalSourceSnapshot()
		{
			// Bone_02 was recovered from an older Unity serialization schema. Opening
			// and saving any copy in Unity 6 adds current default fields and normalizes
			// editor-only renderer data. Compare against a disposable, independently
			// saved source copy so those migrations are not mistaken for hierarchy edits.
			string temporaryPath = AssetDatabase.GenerateUniqueAssetPath(CanonicalSourceSceneBasePath);
			bool temporaryAssetCreated = false;
			try
			{
				if (!AssetDatabase.CopyAsset(SourceScenePath, temporaryPath))
				{
					throw new InvalidOperationException($"Could not create canonical validation copy '{temporaryPath}'.");
				}
				temporaryAssetCreated = true;
				AssetDatabase.ImportAsset(temporaryPath, ImportAssetOptions.ForceSynchronousImport);
				ClearAssetBundleMetadata(temporaryPath);

				Scene canonicalScene = CanonicalizeSceneAssetToFixedPoint(temporaryPath);
				return CaptureScene(canonicalScene);
			}
			finally
			{
				if (temporaryAssetCreated)
				{
					Scene temporaryScene = SceneManager.GetSceneByPath(temporaryPath);
					if (temporaryScene.IsValid() && temporaryScene.isLoaded && temporaryScene.isDirty)
					{
						// This is our disposable asset; discard only its unsaved transient state.
						ClearSceneDirtiness(temporaryScene);
					}
					if (temporaryScene.IsValid() && temporaryScene.isLoaded)
					{
						OpenSceneSafely(SourceScenePath);
					}

					if (!AssetDatabase.DeleteAsset(temporaryPath) && File.Exists(AbsolutePath(temporaryPath)))
					{
						throw new IOException($"Could not remove temporary canonical scene '{temporaryPath}'.");
					}
					AssetDatabase.Refresh(ImportAssetOptions.ForceSynchronousImport);
				}
			}
		}

		private static Scene CanonicalizeSceneAssetToFixedPoint(string assetPath)
		{
			Scene scene = OpenSceneSafely(assetPath);
			string previousHash = null;
			for (int pass = 0; pass < 3; pass++)
			{
				if (!EditorSceneManager.SaveScene(scene, assetPath, saveAsCopy: false))
				{
					throw new InvalidOperationException($"Unity failed to canonicalize scene '{assetPath}'.");
				}
				AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceSynchronousImport);
				string currentHash = ComputeSha256(AbsolutePath(assetPath));
				if (previousHash != null && string.Equals(previousHash, currentHash, StringComparison.Ordinal))
				{
					// Capture only after a disk reload of the stable representation.
					OpenSceneSafely(SourceScenePath);
					return OpenSceneSafely(assetPath);
				}

				previousHash = currentHash;
				OpenSceneSafely(SourceScenePath);
				scene = OpenSceneSafely(assetPath);
			}

			throw new InvalidOperationException(
				$"Scene did not reach a stable Unity 6 serialization after three save passes: '{assetPath}'."
			);
		}

		private static Scene OpenSceneSafely(string assetPath)
		{
			if (SceneManager.sceneCount == 1)
			{
				Scene loadedScene = SceneManager.GetSceneAt(0);
				if (loadedScene.isLoaded && string.Equals(loadedScene.path, assetPath, StringComparison.Ordinal))
				{
					return loadedScene;
				}
			}

			List<PersistentReferenceRestore> restorePoints = PrepareLoadedScenesForSafeUnload();
			try
			{
				return EditorSceneManager.OpenScene(assetPath, OpenSceneMode.Single);
			}
			catch
			{
				// If Unity fails before unloading the current scene, put the temporary
				// tk2d edits back immediately so a later manual Save cannot persist them.
				RestorePersistentMeshReferences(restorePoints);
				throw;
			}
		}

		private static List<PersistentReferenceRestore> PrepareLoadedScenesForSafeUnload()
		{
			List<PersistentReferenceRestore> restorePoints = new List<PersistentReferenceRestore>();
			for (int sceneIndex = 0; sceneIndex < SceneManager.sceneCount; sceneIndex++)
			{
				Scene scene = SceneManager.GetSceneAt(sceneIndex);
				if (!scene.isLoaded)
				{
					continue;
				}
				if (scene.isDirty)
				{
					throw new InvalidOperationException(
						$"Refusing to unload dirty scene '{scene.path}' during tk2d-safe scene switching."
					);
				}

				bool changedSerializedTileMapData = false;
				foreach (GameObject gameObject in GetAllGameObjects(scene))
				{
					foreach (Component component in gameObject.GetComponents<Component>())
					{
						if (component == null)
						{
							continue;
						}

						string typeName = component.GetType().Name;
						if (typeName == "tk2dTileMap")
						{
							changedSerializedTileMapData |= ClearPersistentMeshReferences(component, scene, restorePoints);
						}
						else if (typeName == "tk2dSprite")
						{
							ClearTk2dSpriteRuntimeMeshes(component);
						}
					}
				}

				// The cleared mesh references are only an in-memory unload guard. The
				// saved scene asset must retain its original serialized references.
				if (changedSerializedTileMapData)
				{
					ClearSceneDirtiness(scene);
				}
			}
			return restorePoints;
		}

		private static void ClearSceneDirtiness(Scene scene)
		{
			// Unity 6 still exposes this native-backed operation internally, but no
			// longer publishes it as a public EditorSceneManager API. We need it here
			// because the tk2d cleanup is deliberately an in-memory unload guard: the
			// scene file must never be saved with those generated mesh links cleared.
			MethodInfo method = typeof(EditorSceneManager).GetMethod(
				"ClearSceneDirtiness",
				BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic,
				null,
				new[] { typeof(Scene) },
				null
			);
			if (method == null)
			{
				throw new MissingMethodException(
					typeof(EditorSceneManager).FullName,
					"ClearSceneDirtiness(Scene)"
				);
			}

			method.Invoke(null, new object[] { scene });
		}

		private static bool ClearPersistentMeshReferences(
			Component tileMap,
			Scene scene,
			ICollection<PersistentReferenceRestore> restorePoints)
		{
			SerializedObject serializedTileMap = new SerializedObject(tileMap);
			SerializedProperty property = serializedTileMap.GetIterator();
			bool changed = false;
			while (property.Next(enterChildren: true))
			{
				if (property.propertyType != SerializedPropertyType.ObjectReference ||
					!(property.objectReferenceValue is Mesh mesh) ||
					!EditorUtility.IsPersistent(mesh))
				{
					continue;
				}

				restorePoints.Add(new PersistentReferenceRestore
				{
					Owner = tileMap,
					PropertyPath = property.propertyPath,
					OriginalValue = mesh,
					Scene = scene,
				});
				property.objectReferenceValue = null;
				changed = true;
			}

			if (changed)
			{
				serializedTileMap.ApplyModifiedPropertiesWithoutUndo();
			}
			return changed;
		}

		private static void RestorePersistentMeshReferences(IEnumerable<PersistentReferenceRestore> restorePoints)
		{
			HashSet<Scene> restoredScenes = new HashSet<Scene>();
			foreach (IGrouping<Component, PersistentReferenceRestore> group in restorePoints
				.Where(item => item.Owner != null)
				.GroupBy(item => item.Owner))
			{
				SerializedObject serializedOwner = new SerializedObject(group.Key);
				foreach (PersistentReferenceRestore restorePoint in group)
				{
					SerializedProperty property = serializedOwner.FindProperty(restorePoint.PropertyPath);
					if (property == null || property.propertyType != SerializedPropertyType.ObjectReference)
					{
						continue;
					}
					property.objectReferenceValue = restorePoint.OriginalValue;
					restoredScenes.Add(restorePoint.Scene);
				}
				serializedOwner.ApplyModifiedPropertiesWithoutUndo();
			}

			foreach (Scene scene in restoredScenes)
			{
				if (scene.IsValid() && scene.isLoaded)
				{
					ClearSceneDirtiness(scene);
				}
			}
		}

		private static void ClearTk2dSpriteRuntimeMeshes(Component sprite)
		{
			ClearRuntimeMeshField(sprite, sprite.GetType().GetField("mesh", BindingFlags.Instance | BindingFlags.NonPublic));
			ClearRuntimeMeshField(sprite, sprite.GetType().GetField("meshColliderMesh", BindingFlags.Instance | BindingFlags.Public));
		}

		private static void ClearRuntimeMeshField(Component owner, FieldInfo field)
		{
			if (field == null || !(field.GetValue(owner) is Mesh mesh))
			{
				return;
			}

			field.SetValue(owner, null);
			if (!EditorUtility.IsPersistent(mesh))
			{
				Object.DestroyImmediate(mesh);
			}
		}

		private static void RestoreTargetSceneBytes(byte[] originalBytes)
		{
			Scene loadedTarget = SceneManager.GetSceneByPath(TargetScenePath);
			if (loadedTarget.IsValid() && loadedTarget.isLoaded && loadedTarget.isDirty)
			{
				// Only changes made after targetMutationStarted reach this path.
				ClearSceneDirtiness(loadedTarget);
			}
			if (loadedTarget.IsValid() && loadedTarget.isLoaded)
			{
				OpenSceneSafely(SourceScenePath);
			}

			File.WriteAllBytes(AbsolutePath(TargetScenePath), originalBytes);
			AssetDatabase.ImportAsset(TargetScenePath, ImportAssetOptions.ForceSynchronousImport);
			OpenSceneSafely(TargetScenePath);
		}

		private static void ClearAssetBundleMetadata(string assetPath)
		{
			AssetImporter importer = AssetImporter.GetAtPath(assetPath);
			if (importer == null ||
				(string.IsNullOrEmpty(importer.assetBundleName) && string.IsNullOrEmpty(importer.assetBundleVariant)))
			{
				return;
			}

			importer.SetAssetBundleNameAndVariant(string.Empty, string.Empty);
			importer.SaveAndReimport();
		}

		private static void RequireCleanOpenScenes()
		{
			if (EditorApplication.isPlayingOrWillChangePlaymode)
			{
				throw new InvalidOperationException("Bone_02 readable scene tools cannot run while entering or inside Play Mode.");
			}
			if (PrefabStageUtility.GetCurrentPrefabStage() != null)
			{
				throw new InvalidOperationException("Exit Prefab Mode before running Bone_02 readable scene tools.");
			}

			for (int index = 0; index < SceneManager.sceneCount; index++)
			{
				Scene scene = SceneManager.GetSceneAt(index);
				if (scene.isDirty)
				{
					throw new InvalidOperationException(
						$"Open scene '{scene.path}' has unsaved changes. Save or discard them before running Bone_02 Readable Scene Builder."
					);
				}
			}
		}

		private static void RequireAsset(string assetPath)
		{
			if (AssetDatabase.LoadAssetAtPath<SceneAsset>(assetPath) == null)
			{
				throw new FileNotFoundException($"Scene asset not found: {assetPath}", AbsolutePath(assetPath));
			}
		}

		private static string AbsolutePath(string projectRelativePath)
		{
			string projectRoot = Directory.GetParent(Application.dataPath)?.FullName
				?? throw new InvalidOperationException("Could not resolve Unity project root.");
			return Path.Combine(projectRoot, projectRelativePath.Replace('/', Path.DirectorySeparatorChar));
		}

		private static string ComputeSha256(string path)
		{
			using (SHA256 sha256 = SHA256.Create())
			using (FileStream stream = File.OpenRead(path))
			{
				return BitConverter.ToString(sha256.ComputeHash(stream)).Replace("-", string.Empty).ToLowerInvariant();
			}
		}

		private static bool NearlyEqual(Vector3 left, Vector3 right)
		{
			return (left - right).sqrMagnitude <= 1e-10f;
		}

		private static bool NearlyEqual(Quaternion left, Quaternion right)
		{
			return Mathf.Abs(Quaternion.Dot(left, right)) >= 0.999999f;
		}

		private static bool NearlyEqual(Matrix4x4 left, Matrix4x4 right)
		{
			for (int index = 0; index < 16; index++)
			{
				if (Mathf.Abs(left[index] - right[index]) > 1e-5f)
				{
					return false;
				}
			}
			return true;
		}

		private static string FormatColor(Color value)
		{
			return string.Join(",", FormatFloat(value.r), FormatFloat(value.g), FormatFloat(value.b), FormatFloat(value.a));
		}

		private static string FormatVector2(Vector2 value)
		{
			return string.Join(",", FormatFloat(value.x), FormatFloat(value.y));
		}

		private static string FormatVector3(Vector3 value)
		{
			return string.Join(",", FormatFloat(value.x), FormatFloat(value.y), FormatFloat(value.z));
		}

		private static string FormatVector4(Vector4 value)
		{
			return string.Join(",", FormatFloat(value.x), FormatFloat(value.y), FormatFloat(value.z), FormatFloat(value.w));
		}

		private static string FormatQuaternion(Quaternion value)
		{
			return string.Join(",", FormatFloat(value.x), FormatFloat(value.y), FormatFloat(value.z), FormatFloat(value.w));
		}

		private static string FormatRect(Rect value)
		{
			return string.Join(",", FormatFloat(value.x), FormatFloat(value.y), FormatFloat(value.width), FormatFloat(value.height));
		}

		private static string FormatBounds(Bounds value)
		{
			return $"{FormatVector3(value.center)}|{FormatVector3(value.size)}";
		}

		private static string FormatVector2Int(Vector2Int value)
		{
			return $"{value.x.ToString(CultureInfo.InvariantCulture)},{value.y.ToString(CultureInfo.InvariantCulture)}";
		}

		private static string FormatVector3Int(Vector3Int value)
		{
			return $"{value.x.ToString(CultureInfo.InvariantCulture)},{value.y.ToString(CultureInfo.InvariantCulture)},{value.z.ToString(CultureInfo.InvariantCulture)}";
		}

		private static string FormatRectInt(RectInt value)
		{
			return $"{value.x.ToString(CultureInfo.InvariantCulture)},{value.y.ToString(CultureInfo.InvariantCulture)},{value.width.ToString(CultureInfo.InvariantCulture)},{value.height.ToString(CultureInfo.InvariantCulture)}";
		}

		private static string FormatBoundsInt(BoundsInt value)
		{
			return $"{FormatVector3Int(value.position)}|{FormatVector3Int(value.size)}";
		}

		private static string FormatAnimationCurve(AnimationCurve curve)
		{
			if (curve == null)
			{
				return "null";
			}

			StringBuilder result = new StringBuilder();
			result.Append("pre:").Append((int)curve.preWrapMode).Append(";post:").Append((int)curve.postWrapMode).Append(';');
			foreach (Keyframe key in curve.keys)
			{
				result.Append(FormatFloat(key.time)).Append(',')
					.Append(FormatFloat(key.value)).Append(',')
					.Append(FormatFloat(key.inTangent)).Append(',')
					.Append(FormatFloat(key.outTangent)).Append(',')
					.Append(FormatFloat(key.inWeight)).Append(',')
					.Append(FormatFloat(key.outWeight)).Append(',')
					.Append((int)key.weightedMode).Append(';');
			}
			return result.ToString();
		}

		private static string FormatFloat(float value)
		{
			return value.ToString("R", CultureInfo.InvariantCulture);
		}

		private static string EscapeMarkdown(string value)
		{
			return value.Replace("`", "\\`");
		}

		private static void RunMenuAction(Action action, string successTitle, string successMessage)
		{
			try
			{
				using (EditorErrorCapture errorCapture = new EditorErrorCapture())
				{
					action();
					errorCapture.ThrowIfAny();
				}
				EditorUtility.DisplayDialog(successTitle, successMessage, "OK");
			}
			catch (Exception exception)
			{
				Debug.LogException(exception);
				EditorUtility.DisplayDialog("Bone_02 readable scene failed", exception.Message, "OK");
			}
		}

		private static void RunBatchAction(Action action)
		{
			try
			{
				using (EditorErrorCapture errorCapture = new EditorErrorCapture())
				{
					action();
					errorCapture.ThrowIfAny();
				}
				if (Application.isBatchMode)
				{
					EditorApplication.Exit(0);
				}
			}
			catch (Exception exception)
			{
				Debug.LogException(exception);
				if (Application.isBatchMode)
				{
					EditorApplication.Exit(1);
				}
				else
				{
					throw;
				}
			}
		}

		private sealed class PersistentReferenceRestore
		{
			public Component Owner;
			public string PropertyPath;
			public Object OriginalValue;
			public Scene Scene;
		}

		private sealed class CandidateInfo
		{
			public string LocalId;
			public string OriginalPath;
			public int OriginalSiblingIndex;
			public int ObjectCount;
			public string GroupName;
			public string ReviewReason;
		}

		private sealed class SceneSnapshot
		{
			public string ScenePath;
			public int RootCount;
			public int MissingScriptCount;
			public string EnvironmentSignature;
			public readonly Dictionary<string, ObjectSnapshot> Objects = new Dictionary<string, ObjectSnapshot>(StringComparer.Ordinal);
			public readonly Dictionary<string, int> ComponentCounts = new Dictionary<string, int>(StringComparer.Ordinal);
		}

		private sealed class ObjectSnapshot
		{
			public string LocalId;
			public string Name;
			public string Path;
			public string ParentLocalId;
			public string[] ChildLocalIds;
			public bool ActiveSelf;
			public int Layer;
			public string Tag;
			public int StaticFlags;
			public Vector3 LocalPosition;
			public Quaternion LocalRotation;
			public Vector3 LocalScale;
			public Matrix4x4 LocalToWorld;
			public string ComponentSignature;
			public string SerializedDataCanonical;
			public string ObjectReferenceSignature;
			public string SpriteRendererSignature;
		}

		private sealed class ValidationResult
		{
			public readonly List<string> Errors = new List<string>();

			public void Check(bool condition, string error)
			{
				if (!condition)
				{
					Errors.Add(error);
				}
			}

			public void ThrowIfFailed(string stage)
			{
				if (Errors.Count == 0)
				{
					return;
				}

				string firstErrors = string.Join("\n", Errors.Take(20));
				throw new InvalidOperationException(
					$"Bone_02 readable scene {stage} failed with {Errors.Count} error(s):\n{firstErrors}"
				);
			}
		}

		private sealed class EditorErrorCapture : IDisposable
		{
			private readonly List<string> errors = new List<string>();

			public EditorErrorCapture()
			{
				Application.logMessageReceived += OnLogMessageReceived;
			}

			public void Dispose()
			{
				Application.logMessageReceived -= OnLogMessageReceived;
			}

			public void ThrowIfAny()
			{
				if (errors.Count == 0)
				{
					return;
				}

				throw new InvalidOperationException(
					$"Unity logged {errors.Count} Error/Assert/Exception message(s) during the operation:\n" +
					string.Join("\n", errors.Take(20))
				);
			}

			private void OnLogMessageReceived(string condition, string stackTrace, LogType type)
			{
				if (type == LogType.Error || type == LogType.Assert || type == LogType.Exception)
				{
					errors.Add($"[{type}] {condition}");
				}
			}
		}
	}
}
