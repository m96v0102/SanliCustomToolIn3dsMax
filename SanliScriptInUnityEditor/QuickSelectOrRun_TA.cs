//Sanli一開始跨專案時，常用的一些TA通用script
//快速選擇物件
//define版號參考: https://docs.unity3d.com/Manual/PlatformDependentCompilation.html

#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;                          //EditorWindow會用到的code
using System.IO;                            //Directory.GetFiles
using System.Collections;
using System.Collections.Generic;           //使用List會用到的code
using System.Xml;

namespace Edit.TAScript
{
    [System.Serializable]                   //這行註解掉的話，一按play，lstSelTALBox裡面的內容就會被清掉
    public class SimpleListBox_TA
    {
        public Object obj;
        public bool bOldSelected = false;
        public bool bNewSelected = false;
        public string sSceneName;           //該物件所屬的場景名稱
        public string sLabel;               //物件的名稱
        public string sFullPath;            //在scene裡的詳細路徑
        public int nChildNum;               //同個階層下若有同名，此變數用來記錄該物件是同名物件中第幾個編號
    }

    public class QuickSelectOrRun_TA : EditorWindow
    {
        #region 變數相關
        static string sMaxExportPathInXml = @"Assets\Editor\Sanli\ExrpotRecordPath.xml";

        //記錄或載入選取物件在Hierarchy裡的全名
        //string sSelectFullName = string.Empty;
        bool bShowSelFullNamePanel = true;

        public static bool bLoadingXML = false;

        //記錄選取物件相關
        Vector2 _scroll_pos = Vector2.zero;
        public static List<SimpleListBox_TA> lstSelTALBox = new List<SimpleListBox_TA>();
        public string sSelectionXmlFile = string.Empty;
        public static int sSceneLBWidth = 100;                                                  //Scene Label Width  80
        public static int sObjectLBWidth = 120;                                                 //Object Label Width  60
        public static string sProjWndLabel = "ProjWnd";

        public static string sTAScriptFolder = @"Assets\Editor\TAScript";
        #endregion 變數相關

        #region Menu相關
        [MenuItem("SanliTools/快速選取物件 &`")]
        private static void ReloadAndSelect()
        {
            QuickSelectOrRun_TA.Init();
            LoadXml();
        }
        #endregion Menu相關

        public static void Init()
        {
            #if UNITY_2017_1_OR_NEWER
            Caching.ClearCache();
            #else
            Caching.CleanCache();
            #endif
            EditorWindow.GetWindow<QuickSelectOrRun_TA>(false, "通用_快選或搜尋", true);
        }

        //Set Project Window Selection to SimpleListBox_TA
        public void SetProjSelToLBoxTA(ref SimpleListBox_TA lboxTA)
        {
            Debug.Log("Sanlilog_偵測到選取的物件並非場景物件");
            lboxTA.sSceneName = sProjWndLabel;
            lboxTA.obj = Selection.objects[0];
            lboxTA.sLabel = Selection.objects[0].name;
            lboxTA.sFullPath = AssetDatabase.GetAssetPath(Selection.objects[0]);
        }

        //Set Scene Window Selection to SimpleListBox_TA
        public void SetSceneSelToLBoxTA(ref SimpleListBox_TA lboxTA, ref GameObject _goSelection)
        {
            #if UNITY_5_4_OR_NEWER
            lboxTA.sSceneName = _goSelection.scene.name;
            #else
            lboxTA.sSceneName = EditorApplication.currentScene;
            #endif

            lboxTA.obj = _goSelection;
            lboxTA.sLabel = Selection.objects[0].name;
            lboxTA.sFullPath = GameObjectExtensions.GetFullName(_goSelection);

            //如果有parent物件，就查看parent物件底下有沒有跟自己名稱相同的物件
            //如果同個階層有相同名稱的物件，舊查看自己是第幾個階層
            
            //如果有parent物件，直接判斷自己在parent物件當中有無同名物件，有的話是第幾層
            if (_goSelection.transform.parent != null)
            {
                List<GameObject> lstSelectionUnderParentObj = new List<GameObject>();
                //GameObject goParent = goSelection.transform.parent.gameObject;
                Transform tsParent = _goSelection.transform.parent;
                for (int i = 0; i < tsParent.childCount; i++)
                {
                    if (tsParent.GetChild(i).name == _goSelection.transform.name)
                        lstSelectionUnderParentObj.Add(tsParent.GetChild(i).gameObject);
                }

                for (int i = 0; i < lstSelectionUnderParentObj.Count; i++)
                {
                    if (lstSelectionUnderParentObj[i] == _goSelection)
                    {
                        Debug.Log(string.Format("Sanlilog_該物件在parent下屬於第{0}個同名物件", i.ToString()));
                        lboxTA.nChildNum = i;
                        break;
                    }
                }
            }
            //如果沒有parent物件，就用Resources.FindObjectsOfTypeAll的方式尋找Scene裡同名的物件有幾個
            else
            {
                List<GameObject> lstSelectionObj = new List<GameObject>();
                GameObject[] pAllObjects = (GameObject[])Resources.FindObjectsOfTypeAll(typeof(GameObject));
                //foreach (GameObject pObject in pAllObjects)
                for (int i = 0; i < pAllObjects.Length; i++ )
                {
                    //GameObject pObject = pAllObjects[i];
                    if (pAllObjects[i].hideFlags == HideFlags.NotEditable || pAllObjects[i].hideFlags == HideFlags.HideAndDontSave) continue;
                    if (pAllObjects[i].transform.parent != null) continue;//如果不是場景裡的root物件，直接跳下一個迴圈
                    #if UNITY_5_4_OR_NEWER
                    if (pAllObjects[i].scene.IsValid() == false) continue;//如果不是場景裡的物件，直接跳下一個迴圈
                    #endif

                    if (pAllObjects[i].name == _goSelection.name)
                    {
                        lstSelectionObj.Add(pAllObjects[i]);
                    }
                }

                //Debug.Log("三立log_和選取物件相同的名稱：" + lstSelectionObj.Count.ToString());
                //取出被選取的物件，在同名物件當中，是第幾個物件
                for (int i = 0; i < lstSelectionObj.Count; i++ )
                {
                    if (lstSelectionObj[i] == _goSelection)
                    {
                        Debug.Log("Sanlilog_該模型屬於同名裡的第 " + i.ToString() + " 個物件");
                        lboxTA.nChildNum = i;
                    }
                }
            }
        }

        void GetXmlFileString()
        {
            Object objSelectDataXml = MonoScript.FromScriptableObject(this);
            sSelectionXmlFile = (Path.GetDirectoryName(AssetDatabase.GetAssetPath(objSelectDataXml))) + "/SelectionData.xml";
        }

        public static void LoadXml()
        {
            bLoadingXML = true;
            lstSelTALBox.Clear();
            //string sXml = @"Assets\Editor\Sanli\ExrpotRecordPath.xml";
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.Load(sMaxExportPathInXml);
            XmlNode xndRoot = xmlDoc.LastChild;

            if (xndRoot != null)
            {
                foreach (XmlNode node in xndRoot.ChildNodes)//取得每一層的Properties
                {
                    //Debug.LogFormat("Sanlilog_node name is {0}, node text is {1}", node.Name, node.InnerText);
                    //將絕對路徑改為Asset開頭的相對路徑
                    //例如：將D:\OlgCase\SwitchCSProj_Sanli_201712p4\Assets\Model\stone_wall_01d.FBX 改為 Assets\Model\stone_wall_01d.FBX
                    int nAssetID = node.InnerText.IndexOf("Assets");
                    string sAssetPath = node.InnerText.Substring(nAssetID);
                    //Debug.LogFormat("Sanlilog_Whole：{0}，ID：{1}，Path：{2}", node.InnerText, nAssetID.ToString(), sAssetPath);

                    SimpleListBox_TA lboxTA = new SimpleListBox_TA();
                    lboxTA.sSceneName = "ProjWnd";
                    lboxTA.sLabel = node.Name;
                    lboxTA.sFullPath = sAssetPath;
                    lboxTA.nChildNum = 0;
                    lstSelTALBox.Add(lboxTA);
                }
            }
        }

        Vector2 sv = new Vector2();
        void OnGUI()
        {
            sv = EditorGUILayout.BeginScrollView(sv);
            {
                GUILayout.Space(10);
                GUILayout.BeginHorizontal();
                GUILayout.Label("快選工具_v1.001", EdtUIStyle_TA.lb14FSizeMLeft);
                if (GUILayout.Button(new GUIContent("載入路徑", "重新載入max端的輸出路徑，並選取第一個物件"), GUILayout.MaxWidth(110)))
                {
                    LoadXml();
                }
                if (GUILayout.Button("選取此工具的script", GUILayout.MaxWidth(110)))
                {
                    Selection.activeObject = MonoScript.FromScriptableObject(this);
                    EditorGUIUtility.PingObject(Selection.activeObject);
                }
                GUILayout.EndHorizontal();

                #region 記錄場景裡的選取物件，或選取文字裡指定的物件
                GUILayout.Space(4);                
                bShowSelFullNamePanel = EditorGUILayout.Foldout(bShowSelFullNamePanel, new GUIContent("記錄或選取(建議Unity5以上)", EdtUIStyle_TA.sToolTip), EdtUIStyle_TA.fd14FSize);
                if (bShowSelFullNamePanel)
                {
                    #region 儲存或載入list
                    GUILayout.BeginHorizontal();
                    #region 儲存list
                    if (GUILayout.Button("儲存list", EdtUIStyle_TA.btn14FSizeLCenter))
                    {
                        XmlDocument doc = new XmlDocument();
                        doc.LoadXml("<Root></Root>");//先直接建立一個tag，這樣子稍候才能AppendChild

                        for (int i = 0; i < lstSelTALBox.Count; i++)
                        {
                            //public GameObject goObject;
                            XmlElement newElem = doc.CreateElement("Selection");
                            doc.DocumentElement.AppendChild(newElem);
                            XmlElement elSceneName = doc.CreateElement("sSceneName");   //該物件所屬的場景名稱
                            elSceneName.InnerText = lstSelTALBox[i].sSceneName;
                            newElem.AppendChild(elSceneName);
                            XmlElement elLabel = doc.CreateElement("sLabel");           //物件的名稱
                            elLabel.InnerText = lstSelTALBox[i].sLabel;
                            newElem.AppendChild(elLabel);
                            XmlElement elFullPath = doc.CreateElement("sFullPath");     //在scene裡的詳細路徑
                            elFullPath.InnerText = lstSelTALBox[i].sFullPath;
                            newElem.AppendChild(elFullPath);
                            XmlElement elChildNum = doc.CreateElement("nChildNum");     //是Parent(或Root)裡的第幾個物件
                            elChildNum.InnerText = lstSelTALBox[i].nChildNum.ToString();
                            newElem.AppendChild(elChildNum);
                        }

                        // Save the document to a file. White space is
                        // preserved (no white space).
                        doc.PreserveWhitespace = true;

                        GetXmlFileString();
                        doc.Save(sSelectionXmlFile);

                        AssetDatabase.SaveAssets();
                        AssetDatabase.Refresh();
                    }
                    #endregion 儲存list
                    #region 載入list
                    if (GUILayout.Button("載入list", EdtUIStyle_TA.btn14FSizeLCenter))
                    {
                        lstSelTALBox.Clear();
                        GetXmlFileString();
                        TextAsset xmlData = FnQuickSelectOrRun_TA.CheckFileAndLoad(sSelectionXmlFile) as TextAsset;
                        if (xmlData != null)
                        {
                            Debug.Log("Sanlio_載入成功" + sSelectionXmlFile);
                            XmlDocument xml = new XmlDocument();
                            xml.LoadXml(xmlData.text);
                            XmlNode xndRoot = xml.LastChild;

                            if (xndRoot != null)
                            {
                                foreach (XmlNode node in xndRoot.ChildNodes)//取得每一層的Properties
                                {
                                    SimpleListBox_TA lboxTA = new SimpleListBox_TA();
                                    lboxTA.sSceneName = node.ChildNodes[0].InnerText;
                                    lboxTA.sLabel = node.ChildNodes[1].InnerText;
                                    lboxTA.sFullPath = node.ChildNodes[2].InnerText;
                                    lboxTA.nChildNum = int.Parse(node.ChildNodes[3].InnerText);
                                    lstSelTALBox.Add(lboxTA);
                                }
                            }
                        }
                        else
                            Debug.Log("Sanlilog_載入失敗" + sSelectionXmlFile);
                    }
                    #endregion 載入list
                    GUILayout.EndHorizontal();
                    #endregion

                    #region 增加物件
                    EdtUIStyle_TA.sToolTip = "將選取的單一物件塞到清單裡\n\n " +
                                             "注意1.Unity 4在記錄project window下的物件時，有時不會成功\n 注意2.用Unity 4選取場景裡的物件時，inspector可能會顯示選到兩個物件";
                    if (GUILayout.Button(new GUIContent("增加物件(建議Unity5以上)", EdtUIStyle_TA.sToolTip), EdtUIStyle_TA.btn14FSizeLCenter))
                    {
                        //如果沒選物件，或是選擇超過一個物件，都跳掉
                        if (FnQuickSelectOrRun_TA.CheckObjSelect(true) == false)
                            return;

                        SimpleListBox_TA lboxTA = new SimpleListBox_TA();

                        #if !UNITY_5_4_OR_NEWER
                        //如果不是GameObject，代表使用者選擇的可能ProjectWindow裡的資料夾或script
                        GameObject goSelection = Selection.objects[0] as GameObject;
                        if (goSelection == null)
                        {
                            EditorUtility.DisplayDialog("功能支援不完全", "Unity4不完全支援此功能，建議您更新至Unity5.4以上", "ok");
                        }
                        else
                        {
                            lboxTA.obj = Selection.objects[0];
                            lboxTA.sLabel = Selection.objects[0].name;
                            lboxTA.sSceneName = Path.GetFileNameWithoutExtension(EditorApplication.currentScene);
                            lboxTA.sFullPath = GameObjectExtensions.GetFullName(goSelection);
                            
                        }
                        if (string.IsNullOrEmpty(lboxTA.sSceneName))
                            lboxTA.sSceneName = "沒存檔的場景";
                            
                        lstSelTALBox.Add(lboxTA);


                        #else
                        //如果不是GameObject，代表使用者選擇的可能ProjectWindow裡的資料夾或script
                        GameObject goSelection = Selection.objects[0] as GameObject;
                        if (goSelection == null)
                        {
                            //如果不是場景物件，SceneName就取名為ProjWnd
                            //if (FnQuickSelectOrRun_TA.CheckGOInScene(ref goSelection, goSelection.name, false) == false)
                                SetProjSelToLBoxTA(ref lboxTA);
                        }
                        else
                        {
                            //如果不是場景物件，是ProjectWindow裡的prefab，SceneName就取名為ProjWnd
                            if (FnQuickSelectOrRun_TA.CheckGOInScene(ref goSelection, goSelection.name, false) == false)
                                SetProjSelToLBoxTA(ref lboxTA);
                            else
                            {
                                SetSceneSelToLBoxTA(ref lboxTA, ref goSelection);
                            }
                        }

                        if (string.IsNullOrEmpty(lboxTA.sSceneName))
                            lboxTA.sSceneName = "沒存檔的場景";
                            
                        lstSelTALBox.Add(lboxTA);
                        #endif
                    }
                    #endregion 增加物件

                    #region 顯示標題
                    GUILayout.BeginVertical("AppToolbar");
                    {
                        GUILayout.BeginHorizontal();
                        GUILayout.Space(4);
                        EditorGUILayout.ToggleLeft("物件詳細路徑", false, EdtUIStyle_TA.optInitText);
                        GUILayout.Space(1);
                        EditorGUILayout.LabelField("場景名稱", EdtUIStyle_TA.lb10FSizeMLColor1, GUILayout.MaxWidth(sSceneLBWidth));
                        GUILayout.Space(1);
                        EditorGUILayout.LabelField("物件名稱", EdtUIStyle_TA.lb10FSizeMRColor1, GUILayout.MaxWidth(sObjectLBWidth));
                        GUILayout.Space(1);
                        if (GUILayout.Button(new GUIContent("F", "讓鏡頭Focus該物件"), EdtUIStyle_TA.optListFrameSelBtn)) { }
                        GUILayout.Space(1);
                        if (GUILayout.Button("刪除", EdtUIStyle_TA.optListDelBtn)) { }
                        GUILayout.EndHorizontal();
                    }
                    GUILayout.EndVertical();
                    #endregion 顯示標題

                    #region 顯示與選取清單list
                    _scroll_pos = EditorGUILayout.BeginScrollView(_scroll_pos, EdtUIStyle_TA.styleScrollView);
                    {
                        int rowIndex = 0;

                        //foreach (SimpleListBox_TA es in lstSelTALBox)//用這個remove list會有error，所以改用for
                        for (int i = 0; i < lstSelTALBox.Count; i++)
                        {
                            SimpleListBox_TA es = lstSelTALBox[i];

                            rowIndex++;
                            GUIStyle gUIStyle = (rowIndex % 2 != 0) ? EdtUIStyle_TA.styleEvenBackground : EdtUIStyle_TA.styleOddBackground;
                            GUI.backgroundColor = es.bOldSelected ? Color.cyan : Color.white;
                            EditorGUILayout.BeginVertical(gUIStyle, EdtUIStyle_TA.optInitText);
                            {
                                #region 顯示text和Toggle
                                GUI.backgroundColor = Color.white;
                                GUILayout.Space(2);

                                EditorGUILayout.BeginHorizontal();
                                GUILayout.Space(4);
                                bool selected = EditorGUILayout.ToggleLeft(es.sFullPath, es.bOldSelected, EdtUIStyle_TA.optInitText);
                                //若是重新載入max匯入的物件，就重新刷新整個list，再直接選取第一個物件
                                if (bLoadingXML && es == lstSelTALBox[0])
                                {
                                    //Debug.Log("Sanlilog_reload and select object");
                                    bLoadingXML = false;
                                    selected = true;
                                    es.bOldSelected = false;
                                }
                                es.bNewSelected = selected;

                                //如果是【剛點選】，就選取物件
                                if (es.bOldSelected == false && es.bNewSelected == true)
                                    FnQuickSelectOrRun_TA.SelectObjByList(ref es, ref lstSelTALBox);



                                #endregion 顯示text和Toggle

                                //顯示場景名稱(怕名子過長，可能會被label的寬度切掉，所以有給tooltip)
                                GUILayout.Space(1);
                                //EditorGUILayout.LabelField(new GUIContent(es.goObject.scene.name, es.goObject.scene.name), EdtUIStyle_TA.lb10FSizeMLColor1, GUILayout.MaxWidth(65));
                                EditorGUILayout.LabelField(new GUIContent(es.sSceneName, es.sSceneName), EdtUIStyle_TA.lb10FSizeMLColor1, GUILayout.MaxWidth(sSceneLBWidth));

                                //顯示物件名稱(怕名子過長，可能會被label的寬度切掉，所以有給tooltip)
                                GUILayout.Space(1);
                                EditorGUILayout.LabelField(new GUIContent(es.sLabel, es.sLabel), EdtUIStyle_TA.lb10FSizeMRColor1, GUILayout.MaxWidth(sObjectLBWidth));

                                //顯示選取按鈕
                                GUILayout.Space(1);
                                if (GUILayout.Button(new GUIContent("F", "讓鏡頭Focus該物件"), EdtUIStyle_TA.optListFrameSelBtn))
                                {
                                    es.bNewSelected = EditorGUILayout.ToggleLeft(es.sFullPath, true, EdtUIStyle_TA.optInitText);
                                    FnQuickSelectOrRun_TA.SelectObjByList(ref es, ref lstSelTALBox);
                                    SceneView.lastActiveSceneView.FrameSelected();
                                }

                                //顯示刪除按鈕
                                GUILayout.Space(1);
                                if (GUILayout.Button("刪除", EdtUIStyle_TA.optListDelBtn))
                                    lstSelTALBox.RemoveAt(i);

                                GUILayout.Space(1);
                                EditorGUILayout.EndHorizontal();
                                GUILayout.Space(1);

                                es.bOldSelected = es.bNewSelected;
                            }
                            EditorGUILayout.EndVertical();
                        }
                    }
                    EditorGUILayout.EndScrollView();
                    #endregion 顯示與選取清單list

                    #region 名稱底板拓寬或減少
                    GUILayout.BeginVertical("HelpBox");
                    {
                        GUILayout.Label("增加(減少)底板寬度", EdtUIStyle_TA.lb14FSizeMCenter);
                        GUILayout.BeginHorizontal();
                        if (GUILayout.Button("場景名稱+", EdtUIStyle_TA.btn14FSizeLCenter)) sSceneLBWidth += 3;
                        if (GUILayout.Button("場景名稱-", EdtUIStyle_TA.btn14FSizeLCenter)) sSceneLBWidth -= 3;
                        if (GUILayout.Button("物件名稱+", EdtUIStyle_TA.btn14FSizeLCenter)) sObjectLBWidth += 3;
                        if (GUILayout.Button("物件名稱-", EdtUIStyle_TA.btn14FSizeLCenter)) sObjectLBWidth -= 3;
                        GUILayout.EndHorizontal();
                    }
                    GUILayout.EndVertical();
                    #endregion 名稱底板拓寬或減少
                }
                #endregion 記錄場景裡的選取物件，或選取文字裡指定的物件
            }
            EditorGUILayout.EndScrollView();
        }

        void OnInspectorUpdate                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ()
        {
            Repaint();
        }
    }
}

#endif