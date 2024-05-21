using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Numerics;
using System.Reflection;
using System.Windows.Forms;


namespace CGA_FIRST.modules
{
    public class Drawer
    {
        public float x = 0, y = 0, z = 0;
        private int window_width;
        private int window_height;
        private const int scale = 1;
        private const int zoom_number = 1;
        private float zFar = 1000000, zNear = 0.1F;
        private Color backgroundColour = Color.White;
        private Vector3  lightColor  = new Vector3(20, 20, 20);
        private Vector3 eye = new Vector3(0, 0, 50);
        private Vector3 up = new Vector3(0, 1, 0);
        private Vector3 target = new Vector3(0, 0, 0);

        private Vector3 lightDirection = new Vector3(0, 0, 1);

        private List<Vector4> verteces_changeable;
        private List<Vector4> verteces_start;
        private List<Vector4> verteces_view;
        private List<Vector4> verteces_world;
        private List<double[]> verteces;
        private List<List<List<int>>> faces;
        private List<Vector3> normals;
        private List<Vector3> normals_changeable;

        private Matrix4x4 worldToViewMatrix;
        private Matrix4x4 viewToProjectionMatrix;
        private Matrix4x4 projectionToScreenMatrix;

        private Matrix4x4 translationMatrix = new Matrix4x4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        );

        private Matrix4x4 scaleMatrix = new Matrix4x4(
            scale, 0, 0, 0,
            0, scale, 0, 0,
            0, 0, scale, 0,
            0, 0, 0, 1
        );

        private float[] zBuffer;

        private float gamma = 2.2f;


        public Drawer(int width, int height, List<double[]> vertexes, List<List<List<int>>> faces,
            List<Vector3> normals)
        {
            lightDirection = Vector3.Normalize(lightDirection);
            window_width = width;
            window_height = height;
            //zNear = window_width / 2;
            this.faces = faces;
            this.verteces = vertexes;
            this.normals = normals;
            float aspect = (float)window_width / window_height;
            viewToProjectionMatrix = new Matrix4x4(
                (float)(1 / (aspect * Math.Tan(Math.PI / 4))), 0, 0, 0,
                0, (float)(1 / Math.Tan(Math.PI / 4)), 0, 0,
                0, 0, (float)(zFar / (zNear - zFar)), (float)(zNear * zFar / (zNear - zFar)),
                0, 0, -1, 0
            );

            projectionToScreenMatrix = new Matrix4x4(
                (float)(window_width / 2), 0, 0, (float)(window_width / 2),
                0, -(float)(window_height / 2), 0, (float)(window_height / 2),
                0, 0, 1, 0,
                0, 0, 0, 1
            );

            zBuffer = new float[window_width * window_height];
            cleanZBuffer();

            Vector4 temp;
            verteces_start = new List<Vector4>();
            verteces_view = new List<Vector4>();
            verteces_world = new List<Vector4>();
            normals_changeable = new List<Vector3>();
            foreach (double[] vertex in vertexes)
            {
                if (vertex.Length == 3)
                    temp = new Vector4((float)vertex[0], (float)vertex[1], (float)vertex[2], 1);
                else
                    temp = new Vector4((float)vertex[0], (float)vertex[1], (float)vertex[2], (float)vertex[3]);

                verteces_start.Add(temp);
            }
        }

        public void changeTranslationMatrix(float dx, float dy, float dz)
        {
            x += dx;
            y += dy;
            z += dz;
            translationMatrix.M14 += dx;
            translationMatrix.M24 += dy;
            translationMatrix.M34 += dz;
        }

        public void changeVertexes()
        {
            verteces_changeable.Clear();
            verteces_view.Clear();
            verteces_world.Clear();
            normals_changeable.Clear();

            for (int i = 0; i < verteces_start.Count; i++)
            {
                //from model
                //to world
                verteces_changeable.Add(verteces_start[i]);
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(scaleMatrix);
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(scaleMatrix);

                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(MatrixRotater.rotationMatrixX);
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(MatrixRotater.rotationMatrixY);
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(MatrixRotater.rotationMatrixZ);
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(translationMatrix);
                float W = 1 / verteces_changeable[i].W;
                verteces_world.Add(verteces_changeable[i]);
                verteces_world[i] = new Vector4(verteces_changeable[i].X,
                    verteces_changeable[i].Y,
                    verteces_changeable[i].Z,
                    W);

                //to observer
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(worldToViewMatrix);
                verteces_view.Add(verteces_changeable[i]);

                //to projection
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(viewToProjectionMatrix);
                W = 1 / verteces_changeable[i].W;
                verteces_changeable[i] = Vector4.Divide(verteces_changeable[i], verteces_changeable[i].W);

                //to screen
                verteces_changeable[i] = verteces_changeable[i].ApplyMatrix(projectionToScreenMatrix);
                verteces_changeable[i] = new Vector4(verteces_changeable[i].X,
                    verteces_changeable[i].Y,
                    verteces_changeable[i].Z,
                    W);

            }

            for (int i = 0; i < normals.Count; i++)
            {
                normals_changeable.Add(normals[i]);
                normals_changeable[i] = normals_changeable[i].ApplyMatrix(translationMatrix);
                normals_changeable[i] = normals_changeable[i].ApplyMatrix(MatrixRotater.rotationMatrixX);
                normals_changeable[i] = normals_changeable[i].ApplyMatrix(MatrixRotater.rotationMatrixY);
                normals_changeable[i] = normals_changeable[i].ApplyMatrix(MatrixRotater.rotationMatrixZ);
                normals_changeable[i] = normals_changeable[i].ApplyMatrix(worldToViewMatrix);
            }
        }

        private void cleanZBuffer()
        {
            for (int i = 0; i < zBuffer.Length; i++)
            {
                zBuffer[i] = float.PositiveInfinity;
            }
        }

        public unsafe Bitmap Draw()
        {
            changeVertexes();
            cleanZBuffer();

            Bitmap bmp = new Bitmap(window_width, window_height);
            Graphics gfx = Graphics.FromImage(bmp);
            SolidBrush brush = new SolidBrush(backgroundColour);

            gfx.FillRectangle(brush, 0, 0, window_width, window_height);

            BitmapData bData = bmp.LockBits(new Rectangle(0, 0, bmp.Width, bmp.Height),
                ImageLockMode.ReadWrite, bmp.PixelFormat);
            byte bitsPerPixel = (byte)Bitmap.GetPixelFormatSize(bData.PixelFormat);
            byte* scan0 = (byte*)bData.Scan0.ToPointer();

            for (int j = 0; j < faces.Count; j++)
            {
                List<List<int>> face = faces[j];
                if (!IsBackFace(face))
                {

                    FillTriangle(face, bData, bitsPerPixel, bmp, scan0);
                }
            }

            bmp.UnlockBits(bData);
            return bmp;
        }

        public unsafe void FillTriangle(List<List<int>> face, BitmapData bData, int bitsPerPixel, Bitmap bmp,
            byte* scan0)
        {
            //world
            Vector4 aw = (verteces_world[face[0][0] - 1]);
            Vector4 bw = (verteces_world[face[1][0] - 1]);
            Vector4 cw = (verteces_world[face[2][0] - 1]);

            //screen
            Vector4 a = verteces_changeable[face[0][0] - 1];
            Vector4 b = verteces_changeable[face[1][0] - 1];
            Vector4 c = verteces_changeable[face[2][0] - 1];

            Vector3 vertexNormalA = Vector3.Normalize(normals_changeable[face[0][2] - 1]);
            Vector3 vertexNormalB = Vector3.Normalize(normals_changeable[face[1][2] - 1]);
            Vector3 vertexNormalC = Vector3.Normalize(normals_changeable[face[2][2] - 1]);

            // Поиск текстурной координаты по вершине
            Vector2 textureA = ObjParser.textures[face[0][1] - 1];
            Vector2 textureB = ObjParser.textures[face[1][1] - 1];
            Vector2 textureC = ObjParser.textures[face[2][1] - 1];
            textureA *= a.W;
            textureB *= b.W;
            textureC *= c.W;
            if (a.Y > c.Y)
            {
                (a, c) = (c, a);
                (vertexNormalA, vertexNormalC) = (vertexNormalC, vertexNormalA);
                (textureA, textureC) = (textureC, textureA);
                (aw, cw) = (cw, aw);
            }

            if (a.Y > b.Y)
            {
                (a, b) = (b, a);
                (vertexNormalA, vertexNormalB) = (vertexNormalB, vertexNormalA);
                (textureA, textureB) = (textureB, textureA);
                (aw, bw) = (bw, aw);
            }

            if (b.Y > c.Y)
            {
                (b, c) = (c, b);
                (vertexNormalB, vertexNormalC) = (vertexNormalC, vertexNormalB);
                (textureB, textureC) = (textureC, textureB);
                (bw, cw) = (cw, bw);
            }

            Vector4 k1 = (c - a) / (c.Y - a.Y);
            Vector3 vertexNormalKoeff1 = (vertexNormalC - vertexNormalA) / (c.Y - a.Y);
            Vector4 worldKoeff1 = (cw - aw) / (c.Y - a.Y);
            Vector2 textureKoeff1 = (textureC - textureA) / (c.Y - a.Y);

            Vector4 k2 = (b - a) / (b.Y - a.Y);
            Vector3 vertexNormalKoeff2 = (vertexNormalB - vertexNormalA) / (b.Y - a.Y);
            Vector4 worldKoeff2 = (bw - aw) / (b.Y - a.Y);
            Vector2 textureKoeff2 = (textureB - textureA) / (b.Y - a.Y);

            Vector4 k3 = (c - b) / (c.Y - b.Y);
            Vector3 vertexNormalKoeff3 = (vertexNormalC - vertexNormalB) / (c.Y - b.Y);
            Vector4 worldKoeff3 = (cw - bw) / (c.Y - b.Y);
            Vector2 textureKoeff3 = (textureC - textureB) / (c.Y - b.Y);

            int top = Math.Max(0, (int)Math.Ceiling(a.Y));
            int bottom = Math.Min(window_height, (int)Math.Ceiling(c.Y));
            
            for (int y = top; y < bottom; y++)
            {
                Vector4 l = a + (y - a.Y) * k1;
                Vector4 r = (y < b.Y) ? a + (y - a.Y) * k2 : b + (y - b.Y) * k3;

                Vector4 worldL = aw + (y - a.Y) * worldKoeff1;
                Vector4 worldR = y < b.Y ? aw + (y - a.Y) * worldKoeff2 : bw + (y - b.Y) * worldKoeff3;
                
                // Нахождение нормали для левого и правого Y.
                Vector3 normalL = vertexNormalA + (y - a.Y) * vertexNormalKoeff1;
                Vector3 normalR = y < b.Y
                    ? vertexNormalA + (y - a.Y) * vertexNormalKoeff2
                    : vertexNormalB + (y - b.Y) * vertexNormalKoeff3;

                Vector2 textureL = textureA + (y - a.Y) * textureKoeff1;
                Vector2 textureR =
                    y < b.Y ? textureA + (y - a.Y) * textureKoeff2 : textureB + (y - b.Y) * textureKoeff3;

                if (l.X > r.X)
                {
                    (l, r) = (r, l);
                    (normalL, normalR) = (normalR, normalL);
                    (worldL, worldR) = (worldR, worldL);
                    (textureL, textureR) = (textureR, textureL);
                }

                Vector4 k = (r - l) / (r.X - l.X);
                Vector3 normalKoeff = (normalR - normalL) / (r.X - l.X);
                Vector4 worldKoeff = (worldR - worldL) / (r.X - l.X);
                Vector2 textureKoeff = (textureR - textureL) / (r.X - l.X);

                int left = Math.Max(0, (int)Math.Ceiling(l.X));
                int right = Math.Min(window_width, (int)Math.Ceiling(r.X));

                for (int x = left; x < right; x++)
                {
                    Vector4 p = l + (x - l.X) * k;
                    Vector4 pWorld = worldL + (x - l.X) * worldKoeff;

                    int index = (int)y * window_width + (int)x;
                    if (p.Z < zBuffer[index])
                    {
                        Vector3 normal = normalL + (x - l.X) * normalKoeff;

                        Vector2 texture = (textureL + (x - l.X) * textureKoeff) / p.W;

                        Vector3 albedo = new Vector3(0, 0, 0);
                        if (ObjParser.baseMap != null)
                        {
                            float xt = Math.Max(0, Math.Min(texture.X, 1));
                            float yt = Math.Max(0, Math.Min((1 - texture.Y), 1));
                            Color baseColor = ObjParser.baseMap.GetPixel(
                                (int)Math.Ceiling(xt * (ObjParser.baseMap.Width - 1)),
                                (int)Math.Ceiling(yt * (ObjParser.baseMap.Height - 1)));
                            //albedo = new Vector3(baseColor.R, baseColor.G, baseColor.B);
                             albedo = new Vector3(SRGBLinear(baseColor.R/255f), SRGBLinear(baseColor.G/255f), SRGBLinear(baseColor.B/255f));
                             //albedo = ApplyGama(albedo, 2.2f);
                        }

                        Vector3 metallic = new Vector3(1, 0, 0);
                        float metallicValue;
                        if (ObjParser.metallicMap != null)
                        {
                            float xt = Math.Max(0, Math.Min(texture.X, 1));
                            float yt = Math.Max(0, Math.Min((1 - texture.Y), 1));
                            Color metallicColor = ObjParser.metallicMap.GetPixel(
                                (int)Math.Ceiling(xt * (ObjParser.metallicMap.Width - 1)),
                                (int)Math.Ceiling(yt * (ObjParser.metallicMap.Height - 1)));
                            metallic = new Vector3(metallicColor.R, metallicColor.G, metallicColor.B) / 255;
                        }

                        metallicValue = metallic.X;
                        //metallicValue = (metallic.X + metallic.Y + metallic.Z) / 3f;
                        Vector3 roughness = new Vector3(0, 0, 0);
                        float roughnessValue;
                        if (ObjParser.roughnessMap != null)
                        {
                            float xt = Math.Max(0, Math.Min(texture.X, 1));
                            float yt = Math.Max(0, Math.Min((1 - texture.Y), 1));
                            Color roughnessColor = ObjParser.roughnessMap.GetPixel(
                                (int)Math.Ceiling(xt * (ObjParser.roughnessMap.Width - 1)),
                                (int)Math.Ceiling(yt * (ObjParser.roughnessMap.Height - 1)));
                            roughness = new Vector3(roughnessColor.R, roughnessColor.G, roughnessColor.B) / 255;
                        }

                        roughnessValue = roughness.X;
                        //roughnessValue = metallic.Y;
                        Vector3 ao = new Vector3(1, 0, 0);
                        float aoValue;
                        if (ObjParser.aoMap != null)
                        {
                            float xt = Math.Max(0, Math.Min(texture.X, 1));
                            float yt = Math.Max(0, Math.Min((1 - texture.Y), 1));
                            Color aoColor = ObjParser.aoMap.GetPixel(
                                (int)Math.Ceiling(xt * (ObjParser.aoMap.Width - 1)),
                                (int)Math.Ceiling(yt * (ObjParser.aoMap.Height - 1)));
                            ao = new Vector3(aoColor.R, aoColor.G, aoColor.B) /255f;
                        }

                        aoValue = ao.X;
                        //aoValue = metallic.Z;
                        if (ObjParser.normalMap != null)
                        {
                            float xt = Math.Max(0, Math.Min(texture.X, 1));
                            float yt = Math.Max(0, Math.Min((1 - texture.Y), 1));
                            Color normalColor = ObjParser.normalMap.GetPixel(
                                (int)Math.Ceiling(xt * (ObjParser.normalMap.Width - 1)),
                                (int)Math.Ceiling(yt * (ObjParser.normalMap.Height - 1)));
                            normal = new Vector3(normalColor.R, normalColor.G, normalColor.B) / 255;
                        }
                        normal = normal.ApplyMatrix(MatrixRotater.rotationMatrixX);
                        normal = normal.ApplyMatrix(MatrixRotater.rotationMatrixY);
                        normal = normal.ApplyMatrix(MatrixRotater.rotationMatrixZ);
                        normal = Vector3.Normalize(2*normal - Vector3.One);

                        

                        Vector3 N = Vector3.Normalize(normal) ;
                        Vector3 V = Vector3.Normalize(eye - MatrixSolver.createFromVector4(pWorld));

                        Vector3 F0 = Vector3.Lerp(new Vector3(0.04f), albedo, metallicValue);
                        // F0 = Vector3.Normalize(F0);
                        // выражение отражающей способности
                        Vector3 L = Vector3.Normalize(lightDirection);
                        //Vector3 L = Vector3.Normalize(lightDirection - MatrixSolver.createFromVector4(pWorld));
                        Vector3 H = Vector3.Normalize(V + L);
                        //Vector3 radiance = lightColor / (L.Length()*L.Length());
                        Vector3 radiance = lightColor;
                        //precompute dots
                        float NL = Math.Min(Math.Max(Vector3.Dot(N, L), 0), 1.0f);
                        float NV = Math.Min(Math.Max(Vector3.Dot(N, V), 0), 1.0f);
                        float NH = Math.Min(Math.Max(Vector3.Dot(N, H), 0), 1.0f);
                        float HV = Math.Min(Math.Max(Vector3.Dot(H, V), 0), 1.0f);

                        //precompute roughness square
                        float roug_sqr = roughnessValue * roughnessValue;

                        //calc coefficients
                        float G = GGX_PartialGeometry(NV, roug_sqr) * GGX_PartialGeometry(NL, roug_sqr);
                        float D = GGX_Distribution(NH, roug_sqr);

                        Vector3 F = fresnelSchlick(HV, F0);

                        //mix
                        Vector3 specK = 0.25f * G * D * F / Math.Max(NV, 0.00001f);

                        Vector3 diffK = (Vector3.One - F) * (1f - metallicValue) * albedo / (float)Math.PI;
                        Vector3 color = 0.05f * albedo * aoValue + (diffK * NL + specK) * radiance;
                        
                        color = FilmToneMapper.AcesFitted(color);
                        
                        //color = applyTone(color) ;
                        //color = ApplyGama(color, 1f / 2.2f) * 255;
                        
                        zBuffer[index] = p.Z;
                        byte* data = scan0 + (int)y * bData.Stride + (int)x * bitsPerPixel / 8;
                        color = new Vector3(LinearSRGB(color.X), LinearSRGB(color.Y), LinearSRGB(color.Z)) * 255f;
                        //color *= 255f;
                        data[0] = (byte)Math.Min(color.Z, 255);
                        data[1] = (byte)Math.Min(color.Y, 255);
                        data[2] = (byte)Math.Min(color.X, 255);
                            
                        
                    }
                }
            }
        }        
        
        Vector3 ApplyGama(Vector3 v, float pow)
        {
            float x = (float)Math.Pow(v.X, pow);
            float y = (float)Math.Pow(v.Y, pow);
            float z = (float)Math.Pow(v.Z, pow);

            return new Vector3(x, y, z);
        }

        Vector3 applyTone(Vector3 v)
        {
            return v / (Vector3.One + v);
        }
        
        public void ZoomIn()
        {
            eye.Z -= zoom_number;
            SetWorldToViewMatrix();
        }

        public void ZoomOut()
        {
            eye.Z += zoom_number;
            SetWorldToViewMatrix();
        }

        private void SetWorldToViewMatrix()
        {
            Vector3 axisZ = Vector3.Normalize(Vector3.Subtract(eye, target));
            Vector3 axisX = Vector3.Normalize(Vector3.Cross(up, axisZ));
            Vector3 axisY = Vector3.Normalize(Vector3.Cross(axisZ, axisX));
            worldToViewMatrix = new Matrix4x4(
                axisX.X, axisX.Y, axisX.Z, -Vector3.Dot(axisX, eye),
                axisY.X, axisY.Y, axisY.Z, -Vector3.Dot(axisY, eye),
                axisZ.X, axisZ.Y, axisZ.Z, -Vector3.Dot(axisZ, eye),
                0, 0, 0, 1
            );
        }

        public Bitmap SetUpCamera()
        {
            SetWorldToViewMatrix();
            verteces_changeable = new List<Vector4>();
            return Draw();
        }

        private bool IsBackFace(List<List<int>> face)
        {
            Vector3 normal = CalculateNormal(face);
            Vector3 viewVector = ToVector3(verteces_view[face[0][0] - 1]) - eye;
            return false;
            return Vector3.Dot(normal, viewVector) <= 0;
        }
        
        private Vector3 CalculateNormal(List<List<int>> face)
        {
            Vector3 v1 = Vector3.Normalize(ToVector3(verteces_view[face[1][0] - 1]) - ToVector3(verteces_view[face[0][0] - 1]));
            Vector3 v2 = Vector3.Normalize(ToVector3(verteces_view[face[2][0] - 1]) - ToVector3(verteces_view[face[0][0] - 1]));
            return Vector3.Normalize(Vector3.Cross(v2, v1));
        }

        private Vector3 ToVector3(Vector4 vector)
        {
            return new Vector3(vector.X, vector.Y, vector.Z);
        }
        
        
        float GGX_Distribution(float cosThetaNH, float alpha)
        {
            float alpha2 = alpha * alpha;
            float NH_sqr = cosThetaNH * cosThetaNH;
            float den = NH_sqr * (alpha2 - 1) + 1;
            return alpha2 / Math.Max((float)Math.PI * den * den, 0.00001f);
        }

        float GGX_PartialGeometry(float cosThetaN, float alpha)
        {
            float k = alpha / 2;
            return cosThetaN / Math.Max(cosThetaN * (1 - k) + k , 0.00001f);
        }
        Vector3 fresnelSchlick(float cosTheta, Vector3 F0)
        {
            cosTheta = Math.Max(Math.Min(cosTheta*cosTheta, 1f), 0f);
            return F0 + (Vector3.One - F0) * new Vector3((float)Math.Pow(1.0 - cosTheta, 5));
        }   
        
        public static float LinearSRGB(float x)
        {
            return !(x <= 0.0031308f) ? (1.055f * (float)Math.Pow(x, 1.0f / 2.4f) - 0.055f) : (12.92f * x);
        }

        public static float SRGBLinear(float x)
        {
            return (x <= 0.04045f) ? (x / 12.92f) : (float)Math.Pow((x + 0.055f) / 1.055f, 2.4f);
        }
        
}

}
