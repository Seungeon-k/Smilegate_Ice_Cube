namespace UnityEngine.VAddressable
{
    public enum BuildScope
    {
        CategoryOnly, //실제 서비스에서 개별적인 카테고리별 빌드를 할 때
        CategoryAndDependencies // 개발 에디터에서 필요한 모든 번들을 빌드할 때
    }
    
    public enum UserFrameworkMode
    {
        V,
        USGUser, // 모드실 USGFramework에서 만들어진 창작 모드
        GameUser // 유저 GameFramework에서 만들어진 창작 모드
    }
}