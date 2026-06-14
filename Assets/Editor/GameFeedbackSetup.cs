using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

[InitializeOnLoad]
internal static class GameFeedbackSetup
{
    private const int SetupVersion = 2;
    private const string ScenePath = "Assets/Vulcanus/Custom/MyScene/My_Basic_Sand.unity";
    private const string HolderPrefabPath =
        "Packages/com.v.gameframework.resources/Runtime/Official/Partyroyal Framework/Prop/BasicShape/Pr_Cube.prefab";
    private const string AudioRoot =
        "Packages/com.v.gameframework.resources/Runtime/Official/Partyroyal Framework/RawResource/Audio/SFX/";
    private const string EffectRoot =
        "Packages/com.v.gameframework.resources/Runtime/Essential/Resources/Penguin/Effect/";

    static GameFeedbackSetup()
    {
        EditorApplication.delayCall += TrySetup;
    }

    [MenuItem("Vulcanus/Setup Game Feedback")]
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
        if (!scene.IsValid() || !scene.isLoaded || scene.path != ScenePath)
        {
            return;
        }

        bool changed = ConfigureHolder(
            scene,
            "Feedback_START",
            AudioRoot + "UI/UI_Party_Start.wav",
            EffectRoot + "VFX_Penguin_Spawn_Dust.prefab",
            false
        );
        changed |= ConfigureHolder(
            scene,
            "Feedback_GOAL",
            AudioRoot + "UI/UI_Party_Text_End_Sucess.wav",
            EffectRoot + "VFX_GoalScorer.prefab",
            false
        );
        changed |= ConfigureHolder(
            scene,
            "Feedback_FAIL",
            AudioRoot + "UI/UI_Party_Text_End_Fail.wav",
            EffectRoot + "vfx_Penguin_Respawn.prefab",
            false
        );
        changed |= ConfigureHolder(
            scene,
            "Feedback_IMPACT",
            AudioRoot + "Character/SFX_Penguin_Hit_Big.wav",
            EffectRoot + "VFX_Gimmick_Palm_Hit.prefab",
            true
        );

        if (!changed
            || EditorApplication.isPlayingOrWillChangePlaymode
            || !scene.IsValid()
            || !scene.isLoaded)
        {
            return;
        }

        EditorSceneManager.MarkSceneDirty(scene);
        EditorSceneManager.SaveScene(scene);
        AssetDatabase.SaveAssets();
        Debug.Log(
            "[GameFeedback] Lua-compatible sound/VFX VObjects are ready. Version "
            + SetupVersion
            + "."
        );
    }

    private static bool ConfigureHolder(
        Scene scene,
        string holderName,
        string clipPath,
        string effectPath,
        bool spatial
    )
    {
        bool changed = false;
        GameObject holder = GameObject.Find(holderName);
        if (holder == null)
        {
            GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(HolderPrefabPath);
            if (prefab == null)
            {
                Debug.LogError("[GameFeedback] Missing holder prefab: " + HolderPrefabPath);
                return false;
            }

            holder = PrefabUtility.InstantiatePrefab(prefab, scene) as GameObject;
            if (holder == null)
            {
                return false;
            }

            PrefabUtility.UnpackPrefabInstance(
                holder,
                PrefabUnpackMode.Completely,
                InteractionMode.AutomatedAction
            );
            holder.name = holderName;
            holder.transform.position = new Vector3(0f, -1000f, 0f);
            holder.transform.rotation = Quaternion.identity;
            holder.transform.localScale = Vector3.one;
            changed = true;
        }

        changed |= StripVisualAndPhysics(holder);
        changed |= ConfigureAudio(holder, clipPath, spatial);
        changed |= ConfigureEffect(holder, scene, effectPath);
        return changed;
    }

    private static bool StripVisualAndPhysics(GameObject holder)
    {
        bool changed = false;
        foreach (Renderer renderer in holder.GetComponents<Renderer>())
        {
            Object.DestroyImmediate(renderer);
            changed = true;
        }
        foreach (Collider collider in holder.GetComponents<Collider>())
        {
            Object.DestroyImmediate(collider);
            changed = true;
        }
        foreach (Rigidbody rigidbody in holder.GetComponents<Rigidbody>())
        {
            Object.DestroyImmediate(rigidbody);
            changed = true;
        }
        return changed;
    }

    private static bool ConfigureAudio(GameObject holder, string clipPath, bool spatial)
    {
        AudioClip clip = AssetDatabase.LoadAssetAtPath<AudioClip>(clipPath);
        if (clip == null)
        {
            Debug.LogError("[GameFeedback] Missing audio clip: " + clipPath);
            return false;
        }

        AudioSource source = holder.GetComponent<AudioSource>();
        bool changed = false;
        if (source == null)
        {
            source = holder.AddComponent<AudioSource>();
            changed = true;
        }

        if (source.clip != clip)
        {
            source.clip = clip;
            changed = true;
        }
        if (source.playOnAwake)
        {
            source.playOnAwake = false;
            changed = true;
        }
        if (source.loop)
        {
            source.loop = false;
            changed = true;
        }

        float spatialBlend = spatial ? 0.35f : 0f;
        if (!Mathf.Approximately(source.spatialBlend, spatialBlend))
        {
            source.spatialBlend = spatialBlend;
            changed = true;
        }
        if (!Mathf.Approximately(source.volume, 0.9f))
        {
            source.volume = 0.9f;
            changed = true;
        }
        source.minDistance = 3f;
        source.maxDistance = 40f;
        return changed;
    }

    private static bool ConfigureEffect(GameObject holder, Scene scene, string effectPath)
    {
        const string childName = "FeedbackEffect";
        Transform effectRoot = holder.transform.Find(childName);
        bool changed = false;

        if (effectRoot == null)
        {
            GameObject effectPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(effectPath);
            if (effectPrefab == null)
            {
                Debug.LogError("[GameFeedback] Missing effect prefab: " + effectPath);
                return false;
            }

            GameObject effect = PrefabUtility.InstantiatePrefab(effectPrefab, scene) as GameObject;
            if (effect == null)
            {
                return false;
            }

            effect.name = childName;
            effect.transform.SetParent(holder.transform, false);
            effectRoot = effect.transform;
            changed = true;
        }

        if (effectRoot.localPosition != Vector3.zero)
        {
            effectRoot.localPosition = Vector3.zero;
            changed = true;
        }
        if (effectRoot.localRotation != Quaternion.identity)
        {
            effectRoot.localRotation = Quaternion.identity;
            changed = true;
        }

        foreach (ParticleSystem particle in effectRoot.GetComponentsInChildren<ParticleSystem>(true))
        {
            ParticleSystem.MainModule main = particle.main;
            if (main.playOnAwake)
            {
                main.playOnAwake = false;
                changed = true;
            }
            particle.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        }

        return changed;
    }
}
