using UnityEngine;
using UnityEditor;

namespace GraphProcessor
{
	[ExecuteAlways]
	public class DeleteCallback : UnityEditor.AssetModificationProcessor
	{
		static AssetDeleteResult OnWillDeleteAsset(string path, RemoveAssetOptions options)
		{
            if (path.EndsWith(".unity"))
                return AssetDeleteResult.DidNotDelete; // 씬 삭제는 건드리지 않음
            
			var objects = AssetDatabase.LoadAllAssetsAtPath(path);

			foreach (var obj in objects)
			{
				if (obj is BaseGraph b)
				{
					foreach (var graphWindow in Resources.FindObjectsOfTypeAll< BaseGraphWindow >())
						graphWindow.OnGraphDeleted();
					
					b.OnAssetDeleted();
				}
			}

			return AssetDeleteResult.DidNotDelete;
		}
	}
}