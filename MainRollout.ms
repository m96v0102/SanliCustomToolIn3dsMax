fileIn "FileIn\\XML.ms" --if this function doesn't run at the first line, it will occur an error when I open the main rollout 

--some saving pathes or properties
global g_SanliCustomTool
struct stSomeSavedPathOrProperties
(
	sLoadFileFromPath = "",
	sExportPath = @"e:\",
	sExportRecordPath = @"e:\",  --Export Path record from 1 clip in 1 file

	xmlDoc = undefined,
	ndRoot = undefined,	
	sXmlRecordFile = @"C:\SanliCustomTool\SomePathOrProperties.xml",
	sXmlRecordPath = @"C:\SanliCustomTool\",
	
	sUnityAssetPath = "",
	
	sSrcUnityUIStyleFile = @"C:\SanliCustomTool\EditorUIStyle.cs",
	sSrcUnityFnQuickSelFile = @"C:\SanliCustomTool\FnQuickSelectOrRun_TA.cs",
	sSrcUnityQuickSelFile = @"C:\SanliCustomTool\QuickSelectOrRun_TA.cs",
		
	fn fnCreateXmlAndRoot =
	(
		makeDir sXmlRecordPath
		xmlDoc = tXMLDocument()
		xmlDoc.mfCreateXML rXmlFilePath:sXmlRecordFile
		ndRoot = xmlDoc.mfCreateRootNode "SomePathesorProperties"
	),

	fn fnLoadXmlAndRoot =
	(
		xmlDoc = tXMLDocument()
		xmlDoc.mfLoadXML sXmlRecordFile
		ndRoot = xmlDoc.mfGetRootNode()
	),

	-- fnCreateNewNodeUnderRoot "ExportPath" g_stPathOrProp.sExportPath
	fn fnCreateNewNodeUnderRoot _sNodeName _sNodeText=
	(
		ndNew = xmlDoc.mfGetNewNode _sNodeName
		ndNew.mfSetText _sNodeText
		ndRoot.mfAppendChild ndNew
	),

	-- fnCreateOrReviseNodeUnderRoot "ExportPath" g_stPathOrProp.sExportPath
	fn fnCreateOrReviseNodeUnderRoot _sNodeName _sNodeText=
	(
		ndMatchNode = ndRoot.mfGetChildrenNodesByName _sNodeName
		if ndMatchNode.count != 0 then
			ndMatchNode[1].mfSetText _sNodeText
		else
			fnCreateNewNodeUnderRoot _sNodeName _sNodeText

	),

	-- g_stPathOrProp.sExportPath = g_stPathOrProp.fnGetNodeText "ExportPath"
	fn fnGetNodeText _sNodeName=
	(
		sText = ""
		ndMatchNode = ndRoot.mfGetChildrenNodesByName _sNodeName
		if ndMatchNode.count != 0 then
			sText = ndMatchNode[1].mfGetText()
			
		return sText
	),

	fn fnSaveXmlAndRelease =
	(
		xmlDoc.mfSaveXML()
		xmlDoc.mfReleaseXML()
	),
	
	--g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.edtExportPath.text
	--edtExportPathRecord.text = fnResetUaAndEpRcPath edtExportPath.text g_stPathOrProp.sUnityAssetPath	
	fn fnResetUaAndEpRcPath _sExportPath &sUnityAssetPath=	--Reset Unity Asset and Export Record Path
	(
		--take of the string after Assets, and add the string in the right:  "\\Editor\\Sanli\\ExrpotRecordPath.xml"
		sRecordExportXmlPath = ""
		aFilterRecordExportXmlPath = filterString _sExportPath "\\"
		for i = 1 to aFilterRecordExportXmlPath.count do
		(
			sRecordExportXmlPath += aFilterRecordExportXmlPath[i] + "\\"
			if aFilterRecordExportXmlPath[i] == "Assets" do exit
		)
		sUnityAssetPath = sRecordExportXmlPath

		return (sRecordExportXmlPath + "Editor\\Sanli\\ExrpotRecordPath.xml")
	),
	
	--Copy .cs to unity folder
	fn fnCopyCSToUFolder=
	(
		--Copy Unity script into the unity folder
		sDestUnityUIStyleFile =  sUnityAssetPath + "Editor\\Sanli\\EditorUIStyle.cs"
		sDestUnityFnQuickSelFile =  sUnityAssetPath + "Editor\\Sanli\\FnQuickSelectOrRun_TA.cs"
		sDestUnityQuickSelFile =  sUnityAssetPath + "Editor\\Sanli\\QuickSelectOrRun_TA.cs"
		if (doesFileExist sDestUnityUIStyleFile) == false then
		(
			copyFile sSrcUnityUIStyleFile sDestUnityUIStyleFile
			copyFile sSrcUnityFnQuickSelFile sDestUnityFnQuickSelFile
			copyFile sSrcUnityQuickSelFile sDestUnityQuickSelFile
		)
	),

	fn fnSaveXml=
	(	
		nTabIndex = g_SanliCustomTool.roMainRollout.dnTabs.SelectedIndex + 1
		case nTabIndex of
		(
			1: 	(
				sExportRecordPath = g_SanliCustomTool.roMainRollout.ro1Clip1File.roRecordExportPath.edtExportPathRecord.text
				sExportPath = g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.edtExportPath.text
				)
			2:  (
				sExportRecordPath = g_SanliCustomTool.roMainRollout.roMultiClip1File.roRecordExportPath.edtExportPathRecord.text
				sExportPath = g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.edtExportPath.text	
				)
		)		

		if (doesFileExist sXmlRecordFile) == true then
		(
			fnLoadXmlAndRoot()					
			fnCreateOrReviseNodeUnderRoot "ExportPath" sExportPath	--revise sExportPath for xml node
			fnCreateOrReviseNodeUnderRoot "LoadMaxfileFromPath" sLoadFileFromPath
			fnCreateOrReviseNodeUnderRoot "ExportRecordPath" sExportRecordPath
			fnSaveXmlAndRelease()
		)
		else
		(
			fnCreateXmlAndRoot() --Create Xml and rootnode
			fnCreateNewNodeUnderRoot "ExportPath" sExportPath --create ExportPath node
			fnCreateNewNodeUnderRoot "LoadMaxfileFromPath" sLoadFileFromPath
			fnCreateNewNodeUnderRoot "ExportRecordPath" sExportRecordPath
			fnSaveXmlAndRelease()
		)
	)
)
global g_stPathOrProp = stSomeSavedPathOrProperties()

fileIn "FileIn\\SetMultiClipsIn1FileWnd.ms"  	--Multiple clips in 1 file Window
fileIn "FileIn\\SMeshOrClipIn1FileWnd.ms"		--1 clip in 1 file Window
fileIn "FileIn\\OthersWnd.ms"					--Others Window
fileIn "FileIn\\fnFixCallBack.ms"				--check and fix callbacks virus


global g_stFixCallBack = o_stFixCallBack()		--fileIn fnFixCallBackÆ…∑|•Œ®Ï™∫µ≤∫c

global g_stLoadMaxByList

--Main rollout
-- All other rollouts are added to this rollout as subRollouts
struct stSanliCustomTool
(
	roMainRollout,	

    function Constructor =
    (
        rollout roMainRollout "SwitchTabBelow"
		(
			local ro1Clip1File = st1ClipInFileWnd()
            local roMultiClip1File = stMultiClipsIn1FileWnd()
			local roOthers = stOthersWnd()
			local rollArr = #( 
								#("1 Clip in File or SMesh", #(	ro1Clip1File.roll,  ro1Clip1File.roSearch, ro1Clip1File.roExportSettings, 
																ro1Clip1File.roRecordExportPath, ro1Clip1File.roCheckUndoCallBack)),
								#("     MultiClips in 1 File     ", #(	roMultiClip1File.roll, roMultiClip1File.roSearch, roMultiClip1File.roExportSetAndAniSLMethods,
																		roMultiClip1File.roSeperateAnim, roMultiClip1File.roRecordExportPath)),
								#("  Others or Info  ", #(roOthers.roInfo, roOthers.roBatchRename, roOthers.roSwitchModel, roOthers.roOtherStuff))
								--#("        Others       ", 	#(roOthers.roBatchRename, roOthers.roSwitchModel))
							)
			
			local lastSubRollout = 1
            dotNetControl dnTabs "System.Windows.Forms.TabControl" height:20 --width:420 align:#left
			
			--≥o∏Ã™∫™¯ºe≠Y¶≥ßÔ°AcreateDialog roMainRollout™∫™¯ºe§]≠n§@®÷ßÔ
			--Æ⁄æ⁄¥˙∏’°A≥o∏Ã´¸©w™∫height≥Ã¶n≠n§Òro1Clip1File.roHeight°BroMultiClip1File.roHeight¡Ÿ≠n∞™°Aotherwise we will see some interface got cut off.
			subRollout theSubRollout width:360 height:900 align:#center	--330

            on dnTabs Selected itm do
			(
				for subroll in rollArr[lastSubRollout][2] do
				removeSubRollout theSubRollout subroll
				
				lastSubRollout = itm.TabPageIndex+1
				for subroll in rollArr[lastSubRollout][2] do	
				(
					if (subroll == ro1Clip1File.roll or subroll == roMultiClip1File.roll or subroll == roOthers.roInfo) then
						addSubRollout theSubRollout subroll rolledUp:false
					else
						addSubRollout theSubRollout subroll rolledUp:true
				)
				
				nState = itm.TabPageIndex+1
				case nState of
				(
					1: 	(
						g_SanliCustomTool.roMainRollout.height = ro1Clip1File.roHeight
						
						--reload the maxfile array from the list. or the array might be changed by search field
						g_stLoadMaxByList.fnLoadFileToList &ro1Clip1File.roll.lboxMaxFile ro1Clip1File.roll.edtSourceFolderPath.text
						)
					2:	(
						g_SanliCustomTool.roMainRollout.height = roMultiClip1File.roHeight
						)
					3: 	(
						g_SanliCustomTool.roMainRollout.height = roOthers.roHeight
						)
				)
			)--end tabs clicked	
			
            on roMainRollout open do
			(
				roMainRollout.height = ro1Clip1File.roHeight
				
				for aTab in rollArr do
					dnTabs.TabPages.add aTab[1]
				
                addSubRollout theSubRollout ro1Clip1File.roll
				addSubRollout theSubRollout ro1Clip1File.roSearch rolledUp:true
				addSubRollout theSubRollout ro1Clip1File.roExportSettings rolledUp:true
				addSubRollout theSubRollout ro1Clip1File.roRecordExportPath rolledUp:true
				addSubRollout theSubRollout ro1Clip1File.roCheckUndoCallBack rolledUp:true
				
				--open and check the Startup file, if there has a callback virus in it, then try to fix it.
				g_stFixCallBack.fnCheckAndFixStartupFile()
				
				--Load path xml to edtSourceFolderPath?edtExportPath
				if (doesFileExist g_stPathOrProp.sXmlRecordFile) == true then
				(
					g_stPathOrProp.fnLoadXmlAndRoot()
					g_stPathOrProp.sLoadFileFromPath = g_stPathOrProp.fnGetNodeText "LoadMaxfileFromPath"
					g_stPathOrProp.sExportPath = g_stPathOrProp.fnGetNodeText "ExportPath"
					g_stPathOrProp.sExportRecordPath = g_stPathOrProp.fnGetNodeText "ExportRecordPath"
					g_stPathOrProp.xmlDoc.mfReleaseXML()
					ro1Clip1File.roll.edtSourceFolderPath.text = g_stPathOrProp.sLoadFileFromPath
					ro1Clip1File.roll.edtExportPath.text = g_stPathOrProp.sExportPath
					ro1Clip1File.roRecordExportPath.edtExportPathRecord.text = g_stPathOrProp.sExportRecordPath
				)
				
				
			)-- end roll open

			on roMainRollout close do
			(
				g_stPathOrProp.fnSaveXml()
			)
        )
		
        return true
    ),

    function Show =
	(
		--≥o∏Ã™∫™¯ºe≠Y¶≥ßÔ°AsubRollout theSubRollout™∫™¯ºe§]≠n§@è˛ßÔ
		createDialog roMainRollout 370 roMainRollout.ro1Clip1File.roHeight 560 300 --style:#(#style_toolwindow,#style_sysmenu)
		--createDialog roMainRollout 340 720 2560 400 --style:#(#style_toolwindow,#style_sysmenu)
		roMainRollout.title = "SanliCustomTool(v1.004)"
		
		--copy Unity Editor files to C:\SanliCustomTool
		sCurrentScriptFile = getThisScriptFilename()
		--format "Sanlilog_current Script File: % \n" sCurrentScriptFile
		sCurrentScriptPath = getFilenamePath sCurrentScriptFile
		sUnityUIStyleFile = sCurrentScriptPath + "SanliScriptInUnityEditor\\EditorUIStyle.cs"
		sUnityFnQuickSelFile = sCurrentScriptPath + "SanliScriptInUnityEditor\\FnQuickSelectOrRun_TA.cs"
		sUnityQuickSelFile = sCurrentScriptPath + "SanliScriptInUnityEditor\\QuickSelectOrRun_TA.cs"
		--format "Sanlilog_sUnityUIStyleFile: % \n" sUnityUIStyleFile
		
		--Copy 3 Unity Script files to the SanliCustomTool's folder
		if (doesFileExist g_stPathOrProp.sSrcUnityUIStyleFile) == false then
		(
			makeDir "C:\\SanliCustomTool\\"
			copyFile sUnityUIStyleFile g_stPathOrProp.sSrcUnityUIStyleFile
			copyFile sUnityFnQuickSelFile g_stPathOrProp.sSrcUnityFnQuickSelFile
			copyFile sUnityQuickSelFile g_stPathOrProp.sSrcUnityQuickSelFile
		)
	),

    init = Constructor()
)

if g_SanliCustomTool != undefined and g_SanliCustomTool.roMainRollout != undefined do destroydialog g_SanliCustomTool.roMainRollout
g_SanliCustomTool = stSanliCustomTool()
-- if roMainRolloutFloater != undefined do closeRolloutFloater roMainRolloutFloater
-- roMainRolloutFloater = newRolloutFloater "SanliCustomTool v1.001" 410 425	-- •i•H™¯ºe°B¶Ï∏mêm´¸©w
-- addRollout g_SanliCustomTool.roMainRollout roMainRolloutFloater
g_SanliCustomTool.Show()
