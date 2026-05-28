

using UnityEditor;
using UnityEngine;
using UnityEngine.Audio;

namespace GeneratedTable
{
    [CustomEditor(typeof(SoundScriptableObject))]
    [CanEditMultipleObjects]
    public class SoundScriptableObjectEditor : UnityEditor.Editor
    {
        //SerializedProperty ID;
        SerializedProperty ClipNames;

        SerializedProperty sequential;
        SerializedProperty nonRepeatingBGMGroup;

        SerializedProperty VolumeMin;
        SerializedProperty VolumeMax;

        SerializedProperty PitchMin;
        SerializedProperty PitchMax;

        SerializedProperty loop ;
        SerializedProperty followingObjectPos;
        SerializedProperty MixerGroupName;
        SerializedProperty overlapMax;

        SerializedProperty sound3D;                                // True(3D) / False(2D)
        SerializedProperty spatialBlend;
        SerializedProperty dopplerLevel;
        SerializedProperty spread;

        SerializedProperty rolloffMode;
        SerializedProperty curveName;

        SerializedProperty minDistance;
        SerializedProperty maxDistance;

        SerializedProperty fadeInTime;
        SerializedProperty fadeOutTime;
        SerializedProperty priority;
        SerializedProperty delay;

        SerializedProperty RemoveOnAnimationChange;

        int previewIndex;
        int clipIndex;
        string[] clipNameOptions = System.Array.Empty<string>();

        private void OnEnable()
        {
            //ID = serializedObject.FindProperty("ID");
            ClipNames = serializedObject.FindProperty("ClipNames");

            sequential = serializedObject.FindProperty("sequential");
            nonRepeatingBGMGroup = serializedObject.FindProperty("nonRepeatingBGMGroup");

            var volProp = serializedObject.FindProperty("Volume");
            VolumeMin = volProp.FindPropertyRelative("min");
            VolumeMax = volProp.FindPropertyRelative("max");

            var pitchProp = serializedObject.FindProperty("Pitch");
            PitchMin = pitchProp.FindPropertyRelative("min");
            PitchMax = pitchProp.FindPropertyRelative("max");

            loop = serializedObject.FindProperty("loop");
            followingObjectPos = serializedObject.FindProperty("followingObjectPos");
            MixerGroupName = serializedObject.FindProperty("MixerGroupName");
            overlapMax = serializedObject.FindProperty("overlapMax");

            sound3D = serializedObject.FindProperty("sound3D");
            spatialBlend = serializedObject.FindProperty("spatialBlend");
            dopplerLevel = serializedObject.FindProperty("dopplerLevel");
            spread = serializedObject.FindProperty("spread");

            rolloffMode = serializedObject.FindProperty("rolloffMode");
            curveName = serializedObject.FindProperty("curveName");

            minDistance = serializedObject.FindProperty("minDistance");
            maxDistance = serializedObject.FindProperty("maxDistance");

            fadeInTime = serializedObject.FindProperty("fadeInTime");
            fadeOutTime = serializedObject.FindProperty("fadeOutTime");
            priority = serializedObject.FindProperty("priority");
            delay = serializedObject.FindProperty("delay");

            RemoveOnAnimationChange = serializedObject.FindProperty("RemoveOnAnimationChange");

            RebuildClipOptions();
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Sound Info", EditorStyles.boldLabel);
            //EditorGUILayout.PropertyField(ID);
            EditorGUILayout.PropertyField(ClipNames);

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Playback Options", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(sequential);
            EditorGUILayout.PropertyField(nonRepeatingBGMGroup);
            EditorGUILayout.PropertyField(loop);
            EditorGUILayout.PropertyField(followingObjectPos);
            
            EditorGUILayout.PropertyField(MixerGroupName);
            EditorGUILayout.PropertyField(overlapMax);

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Audio Settings", EditorStyles.boldLabel);

            DrawMinMaxLine("Volume", VolumeMax, VolumeMin, 0f, 1f);
            DrawMinMaxLine("Pitch", PitchMax, PitchMin, 0f, 3f);
            
            EditorGUILayout.PropertyField(priority);
            EditorGUILayout.PropertyField(delay);

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Spatial Settings", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(sound3D, new GUIContent("Enable 3D Sound"));

            if (sound3D.boolValue)
            {
                using (new EditorGUI.IndentLevelScope())
                {
                    EditorGUILayout.Slider(spatialBlend, 0f, 1f);
                    EditorGUILayout.Slider(dopplerLevel, 0f, 5f);
                    EditorGUILayout.Slider(spread, 0f, 360f);
                    EditorGUILayout.PropertyField(rolloffMode);

                    if (rolloffMode.enumValueIndex == (int)AudioRolloffMode.Custom)
                    {
                        using (new EditorGUI.IndentLevelScope())
                        {
                            EditorGUILayout.PropertyField(curveName, new GUIContent("Curve Name"));
                        }
                    }

                    EditorGUILayout.PropertyField(minDistance);
                    EditorGUILayout.PropertyField(maxDistance);
                }
            }
            else
            {
                spatialBlend.floatValue = 0f;
                rolloffMode.enumValueIndex = (int)AudioRolloffMode.Linear;

            }

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Fade Settings", EditorStyles.boldLabel);
            EditorGUILayout.PropertyField(fadeInTime);
            EditorGUILayout.PropertyField(fadeOutTime);

            EditorGUILayout.Space();
            EditorGUILayout.PropertyField(RemoveOnAnimationChange);

            DrawPreviewSimple();

            serializedObject.ApplyModifiedProperties();

            if (EditorGUI.EndChangeCheck())
            {
                RebuildClipOptions();
            }
        }

        void DrawMinMaxLine(string title, SerializedProperty maxProp, SerializedProperty minProp, float minLimit, float maxLimit)
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                // 왼쪽 제목
                EditorGUILayout.LabelField(title, GUILayout.Width(70));

                // Min
                EditorGUILayout.LabelField("Min", GUILayout.Width(30));
                minProp.floatValue = EditorGUILayout.FloatField(
                    Mathf.Clamp(minProp.floatValue, minLimit, maxLimit),
                    GUILayout.Width(60)
                );

                GUILayout.Space(8);

                // Max
                EditorGUILayout.LabelField("Max", GUILayout.Width(30));
                maxProp.floatValue = EditorGUILayout.FloatField(
                    Mathf.Clamp(maxProp.floatValue, minLimit, maxLimit),
                    GUILayout.Width(60)
                );


            }

            // Min <= Max 강제
            if (minProp.floatValue > maxProp.floatValue)
                minProp.floatValue = maxProp.floatValue;
        }

        void DrawPreviewSimple()
        {
            EditorGUILayout.LabelField("Preview", EditorStyles.boldLabel);

            if (ClipNames.arraySize <= 0)
            {
                EditorGUILayout.HelpBox("ClipNames가 비어 있습니다.", MessageType.Info);
                return;
            }

            EditorGUILayout.BeginHorizontal();
            previewIndex = EditorGUILayout.Popup(previewIndex, clipNameOptions);

            if (GUILayout.Button("Play", GUILayout.Width(50)))
            {
                var clip = FindClipByName(clipNameOptions[previewIndex]);
                if (clip != null) PreviewPlay(clip);
                else EditorGUILayout.HelpBox("클립을 찾지 못했어요.", MessageType.Warning);
            }
            if (GUILayout.Button("Stop", GUILayout.Width(50)))
                PreviewStop();
            EditorGUILayout.EndHorizontal();
        }

        void RebuildClipOptions()
        {
            if (ClipNames == null || !ClipNames.isArray) 
            {
                clipNameOptions = System.Array.Empty<string>(); 
                return; 
            }


            clipIndex = ClipNames.arraySize;
            clipNameOptions = new string[clipIndex];
            for (int i = 0; i < clipIndex; i++)
            {
                var el = ClipNames.GetArrayElementAtIndex(i);
                if(el.displayName.Contains(" "))
                {
                    Debug.LogError("공백이 있습니다.");
                }
                clipNameOptions[i] = el.displayName;
            }
            previewIndex = Mathf.Clamp(previewIndex, 0, Mathf.Max(0, clipNameOptions.Length - 1));
        }

        AudioClip FindClipByName(string clipName)
        {
            if (string.IsNullOrEmpty(clipName)) return null;
            var guids = AssetDatabase.FindAssets($"t:AudioClip {clipName}");
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var clip = AssetDatabase.LoadAssetAtPath<AudioClip>(path);
                if (clip != null && string.Equals(clip.name, clipName, System.StringComparison.OrdinalIgnoreCase))
                    return clip;
            }
            return null;
        }

        static readonly System.Type AUType = typeof(AudioImporter).Assembly.GetType("UnityEditor.AudioUtil");
        static readonly System.Reflection.MethodInfo AUPlay = AUType?.GetMethod("PlayPreviewClip", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public,null, new[] { typeof(AudioClip), typeof(int), typeof(bool) }, null)
            ?? AUType?.GetMethod("PlayPreviewClip",System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public);
        static readonly System.Reflection.MethodInfo AUStopAll = AUType?.GetMethod("StopAllPreviewClips", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public);


        static void PreviewPlay(AudioClip clip)
        {
            if (clip == null || AUPlay == null) return;
            var pars = AUPlay.GetParameters();
            if (pars.Length == 3) AUPlay.Invoke(null, new object[] { clip, 0, false });
            else AUPlay.Invoke(null, new object[] { clip });
        }


        static void PreviewStop() => AUStopAll?.Invoke(null, null);
    }
}