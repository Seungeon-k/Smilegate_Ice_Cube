using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.VAddressable;

namespace UnityEditor.VAddressable
{
    [CreateAssetMenu(menuName = "Addressables/Category/Group Category", fileName = "VAddressableGroupCategory")]
    public class VAddressableGroupCategory : ScriptableObject
    {
        public UserFrameworkMode UserFrameworkMode = UserFrameworkMode.V;
        
        public List<VAddressableGroupCategory> Dependencies = new();
    }
}