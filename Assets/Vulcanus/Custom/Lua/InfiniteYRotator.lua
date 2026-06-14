local this = __CREATOR__.new()

this.RotationSpeed = __EX_VARIABLE__.float(20.0)
this.PivotOffset = __EX_VARIABLE__.vector3(18.768356, 8.681134, 5.936426)

local targetTransform
local pivotCenter
local scaledPivotOffset
local startLocalRotation
local rotationAngle = 0

function this.OnStart()
    local scriptObject = this.scriptObject
    if scriptObject == nil or scriptObject.parent == nil then return end

    targetTransform = scriptObject.parent.transform
    startLocalRotation = targetTransform.localRotation

    local scale = targetTransform.localScale
    scaledPivotOffset = Vector3(
        this.PivotOffset.x * scale.x,
        this.PivotOffset.y * scale.y,
        this.PivotOffset.z * scale.z
    )
    pivotCenter =
        targetTransform.localPosition + startLocalRotation * scaledPivotOffset

    rotationAngle = 0
end

function this.OnUpdate(deltaTime)
    if targetTransform == nil then return end

    rotationAngle = (rotationAngle + this.RotationSpeed * deltaTime) % 360

    local nextLocalRotation =
        startLocalRotation * Quaternion.AngleAxis(rotationAngle, Vector3(0, 1, 0))
    local nextLocalPosition =
        pivotCenter - nextLocalRotation * scaledPivotOffset

    targetTransform.localRotation = nextLocalRotation
    targetTransform.localPosition = nextLocalPosition
end
