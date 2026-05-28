using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

using UnityEngine;

namespace PixelCanvas
{
    public static class MeshMassBoundsCalculator
    {
        public static List<Vector3> Verticies
        {
            get
            {
                if (_position == null)
                {
                    _position = GeodesicDome.Subdivide(ResourceManager.Instance._geodesicDomeFrequency);
                    for (var i=0; i<_position.Count; ++i)
                    {
                        _position[i] *= ResourceManager.Instance._geodesicDomeRadius;
                    }
                }
                return _position;
            }
        }
        private static List<Vector3> _position;

        public static void GenerateDome(int frequency, float distance)
        {
            _position = GeodesicDome.Subdivide(frequency);
            for (var i = 0; i < _position.Count; ++i)
            {
                _position[i] *= distance;
            }
        }

        public struct MeshHitInfo
        {
            public Vector3 point;
            public int triangleIndex;
            public Vector3 normal;
        }

        public static bool Calculate(GameObject target, float surfaceNormalAllowance, out Bounds massBounds)
        {
            var mesh = default(Mesh);
            var offset = default(Vector3);
            var rotation = default(Quaternion);
            var renderer = target.GetComponentInChildren<Renderer>();
            switch (renderer)
            {
                case MeshRenderer meshRenderer:
                    var meshFilter = meshRenderer.GetComponent<MeshFilter>();
                    mesh = meshFilter.sharedMesh;
                    offset = renderer.transform.position - meshRenderer.bounds.center;
                    rotation = meshRenderer.transform.rotation;
                    break;
                case SkinnedMeshRenderer skinnedMeshRenderer:
                    mesh = new Mesh();
                    skinnedMeshRenderer.BakeMesh(mesh);
                    offset = renderer.transform.position - mesh.bounds.center;
                    rotation = Quaternion.identity;
                    break;
            }

            var result = Calculate(mesh, offset, rotation, surfaceNormalAllowance, out massBounds);
            //massBounds.center += target.transform.localPosition;
            return result;
        }

        public static bool Calculate(Mesh mesh, Vector3 offset, Quaternion rotation, float surfaceNormalAllowance, out Bounds massBounds)
        {
            massBounds = default;

            if (mesh == null)
                return false;

            var min = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
            var max = new Vector3(float.MinValue, float.MinValue, float.MinValue);

            var vertexCount = mesh.vertexCount;
            var vertexies = new List<Vector3>();
            mesh.GetVertices(vertexies);
            foreach (var point in vertexies)
            {
                var modifiedPoint = rotation * point;
                modifiedPoint += offset;
                min = Vector3.Min(min, rotation * modifiedPoint);
                max = Vector3.Max(max, rotation * modifiedPoint);
            }

            var boundsCenter = (min + max) * 0.5f;
            massBounds.SetMinMax(min, max);

            min = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
            max = new Vector3(float.MinValue, float.MinValue, float.MinValue);

            for (var i = 0; i < Verticies.Count; ++i)
            {
                var domeOffset = Verticies[i];
                var rayOrigin = domeOffset + massBounds.center;

                var ray = new Ray(rayOrigin, -domeOffset.normalized);
                if (AnalyzeMeshWithRaycast(ray, mesh, new Vector3(0, 0, 0), rotation, out var hitInfo) == true)
                {
                    var test = Vector3.Dot(hitInfo.normal, -ray.direction);
                    if (test < surfaceNormalAllowance)
                        continue;
                    min = Vector3.Min(min, hitInfo.point);
                    max = Vector3.Max(max, hitInfo.point);
                }
            }

            //for (int i = 0; i < density; i++)
            //{
            //    var t = i / (density - 1);
            //    var phi = t * Mathf.PI;
            //    var theta = t * density2 * Mathf.PI;

            //    var tempRadius = 100;
            //    var x = tempRadius * Mathf.Sin(phi) * Mathf.Cos(theta);
            //    var y = tempRadius * Mathf.Cos(phi);
            //    var z = tempRadius * Mathf.Sin(phi) * Mathf.Sin(theta);

            //    var offset = new Vector3(x, y, z);
            //    var rayOrigin = offset + massBounds.center;

            //    var ray = new Ray(rayOrigin, -offset.normalized);
            //    if (AnalyzeMeshWithRaycast(ray, mesh, new Vector3(0, 0, 0), rotation, out var hitInfo) == true)
            //    {
            //        var test = Vector3.Dot(hitInfo.normal, -ray.direction);
            //        if (test < surfaceNormalAllowance)
            //            continue;
            //        min = Vector3.Min(min, hitInfo.point);
            //        max = Vector3.Max(max, hitInfo.point);
            //    }
            //}

            massBounds.SetMinMax(min, max);
            return true;
        }

        public static bool AnalyzeMeshWithRaycast(Ray ray, Mesh mesh, Vector3 position, Quaternion rotation, out MeshHitInfo hitInfo)
        {
            hitInfo = default;
            var vertices = mesh.vertices;
            var triangles = mesh.triangles;
            var normals = mesh.normals;

            var closestDistance = float.MaxValue;
            var hit = false;

            ray.origin = Quaternion.Inverse(rotation) * ray.origin;
            ray.direction = Quaternion.Inverse(rotation) * ray.direction;

            for (int i = 0; i < triangles.Length; i += 3)
            {
                var v0 = position + vertices[triangles[i]];
                var v1 = position + vertices[triangles[i + 1]];
                var v2 = position + vertices[triangles[i + 2]];

                if (IntersectsTriangle(ray, v0, v1, v2, out float distance, out Vector3 point))
                {
                    if (distance < closestDistance)
                    {
                        closestDistance = distance;
                        hit = true;
                        hitInfo.point = rotation * point;
                        hitInfo.triangleIndex = i / 3;
                        hitInfo.normal = rotation * Vector3.Normalize(normals[triangles[i]]);
                    }
                }
            }

            return hit;
        }

        private static bool IntersectsTriangle(Ray ray, Vector3 v0, Vector3 v1, Vector3 v2, out float distance, out Vector3 hitPoint)
        {
            distance = 0f;
            hitPoint = Vector3.zero;

            var edge1 = v1 - v0;
            var edge2 = v2 - v0;
            var h = Vector3.Cross(ray.direction, edge2);
            var a = Vector3.Dot(edge1, h);

            if (Mathf.Abs(a) < 0.00001f) return false;

            var f = 1f / a;
            var s = ray.origin - v0;
            var u = f * Vector3.Dot(s, h);

            if (u < 0f || u > 1f) return false;

            var q = Vector3.Cross(s, edge1);
            var v = f * Vector3.Dot(ray.direction, q);

            if (v < 0f || u + v > 1f) return false;

            distance = f * Vector3.Dot(edge2, q);
            if (distance > 0f)
            {
                hitPoint = ray.origin + ray.direction * distance;
                return true;
            }
            return false;
        }
    }

    public class GeodesicDome
    {
        private static Vector3[] GenerateIcosahedron()
        {
            float t = (1.0f + Mathf.Sqrt(5.0f)) / 2.0f; // Golden Ratio(phi)

            // Vertex of Icosahedron
            var originVertices = new Vector3[]
            {
                new Vector3(-1, t, 0),
                new Vector3(1, t, 0),
                new Vector3(-1, -t, 0),
                new Vector3(1, -t, 0),
                new Vector3(0, -1, t),
                new Vector3(0, 1, t),
                new Vector3(0, -1, -t),
                new Vector3(0, 1, -t),
                new Vector3(t, 0, -1),
                new Vector3(t, 0, 1),
                new Vector3(-t, 0, -1),
                new Vector3(-t, 0, 1)
            };

            foreach (var vertex in originVertices)
                vertex.Normalize();

            return originVertices;
        }

        public static List<Vector3> Subdivide(int frequency)
        {
            // Initial Triangles
            int[,] faces = new int[,]
            {
                {0, 11, 5}, {0, 5, 1}, {0, 1, 7}, {0, 7, 10}, {0, 10, 11},
                {1, 5, 9}, {5, 11, 4}, {11, 10, 2}, {10, 7, 6}, {7, 1, 8},
                {3, 9, 4}, {3, 4, 2}, {3, 2, 6}, {3, 6, 8}, {3, 8, 9},
                {4, 9, 5}, {2, 4, 11}, {6, 2, 10}, {8, 6, 7}, {9, 8, 1}
            };

            var newVertices = new HashSet<Vector3>();
            var originVertices = GenerateIcosahedron();
            for (int i = 0; i < faces.GetLength(0); i++)
            {
                int v1 = faces[i, 0];
                int v2 = faces[i, 1];
                int v3 = faces[i, 2];

                SubdivideTriangle(originVertices, v1, v2, v3, frequency, newVertices);
            }

            return newVertices.ToList();
        }

        private static void SubdivideTriangle(Vector3[] originVertices, int v1, int v2, int v3, int frequency, HashSet<Vector3> newVertices)
        {
            for (int i = 0; i <= frequency; i++)
            {
                for (int j = 0; j <= frequency - i; j++)
                {
                    float a = (float)i / frequency;
                    float b = (float)j / frequency;
                    float c = (float)(frequency - i - j) / frequency;

                    Vector3 newPoint = new Vector3(
                        originVertices[v1].x * c + originVertices[v2].x * a + originVertices[v3].x * b,
                        originVertices[v1].y * c + originVertices[v2].y * a + originVertices[v3].y * b,
                        originVertices[v1].z * c + originVertices[v2].z * a + originVertices[v3].z * b
                    );
                    newPoint.Normalize();

                    if (newVertices.Contains(newPoint) == false)
                        newVertices.Add(newPoint);
                }
            }
        }
    }
}