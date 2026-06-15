using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

[InitializeOnLoad]
internal static class IceCubeBoundarySetup
{
    private const int SetupVersion = 5;
    private const string ScenePath = "Assets/Vulcanus/Custom/MyScene/My_Basic_Sand.unity";
    private const string IceCubeName = "Ice_Cube";
    private const string BoundaryRootName = "Player_Boundary_Walls";

    private const float WallThickness = 0.004f;
    private const float WallHeight = 0.55f;
    private const float WallLength = 2.9f;
    private const float WallOffset = 1.45f;

    static IceCubeBoundarySetup()
    {
        EditorApplication.delayCall += TrySetup;
    }

    [MenuItem("Vulcanus/Setup Ice Cube Player Boundary")]
    private static void SetupFromMenu()
    {
        TrySetup();
    }

    private static void TrySetup()
    {
        if (EditorApplication.isPlayingOrWillChangePlaymode)
        {
            return;
        }

        Scene scene = SceneManager.GetActiveScene();
        if (!scene.IsValid() || scene.path != ScenePath)
        {
            return;
        }

        GameObject iceCube = GameObject.Find(IceCubeName);
        if (iceCube == null)
        {
            Debug.LogWarning("[IceCubeBoundary] Ice_Cube was not found.");
            return;
        }

        Transform root = iceCube.transform.Find(BoundaryRootName);
        bool changed = false;
        if (root == null)
        {
            GameObject rootObject = new(BoundaryRootName);
            root = rootObject.transform;
            root.SetParent(iceCube.transform, false);
            changed = true;
        }

        changed |= ConfigureRoot(root, iceCube.layer);
        changed |= ConfigureWall(
            root,
            "Boundary_Left",
            new Vector3(-WallOffset, 0.5f + WallHeight * 0.5f, 0f),
            new Vector3(WallThickness, WallHeight, WallLength),
            iceCube.layer
        );
        changed |= ConfigureWall(
            root,
            "Boundary_Right",
            new Vector3(WallOffset, 0.5f + WallHeight * 0.5f, 0f),
            new Vector3(WallThickness, WallHeight, WallLength),
            iceCube.layer
        );
        changed |= ConfigureWall(
            root,
            "Boundary_Back",
            new Vector3(0f, 0.5f + WallHeight * 0.5f, -WallOffset),
            new Vector3(WallLength, WallHeight, WallThickness),
            iceCube.layer
        );
        changed |= ConfigureWall(
            root,
            "Boundary_Front",
            new Vector3(0f, 0.5f + WallHeight * 0.5f, WallOffset),
            new Vector3(WallLength, WallHeight, WallThickness),
            iceCube.layer
        );

        if (!changed)
        {
            return;
        }

        if (EditorApplication.isPlayingOrWillChangePlaymode
            || !scene.IsValid()
            || !scene.isLoaded)
        {
            return;
        }

        EditorUtility.SetDirty(iceCube);
        EditorSceneManager.MarkSceneDirty(scene);
        EditorSceneManager.SaveScene(scene);
        Debug.Log(
            "[IceCubeBoundary] Four invisible player boundary walls are ready. Version "
            + SetupVersion
            + "."
        );
    }

    private static bool ConfigureRoot(Transform root, int layer)
    {
        bool changed = false;
        changed |= SetLocalTransform(root, Vector3.zero, Quaternion.identity, Vector3.one);

        if (root.gameObject.layer != layer)
        {
            root.gameObject.layer = layer;
            changed = true;
        }

        return changed;
    }

    private static bool ConfigureWall(
        Transform root,
        string name,
        Vector3 localPosition,
        Vector3 size,
        int layer
    )
    {
        Transform wall = root.Find(name);
        bool changed = false;
        if (wall == null)
        {
            GameObject wallObject = new(name);
            wall = wallObject.transform;
            wall.SetParent(root, false);
            changed = true;
        }

        changed |= SetLocalTransform(wall, localPosition, Quaternion.identity, Vector3.one);

        if (wall.gameObject.layer != layer)
        {
            wall.gameObject.layer = layer;
            changed = true;
        }

        BoxCollider collider = wall.GetComponent<BoxCollider>();
        if (collider == null)
        {
            collider = wall.gameObject.AddComponent<BoxCollider>();
            changed = true;
        }

        if (collider.isTrigger)
        {
            collider.isTrigger = false;
            changed = true;
        }
        if (collider.center != Vector3.zero)
        {
            collider.center = Vector3.zero;
            changed = true;
        }
        if (collider.size != size)
        {
            collider.size = size;
            changed = true;
        }

        foreach (Renderer renderer in wall.GetComponents<Renderer>())
        {
            Object.DestroyImmediate(renderer);
            changed = true;
        }

        return changed;
    }

    private static bool SetLocalTransform(
        Transform transform,
        Vector3 position,
        Quaternion rotation,
        Vector3 scale
    )
    {
        bool changed = false;
        if (transform.localPosition != position)
        {
            transform.localPosition = position;
            changed = true;
        }
        if (transform.localRotation != rotation)
        {
            transform.localRotation = rotation;
            changed = true;
        }
        if (transform.localScale != scale)
        {
            transform.localScale = scale;
            changed = true;
        }
        return changed;
    }
}
