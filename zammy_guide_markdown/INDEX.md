# 재미스미스(Zammy Smith) 크리에이터 가이드 INDEX

총 451개 페이지. 원본은 https://developers-zammysmith.onstove.com/ko/ 의 SingleFile 저장본을 변환한 결과입니다. 각 페이지 상단 frontmatter에 `source_url` / `last_updated` 메타데이터가 있습니다.

## 카테고리 요약

- **시작하기** (2)
- **Creator Hub** (4)
- **Lua Script API** (445)
  - [Components](#luascript--components) (264)
  - [DataTypes](#luascript--datatypes) (35)
  - [Resources](#luascript--resources) (11)
  - [Utilities](#luascript--utilities) (22)
  - [VObjects](#luascript--vobjects) (113)

## 시작하기

- [사용시 유의 사항](Important-Notes-for-Use.md)
- [재미스미스 소개](Introduction.md)

## Creator Hub

- [분석](creator-hub/Analytics.md)
- [홈 대시보드](creator-hub/dashboard.md)
- [게임 출시 관리](creator-hub/game_release.md)
- [게임 서비스](creator-hub/gameservice.md)

## Lua Script API

### LuaScript / Components (264) <a id="luascript--components"></a>

**단일 페이지**

- [MeshCollider](LuaScript/Components/MeshCollider.md)
- [MeshRenderer](LuaScript/Components/MeshRenderer.md)
- [SkinnedMeshRenderer](LuaScript/Components/SkinnedMeshRenderer.md)

#### Animation (14)

_Methods_ (7)

- [Blend](LuaScript/Components/Animation/Methods/Animation_Blend.md)
- [CrossFade](LuaScript/Components/Animation/Methods/Animation_CrossFade.md)
- [IsPlaying](LuaScript/Components/Animation/Methods/Animation_IsPlaying_UAnimationWrap_string.md)
- [Play](LuaScript/Components/Animation/Methods/Animation_Play.md)
- [Rewind](LuaScript/Components/Animation/Methods/Animation_Rewind.md)
- [Stop](LuaScript/Components/Animation/Methods/Animation_Stop.md)
- [SyncLayer](LuaScript/Components/Animation/Methods/Animation_SyncLayer_UAnimationWrap_number.md)

_Properties_ (7)

- [animatePhysics](LuaScript/Components/Animation/Properties/Animation_animatePhysics.md)
- [clip](LuaScript/Components/Animation/Properties/Animation_clip.md)
- [cullingType](LuaScript/Components/Animation/Properties/Animation_cullingType.md)
- [isPlaying](LuaScript/Components/Animation/Properties/Animation_isPlaying.md)
- [localBounds](LuaScript/Components/Animation/Properties/Animation_localBounds.md)
- [playAutomatically](LuaScript/Components/Animation/Properties/Animation_playAutomatically.md)
- [wrapMode](LuaScript/Components/Animation/Properties/Animation_wrapMode.md)

#### Animator (42)

_Methods_ (17)

- [GetBool](LuaScript/Components/Animator/Methods/Animator_GetBool_UAnimatorWrap_string.md)
- [GetCurrentAnimatorStateInfo](LuaScript/Components/Animator/Methods/Animator_GetCurrentAnimatorStateInfo_UAnimatorWrap_number.md)
- [GetInteger](LuaScript/Components/Animator/Methods/Animator_GetInteger.md)
- [GetLayerIndex](LuaScript/Components/Animator/Methods/Animator_GetLayerIndex_UAnimatorWrap_string.md)
- [GetLayerName](LuaScript/Components/Animator/Methods/Animator_GetLayerName_UAnimatorWrap_number.md)
- [GetLayerWeight](LuaScript/Components/Animator/Methods/Animator_GetLayerWeight_UAnimatorWrap_number.md)
- [GetNextAnimatorStateInfo](LuaScript/Components/Animator/Methods/Animator_GetNextAnimatorStateInfo_UAnimatorWrap_number.md)
- [HasState](LuaScript/Components/Animator/Methods/Animator_HasState_UAnimatorWrap_number_number.md)
- [IsInTransition](LuaScript/Components/Animator/Methods/Animator_IsInTransition_UAnimatorWrap_number.md)
- [IsParameterControlledByCurve](LuaScript/Components/Animator/Methods/Animator_IsParameterControlledByCurve.md)
- [Play](LuaScript/Components/Animator/Methods/Animator_Play.md)
- [ResetTrigger](LuaScript/Components/Animator/Methods/Animator_ResetTrigger.md)
- [SetBool](LuaScript/Components/Animator/Methods/Animator_SetBool_UAnimatorWrap_string_boolean.md)
- [SetFloat](LuaScript/Components/Animator/Methods/Animator_SetFloat_UAnimatorWrap_string_number.md)
- [SetInteger](LuaScript/Components/Animator/Methods/Animator_SetInteger.md)
- [SetTrigger](LuaScript/Components/Animator/Methods/Animator_SetTrigger.md)
- [StringToHash](LuaScript/Components/Animator/Methods/Animator_StringToHash_string.md)

_Properties_ (25)

- [angularVelocity](LuaScript/Components/Animator/Properties/Animator_angularVelocity.md)
- [applyRootMotion](LuaScript/Components/Animator/Properties/Animator_applyRootMotion.md)
- [bodyPosition](LuaScript/Components/Animator/Properties/Animator_bodyPosition.md)
- [bodyRotation](LuaScript/Components/Animator/Properties/Animator_bodyRotation.md)
- [deltaPosition](LuaScript/Components/Animator/Properties/Animator_deltaPosition.md)
- [deltaRotation](LuaScript/Components/Animator/Properties/Animator_deltaRotation.md)
- [enabled](LuaScript/Components/Animator/Properties/Animator_enabled.md)
- [fireEvents](LuaScript/Components/Animator/Properties/Animator_fireEvents.md)
- [gravityWeight](LuaScript/Components/Animator/Properties/Animator_gravityWeight.md)
- [hasRootMotion](LuaScript/Components/Animator/Properties/Animator_hasRootMotion.md)
- [hasTransformHierarchy](LuaScript/Components/Animator/Properties/Animator_hasTransformHierarchy.md)
- [humanScale](LuaScript/Components/Animator/Properties/Animator_humanScale.md)
- [isHuman](LuaScript/Components/Animator/Properties/Animator_isHuman.md)
- [isInitialized](LuaScript/Components/Animator/Properties/Animator_isInitialized.md)
- [isMatchingTarget](LuaScript/Components/Animator/Properties/Animator_isMatchingTarget.md)
- [isOptimizable](LuaScript/Components/Animator/Properties/Animator_isOptimizable.md)
- [layerCount](LuaScript/Components/Animator/Properties/Animator_layerCount.md)
- [rootPosition](LuaScript/Components/Animator/Properties/Animator_rootPosition.md)
- [rootRotation](LuaScript/Components/Animator/Properties/Animator_rootRotation.md)
- [speed](LuaScript/Components/Animator/Properties/Animator_speed.md)
- [stabilizeFeet](LuaScript/Components/Animator/Properties/Animator_stabilizeFeet.md)
- [targetPosition](LuaScript/Components/Animator/Properties/Animator_targetPosition.md)
- [targetRotation](LuaScript/Components/Animator/Properties/Animator_targetRotation.md)
- [updateMode](LuaScript/Components/Animator/Properties/Animator_updateMode.md)
- [velocity](LuaScript/Components/Animator/Properties/Animator_velocity.md)

#### AudioSource (15)

_Methods_ (7)

- [Pause](LuaScript/Components/AudioSource/Methods/AudioSource_Pause_UAudioSourceWrap.md)
- [Play](LuaScript/Components/AudioSource/Methods/AudioSource_Play.md)
- [PlayDelayed](LuaScript/Components/AudioSource/Methods/AudioSource_PlayDelayed_UAudioSourceWrap_number.md)
- [PlayOneShot](LuaScript/Components/AudioSource/Methods/AudioSource_PlayOneShot.md)
- [PlayScheduled](LuaScript/Components/AudioSource/Methods/AudioSource_PlayScheduled_UAudioSourceWrap_number.md)
- [Stop](LuaScript/Components/AudioSource/Methods/AudioSource_Stop_UAudioSourceWrap.md)
- [UnPause](LuaScript/Components/AudioSource/Methods/AudioSource_UnPause_UAudioSourceWrap.md)

_Properties_ (8)

- [clip](LuaScript/Components/AudioSource/Properties/AudioSource_clip.md)
- [isPlaying](LuaScript/Components/AudioSource/Properties/AudioSource_isPlaying.md)
- [loop](LuaScript/Components/AudioSource/Properties/AudioSource_loop.md)
- [maxDistance](LuaScript/Components/AudioSource/Properties/AudioSource_maxDistance.md)
- [minDistance](LuaScript/Components/AudioSource/Properties/AudioSource_minDistance.md)
- [mute](LuaScript/Components/AudioSource/Properties/AudioSource_mute.md)
- [pitch](LuaScript/Components/AudioSource/Properties/AudioSource_pitch.md)
- [volume](LuaScript/Components/AudioSource/Properties/AudioSource_volume.md)

#### BoxCollider (2)

_Properties_ (2)

- [center](LuaScript/Components/BoxCollider/Properties/BoxCollider_center.md)
- [size](LuaScript/Components/BoxCollider/Properties/BoxCollider_size.md)

#### Button (1)

_Events_ (1)

- [onClick](LuaScript/Components/Button/Events/Button_onClick.md)

#### Camera (13)

_Methods_ (8)

- [ScreenPointToRay](LuaScript/Components/Camera/Methods/Camera_ScreenPointToRay_UCameraWrap_Vector3.md)
- [ScreenToViewportPoint](LuaScript/Components/Camera/Methods/Camera_ScreenToViewportPoint_UCameraWrap_Vector3.md)
- [ScreenToWorldPoint](LuaScript/Components/Camera/Methods/Camera_ScreenToWorldPoint_UCameraWrap_Vector3.md)
- [ViewportPointToRay](LuaScript/Components/Camera/Methods/Camera_ViewportPointToRay_UCameraWrap_Vector3.md)
- [ViewportToScreenPoint](LuaScript/Components/Camera/Methods/Camera_ViewportToScreenPoint_UCameraWrap_Vector3.md)
- [ViewportToWorldPoint](LuaScript/Components/Camera/Methods/Camera_ViewportToWorldPoint_UCameraWrap_Vector3.md)
- [WorldToScreenPoint](LuaScript/Components/Camera/Methods/Camera_WorldToScreenPoint_UCameraWrap_Vector3.md)
- [WorldToViewportPoint](LuaScript/Components/Camera/Methods/Camera_WorldToViewportPoint_UCameraWrap_Vector3.md)

_Properties_ (5)

- [farClipPlane](LuaScript/Components/Camera/Properties/Camera_farClipPlane.md)
- [fieldOfView](LuaScript/Components/Camera/Properties/Camera_fieldOfView.md)
- [nearClipPlane](LuaScript/Components/Camera/Properties/Camera_nearClipPlane.md)
- [pixelHeight](LuaScript/Components/Camera/Properties/Camera_pixelHeight.md)
- [pixelWidth](LuaScript/Components/Camera/Properties/Camera_pixelWidth.md)

#### Canvas (6)

_Properties_ (6)

- [canvasRect](LuaScript/Components/Canvas/Properties/Canvas_canvasRect.md)
- [isRootCanvas](LuaScript/Components/Canvas/Properties/Canvas_isRootCanvas.md)
- [pixelRect](LuaScript/Components/Canvas/Properties/Canvas_pixelRect.md)
- [planeDistance](LuaScript/Components/Canvas/Properties/Canvas_planeDistance.md)
- [renderingDisplaySize](LuaScript/Components/Canvas/Properties/Canvas_renderingDisplaySize.md)
- [scaleFactor](LuaScript/Components/Canvas/Properties/Canvas_scaleFactor.md)

#### CapsuleCollider (4)

_Properties_ (4)

- [center](LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_center.md)
- [direction](LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_direction.md)
- [height](LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_height.md)
- [radius](LuaScript/Components/CapsuleCollider/Properties/CapsuleCollider_radius.md)

#### Collider (9)

_Methods_ (3)

- [ClosestPointOnBounds](LuaScript/Components/Collider/Methods/Collider_ClosestPointOnBounds_UColliderWrap_Vector3.md)
- [ClosestPoint](LuaScript/Components/Collider/Methods/Collider_ClosestPoint_UColliderWrap_Vector3.md)
- [Raycast](LuaScript/Components/Collider/Methods/Collider_Raycast_UColliderWrap_Ray_number.md)

_Properties_ (6)

- [attachedRigidbody](LuaScript/Components/Collider/Properties/Collider_attachedRigidbody.md)
- [bounds](LuaScript/Components/Collider/Properties/Collider_bounds.md)
- [enabled](LuaScript/Components/Collider/Properties/Collider_enabled.md)
- [isTrigger](LuaScript/Components/Collider/Properties/Collider_isTrigger.md)
- [material](LuaScript/Components/Collider/Properties/Collider_material.md)
- [sharedMaterial](LuaScript/Components/Collider/Properties/Collider_sharedMaterial.md)

#### Image (28)

_Methods_ (6)

- [CalculateLayoutInputHorizontal](LuaScript/Components/Image/Methods/Image_CalculateLayoutInputHorizontal_UImageWrap.md)
- [CalculateLayoutInputVertical](LuaScript/Components/Image/Methods/Image_CalculateLayoutInputVertical_UImageWrap.md)
- [DisableSpriteOptimizations](LuaScript/Components/Image/Methods/Image_DisableSpriteOptimizations_UImageWrap.md)
- [OnAfterDeserialize](LuaScript/Components/Image/Methods/Image_OnAfterDeserialize_UImageWrap.md)
- [OnBeforeSerialize](LuaScript/Components/Image/Methods/Image_OnBeforeSerialize_UImageWrap.md)
- [SetNativeSize](LuaScript/Components/Image/Methods/Image_SetNativeSize_UImageWrap.md)

_Properties_ (22)

- [alphaHitTestMinimumThreshold](LuaScript/Components/Image/Properties/Image_alphaHitTestMinimumThreshold.md)
- [color](LuaScript/Components/Image/Properties/Image_color.md)
- [fillAmount](LuaScript/Components/Image/Properties/Image_fillAmount.md)
- [fillCenter](LuaScript/Components/Image/Properties/Image_fillCenter.md)
- [fillClockwise](LuaScript/Components/Image/Properties/Image_fillClockwise.md)
- [fillOrigin](LuaScript/Components/Image/Properties/Image_fillOrigin.md)
- [flexibleHeight](LuaScript/Components/Image/Properties/Image_flexibleHeight.md)
- [flexibleWidth](LuaScript/Components/Image/Properties/Image_flexibleWidth.md)
- [hasBorder](LuaScript/Components/Image/Properties/Image_hasBorder.md)
- [layoutPriority](LuaScript/Components/Image/Properties/Image_layoutPriority.md)
- [mainTexture](LuaScript/Components/Image/Properties/Image_mainTexture.md)
- [material](LuaScript/Components/Image/Properties/Image_material.md)
- [minHeight](LuaScript/Components/Image/Properties/Image_minHeight.md)
- [minWidth](LuaScript/Components/Image/Properties/Image_minWidth.md)
- [overrideSprite](LuaScript/Components/Image/Properties/Image_overrideSprite.md)
- [pixelsPerUnit](LuaScript/Components/Image/Properties/Image_pixelsPerUnit.md)
- [pixelsPerUnitMultiplier](LuaScript/Components/Image/Properties/Image_pixelsPerUnitMultiplier.md)
- [preferredHeight](LuaScript/Components/Image/Properties/Image_preferredHeight.md)
- [preferredWidth](LuaScript/Components/Image/Properties/Image_preferredWidth.md)
- [preserveAspect](LuaScript/Components/Image/Properties/Image_preserveAspect.md)
- [sprite](LuaScript/Components/Image/Properties/Image_sprite.md)
- [useSpriteMesh](LuaScript/Components/Image/Properties/Image_useSpriteMesh.md)

#### InputBindingHandler (2)

_Methods_ (1)

- [SetVector2Value](LuaScript/Components/InputBindingHandler/Methods/InputBindingHandler_SetVector2Value_InputBindingHandler.md)

_Properties_ (1)

- [inputEnabled](LuaScript/Components/InputBindingHandler/Properties/InputBindingHandler_inputEnabled.md)

#### ParticleSystem (17)

_Methods_ (5)

- [Clear](LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Clear.md)
- [IsAlive](LuaScript/Components/ParticleSystem/Methods/ParticleSystem_IsAlive.md)
- [Pause](LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Pause.md)
- [Play](LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Play.md)
- [Stop](LuaScript/Components/ParticleSystem/Methods/ParticleSystem_Stop.md)

_Properties_ (12)

- [has3DParticleRotations](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_has3DParticleRotations.md)
- [hasNonUniformParticleSizes](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_hasNonUniformParticleSizes.md)
- [isEmitting](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isEmitting.md)
- [isPaused](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isPaused.md)
- [isPlaying](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isPlaying.md)
- [isStopped](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_isStopped.md)
- [particleCount](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_particleCount.md)
- [proceduralSimulationSupported](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_proceduralSimulationSupported.md)
- [randomSeed](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_randomSeed.md)
- [time](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_time.md)
- [totalTime](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_totalTime.md)
- [useAutoRandomSeed](LuaScript/Components/ParticleSystem/Properties/ParticleSystem_useAutoRandomSeed.md)

#### RectTransform (10)

_Methods_ (1)

- [ForceUpdateRectTransforms](LuaScript/Components/RectTransform/Methods/RectTransform_ForceUpdateRectTransforms_URectTransformWrap.md)

_Properties_ (9)

- [anchorMax](LuaScript/Components/RectTransform/Properties/RectTransform_anchorMax.md)
- [anchorMin](LuaScript/Components/RectTransform/Properties/RectTransform_anchorMin.md)
- [anchoredPosition](LuaScript/Components/RectTransform/Properties/RectTransform_anchoredPosition.md)
- [anchoredPosition3D](LuaScript/Components/RectTransform/Properties/RectTransform_anchoredPosition3D.md)
- [offsetMax](LuaScript/Components/RectTransform/Properties/RectTransform_offsetMax.md)
- [offsetMin](LuaScript/Components/RectTransform/Properties/RectTransform_offsetMin.md)
- [pivot](LuaScript/Components/RectTransform/Properties/RectTransform_pivot.md)
- [rect](LuaScript/Components/RectTransform/Properties/RectTransform_rect.md)
- [sizeDelta](LuaScript/Components/RectTransform/Properties/RectTransform_sizeDelta.md)

#### Renderer (11)

_Properties_ (11)

- [bounds](LuaScript/Components/Renderer/Properties/Renderer_bounds.md)
- [enabled](LuaScript/Components/Renderer/Properties/Renderer_enabled.md)
- [forceRenderingOff](LuaScript/Components/Renderer/Properties/Renderer_forceRenderingOff.md)
- [isVisible](LuaScript/Components/Renderer/Properties/Renderer_isVisible.md)
- [localBounds](LuaScript/Components/Renderer/Properties/Renderer_localBounds.md)
- [material](LuaScript/Components/Renderer/Properties/Renderer_material.md)
- [materials](LuaScript/Components/Renderer/Properties/Renderer_materials.md)
- [receiveShadows](LuaScript/Components/Renderer/Properties/Renderer_receiveShadows.md)
- [shadowCastingMode](LuaScript/Components/Renderer/Properties/Renderer_shadowCastingMode.md)
- [sharedMaterial](LuaScript/Components/Renderer/Properties/Renderer_sharedMaterial.md)
- [sharedMaterials](LuaScript/Components/Renderer/Properties/Renderer_sharedMaterials.md)

#### Rigidbody (19)

_Methods_ (11)

- [AddExplosionForce](LuaScript/Components/Rigidbody/Methods/Rigidbody_AddExplosionForce.md)
- [AddForce](LuaScript/Components/Rigidbody/Methods/Rigidbody_AddForce.md)
- [AddRelativeForce](LuaScript/Components/Rigidbody/Methods/Rigidbody_AddRelativeForce.md)
- [AddRelativeTorque](LuaScript/Components/Rigidbody/Methods/Rigidbody_AddRelativeTorque.md)
- [AddTorque](LuaScript/Components/Rigidbody/Methods/Rigidbody_AddTorque.md)
- [GetAccumulatedForce](LuaScript/Components/Rigidbody/Methods/Rigidbody_GetAccumulatedForce_URigidbodyWrap.md)
- [GetAccumulatedTorque](LuaScript/Components/Rigidbody/Methods/Rigidbody_GetAccumulatedTorque_URigidbodyWrap.md)
- [GetPointVelocity](LuaScript/Components/Rigidbody/Methods/Rigidbody_GetPointVelocity_URigidbodyWrap_Vector3.md)
- [GetRelativePointVelocity](LuaScript/Components/Rigidbody/Methods/Rigidbody_GetRelativePointVelocity_URigidbodyWrap_Vector3.md)
- [MovePosition](LuaScript/Components/Rigidbody/Methods/Rigidbody_MovePosition_URigidbodyWrap_Vector3.md)
- [MoveRotation](LuaScript/Components/Rigidbody/Methods/Rigidbody_MoveRotation_URigidbodyWrap_Quaternion.md)

_Properties_ (8)

- [angularVelocity](LuaScript/Components/Rigidbody/Properties/Rigidbody_angularVelocity.md)
- [constraints](LuaScript/Components/Rigidbody/Properties/Rigidbody_constraints.md)
- [isKinematic](LuaScript/Components/Rigidbody/Properties/Rigidbody_isKinematic.md)
- [mass](LuaScript/Components/Rigidbody/Properties/Rigidbody_mass.md)
- [position](LuaScript/Components/Rigidbody/Properties/Rigidbody_position.md)
- [rotation](LuaScript/Components/Rigidbody/Properties/Rigidbody_rotation.md)
- [useGravity](LuaScript/Components/Rigidbody/Properties/Rigidbody_useGravity.md)
- [velocity](LuaScript/Components/Rigidbody/Properties/Rigidbody_velocity.md)

#### Slider (6)

_Methods_ (1)

- [SetValueWithoutNotify](LuaScript/Components/Slider/Methods/Slider_SetValueWithoutNotify_USliderWrap_number.md)

_Properties_ (5)

- [maxValue](LuaScript/Components/Slider/Properties/Slider_maxValue.md)
- [minValue](LuaScript/Components/Slider/Properties/Slider_minValue.md)
- [normalizedValue](LuaScript/Components/Slider/Properties/Slider_normalizedValue.md)
- [value](LuaScript/Components/Slider/Properties/Slider_value.md)
- [wholeNumbers](LuaScript/Components/Slider/Properties/Slider_wholeNumbers.md)

#### SphereCollider (2)

_Properties_ (2)

- [center](LuaScript/Components/SphereCollider/Properties/SphereCollider_center.md)
- [radius](LuaScript/Components/SphereCollider/Properties/SphereCollider_radius.md)

#### TMP_Text (2)

_Properties_ (2)

- [color](LuaScript/Components/TMP_Text/Properties/TMP_Text_color.md)
- [text](LuaScript/Components/TMP_Text/Properties/TMP_Text_text.md)

#### TextMeshPro (3)

_Methods_ (1)

- [ForceMeshUpdate](LuaScript/Components/TextMeshPro/Methods/TextMeshPro_ForceMeshUpdate.md)

_Properties_ (2)

- [color](LuaScript/Components/TextMeshPro/Properties/TextMeshPro_color.md)
- [text](LuaScript/Components/TextMeshPro/Properties/TextMeshPro_text.md)

#### TextMeshProUGUI (17)

_Methods_ (12)

- [CalculateLayoutInputHorizontal](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_CalculateLayoutInputHorizontal_UTextMeshProUGUIWrap.md)
- [CalculateLayoutInputVertical](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_CalculateLayoutInputVertical_UTextMeshProUGUIWrap.md)
- [ComputeMarginSize](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_ComputeMarginSize_UTextMeshProUGUIWrap.md)
- [Cull](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_Cull_UTextMeshProUGUIWrap_Rect_boolean.md)
- [Rebuild](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_Rebuild_UTextMeshProUGUIWrap_CanvasUpdate.md)
- [RecalculateClipping](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_RecalculateClipping_UTextMeshProUGUIWrap.md)
- [SetAllDirty](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetAllDirty_UTextMeshProUGUIWrap.md)
- [SetLayoutDirty](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetLayoutDirty_UTextMeshProUGUIWrap.md)
- [SetMaterialDirty](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetMaterialDirty_UTextMeshProUGUIWrap.md)
- [SetVerticesDirty](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_SetVerticesDirty_UTextMeshProUGUIWrap.md)
- [UpdateFontAsset](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_UpdateFontAsset_UTextMeshProUGUIWrap.md)
- [UpdateVertexData](LuaScript/Components/TextMeshProUGUI/Methods/TextMeshProUGUI_UpdateVertexData.md)

_Properties_ (5)

- [autoSizeTextContainer](LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_autoSizeTextContainer.md)
- [canvasRenderer](LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_canvasRenderer.md)
- [maskOffset](LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_maskOffset.md)
- [materialForRendering](LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_materialForRendering.md)
- [mesh](LuaScript/Components/TextMeshProUGUI/Properties/TextMeshProUGUI_mesh.md)

#### TrailRenderer (7)

_Methods_ (1)

- [Clear](LuaScript/Components/TrailRenderer/Methods/TrailRenderer_Clear_UTrailRendererWrap.md)

_Properties_ (6)

- [endColor](LuaScript/Components/TrailRenderer/Properties/TrailRenderer_endColor.md)
- [endWidth](LuaScript/Components/TrailRenderer/Properties/TrailRenderer_endWidth.md)
- [startColor](LuaScript/Components/TrailRenderer/Properties/TrailRenderer_startColor.md)
- [startWidth](LuaScript/Components/TrailRenderer/Properties/TrailRenderer_startWidth.md)
- [time](LuaScript/Components/TrailRenderer/Properties/TrailRenderer_time.md)
- [widthMultiplier](LuaScript/Components/TrailRenderer/Properties/TrailRenderer_widthMultiplier.md)

#### Transform (27)

_Methods_ (14)

- [ChangeLocalScale](LuaScript/Components/Transform/Methods/Transform_ChangeLocalScale_UTransformWrap_Vector3.md)
- [ChangePosition](LuaScript/Components/Transform/Methods/Transform_ChangePosition_UTransformWrap_Vector3.md)
- [ChangeRotation](LuaScript/Components/Transform/Methods/Transform_ChangeRotation_UTransformWrap_Vector3.md)
- [InverseTransformDirection](LuaScript/Components/Transform/Methods/Transform_InverseTransformDirection.md)
- [InverseTransformPoint](LuaScript/Components/Transform/Methods/Transform_InverseTransformPoint.md)
- [InverseTransformVector](LuaScript/Components/Transform/Methods/Transform_InverseTransformVector.md)
- [LookAt](LuaScript/Components/Transform/Methods/Transform_LookAt.md)
- [Rotate](LuaScript/Components/Transform/Methods/Transform_Rotate.md)
- [RotateAround](LuaScript/Components/Transform/Methods/Transform_RotateAround_UTransformWrap_Vector3_Vector3_number.md)
- [SyncTransform](LuaScript/Components/Transform/Methods/Transform_SyncTransform_UTransformWrap.md)
- [TransformDirection](LuaScript/Components/Transform/Methods/Transform_TransformDirection.md)
- [TransformPoint](LuaScript/Components/Transform/Methods/Transform_TransformPoint.md)
- [TransformVector](LuaScript/Components/Transform/Methods/Transform_TransformVector.md)
- [Translate](LuaScript/Components/Transform/Methods/Transform_Translate.md)

_Properties_ (13)

- [eulerAngles](LuaScript/Components/Transform/Properties/Transform_eulerAngles.md)
- [forward](LuaScript/Components/Transform/Properties/Transform_forward.md)
- [localEulerAngles](LuaScript/Components/Transform/Properties/Transform_localEulerAngles.md)
- [localPosition](LuaScript/Components/Transform/Properties/Transform_localPosition.md)
- [localRotation](LuaScript/Components/Transform/Properties/Transform_localRotation.md)
- [localScale](LuaScript/Components/Transform/Properties/Transform_localScale.md)
- [lossyScale](LuaScript/Components/Transform/Properties/Transform_lossyScale.md)
- [name](LuaScript/Components/Transform/Properties/Transform_name.md)
- [position](LuaScript/Components/Transform/Properties/Transform_position.md)
- [right](LuaScript/Components/Transform/Properties/Transform_right.md)
- [rotation](LuaScript/Components/Transform/Properties/Transform_rotation.md)
- [up](LuaScript/Components/Transform/Properties/Transform_up.md)
- [vObject](LuaScript/Components/Transform/Properties/Transform_vObject.md)

#### VTween (4)

_Methods_ (2)

- [Play](LuaScript/Components/VTween/Methods/VTween_Play_VTween.md)
- [Stop](LuaScript/Components/VTween/Methods/VTween_Stop_VTween.md)

_Events_ (2)

- [OnTweenComplete](LuaScript/Components/VTween/Events/VTween_OnTweenComplete.md)
- [OnTweenStart](LuaScript/Components/VTween/Events/VTween_OnTweenStart.md)

### LuaScript / DataTypes (35) <a id="luascript--datatypes"></a>

#### AnimatorStateInfo (10)

_Methods_ (2)

- [IsName](LuaScript/DataTypes/AnimatorStateInfo/Methods/AnimatorStateInfo_IsName_AnimatorStateInfo_string.md)
- [IsTag](LuaScript/DataTypes/AnimatorStateInfo/Methods/AnimatorStateInfo_IsTag_AnimatorStateInfo_string.md)

_Properties_ (8)

- [fullPathHash](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_fullPathHash.md)
- [length](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_length.md)
- [loop](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_loop.md)
- [normalizedTime](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_normalizedTime.md)
- [shortNameHash](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_shortNameHash.md)
- [speed](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_speed.md)
- [speedMultiplier](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_speedMultiplier.md)
- [tagHash](LuaScript/DataTypes/AnimatorStateInfo/Properties/AnimatorStateInfo_tagHash.md)

#### Bounds (19)

_Methods_ (14)

- [ClosestPoint](LuaScript/DataTypes/Bounds/Methods/Bounds_ClosestPoint_Bounds_Vector3.md)
- [Contains](LuaScript/DataTypes/Bounds/Methods/Bounds_Contains_Bounds_Vector3.md)
- [Encapsulate](LuaScript/DataTypes/Bounds/Methods/Bounds_Encapsulate_Bounds_Vector3.md)
- [Expand](LuaScript/DataTypes/Bounds/Methods/Bounds_Expand.md)
- [GetMax](LuaScript/DataTypes/Bounds/Methods/Bounds_GetMax_Bounds.md)
- [GetMin](LuaScript/DataTypes/Bounds/Methods/Bounds_GetMin_Bounds.md)
- [GetSize](LuaScript/DataTypes/Bounds/Methods/Bounds_GetSize_Bounds.md)
- [Get](LuaScript/DataTypes/Bounds/Methods/Bounds_Get_Bounds.md)
- [IntersectRay](LuaScript/DataTypes/Bounds/Methods/Bounds_IntersectRay_Bounds_Ray.md)
- [Intersects](LuaScript/DataTypes/Bounds/Methods/Bounds_Intersects_Bounds_Bounds.md)
- [SetMax](LuaScript/DataTypes/Bounds/Methods/Bounds_SetMax_Bounds_Vector3.md)
- [SetMinMax](LuaScript/DataTypes/Bounds/Methods/Bounds_SetMinMax_Bounds_Vector3_Vector3.md)
- [SetMin](LuaScript/DataTypes/Bounds/Methods/Bounds_SetMin_Bounds_Vector3.md)
- [SetSize](LuaScript/DataTypes/Bounds/Methods/Bounds_SetSize_Bounds_Vector3.md)

_Properties_ (5)

- [center](LuaScript/DataTypes/Bounds/Properties/Bounds_center.md)
- [extents](LuaScript/DataTypes/Bounds/Properties/Bounds_extents.md)
- [max](LuaScript/DataTypes/Bounds/Properties/Bounds_max.md)
- [min](LuaScript/DataTypes/Bounds/Properties/Bounds_min.md)
- [size](LuaScript/DataTypes/Bounds/Properties/Bounds_size.md)

#### Collision (6)

_Properties_ (6)

- [collider](LuaScript/DataTypes/Collision/Properties/Collision_collider.md)
- [impulse](LuaScript/DataTypes/Collision/Properties/Collision_impulse.md)
- [relativeVelocity](LuaScript/DataTypes/Collision/Properties/Collision_relativeVelocity.md)
- [rigidbody](LuaScript/DataTypes/Collision/Properties/Collision_rigidbody.md)
- [transform](LuaScript/DataTypes/Collision/Properties/Collision_transform.md)
- [vObject](LuaScript/DataTypes/Collision/Properties/Collision_vObject.md)

### LuaScript / Resources (11) <a id="luascript--resources"></a>

#### AnimationClip (11)

_Properties_ (11)

- [empty](LuaScript/Resources/AnimationClip/Properties/AnimationClip_empty.md)
- [frameRate](LuaScript/Resources/AnimationClip/Properties/AnimationClip_frameRate.md)
- [hasGenericRootTransform](LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasGenericRootTransform.md)
- [hasMotionCurves](LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasMotionCurves.md)
- [hasMotionFloatCurves](LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasMotionFloatCurves.md)
- [hasRootCurves](LuaScript/Resources/AnimationClip/Properties/AnimationClip_hasRootCurves.md)
- [humanMotion](LuaScript/Resources/AnimationClip/Properties/AnimationClip_humanMotion.md)
- [legacy](LuaScript/Resources/AnimationClip/Properties/AnimationClip_legacy.md)
- [length](LuaScript/Resources/AnimationClip/Properties/AnimationClip_length.md)
- [localBounds](LuaScript/Resources/AnimationClip/Properties/AnimationClip_localBounds.md)
- [wrapMode](LuaScript/Resources/AnimationClip/Properties/AnimationClip_wrapMode.md)

### LuaScript / Utilities (22) <a id="luascript--utilities"></a>

**단일 페이지**

- [Mathf](LuaScript/Utilities/Mathf.md)
- [Time](LuaScript/Utilities/Time.md)

#### Cursor (13)

_Methods_ (7)

- [ResetIcon](LuaScript/Utilities/Cursor/Methods/Cursor_ResetIcon_VCursor.md)
- [SetCaptured](LuaScript/Utilities/Cursor/Methods/Cursor_SetCaptured_VCursor.md)
- [SetConfined](LuaScript/Utilities/Cursor/Methods/Cursor_SetConfined_VCursor_boolean.md)
- [SetHidden](LuaScript/Utilities/Cursor/Methods/Cursor_SetHidden_VCursor.md)
- [SetIcon](LuaScript/Utilities/Cursor/Methods/Cursor_SetIcon.md)
- [SetPointer](LuaScript/Utilities/Cursor/Methods/Cursor_SetPointer.md)
- [Set](LuaScript/Utilities/Cursor/Methods/Cursor_Set_VCursor_CursorLockMode_boolean.md)

_Properties_ (5)

- [Current](LuaScript/Utilities/Cursor/Properties/Cursor_Current.md)
- [isCaptured](LuaScript/Utilities/Cursor/Properties/Cursor_isCaptured.md)
- [isConfined](LuaScript/Utilities/Cursor/Properties/Cursor_isConfined.md)
- [isPointer](LuaScript/Utilities/Cursor/Properties/Cursor_isPointer.md)
- [isVisible](LuaScript/Utilities/Cursor/Properties/Cursor_isVisible.md)

_Events_ (1)

- [OnChanged](LuaScript/Utilities/Cursor/Events/Cursor_OnChanged.md)

#### InputLocks (7)

_Methods_ (6)

- [Block](LuaScript/Utilities/InputLocks/Methods/InputLocks_Block_VInputGate_string_InputChannel.md)
- [Clear](LuaScript/Utilities/InputLocks/Methods/InputLocks_Clear_VInputGate_string_InputChannel.md)
- [GetCount](LuaScript/Utilities/InputLocks/Methods/InputLocks_GetCount_VInputGate_string_InputChannel.md)
- [IsBlocked](LuaScript/Utilities/InputLocks/Methods/InputLocks_IsBlocked_VInputGate_InputChannel.md)
- [Set](LuaScript/Utilities/InputLocks/Methods/InputLocks_Set_VInputGate_string_InputChannel.md)
- [Unblock](LuaScript/Utilities/InputLocks/Methods/InputLocks_Unblock_VInputGate_string_InputChannel.md)

_Properties_ (1)

- [isBlocked](LuaScript/Utilities/InputLocks/Properties/InputLocks_isBlocked.md)

### LuaScript / VObjects (113) <a id="luascript--vobjects"></a>

**단일 페이지**

- [2DContainer](LuaScript/VObjects/2DContainer.md)
- [3DContainer](LuaScript/VObjects/3DContainer.md)
- [ClientScriptObject](LuaScript/VObjects/ClientScriptObject.md)
- [FreeViewController](LuaScript/VObjects/FreeViewController.md)
- [PlayerSpawnPoint](LuaScript/VObjects/PlayerSpawnPoint.md)
- [ServerScriptObject](LuaScript/VObjects/ServerScriptObject.md)
- [TopViewController](LuaScript/VObjects/TopViewController.md)

#### ItemVo (14)

_Methods_ (3)

- [GetOwnerCharacter](LuaScript/VObjects/ItemVo/Methods/Item_GetOwnerCharacter_ItemVo.md)
- [NotifyItemAutoUseCompleted](LuaScript/VObjects/ItemVo/Methods/Item_NotifyItemAutoUseCompleted_ItemVo.md)
- [SetWorldEnabled](LuaScript/VObjects/ItemVo/Methods/Item_SetWorldEnabled_ItemVo_boolean.md)

_Properties_ (7)

- [amount](LuaScript/VObjects/ItemVo/Properties/Item_amount.md)
- [buttonActionTrigger](LuaScript/VObjects/ItemVo/Properties/Item_buttonActionTrigger.md)
- [coolTime](LuaScript/VObjects/ItemVo/Properties/Item_coolTime.md)
- [dropOnSpawn](LuaScript/VObjects/ItemVo/Properties/Item_dropOnSpawn.md)
- [isActiveInWorld](LuaScript/VObjects/ItemVo/Properties/Item_isActiveInWorld.md)
- [itemId](LuaScript/VObjects/ItemVo/Properties/Item_itemID.md)
- [itemIcon](LuaScript/VObjects/ItemVo/Properties/Item_itemIcon.md)

_Events_ (4)

- [OnAttack](LuaScript/VObjects/ItemVo/Events/Item_OnAttack.md)
- [OnAttackBegin](LuaScript/VObjects/ItemVo/Events/Item_OnAttackBegin.md)
- [OnEquipped](LuaScript/VObjects/ItemVo/Events/Item_OnEquipped.md)
- [OnUnequipped](LuaScript/VObjects/ItemVo/Events/Item_OnUnequipped.md)

#### PenguinCharacter (43)

_Methods_ (34)

- [AddBuff](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddBuff_PenguinCharacterVo_Buff.md)
- [AddExplosionForce](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddExplosionForce.md)
- [AddForce](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddForce_PenguinCharacterVo_Vector3_ForceMode.md)
- [AddItem](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddItem_PenguinCharacterVo_Item.md)
- [AddMaxVelocityBonus](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AddMaxVelocityBonus_PenguinCharacterVo_number.md)
- [AttachPart](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_AttachPart_PenguinCharacterVo_WorldG_2EA5A0B519.md)
- [BounceAt](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_BounceAt_PenguinCharacterVo_Vector3__A468602544.md)
- [CancelKnockBack](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_CancelKnockBack_PenguinCharacterVo.md)
- [EquipItem](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_EquipItem_PenguinCharacterVo_Item.md)
- [GetBuff](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetBuff_PenguinCharacterVo_string.md)
- [GetBuffs](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetBuffs_PenguinCharacterVo.md)
- [GetEquippedItem](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_GetEquippedItem_PenguinCharacterVo.md)
- [HasBuff](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_HasBuff_PenguinCharacterVo_string.md)
- [IsItemInUse](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_IsItemInUse_PenguinCharacterVo.md)
- [KnockBack](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_KnockBack.md)
- [OverrideMaterialOnAllParts](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_OverrideMaterialOnAllParts_PenguinCh_9549537793.md)
- [RemoveAllItems](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveAllItems_PenguinCharacterVo.md)
- [RemoveBuff](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveBuff_PenguinCharacterVo_Buff.md)
- [RemoveItem](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveItem_PenguinCharacterVo_string.md)
- [RemoveMaxVelocityBonus](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RemoveMaxVelocityBonus_PenguinCharac_F69575037F.md)
- [ResetMaxVelocityBonus](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_ResetMaxVelocityBonus_PenguinCharacterVo.md)
- [RestoreMass](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreMass_PenguinCharacterVo.md)
- [RestoreMaterialOnAllParts](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreMaterialOnAllParts_PenguinCharacterVo.md)
- [RestoreRigidbodyConstraints](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_RestoreRigidbodyConstraints_PenguinCharacterVo.md)
- [SetAngularVelocity](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetAngularVelocity_PenguinCharacterVo_Vector3.md)
- [SetControlBlocked](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetControlBlocked_PenguinCharacterVo_boolean.md)
- [SetIsOnIce](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetIsOnIce_PenguinCharacterVo_boolean.md)
- [SetMass](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetMass_PenguinCharacterVo_number.md)
- [SetMaxVelocityBonus](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetMaxVelocityBonus_PenguinCharacterVo_number.md)
- [SetRigidbodyConstraints](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetRigidbodyConstraints_PenguinChara_951D17D9CC.md)
- [SetVelocity](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_SetVelocity_PenguinCharacterVo_Vector3.md)
- [StopState](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_StopState_PenguinCharacterVo_CharacterState.md)
- [UnEquipItem](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_UnEquipItem.md)
- [UseItem](LuaScript/VObjects/PenguinCharacter/Methods/PenguinCharacter_UseItem_PenguinCharacterVo_Item.md)

_Properties_ (9)

- [MaxVelocityBonus](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_MaxVelocityBonus.md)
- [externalForceScale](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_externalForceScale.md)
- [headbuttingForceScale](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_headbuttingForceScale.md)
- [isFalling](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isFalling.md)
- [isHeadButting](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isHeadButting.md)
- [isJumping](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isJumping.md)
- [isKnockedDown](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isKnockedDown.md)
- [isOnIce](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isOnIce.md)
- [isRunning](LuaScript/VObjects/PenguinCharacter/Properties/PenguinCharacter_isRunning.md)

#### PlayerVo (15)

_Methods_ (4)

- [AddItem](LuaScript/VObjects/PlayerVo/Methods/Player_AddItem_PlayerVo_ItemVo.md)
- [RemoveAllItems](LuaScript/VObjects/PlayerVo/Methods/Player_RemoveAllItems_PlayerVo.md)
- [RemoveItem](LuaScript/VObjects/PlayerVo/Methods/Player_RemoveItem_PlayerVo_string.md)
- [SpawnCharacter](LuaScript/VObjects/PlayerVo/Methods/Player_SpawnCharacter_PlayerVo_PlayerSpawnPointVo.md)

_Properties_ (10)

- [character](LuaScript/VObjects/PlayerVo/Properties/Player_character.md)
- [id](LuaScript/VObjects/PlayerVo/Properties/Player_id.md)
- [isLocalPlayer](LuaScript/VObjects/PlayerVo/Properties/Player_isLocalPlayer.md)
- [isSpawnCharacter](LuaScript/VObjects/PlayerVo/Properties/Player_isSpawnCharacter.md)
- [lastPlayerSpawnPoint](LuaScript/VObjects/PlayerVo/Properties/Player_lastPlayerSpawnPoint.md)
- [life](LuaScript/VObjects/PlayerVo/Properties/Player_life.md)
- [nickname](LuaScript/VObjects/PlayerVo/Properties/Player_nickname.md)
- [savePlayerSpawnPoint](LuaScript/VObjects/PlayerVo/Properties/Player_savePlayerSpawnPoint.md)
- [startPlayerSpawnPoint](LuaScript/VObjects/PlayerVo/Properties/Player_startPlayerSpawnPoint.md)
- [userId](LuaScript/VObjects/PlayerVo/Properties/Player_userId.md)

_Events_ (1)

- [OnChangedLife](LuaScript/VObjects/PlayerVo/Events/Player_OnChangedLife.md)

#### ScriptObject (3)

_Methods_ (3)

- [AsyncCall](LuaScript/VObjects/ScriptObject/Methods/ScriptObject_AsyncCall_ScriptObjectVo_LuaFunction.md)
- [GetLua](LuaScript/VObjects/ScriptObject/Methods/ScriptObject_GetLua_ScriptVo.md)
- [Log](LuaScript/VObjects/ScriptObject/Methods/ScriptObject_Log_ScriptVo_string.md)

#### TargetTracker (2)

_Methods_ (2)

- [SetTargetObject](LuaScript/VObjects/TargetTracker/Methods/TargetTracker_SetTargetObject_TargetTrackerVo_VObject.md)
- [SetTargetOffset](LuaScript/VObjects/TargetTracker/Methods/TargetTracker_SetTargetOffset_TargetTrackerVo_Vector3.md)

#### UIObject (11)

_Methods_ (9)

- [Destroy](LuaScript/VObjects/UIObject/Methods/UIObject_Destroy_UIGameObjectVo.md)
- [GetComponentByType](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentByType_UIGameObjectVo_Type.md)
- [GetComponentInChildrenByType](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentInChildrenByType_UIGameObjectVo_Type.md)
- [GetComponentInChildren](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentInChildren_UIGameObjectVo_string.md)
- [GetComponent](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponent_UIGameObjectVo_string.md)
- [GetComponentsByType](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentsByType_UIGameObjectVo_Type.md)
- [GetComponentsInChildrenByType](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentsInChildrenByType_UIGameObjectVo_Type.md)
- [GetComponentsInChildren](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponentsInChildren_UIGameObjectVo_string.md)
- [GetComponents](LuaScript/VObjects/UIObject/Methods/UIObject_GetComponents_UIGameObjectVo_string.md)

_Properties_ (2)

- [transform](LuaScript/VObjects/UIObject/Properties/UIObject_transform.md)
- [transform](LuaScript/VObjects/UIObject/Properties/UIObject_transformWrap.md)

#### VObject (7)

_Methods_ (4)

- [CastByType](LuaScript/VObjects/VObject/Methods/VObject_CastByType_VObject_Type.md)
- [Cast](LuaScript/VObjects/VObject/Methods/VObject_Cast_VObject_string.md)
- [SetActive](LuaScript/VObjects/VObject/Methods/VObject_SetActive_VObject_boolean.md)
- [SetParent](LuaScript/VObjects/VObject/Methods/VObject_SetParent_VObject_GameEntity.md)

_Properties_ (3)

- [name](LuaScript/VObjects/VObject/Properties/VObject_Name.md)
- [activeSelf](LuaScript/VObjects/VObject/Properties/VObject_activeSelf.md)
- [parent](LuaScript/VObjects/VObject/Properties/VObject_parent.md)

#### WorldObject (11)

_Methods_ (9)

- [Destroy](LuaScript/VObjects/WorldObject/Methods/WorldObject_Destroy_WorldGameObjectVo.md)
- [GetComponentByType](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentByType_WorldGameObjectVo_Type.md)
- [GetComponentInChildrenByType](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentInChildrenByType_WorldGameObjectVo_Type.md)
- [GetComponentInChildren](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentInChildren_WorldGameObjectVo_string.md)
- [GetComponent](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponent_WorldGameObjectVo_string.md)
- [GetComponentsByType](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentsByType_WorldGameObjectVo_Type.md)
- [GetComponentsInChildrenByType](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentsInChildrenByType_WorldGameObjectVo_Type.md)
- [GetComponentsInChildren](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponentsInChildren_WorldGameObjectVo_string.md)
- [GetComponents](LuaScript/VObjects/WorldObject/Methods/WorldObject_GetComponents_WorldGameObjectVo_string.md)

_Properties_ (2)

- [transform](LuaScript/VObjects/WorldObject/Properties/WorldObject_transform.md)
- [transform](LuaScript/VObjects/WorldObject/Properties/WorldObject_transformWrap.md)
