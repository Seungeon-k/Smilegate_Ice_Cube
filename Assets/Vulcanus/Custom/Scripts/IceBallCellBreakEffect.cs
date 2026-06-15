using System.Collections.Generic;
using UnityEngine;

public sealed class IceBallCellBreakEffect : MonoBehaviour
{
    [SerializeField] private float breakDuration = 0.75f;
    [SerializeField] private float scatterDistance = 3.2f;
    [SerializeField] private float upwardDistance = 1.2f;
    [SerializeField] private float spinDegrees = 420f;
    [SerializeField] private string platformName = "Snow_Platform (2)";
    [SerializeField] private float landingOffset = -0.3f;

    private readonly List<CellState> cells = new();
    private bool collected;
    private bool breaking;
    private bool fallingStarted;
    private float breakTime;
    private float previousY;

    private void OnEnable()
    {
        CollectCells();
        ResetCells();
        breaking = false;
        fallingStarted = false;
        breakTime = 0f;
        previousY = transform.position.y;
    }

    private void OnDisable()
    {
        ResetCells();
    }

    private void Update()
    {
        if (!breaking)
        {
            float currentY = transform.position.y;
            if (currentY < previousY - 0.01f)
            {
                fallingStarted = true;
            }

            if (fallingStarted && currentY <= GetLandingY() + 0.01f)
            {
                BreakNow();
            }

            previousY = currentY;
            return;
        }

        breakTime += Time.deltaTime;
        float t = Mathf.Clamp01(breakTime / Mathf.Max(breakDuration, 0.05f));
        float eased = 1f - (1f - t) * (1f - t);

        ApplyBreakPose(t, eased);
    }

    public void BreakNow()
    {
        if (breaking)
        {
            return;
        }

        CollectCells();
        ResetCells();
        breaking = true;
        breakTime = 0f;
        ApplyBreakPose(0.08f, 1f - 0.92f * 0.92f);
    }

    private void ApplyBreakPose(float t, float eased)
    {
        foreach (CellState cell in cells)
        {
            if (cell.Transform == null)
            {
                continue;
            }

            Vector3 scatter = cell.Direction * scatterDistance * eased;
            scatter.y += Mathf.Sin(t * Mathf.PI) * upwardDistance;
            cell.Transform.localPosition = cell.OriginPosition + scatter;
            cell.Transform.localRotation =
                cell.OriginRotation * Quaternion.Euler(cell.SpinAxis * spinDegrees * eased);
            cell.Transform.localScale = cell.OriginScale * Mathf.Clamp01(1f - t);
        }
    }

    private void CollectCells()
    {
        if (collected)
        {
            return;
        }

        collected = true;
        cells.Clear();
        Renderer[] renderers = GetComponentsInChildren<Renderer>(true);
        foreach (Renderer renderer in renderers)
        {
            Transform cellTransform = renderer.transform;
            if (cellTransform == transform)
            {
                continue;
            }

            Vector3 direction = cellTransform.localPosition;
            if (direction.sqrMagnitude < 0.0001f)
            {
                direction = Random.onUnitSphere;
            }

            direction.y = Mathf.Abs(direction.y) + Random.Range(0.15f, 0.55f);
            direction.Normalize();

            cells.Add(new CellState
            {
                Transform = cellTransform,
                OriginPosition = cellTransform.localPosition,
                OriginRotation = cellTransform.localRotation,
                OriginScale = cellTransform.localScale,
                Direction = direction,
                SpinAxis = Random.onUnitSphere
            });
        }
    }

    private void ResetCells()
    {
        foreach (CellState cell in cells)
        {
            if (cell.Transform == null)
            {
                continue;
            }

            cell.Transform.localPosition = cell.OriginPosition;
            cell.Transform.localRotation = cell.OriginRotation;
            cell.Transform.localScale = cell.OriginScale;
        }
    }

    private float GetLandingY()
    {
        GameObject platform = GameObject.Find(platformName);
        if (platform == null)
        {
            return transform.position.y - 1000f;
        }

        bool hasBounds = false;
        Bounds bounds = new(platform.transform.position, Vector3.zero);

        foreach (Collider collider in platform.GetComponentsInChildren<Collider>(true))
        {
            if (!hasBounds)
            {
                bounds = collider.bounds;
                hasBounds = true;
            }
            else
            {
                bounds.Encapsulate(collider.bounds);
            }
        }

        if (!hasBounds)
        {
            foreach (Renderer renderer in platform.GetComponentsInChildren<Renderer>(true))
            {
                if (!hasBounds)
                {
                    bounds = renderer.bounds;
                    hasBounds = true;
                }
                else
                {
                    bounds.Encapsulate(renderer.bounds);
                }
            }
        }

        if (!hasBounds)
        {
            return platform.transform.position.y + landingOffset;
        }

        return bounds.max.y + landingOffset;
    }

    private sealed class CellState
    {
        public Transform Transform;
        public Vector3 OriginPosition;
        public Quaternion OriginRotation;
        public Vector3 OriginScale;
        public Vector3 Direction;
        public Vector3 SpinAxis;
    }
}
