#if UNITY_EDITOR
//Sanli一開始跨專案時，常用的一些TA通用script
using UnityEngine;
using UnityEditor;              //AssetDatabase和Selection會用到的code
using System.Collections;
using System.Collections.Generic;
using System.IO;                //File.Exists()會用到的code

namespace Edit.TAScript
{
    //取得hierarch window裡的物件full path
    //http://www.marcosecchi.it/2016/06/15/get-the-full-name-of-a-gameobject-in-unity/?lang=en
    public static class GameObjectExtensions
    {
        /// <summary>
        /// Returns the full hierarchy name of the game object.
        /// </summary>
        /// <param name="go">The game object.</param>
        //public static string GetFullName(this GameObject go)
        public static string GetFullName(GameObject go)
        {
            string name = go.name;
            while (go.transform.parent != null)
            {
                go = go.transform.parent.gameObject;
                name = go.name + "/" + name;
            }
            return name;
        }
    }

    public class FnQuickSelectOrRun_TA : MonoBehaviour
    {
        public static void QuickSelect(string _sFile)
        {
            if (File.Exists(_sFile) || Directory.Exists(_sFile))
            {
                Object objQuickSelect = AssetDatabase.LoadAssetAtPath(_sFile, typeof(Object)) as Object;
                if (objQuickSelect != null)
                {
                    EditorGUIUtility.PingObject(objQuickSelect);
                    Selection.objects = new Object[1] { objQuickSelect };
                }
                else
                    EditorUtility.DisplayDialog("規格不符", string.Format("路徑正確，但無法選取載入的物件：{0}", _sFile), "ok");
            }
            else
                EditorUtility.DisplayDialog("找不到路徑", string.Format("找不到路徑：{0}", _sFile), "ok");
            
        }


        //檢查有沒有選取物件
        //一般狀況下，有選取物件就回true，沒選取就回false
        //若輸入參數_bCHeckSelect1Only是true，就會檢查選取的物件是否只有一個，否則就直接返回false
        public static bool CheckObjSelect(bool _bCHeckSelect1Only)
        {
            if (Selection.objects.Length == 0)
            {
                EditorUtility.DisplayDialog("請選取一個物件", "請選取物件", "我知道了");
                return false;
            }

            //如果_bCHeckSelect1Only是true，就檢查是否只選取一個物件
            if (_bCHeckSelect1Only)
            {
                if (Selection.objects.Length != 1)
                {
                    EditorUtility.DisplayDialog("請選取一個物件", "只能選取一個物件", "我知道了");
                    return false;
                }
            }

            return true;
        }


        //列出所有選取的資料夾
        static public List<string> GetSelectFolders()
        {
            List<string> dirs = new List<string>();
            foreach (UnityEngine.Object obj in Selection.objects)
            {
                string path = AssetDatabase.GetAssetPath(obj);
                if (Directory.Exists(path))
                    dirs.Add(path);
            }

            if (dirs.Count <= 0)
            {
                Debug.Log("Sanlilog_沒有選到有子物件的資料夾");
            }

            return dirs;
        }

        #if UNITY_5_4_OR_NEWER
        //檢查場景裡是否有指定的GameObject(有就返回true，無就返回false)
        //使用範例：CheckGOInScene(ref US_ROOT, "US_ROOT")
        static public bool CheckGOInScene(ref GameObject _goInScene, string _sGameObjInScene, bool _bWarning = true)
        {
            if (_goInScene == null)
            {
                if (_bWarning) EditorUtility.DisplayDialog("找不到" + _sGameObjInScene, "找不到" + _sGameObjInScene + "，請確認場景有無此物件，而且沒有被隱藏", "OK");
                return false;
            }
            else
            {
                if (_goInScene.scene.IsValid()) return true;
                else
                {
                    if (_bWarning) EditorUtility.DisplayDialog("找不到場景物件", _sGameObjInScene + "不在場景裡，請選取場景裡的物件!!!!", "ok");
                    return false;
                }
            }
        }
        #endif

        //透過listbox清單選選取某個物件
        static public void SelectObjByList(ref SimpleListBox_TA es, ref List<SimpleListBox_TA> _lstSelTALBox)
        {
            #if !UNITY_5_4_OR_NEWER
            List<Object> lstSelection = new List<Object>();
            #endif

            es.bOldSelected = es.bNewSelected;

            //除了現有的勾勾以外，其他勾勾都拿掉
            for (int j = 0; j < _lstSelTALBox.Count; j++)
            {
                if (_lstSelTALBox[j] != es)
                    _lstSelTALBox[j].bOldSelected = false;
            }

            if (es.sSceneName == QuickSelectOrRun_TA.sProjWndLabel)
            {
                QuickSelect(es.sFullPath);
            }
            else if (es.obj != null)
            {
                Debug.Log("Sanlilog_直接透過Object的判斷方式選取物件");
                Selection.objects = new Object[1] { es.obj };
                EditorGUIUtility.PingObject(Selection.objects[0]);
            }
            else
            {
                Debug.Log("Sanlilog_用字串的方式選取物件");

                //選取物件
                List<GameObject> lstSelectionInRootObj = new List<GameObject>();
                string[] aFilterName = es.sFullPath.Split('/');
                string sRootName = aFilterName[0];
                //Debug.Log(string.Format("Sanlilog_名稱：{0}、路徑：{1}", es.sLabel, es.sFullPath));
                GameObject[] pAllObjects = (GameObject[])Resources.FindObjectsOfTypeAll(typeof(GameObject));
                foreach (GameObject pObject in pAllObjects)
                {
                    if (pObject.hideFlags == HideFlags.NotEditable || pObject.hideFlags == HideFlags.HideAndDontSave) continue;
                    if (pObject.transform.parent != null) continue;//如果不是場景裡的root物件，直接跳下一個迴圈
                    #if UNITY_5_4_OR_NEWER
                    if (pObject.scene.IsValid() == false) continue;//如果不是場景裡的物件，直接跳下一個迴圈
                    #endif
                    if (pObject.name == sRootName)
                    {
                        #region Object本身就是root，先存到list裡
                        if (es.sLabel == es.sFullPath)
                        {
                            lstSelectionInRootObj.Add(pObject);
                            //Selection.objects = new GameObject[1] { pObject };
                            //EditorGUIUtility.PingObject(pObject);
                        }
                        #endregion Object本身就是root，先存到list裡
                        #region Object是在root底下，準備進行選取
                        else
                        {
                            string sChildFullPath = es.sFullPath.Remove(0, sRootName.Length + 1);
                            Transform tsHierarchy = pObject.transform.Find(sChildFullPath);
                            if (tsHierarchy != null)
                            {
                                #if UNITY_5_4_OR_NEWER
                                //重新指定Target物件是parent物件第幾個階層
                                List<GameObject> lstSelectionUnderParentObj = new List<GameObject>();
                                Transform tsParent = tsHierarchy.parent;
                                //先把同階層的同名物件都蒐集起來。
                                for (int i = 0; i < tsParent.childCount; i++ )
                                {
                                    if (tsParent.GetChild(i).name == es.sLabel)
                                        lstSelectionUnderParentObj.Add(tsParent.GetChild(i).gameObject);
                                }

                                //如果場景裡的階層被修改，就改編號
                                if (es.nChildNum >= lstSelectionUnderParentObj.Count)
                                {
                                    Debug.LogFormat("Sanlilog_發現同個階層的同名物件有{0}個，而nChildNum是{1}，所以nChildNum會被修改", lstSelectionUnderParentObj.Count.ToString(), es.nChildNum.ToString());
                                    es.nChildNum = lstSelectionUnderParentObj.Count - 1;
                                }

                                Debug.LogFormat("Sanlilog_此物件是parent物件裡的第{0}個同名物件",es.nChildNum.ToString());
                                GameObject goSelection = lstSelectionUnderParentObj[es.nChildNum];
                                es.obj = goSelection as Object;
                                //GameObject goSelection = tsHierarchy.parent.GetChild(es.nChildNum).gameObject;
                                Selection.objects = new GameObject[1] { goSelection };
                                EditorGUIUtility.PingObject(goSelection);
                                break;
                                #else
                                //很難區分物件是否在Scene裡還是project裡，所以乾脆都放到list，最後一起選取
                                lstSelection.Add(tsHierarchy.gameObject);
                                #endif
                            }
                        }
                        #endregion Object是在root底下，準備進行選取
                    }
                }

                #region 若Object本身就是root且存到裡list，就準備進行選取
                //Debug.Log("三立log_選取的是Root物件，和選取物件同名的物件數量：" + lstSelectionObj.Count.ToString());
                if (lstSelectionInRootObj.Count > 0)
                {
                    Debug.Log("Sanlilog_nChildNum：" + es.nChildNum.ToString());
                    Selection.objects = new GameObject[1] { lstSelectionInRootObj[es.nChildNum] };
                    es.obj = Selection.objects[0] as Object;
                    EditorGUIUtility.PingObject(lstSelectionInRootObj[es.nChildNum]);
                }
                #endregion 若Object本身就是root且存到裡list，就準備進行選取

#if !UNITY_5_4_OR_NEWER
                Selection.objects = lstSelection.ToArray();
#endif
            }

            
        }

        //先檢查路徑再載入GameObject
        public static Object CheckFileAndLoad(string _sFile)
        {
            if (File.Exists(_sFile) || Directory.Exists(_sFile))
            {
                return AssetDatabase.LoadAssetAtPath(_sFile, typeof(Object)) as Object;
            }
            else
            {
                string sMessage = string.Format("找不到路徑: {0} ", _sFile);
                EditorUtility.DisplayDialog("找不到路徑", sMessage, "ok");
                return null;
            }
        }
    }
}

#endif