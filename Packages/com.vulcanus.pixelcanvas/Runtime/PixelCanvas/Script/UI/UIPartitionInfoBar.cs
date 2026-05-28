using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Net.NetworkInformation;

using TMPro;

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.XR;

namespace PixelCanvas
{
    public class UIPartitionInfoBar : MonoBehaviour
    {
        [SerializeField] private Button _allButton;
        [SerializeField] private TMP_Text _partitionNameText;
        [SerializeField] private Button _prvPartition;
        [SerializeField] private Button _nextPartition;
        [SerializeField] private Toggle _lockToggle;

        private void Awake()
        {
            _allButton.onClick.AddListener(() => 
            {
                //_lockToggle.SetIsOnWithoutNotify(false);
                //EventManager.Notify(EPixelArtEventID.LockPartition, false, false);
                EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            });

            _lockToggle.SetIsOnWithoutNotify(false);
            _lockToggle.onValueChanged.AddListener((flag) => 
            {
                EventManager.Notify(EPixelArtEventID.LockPartition, flag, true);
            });            

            //_prvPartition.onClick.AddListener(() =>
            //{
            //    var partitionIndex = _partitionIndex - 1;
            //    if (_modelDataName._partitions.Length <= partitionIndex)
            //        partitionIndex = 0;
            //    else if (partitionIndex <= -1)
            //        partitionIndex = _modelDataName._partitions.Length - 1;
            //    ChangePartition(partitionIndex);
            //    EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            //});

            //_nextPartition.onClick.AddListener(() =>
            //{
            //    var partitionIndex = _partitionIndex + 1;
            //    if (_modelDataName._partitions.Length <= partitionIndex)
            //        partitionIndex = 0;
            //    else if (partitionIndex <= -1)
            //        partitionIndex = _modelDataName._partitions.Length - 1;
            //    ChangePartition(partitionIndex);
            //    EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            //});

        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnLockPartition, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnLockPartition, NotifyEvent);
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnPartitionChanged:
                    {
                        var partition = datas[0] as Partition;

                        if (ParseKeyToPartsName(partition._name, out var partitionName) == true)
                        {
                            _partitionNameText.text = partitionName;
                            return;
                        }
                        _partitionNameText.text = partition._name;

                        static bool ParseKeyToPartsName(in string key, out string data)
                        {
                            var splitResult = key.Split('@');
                            if (0 == splitResult.Length)
                            {
                                data = null;
                                return false;
                            }

                            if (TextTable.TryGetTextDataString(splitResult[0], out var tableResult) == false)
                            {
                                data = null;
                                return false;
                            }

                            for (var i=1; i<splitResult.Length ; ++i)
                            {
                                tableResult += $" {splitResult[i]}";
                            }

                            data = tableResult;
                            return true;
                        }
                    }
                    break;
                case EPixelArtEventID.OnLockPartition:
                    {
                        var lockFlag = (bool)datas[0];
                        _lockToggle.isOn = lockFlag;
                    }
                    break;
            }
        }

    }
}
