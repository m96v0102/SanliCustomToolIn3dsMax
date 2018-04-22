#if UNITY_EDITOR
//Sanli一開始跨專案時，常用的一些TA通用Editor UI Style
//此script版本記錄: v1.002
using UnityEngine;
using UnityEditor;
using System;

namespace Edit.TAScript
{
    //從網路摳的填色code：https://answers.unity.com/questions/1154384/labelfield-wont-change-background-color.html
    public static class Texture2DExtensions
    {
        public static void SetColor(this Texture2D tex2, Color32 color)
        {
            var fillColorArray = tex2.GetPixels32();

            for (var i = 0; i < fillColorArray.Length; ++i)
            {
                fillColorArray[i] = color;
            }

            tex2.SetPixels32(fillColorArray);

            tex2.Apply();
        }
    }

    public class EdtUIStyle_TA
    {
        #region 變數宣告
        static GUIStyle m_lb14FSizeMLeft;
        static GUIStyle m_lb14FSizeLRight;
        static GUIStyle m_lb14FSizeMCenter;
        static GUIStyle m_lb12FSizeMCenter;
        static GUIStyle m_lb12FSizeMLeft;
        static GUIStyle m_lb10FSizeMCenter;
        static GUIStyle m_lb10FSizeMLeft;
        static GUIStyle m_lb10FSizeMRClor11;
        static GUIStyle m_lb10FSizeMLColor1;

        static GUIStyle m_btn14FSizeLCenter;
        static GUIStyle m_btn12FSizeLCenter;
        static GUIStyle m_btn10FSizeUCenter;

        static GUIStyle m_txf14FSize;           //(GUI.skin.textField)
        static GUIStyle m_txf12FSizeMCenter;           //(GUI.skin.textField)
        static GUIStyle m_txf10FSize;           //(GUI.skin.textField)

        static GUIStyle m_bxStyle;              //專門塞Folder的BoxStyle(GUI.skin.box)
        
        static GUIStyle m_pp12FSize18Height;    //Popup MenuStyle
        static GUIStyle m_pp10FSize16HULeft;    //Popup MenuStyle-10FontSize 16Height UpperLeft
        static GUIStyle m_pp10FSize16HUCenter;  //Popup MenuStyle-10FontSize 16Height UpperCenter
        
        static GUIStyle m_tgLLeft;              //(GUI.skin.toggle)
        static GUIStyle m_tgLCenter;            //(GUI.skin.toggle)

        static GUIStyle m_foldout;

        //listbox相關變數
        static GUIStyle m_style_scrollview;             
        private static GUIStyle m_style_evenBackground;
        private static GUIStyle m_style_oddBackground;
        private static GUILayoutOption[] m_optInitText;
        private static GUILayoutOption[] m_optListFrameSelBtn;
        private static GUILayoutOption[] m_optListDelBtn;

        public static string sToolTip;

        #region tooltip相關
        public static string e_tipstring = "";
        public static Rect e_tipRect = new Rect(0, 0, 0, 0);
        public static bool setTipFlag = false;
        public static Texture e_tipTexture;
        static void SetTip(string s)
        {
            // 避免ＧＵＩ無關緊要的報錯
            if (Event.current.type != EventType.Layout && Event.current.type != EventType.Repaint)
                return;

            setTipFlag = true;
            GUIContent contentA = new GUIContent(s);
            e_tipstring = s;
            Rect nr = GUILayoutUtility.GetRect(contentA, EditorStyles.largeLabel);
            e_tipRect = new Rect(0, 0, Mathf.Min(nr.width, 500) + 5, nr.height + 5);
            e_tipTexture = null;
        }

        static void SetTip(string s, Texture tex)
        {
            // 避免ＧＵＩ無關緊要的報錯
            if (Event.current.type != EventType.Layout && Event.current.type != EventType.Repaint)
                return;

            setTipFlag = true;
            GUIContent contentA = new GUIContent(s);
            e_tipstring = s;
            Rect nr = GUILayoutUtility.GetRect(contentA, EditorStyles.largeLabel);
            e_tipTexture = tex;
            e_tipRect = new Rect(0, 0, Mathf.Min(nr.width, 500) + 5, nr.height + 5);

        }
        #endregion tooltip相關

        //說明專用格式
        static GUIStyle m_hbx12FSize;//HelpBox style
        #endregion 變數宣告

        public static int nCustomStyleID = 233;

        public static GUIStyle lb14FSizeMLeft  //label of 14 FontSize and MiddleLeft
        {
            get
            {
                if (m_lb14FSizeMLeft == null)
                {
                    m_lb14FSizeMLeft = new GUIStyle(GUI.skin.label);
                    m_lb14FSizeMLeft.fontSize = 14;
                    m_lb14FSizeMLeft.alignment = TextAnchor.MiddleLeft;
                }
                return m_lb14FSizeMLeft;
            }
        }
        public static GUIStyle lb14FSizeLRight  //label of 14 FontSize and LowerRight
        {
            get
            {
                if (m_lb14FSizeLRight == null)
                {
                    m_lb14FSizeLRight = new GUIStyle(GUI.skin.label);
                    m_lb14FSizeLRight.fontSize = 14;
                    m_lb14FSizeLRight.alignment = TextAnchor.LowerRight;
                }
                return m_lb14FSizeLRight;
            }
        }
        public static GUIStyle lb14FSizeMCenter  //label of 14 FontSize and LowerRight
        {
            get
            {
                if (m_lb14FSizeMCenter == null)
                {
                    m_lb14FSizeMCenter = new GUIStyle(GUI.skin.label);
                    m_lb14FSizeMCenter.fontSize = 14;
                    m_lb14FSizeMCenter.alignment = TextAnchor.MiddleCenter;
                }
                return m_lb14FSizeMCenter;
            }
        }
        public static GUIStyle lb12FSizeMCenter  //label of 12 FontSize and MiddleCenter
        {
            get
            {
                if (m_lb12FSizeMCenter == null)
                {
                    m_lb12FSizeMCenter = new GUIStyle(GUI.skin.label);
                    m_lb12FSizeMCenter.fontSize = 12;
                    m_lb12FSizeMCenter.alignment = TextAnchor.MiddleCenter;
                }
                return m_lb12FSizeMCenter;
            }
        }        
        public static GUIStyle lb12FSizeMLeft  //label of 12 FonSize and MiddleLeft
        {
            get
            {
                if (m_lb12FSizeMLeft == null)
                {
                    m_lb12FSizeMLeft = new GUIStyle(GUI.skin.label);
                    m_lb12FSizeMLeft.fontSize = 12;
                    m_lb12FSizeMLeft.alignment = TextAnchor.MiddleLeft;
                }
                return m_lb12FSizeMLeft;
            }
        }
        public static GUIStyle lb10FSizeMCenter  //label of 10 FontSize and MiddleCenter
        {
            get
            {
                if (m_lb10FSizeMCenter == null)
                {
                    m_lb10FSizeMCenter = new GUIStyle(GUI.skin.label);
                    m_lb10FSizeMCenter.fontSize = 10;
                    m_lb10FSizeMCenter.alignment = TextAnchor.MiddleCenter;
                }
                return m_lb10FSizeMCenter;
            }
        }
        public static GUIStyle lb10FSizeMLeft  //label of 10 FonSize and MiddleLeft
        {
            get
            {
                if (m_lb10FSizeMLeft == null)
                {
                    m_lb10FSizeMLeft = new GUIStyle(GUI.skin.label);
                    m_lb10FSizeMLeft.fontSize = 10;
                    m_lb10FSizeMLeft.alignment = TextAnchor.MiddleLeft;
                }
                return m_lb10FSizeMLeft;
            }
        }
        public static GUIStyle lb10FSizeMLColor1  //label of 10 FonSize and MiddleRight With Custom Color
        {
            get
            {
                m_lb10FSizeMLColor1 = new GUIStyle(GUI.skin.label);
                m_lb10FSizeMLColor1.fontSize = 10;
                m_lb10FSizeMLColor1.alignment = TextAnchor.MiddleLeft;

                //設定顏色(一定要先class一個Texture2DExtensions，才會有作用)
                Texture2D tex = new Texture2D(2, 2);
                if (EditorGUIUtility.isProSkin) tex.SetColor(new Color(0.9f, 0.9f, 0.9f, 0.25f));//r,g,b,a
                else tex.SetColor(new Color(0.9f, 0.9f, 0.9f, 1f));//r,g,b,a
                m_lb10FSizeMLColor1.normal.background = tex;
                return m_lb10FSizeMLColor1;
            }
        }
        public static GUIStyle lb10FSizeMRColor1  //label of 10 FonSize and MiddleRight With Custom Color
        {
            get
            {
                m_lb10FSizeMRClor11 = new GUIStyle(GUI.skin.label);
                m_lb10FSizeMRClor11.fontSize = 10;
                m_lb10FSizeMRClor11.alignment = TextAnchor.MiddleRight;

                //設定顏色(一定要先class一個Texture2DExtensions，才會有作用)
                Texture2D tex = new Texture2D(2, 2);
                if (EditorGUIUtility.isProSkin) tex.SetColor(new Color(0.9f, 0.9f, 0.9f, 0.25f));//r,g,b,a
                else                            tex.SetColor(new Color(0.9f, 0.9f, 0.9f, 1f));//r,g,b,a
                m_lb10FSizeMRClor11.normal.background = tex;
                return m_lb10FSizeMRClor11;
            }
        }
        
        public static GUIStyle btn14FSizeLCenter  //label of 14 FontSize and LowerCenter
        {
            get
            {
                if (m_btn14FSizeLCenter == null)
                {
                    m_btn14FSizeLCenter = new GUIStyle(GUI.skin.button);
                    m_btn14FSizeLCenter.fontSize = 14;
                    m_btn14FSizeLCenter.alignment = TextAnchor.LowerCenter;
                }
                return m_btn14FSizeLCenter;
            }
        }
        public static GUIStyle btn12FSizeLCenter //button of 12 FontSize and LowerCenter
        {
            get
            {
                if (m_btn12FSizeLCenter == null)
                {
                    m_btn12FSizeLCenter = new GUIStyle(GUI.skin.button);
                    m_btn12FSizeLCenter.fontSize = 12;
                    m_btn12FSizeLCenter.alignment = TextAnchor.LowerCenter;
                }
                return m_btn12FSizeLCenter;
            }
        }
        public static GUIStyle btn10FSizeUCenter //button of 10 FontSize and UpperCenter
        {
            get
            {
                if (m_btn10FSizeUCenter == null)
                {
                    m_btn10FSizeUCenter = new GUIStyle(GUI.skin.button);
                    m_btn10FSizeUCenter.fontSize = 10;
                    m_btn10FSizeUCenter.alignment = TextAnchor.UpperCenter;
                }
                return m_btn10FSizeUCenter;
            }
        }

        public static GUIStyle txf14FSize  //textfield of 14 FontSize
        {
            get
            {
                if (m_txf14FSize == null)
                {
                    m_txf14FSize = new GUIStyle(GUI.skin.textField);
                    m_txf14FSize.fontSize = 14;
                }
                return m_txf14FSize;
            }
        }
        public static GUIStyle txf12FSize  //textfield of 14 FontSize
        {
            get
            {
                if (m_txf12FSizeMCenter == null)
                {
                    m_txf12FSizeMCenter = new GUIStyle(GUI.skin.textField);
                    m_txf12FSizeMCenter.fontSize = 14;
                    m_txf12FSizeMCenter.alignment = TextAnchor.MiddleCenter;
                }
                return m_txf12FSizeMCenter;
            }
        }
        public static GUIStyle txf10FSize  //textfield of 12 FontSize
        {
            get
            {
                if (m_txf10FSize == null)
                {
                    m_txf10FSize = new GUIStyle(GUI.skin.textField);
                    m_txf10FSize.fontSize = 10;
                }
                return m_txf10FSize;
            }
        }
        
        public static GUIStyle pp12FSize18HeightULeft //label of 12 FontSize and 18 fixedHieght
        {
            get
            {
                if (m_pp12FSize18Height == null)
                {
                    m_pp12FSize18Height = new GUIStyle(EditorStyles.popup);
                    m_pp12FSize18Height.fontSize = 12;
                    m_pp12FSize18Height.alignment = TextAnchor.UpperLeft;
                    m_pp12FSize18Height.fixedHeight = 18;
                }
                return m_pp12FSize18Height;
            }
        }

        public static GUIStyle pp10FSize16HeightULeft //label of 10 FontSize and 16 fixedHieght with UpperLeft
        {
            get
            {
                if (m_pp10FSize16HULeft == null)
                {
                    m_pp10FSize16HULeft = new GUIStyle(EditorStyles.popup);
                    m_pp10FSize16HULeft.fontSize = 10;
                    m_pp10FSize16HULeft.alignment = TextAnchor.UpperLeft;
                    m_pp10FSize16HULeft.fixedHeight = 16;
                }
                return m_pp10FSize16HULeft;
            }
        }
        public static GUIStyle pp10FSize16HeightUCenter //label of 10 FontSize and 16 fixedHieght with UpperCenter
        {
            get
            {
                if (m_pp10FSize16HUCenter == null)
                {
                    m_pp10FSize16HUCenter = new GUIStyle(EditorStyles.popup);
                    m_pp10FSize16HUCenter.fontSize = 10;
                    m_pp10FSize16HUCenter.alignment = TextAnchor.UpperCenter;
                    m_pp10FSize16HUCenter.fixedHeight = 16;
                }
                return m_pp10FSize16HUCenter;
            }
        }

        public static GUIStyle bxNormal
        {
            get
            {
                if (m_bxStyle == null)
                {
                    m_bxStyle = new GUIStyle(GUI.skin.box);
                }
                return m_bxStyle;
            }
        }

        public static GUIStyle tgLLeft  //toggle of Lower Left
        {
            get
            {
                if (m_tgLLeft == null)
                {
                    m_tgLLeft = new GUIStyle(GUI.skin.toggle);
                    m_tgLLeft.alignment = TextAnchor.LowerLeft;
                }
                return m_tgLLeft;
            }
        }
        public static GUIStyle tgLCenter  //toggle of Lower Left
        {
            get
            {
                if (m_tgLCenter == null)
                {
                    m_tgLCenter = new GUIStyle(GUI.skin.toggle);
                    m_tgLCenter.alignment = TextAnchor.LowerCenter;
                }
                return m_tgLCenter;
            }
        }

        public static GUIStyle hbx12FSize    //helpbox of 12 FontSize
        {
            get
            {
                if (m_hbx12FSize == null)
                {
                    m_hbx12FSize = new GUIStyle(GUI.skin.GetStyle("HelpBox"));
                    m_hbx12FSize.richText = true;
                    m_hbx12FSize.fontSize = 12;
                }
                return m_hbx12FSize;
            }
        }

        public static GUIStyle fd14FSize    //Foldout of 14 FontSize
        {
            get
            {
                if (m_foldout == null)
                {
                    m_foldout = new GUIStyle("Foldout");
                    //m_foldout.richText = true;
                    m_foldout.fontSize = 14;
                    //m_foldout.alignment = TextAnchor.LowerLeft;
                }
                return m_foldout;
            }
        }        

        public static GUIStyle styleScrollView 
        {
            get 
            {
                if (m_style_scrollview == null)
                {
                    m_style_scrollview = new GUIStyle("CN Box");
                    m_style_scrollview.overflow = new RectOffset(1, 1, 1, 1);
                }
                return m_style_scrollview; 
            }
        }

        public static GUIStyle styleEvenBackground
        {
            get
            {
                if (m_style_evenBackground == null)
                {
                    GUIStyle evenBackground = "CN EntryBackEven";
                    m_style_evenBackground = new GUIStyle();
                    m_style_evenBackground.normal = evenBackground.normal;
                }
                return m_style_evenBackground; 
            } 
        }

        public static GUIStyle styleOddBackground
        {
            get
            {
                if (m_style_oddBackground == null)
                {
                    GUIStyle oddBackground = "CN EntryBackodd";
                    m_style_oddBackground = new GUIStyle();
                    m_style_oddBackground.normal = oddBackground.normal;
                }
                return m_style_oddBackground; 
            } 
        }

        public static GUILayoutOption[] optInitText
        {
            get
            {
                if (m_optInitText == null)
                    m_optInitText = new GUILayoutOption[0];
                return m_optInitText;
            }
        }
        public static GUILayoutOption[] optListFrameSelBtn
        {
            get
            {
                if (m_optListFrameSelBtn == null)
                {
                    m_optListFrameSelBtn = new GUILayoutOption[] { GUILayout.Width(18), GUILayout.MaxHeight(EditorGUIUtility.singleLineHeight) };
                }
                return m_optListFrameSelBtn;
            }
        }
        public static GUILayoutOption[] optListDelBtn
        {
            get
            {
                if (m_optListDelBtn == null)
                {
                    m_optListDelBtn = new GUILayoutOption[] { GUILayout.Width(32), GUILayout.MaxHeight(EditorGUIUtility.singleLineHeight) };
                }
                return m_optListDelBtn; 
            } 
        }


    }
}

#endif
