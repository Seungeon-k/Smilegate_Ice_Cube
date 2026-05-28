using GeneratedTable;
using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(SoundScriptableObject.ClipInfo))]
public class ClipInfoDrawer : PropertyDrawer
{
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        // fileName 한 줄 + path 한 줄 + 간격 약간
        return EditorGUIUtility.singleLineHeight * 3f
             + EditorGUIUtility.standardVerticalSpacing * 4f;
    }

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.BeginProperty(position, label, property);

        // 기본 인덴트 처리
        var indent = EditorGUI.indentLevel;
        EditorGUI.indentLevel = 0;

        // 내부 프로퍼티 찾기
        var fileNameProp = property.FindPropertyRelative("fileName");
        var pathProp = property.FindPropertyRelative("path");
        var weightProp = property.FindPropertyRelative("weight");

        float lineHeight = EditorGUIUtility.singleLineHeight;
        float spacing = EditorGUIUtility.standardVerticalSpacing;

        // 첫 줄: fileName
        var fileRect = new Rect(
            position.x,
            position.y,
            position.width,
            lineHeight
        );

        // 둘째 줄: path (SoundLabelType)
        var pathRect = new Rect(
            position.x,
            position.y + lineHeight + spacing,
            position.width,
            lineHeight
        );

        var weightRect = new Rect(
            position.x,
            position.y + (lineHeight + spacing) * 2,
            position.width, 
            lineHeight
        );
        
        // fileName 필드 + 드래그 드롭 처리
        EditorGUI.PropertyField(fileRect, fileNameProp);
        HandleDragAndDrop(fileRect, fileNameProp);

        // SoundLabelType enum 필드
        EditorGUI.PropertyField(pathRect, pathProp);
       
        // weight
        EditorGUI.PropertyField(weightRect, weightProp);

        EditorGUI.indentLevel = indent;
        EditorGUI.EndProperty();
    }

    void HandleDragAndDrop(Rect dropArea, SerializedProperty fileNameProp)
    {
        Event evt = Event.current;

        if (!dropArea.Contains(evt.mousePosition))
            return;

        if (evt.type == EventType.DragUpdated)
        {
            DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
            evt.Use();
        }

        if (evt.type == EventType.DragPerform)
        {
            DragAndDrop.AcceptDrag();
            foreach (var obj in DragAndDrop.objectReferences)
            {
                var clip = obj as AudioClip;
                if (clip != null)
                {
                    fileNameProp.stringValue = clip.name; // 파일 이름만 넣기
                    fileNameProp.serializedObject.ApplyModifiedProperties();
                    break;
                }
            }
            evt.Use();
        }
    }
}
