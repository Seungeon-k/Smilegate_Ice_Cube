using System.Collections;
using System.Collections.Generic;
using System.Text;

using TMPro;

using UnityEngine;

namespace PixelCanvas
{
    public class UITaskCommandMonitor : MonoBehaviour
    {
        [SerializeField] private TMP_Text _monitor;

        private StringBuilder _strBuilder = new StringBuilder();

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.OnTaskCommandUpdate, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.OnTaskCommandUpdate, NotifyEvent);
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnTaskCommandUpdate:
                    var tasks = datas[0] as Deque<TaskCommand>;
                    var redoTasks = datas[1] as Deque<TaskCommand>;

                    _strBuilder.Clear();

                    var tempStack = new Deque<TaskCommand>();
                    foreach (var task in redoTasks)
                        tempStack.Push(task);

                    foreach (var task in tempStack)
                        _strBuilder.AppendLine(task.GetType().Name);

                    _strBuilder.AppendLine("-----------------------");

                    foreach (var task in tasks)
                        _strBuilder.AppendLine(task.GetType().Name);

                    _monitor.text = _strBuilder.ToString();

                    break;
            }
        }
    }
}
