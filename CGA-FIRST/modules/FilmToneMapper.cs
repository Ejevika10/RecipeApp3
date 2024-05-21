using System;
using System.Numerics;

namespace CGA_FIRST.modules
{

    public class FilmToneMapper
    {
        private static readonly Vector3[] acesInputMatrix =
        {
            new Vector3(0.59719f, 0.35458f, 0.04823f),
            new Vector3(0.07600f, 0.90834f, 0.01566f),
            new Vector3(0.02840f, 0.13383f, 0.83777f)
        };

        private static readonly Vector3[] acesOutputMatrix =
        {
            new Vector3(1.60475f, -0.53108f, -0.07367f),
            new Vector3(-0.10208f, 1.10813f, -0.00605f),
            new Vector3(-0.00327f, -0.07276f, 1.07602f)
        };

        private static Vector3 MultiplyMatrixVector(Vector3[] m, Vector3 v)
        {
            float x = m[0].X * v.X + m[0].Y * v.Y + m[0].Z * v.Z;
            float y = m[1].X * v.X + m[1].Y * v.Y + m[1].Z * v.Z;
            float z = m[2].X * v.X + m[2].Y * v.Y + m[2].Z * v.Z;
            return new Vector3(x, y, z);
        }

        private static Vector3 RttAndOdtFit(Vector3 v)
        {
            Vector3 a = v * (v + new Vector3(0.0245786f)) - new Vector3(0.000090537f);
            Vector3 b = v * (new Vector3(0.983729f) * v + new Vector3(0.4329510f)) + new Vector3(0.238081f);
            return a / b;
        }

        public static Vector3 AcesFitted(Vector3 v)
        {
            v = MultiplyMatrixVector(acesInputMatrix, v);
            v = RttAndOdtFit(v);
            v = MultiplyMatrixVector(acesOutputMatrix, v);
            v.X = Math.Min(Math.Max(v.X, 0.0f), 1.0f);
            v.Y = Math.Min(Math.Max(v.Y, 0.0f), 1.0f);
            v.Z = Math.Min(Math.Max(v.Z, 0.0f), 1.0f);
            return v;
        }
        
        public static Vector3 ACESFilm(Vector3 x)
        {
            float a = 2.51f;
            float b = 0.03f;
            float c = 2.43f;
            float d = 0.59f;
            float e = 0.14f;

            Vector3 numerator = x * (a * x + new Vector3(b));
            Vector3 denominator = x * (c * x + new Vector3(d)) + new Vector3(e);

            return Vector3.Clamp(numerator / denominator, Vector3.Zero, Vector3.One);
        }
    }
}