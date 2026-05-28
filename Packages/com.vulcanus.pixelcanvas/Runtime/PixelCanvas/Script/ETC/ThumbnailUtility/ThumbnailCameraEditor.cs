using PixelCanvas;

using UnityEditor;

#if UNITY_EDITOR
using UnityEngine;

[CustomEditor(typeof(ThumbnailCameraHandle))]
public class ThumbnailCameraEditor: Editor
{
    void OnSceneGUI()
    {
        Tools.current = Tool.None;

        var targetComp = (ThumbnailCameraHandle)target;
        var transform = targetComp.transform;

        EditorGUI.BeginChangeCheck();
        var modelPivotPosition = Handles.PositionHandle(targetComp.ModelPivot, Quaternion.identity);
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(targetComp, "Move ModelPivot");
            targetComp.ModelPivot = modelPivotPosition;
            targetComp.OnValidate();
        }

        EditorGUI.BeginChangeCheck();
        var cameraPivotPosition = Handles.PositionHandle(targetComp.CameraPivot, Quaternion.identity);
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(targetComp, "Move CameraPivot");
            targetComp.CameraPivot = cameraPivotPosition;
            targetComp.OnValidate();
        }

        //float handleSize = HandleUtility.GetHandleSize(transform.position) * 1f;

        Handles.color = Color.cyan;
        EditorGUI.BeginChangeCheck();
        var yawRotation = Handles.Disc
        (
            Quaternion.Euler(0, targetComp.GimbalEuler.y, 0),
            targetComp.CameraPivot,
            Vector3.up,
            targetComp.CameraDistance,
            false,
            0
        );
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(transform, "Rotate Object");
            targetComp.GimbalEuler.y = yawRotation.eulerAngles.y;
            targetComp.OnValidate();
        }

        Handles.color = Color.red;
        EditorGUI.BeginChangeCheck();
        var pitchRotation = Handles.Disc
        (
            Quaternion.Euler(targetComp.GimbalEuler.x, targetComp.GimbalEuler.y, 0),
            targetComp.CameraPivot,
            Vector3.Cross(Vector3.up, Quaternion.Euler(0, targetComp.GimbalEuler.y, 0) * new Vector3(0, 0, -1)),
            targetComp.CameraDistance,
            false,
            0
        );
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(transform, "Rotate Object");

            targetComp.GimbalEuler.x = pitchRotation.eulerAngles.x;
            targetComp.OnValidate();
        }

        //var localRotation = Quaternion.Euler(targetComp.LocalEuler);
        //EditorGUI.BeginChangeCheck();
        //var newLocalRotation = Handles.RotationHandle(targetComp.transform.rotation * localRotation, targetComp.transform.position);
        //if (EditorGUI.EndChangeCheck())
        //{
        //    Undo.RecordObject(targetComp, "Rotate Object");

        //    //var forward = (targetComp.ModelFBX.transform.position - targetComp.transform.position).normalized;
        //    //var q = Quaternion.LookRotation(forward, Vector3.up);
        //    //targetComp.LocalRotation = localRotation;

        //    targetComp.LocalEuler = newLocalRotation.eulerAngles;
        //    targetComp.OnValidate();
        //}


        //EditorGUI.BeginChangeCheck();
        //var localRotation = Handles.RotationHandle(targetComp.transform.rotation, targetComp.transform.position);
        //if (EditorGUI.EndChangeCheck())
        //{
        //    Undo.RecordObject(targetComp, "Rotate Object");

        //    var forward = (targetComp.ModelFBX.transform.position - targetComp.transform.position).normalized;
        //    var q = Quaternion.LookRotation(forward, Vector3.up);

        //    targetComp.LocalRotation = localRotation;
        //}

        //EditorGUI.BeginChangeCheck();
        //var handleRevolution = Handles.RotationHandle(targetComp.Revolution, targetComp.CameraPivot);
        //if (EditorGUI.EndChangeCheck())
        //{
        //    Undo.RecordObject(targetComp, "Rotate Object");
        //    targetComp._revolution = handleRevolution;

        //    var offset = new Vector3(0, 0, targetComp.CameraDistance);
        //    var cameraPosition = handleRevolution * offset;
        //    transform.position = cameraPosition + targetComp.CameraPivot;
        //    transform.rotation = handleRevolution * targetComp.LocalRotation;
        //}

    }
}
#endif