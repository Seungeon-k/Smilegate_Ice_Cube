using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

[InitializeOnLoad]
internal static class IceBallHazardSetup
{
    private const string ScenePath = "Assets/Vulcanus/Custom/MyScene/My_Basic_Sand.unity";
    private const string PlatformName = "Snow_Platform (2)";
    private const string BallName = "Ice_Ball_Hazard";
    private const string ShadowName = "Ice_Ball_Shadow";
    private const string CubePrefabPath =
        "Packages/com.v.gameframework.resources/Runtime/Official/Partyroyal Framework/Prop/BasicShape/Pr_Cube.prefab";
    private const string CylinderPrefabPath =
        "Packages/com.v.gameframework.resources/Runtime/Official/Partyroyal Framework/Prop/BasicShape/Pr_Cylinder_R.prefab";
    private const string BallModelPath = "Assets/Vulcanus/Custom/Object/ice_ball.fbx";
    private const string IceMaterialPath = "Assets/Vulcanus/Custom/M_RunIce01.mat";
    private const string MaterialFolder = "Assets/Vulcanus/Custom/Material";
    private const string ShadowMaterialPath = MaterialFolder + "/IceBallShadow.mat";
    private const float BallDiameter = 10f;
    private const float BallRadius = BallDiameter * 0.5f;

    private static bool loggedWaiting;

    static IceBallHazardSetup()
    {
        EditorApplication.delayCall += TrySetup;
    }

    [MenuItem("Vulcanus/Setup Ice Ball Hazard")]
    private static void SetupFromMenu()
    {
        loggedWaiting = false;
        TrySetup();
    }

    private static void TrySetup()
    {
        if (EditorApplication.isPlayingOrWillChangePlaymode)
        {
            EditorApplication.delayCall += TrySetup;
            return;
        }

        Scene scene = SceneManager.GetActiveScene();
        if (!scene.IsValid() || scene.path != ScenePath)
        {
            return;
        }

        GameObject platform = GameObject.Find(PlatformName);
        if (platform == null)
        {
            if (!loggedWaiting)
            {
                loggedWaiting = true;
                Debug.Log(
                    "[IceBallHazardSetup] Waiting for Snow_Platform (2). "
                    + "Save the current scene or run Vulcanus > Setup Ice Ball Hazard after adding it."
                );
            }
            return;
        }

        bool changed = RemoveDuplicateRootObjects(BallName) || false;
        changed = RemoveDuplicateRootObjects(ShadowName) || changed;

        GameObject ball = GameObject.Find(BallName);
        GameObject shadow = GameObject.Find(ShadowName);

        if (ball == null)
        {
            ball = CreateBall(scene);
            changed = ball != null;
        }
        else
        {
            changed = ConfigureBall(ball, scene) || changed;
        }

        if (shadow == null)
        {
            shadow = CreateShadow(scene);
            changed = shadow != null || changed;
        }
        else
        {
            changed = ConfigureShadow(shadow) || changed;
        }

        if (ball == null || shadow == null)
        {
            Debug.LogError("[IceBallHazardSetup] Could not create the Ice Ball hazard objects.");
            return;
        }

        if (changed)
        {
            EditorSceneManager.MarkSceneDirty(scene);
            EditorSceneManager.SaveScene(scene);
            AssetDatabase.SaveAssets();
            Debug.Log("[IceBallHazardSetup] Ice Ball and warning shadow are ready.");
        }
    }

    private static GameObject CreateBall(Scene scene)
    {
        GameObject root = InstantiateAndUnpack(CubePrefabPath, scene);
        GameObject modelAsset = AssetDatabase.LoadAssetAtPath<GameObject>(BallModelPath);
        if (root == null || modelAsset == null)
        {
            if (root != null)
            {
                Object.DestroyImmediate(root);
            }
            return null;
        }

        root.name = BallName;
        root.transform.position = new Vector3(0f, -1000f, 0f);
        root.transform.rotation = Quaternion.identity;
        root.transform.localScale = Vector3.one;

        if (!ConfigureBall(root, scene))
        {
            GameObject model = PrefabUtility.InstantiatePrefab(modelAsset, scene) as GameObject;
            if (model == null)
            {
                Object.DestroyImmediate(root);
                return null;
            }

            model.name = "Ice_Ball_Visual";
            model.transform.SetParent(root.transform, false);
            model.transform.localPosition = Vector3.zero;
            model.transform.localRotation = Quaternion.identity;
            model.transform.localScale = Vector3.one;
            ConfigureBall(root, scene);
        }

        Undo.RegisterCreatedObjectUndo(root, "Create Ice Ball Hazard");
        return root;
    }

    private static bool RemoveDuplicateRootObjects(string objectName)
    {
        GameObject[] objects = Object.FindObjectsByType<GameObject>(
            FindObjectsInactive.Include,
            FindObjectsSortMode.None
        );
        GameObject keep = null;
        bool changed = false;

        foreach (GameObject obj in objects)
        {
            if (obj.name != objectName)
            {
                continue;
            }

            if (keep == null)
            {
                keep = obj;
                continue;
            }

            Object.DestroyImmediate(obj);
            changed = true;
        }

        return changed;
    }

    private static GameObject CreateShadow(Scene scene)
    {
        GameObject root = InstantiateAndUnpack(CylinderPrefabPath, scene);
        if (root == null)
        {
            return null;
        }

        root.name = ShadowName;
        root.transform.position = new Vector3(0f, -1000f, 0f);
        root.transform.rotation = Quaternion.identity;
        root.transform.localScale = new Vector3(BallDiameter, 0.025f, BallDiameter);
        ConfigureShadow(root);

        Undo.RegisterCreatedObjectUndo(root, "Create Ice Ball Shadow");
        return root;
    }

    private static bool ConfigureBall(GameObject root, Scene scene)
    {
        bool changed = false;
        changed = RemoveAllVisuals(root) || changed;
        GameObject modelAsset = AssetDatabase.LoadAssetAtPath<GameObject>(BallModelPath);
        if (modelAsset == null)
        {
            Debug.LogError("[IceBallHazardSetup] Missing model: " + BallModelPath);
            return changed;
        }

        GameObject model = PrefabUtility.InstantiatePrefab(modelAsset, scene) as GameObject;
        if (model == null)
        {
            return changed;
        }

        model.name = "Ice_Ball_Visual";
        model.transform.SetParent(root.transform, false);
        model.transform.localPosition = Vector3.zero;
        model.transform.localRotation = Quaternion.identity;
        model.transform.localScale = Vector3.one;
        PrefabUtility.UnpackPrefabInstance(
            model,
            PrefabUnpackMode.Completely,
            InteractionMode.AutomatedAction
        );
        changed = true;

        foreach (MeshRenderer renderer in root.GetComponents<MeshRenderer>())
        {
            Object.DestroyImmediate(renderer);
            changed = true;
        }

        foreach (MeshFilter meshFilter in root.GetComponents<MeshFilter>())
        {
            Object.DestroyImmediate(meshFilter);
            changed = true;
        }

        foreach (Component component in root.GetComponents<Component>())
        {
            if (component == null || component is Transform || component is SphereCollider
                || component is IceBallCellBreakEffect)
            {
                continue;
            }

            string typeName = component.GetType().Name;
            if (typeName.Contains("Material") || typeName.Contains("Renderer"))
            {
                Object.DestroyImmediate(component);
                changed = true;
            }
        }

        foreach (BoxCollider boxCollider in root.GetComponents<BoxCollider>())
        {
            Object.DestroyImmediate(boxCollider);
            changed = true;
        }

        SphereCollider sphereCollider = root.GetComponent<SphereCollider>();
        if (sphereCollider == null)
        {
            sphereCollider = root.AddComponent<SphereCollider>();
            changed = true;
        }

        Vector3 colliderCenter = new(0f, BallRadius, 0f);
        if (!Mathf.Approximately(sphereCollider.radius, BallRadius))
        {
            sphereCollider.radius = BallRadius;
            changed = true;
        }
        if (sphereCollider.center != colliderCenter)
        {
            sphereCollider.center = colliderCenter;
            changed = true;
        }
        if (!sphereCollider.isTrigger)
        {
            sphereCollider.isTrigger = true;
            changed = true;
        }

        IceBallCellBreakEffect breakEffect = root.GetComponent<IceBallCellBreakEffect>();
        if (breakEffect == null)
        {
            root.AddComponent<IceBallCellBreakEffect>();
            changed = true;
        }

        Material iceMaterial = AssetDatabase.LoadAssetAtPath<Material>(IceMaterialPath);
        if (iceMaterial != null)
        {
            foreach (Renderer renderer in model.GetComponentsInChildren<Renderer>(true))
            {
                if (renderer.sharedMaterial != iceMaterial)
                {
                    renderer.sharedMaterial = iceMaterial;
                    changed = true;
                }
            }
        }
        else
        {
            Debug.LogWarning("[IceBallHazardSetup] Missing material: " + IceMaterialPath);
        }

        changed = NormalizeModelWithBottomPivot(root, model, BallDiameter) || changed;
        return changed;
    }

    private static bool RemoveAllVisuals(GameObject root)
    {
        bool changed = false;

        for (int i = root.transform.childCount - 1; i >= 0; i--)
        {
            Transform child = root.transform.GetChild(i);
            if (child.name == "Ice_Ball_Visual" || child.name.StartsWith("ice_ball")
                || child.name.StartsWith("Sphere_cell"))
            {
                Object.DestroyImmediate(child.gameObject);
                changed = true;
            }
        }

        return changed;
    }

    private static bool ConfigureShadow(GameObject root)
    {
        bool changed = false;

        Vector3 targetScale = new(BallDiameter, 0.025f, BallDiameter);
        if (root.transform.localScale != targetScale)
        {
            root.transform.localScale = targetScale;
            changed = true;
        }

        foreach (Collider collider in root.GetComponents<Collider>())
        {
            Object.DestroyImmediate(collider);
            changed = true;
        }

        Material shadowMaterial = GetOrCreateShadowMaterial();
        MeshRenderer renderer = root.GetComponent<MeshRenderer>();
        if (renderer != null && shadowMaterial != null)
        {
            if (renderer.sharedMaterial != shadowMaterial)
            {
                renderer.sharedMaterial = shadowMaterial;
                changed = true;
            }
            if (renderer.shadowCastingMode != ShadowCastingMode.Off)
            {
                renderer.shadowCastingMode = ShadowCastingMode.Off;
                changed = true;
            }
            if (renderer.receiveShadows)
            {
                renderer.receiveShadows = false;
                changed = true;
            }
        }

        return changed;
    }

    private static GameObject InstantiateAndUnpack(string path, Scene scene)
    {
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(path);
        if (prefab == null)
        {
            Debug.LogError("[IceBallHazardSetup] Missing prefab: " + path);
            return null;
        }

        GameObject instance = PrefabUtility.InstantiatePrefab(prefab, scene) as GameObject;
        if (instance == null)
        {
            return null;
        }

        PrefabUtility.UnpackPrefabInstance(
            instance,
            PrefabUnpackMode.Completely,
            InteractionMode.AutomatedAction
        );
        return instance;
    }

    private static bool NormalizeModelWithBottomPivot(GameObject root, GameObject model, float targetDiameter)
    {
        Renderer[] renderers = model.GetComponentsInChildren<Renderer>(true);
        if (renderers.Length == 0)
        {
            return false;
        }

        Bounds bounds = renderers[0].bounds;
        for (int i = 1; i < renderers.Length; i++)
        {
            bounds.Encapsulate(renderers[i].bounds);
        }

        float diameter = Mathf.Max(bounds.size.x, bounds.size.y, bounds.size.z);
        if (diameter <= 0.001f)
        {
            return false;
        }

        float scale = targetDiameter / diameter;
        bool changed = !Mathf.Approximately(model.transform.localScale.x, scale)
            || !Mathf.Approximately(model.transform.localScale.y, scale)
            || !Mathf.Approximately(model.transform.localScale.z, scale);
        model.transform.localScale = Vector3.one * scale;

        bounds = renderers[0].bounds;
        for (int i = 1; i < renderers.Length; i++)
        {
            bounds.Encapsulate(renderers[i].bounds);
        }

        Vector3 localCenter = root.transform.InverseTransformPoint(bounds.center);
        Vector3 localBottom = root.transform.InverseTransformPoint(new Vector3(
            bounds.center.x,
            bounds.min.y,
            bounds.center.z
        ));
        Vector3 correction = new(localCenter.x, localBottom.y, localCenter.z);
        changed = changed || correction.sqrMagnitude > 0.000001f;
        model.transform.localPosition -= correction;
        return changed;
    }

    private static Material GetOrCreateShadowMaterial()
    {
        Material material = AssetDatabase.LoadAssetAtPath<Material>(ShadowMaterialPath);
        if (material != null)
        {
            return material;
        }

        if (!AssetDatabase.IsValidFolder(MaterialFolder))
        {
            Directory.CreateDirectory(MaterialFolder);
            AssetDatabase.Refresh();
        }

        Shader shader = Shader.Find("Universal Render Pipeline/Unlit");
        if (shader == null)
        {
            shader = Shader.Find("Unlit/Color");
        }
        if (shader == null)
        {
            shader = Shader.Find("Standard");
        }

        material = new Material(shader)
        {
            name = "IceBallShadow",
            color = new Color(0.04f, 0.14f, 0.24f, 0.42f)
        };

        if (material.HasProperty("_BaseColor"))
        {
            material.SetColor("_BaseColor", new Color(0.04f, 0.14f, 0.24f, 0.42f));
        }
        if (material.HasProperty("_Surface"))
        {
            material.SetFloat("_Surface", 1f);
        }
        if (material.HasProperty("_ZWrite"))
        {
            material.SetFloat("_ZWrite", 0f);
        }

        material.renderQueue = (int)RenderQueue.Transparent;
        AssetDatabase.CreateAsset(material, ShadowMaterialPath);
        return material;
    }
}
