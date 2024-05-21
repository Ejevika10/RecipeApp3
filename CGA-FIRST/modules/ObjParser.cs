using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Numerics;
using System.Reflection;
using System.Text.RegularExpressions;

namespace CGA_FIRST.modules
{
    public class ObjParser
    {
        public List<double[]> verteces = new List<double[]>();
        public List<Vector3> normals = new List<Vector3>();
        public List<List<List<int>>> faces = new List<List<List<int>>>();
        public static Bitmap diffuseMap = null;
        public static Bitmap mirrorMap = null;
        public static Bitmap normalMap = null;
        public static Bitmap aoMap;
        public static Bitmap baseMap;
        public static Bitmap metallicMap;
        public static Bitmap roughnessMap;
        public static Vector3[,] fileNormals;
        public static List<Vector2> textures = new List<Vector2>();
        //public static List<Vector2> listVt = new List<Vector2>();

        public void parseFile(string path)
        {
            string[] lines = File.ReadAllLines(path);
            var fmt = new NumberFormatInfo
            {
                NegativeSign = "-"
            };

            foreach (string line in lines)
            {
                string newline = line.Trim();
                string[] literals = Regex.Split(newline, @"\s+");
                switch (literals[0])
                {
                    case "v":
                        if (literals.Length == 4)
                        {
                            verteces.Add(new double[] { double.Parse(literals[1], fmt), double.Parse(literals[2],fmt),
                                                     double.Parse(literals[3], fmt), 1});
                        }
                        else
                        {
                            verteces.Add(new double[] { double.Parse(literals[1]), double.Parse(literals[2]),
                                                     double.Parse(literals[3]), double.Parse(literals[4])});
                        }
                        break;
                    case "f":
                        if (newline.Contains('/'))
                        {
                            List<List<int>> topLevelList = new List<List<int>>();
                            for (int i = 1; i < literals.Length; i++)
                            {
                                string[] numbers = literals[i].Split('/');
                                List<int> tempList = new List<int>();
                                foreach (string numb in numbers)
                                {
                                    if (numb.Length != 0)
                                        tempList.Add(int.Parse(numb));
                                    else
                                        tempList.Add(0);
                                }
                                topLevelList.Add(tempList);
                            }
                            if (topLevelList.Count == 4)
                            {
                                faces.Add(new List<List<int>> { topLevelList[0], topLevelList[1], topLevelList[2] });
                                faces.Add(new List<List<int>> { topLevelList[0], topLevelList[2], topLevelList[3] });
                            }
                            else
                            {
                                faces.Add(topLevelList);
                            }
                        }
                        else
                        {
                            List<List<int>> topLevelList = new List<List<int>>();
                            for (int i = 1; i < literals.Length; i++)
                            {
                                List<int> tempList = new List<int>
                                {
                                    int.Parse(literals[i])
                                };
                                topLevelList.Add(tempList);
                            }
                            faces.Add(topLevelList);
                        }
                        break;

                    case "vn":
                        {
                            normals.Add(new Vector3 ((float)double.Parse(literals[1], fmt), 
                                                     (float)double.Parse(literals[2], fmt),
                                                     (float)double.Parse(literals[3], fmt)));
                        }
                        break;
                    case "vt":
                        {
                            textures.Add(new Vector2((float)double.Parse(literals[1], fmt),
                                                     (float)double.Parse(literals[2], fmt)));
                        }
                        break;
                }
            }            
        }

        public void parseTextures(string AOMapPath, string BaseMapPath, string metallicMapPath, string normalMapPath, string roughnessMapPath) {
            try
            {
                aoMap = (Bitmap)Bitmap.FromFile(AOMapPath);
            }
            catch (Exception ex)
            {
                aoMap = null;
            }

            try
            {
                baseMap = (Bitmap)Bitmap.FromFile(BaseMapPath);
            }
            catch (Exception ex)
            {
                baseMap = null;
            }
            try
            {
                metallicMap = (Bitmap)Bitmap.FromFile(metallicMapPath);
            }
            catch (Exception ex)
            {
                metallicMap = null;
            }
            try
            {
                roughnessMap = (Bitmap)Bitmap.FromFile(roughnessMapPath);
            }
            catch (Exception ex)
            {
                roughnessMap = null;
            }

            try
            {
                normalMap = (Bitmap)Bitmap.FromFile(normalMapPath);
                fileNormals = new Vector3[normalMap.Width, normalMap.Height];

                for (int i = 0; i < normalMap.Width; i++)
                {
                    for (int j = 0; j < normalMap.Height; j++)
                    {
                        Color normalColor = normalMap.GetPixel(i, j);
                        Vector3 normal = new Vector3(normalColor.R / 255f, normalColor.G / 255f, normalColor.B / 255f);
                        normal = (normal * 2) - Vector3.One;
                        normal = Vector3.Normalize(normal);
                        fileNormals[i,j] = normal;
                    }
                }
            }
            catch (Exception ex)
            {
                normalMap = null;
            }
        }
    }
}
