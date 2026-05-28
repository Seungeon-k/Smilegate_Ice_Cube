
namespace PixelCanvas
{
	public enum EReadOnlyType
	{
		FULLY_DISABLED,
		EDITABLE_RUNTIME,
		EDITABLE_EDITOR,
	}

	public class InspectorReadOnlyAttribute : UnityEngine.PropertyAttribute
	{

		public readonly EReadOnlyType runtimeOnly;

		public InspectorReadOnlyAttribute(EReadOnlyType runtimeOnly = EReadOnlyType.FULLY_DISABLED)
		{
			this.runtimeOnly = runtimeOnly;
		}
	}

	public class BeginReadOnlyAttribute : UnityEngine.PropertyAttribute { }

	public class EndReadOnlyAttribute : UnityEngine.PropertyAttribute { }
}