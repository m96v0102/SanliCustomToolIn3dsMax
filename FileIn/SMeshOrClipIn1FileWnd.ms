
struct stLoadMaxByList
(
	aFile = #(),
	aFileName = #(),
	aFile_Backup = #(),
	aFileName_Backup = #(),

	sLoadMergeImportLogFileNameWthExt = "LoadMergeImport.log",

	--grpTNWidth = 150,		--thumbnail group width
	--grpEtWidth = 150,		--Export group width
	TNWidth = 118,			--ThumbnailWidth
	TNHeight = 118,			--ThumbnailHeight
	btnRnWidth = 118,		--button of render tool's width
	btnWidth1 = 102,

	xmlDoc = undefined,
	ndRoot = undefined,

	--the elements in this array have to be same with the rdoLoadType labels.
	aLoadType = #(#Load, #Merge, #ImportFbx, #ImportObj),
	nDefaultLoadType = 1,
	bShowMIOptions = false,	--Show merge or import options
	
	--the elements in this array have to be same with the ddlExportMode items.
	aExportType = #(#StaticMesh, #SkinMesh, #Animation),
	
	--the elements in this array have to be same with the ddlEmbedTextureMode items.
	aEmbedTextureType = #(#EmbedTexture, #CopyTexture, #None),

	--the elements in this array have to be same with the rdoBatchCheckMode. labels.
	aBatchCheckMode = #(#Check, #CheckAndRemove),

	fn fnInitialize=
	(
		aFile = #()
		aFileName = #()
		aFile_Backup = #()
		aFileName_Backup = #()
		xmlDoc = undefined
		ndRoot = undefined
	),
	
	fn fnGetScriptPath=
	(
		sCurrScriptFile = getThisScriptFilename()
		sCurrScriptPath = pathConfig.removePathLeaf sCurrScriptFile
		return (sCurrScriptPath + "\\")
	),

	fn fnSetMATEmbedType _state=
	(
		if g_SanliCustomTool != undefined then
		(
			EnumEmbedMATType = aEmbedTextureType[_state]
			case EnumEmbedMATType of
			(
				#EmbedTexture:
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckCopyTexture.checked = false
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckEmbedTexture.checked = true
				)
				#CopyTexture:
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckCopyTexture.checked = true
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckEmbedTexture.checked = false
				)
				#None:
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckCopyTexture.checked = false
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckEmbedTexture.checked = false
				)
			)
		)
	),

	--Get files from folder(Include first folder and children)
	fn fnGetFilesRecursiveByLoadingPath root pattern =
	(
		dir_array = sort (GetDirectories (root+"*"))
		
		my_files = #()
		join my_files (getFiles (root + pattern))
		
		for d in dir_array do
			join dir_array (GetDirectories (d+"*"))
		
		for f in dir_array do
		(
			join my_files (getFiles (f + pattern))
		)

		my_files 
	),

	--g_stLoadMaxByList.fnLoadFileToList &btnLoadFileFromPath edtSourceFolderPath.text
	fn fnLoadFileToList &_lboxMaxFile _sLoadFileFromPath _enLoadType:#Load=
	(
		fnInitialize()
		aFile = #()

		case _enLoadType of
		(
			#Load:
			(
				aFile =sort( fnGetFilesRecursiveByLoadingPath _sLoadFileFromPath "*.max" )
				if g_SanliCustomTool != undefined do
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.btnLoadMergeImportFile.enabled = true
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnExportFile.enabled = true
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnSelExport.enabled = true
				)
			)
			#Merge:
			(
				aFile =sort( fnGetFilesRecursiveByLoadingPath _sLoadFileFromPath "*.max" )
				if g_SanliCustomTool != undefined do
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.btnLoadMergeImportFile.enabled = true
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnExportFile.enabled = false
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnSelExport.enabled = false
				)
				
			)
			#ImportFbx:
			(
				aFile =sort( fnGetFilesRecursiveByLoadingPath _sLoadFileFromPath "*.fbx" )
				if g_SanliCustomTool != undefined do
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.btnLoadMergeImportFile.enabled = true
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnExportFile.enabled = false
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnSelExport.enabled = false
				)
			)
			#ImportObj:
			(
				aFile =sort( fnGetFilesRecursiveByLoadingPath _sLoadFileFromPath "*.obj" )
				if g_SanliCustomTool != undefined do
				(
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.btnLoadMergeImportFile.enabled = true
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnExportFile.enabled = false
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.btnSelExport.enabled = false
				)
			)
		)
		
		aFile_Backup = deepCopy aFile
		
		for xx in aFile do
			append aFileName (getFileNameFile xx )

		aFileName_Backup = deepCopy aFileName
		
		_lboxMaxFile.items = aFileName
		_lboxMaxFile.selection = 1				
	),
	
	--Example: g_stLoadMaxByList.fnLoadMergeOrImport enLoadType sel
	fn fnLoadMergeOrImport _enLoadType _sel=
	(
		case _enLoadType of
		(
			#Load:
			(
				local result = loadMaxFile aFile[_sel] quiet:on useFileUnits:on
				if result == false do
					MessageBox("LoadMax failed - Please recheck the file version and the current max version!!")
			)
			#Merge:
			(
				if bShowMIOptions == true then	mergeMAXFile aFile[_sel]
				else  							mergeMAXFile aFile[_sel] #renameMtlDups #AutoRenameDups #useSceneMtlDups		
			)
			#ImportFbx:
			(
				if bShowMIOptions == true then 	importFile aFile[_sel]
				else				 			importFile aFile[_sel] #noPrompt
			)
			#ImportObj:
			(
				if bShowMIOptions == true then	importFile aFile[_sel]
				else				  			importFile aFile[_sel] #noPrompt
			)
		)	
	)
)
g_stLoadMaxByList = stLoadMaxByList()
global g_stPathOrProp		--there might cause  an error in the first run(Open rollout) if I comment this line
global g_SanliCustomTool	--there might cause  an error in the first run(Open rollout) if I comment this line
global g_stFixCallBack		--there might cause  an error in the first run(Open rollout) if I comment this line

struct st1ClipInFileWnd
(
	public roll,
	roExportFn,
	roSearch,
	roImportOrMergeSettings,
	roExportSettings,
	roRecordExportPath,
	roCheckUndoCallBack,
	roHeight = 640,

	fn Constructor =
	(
		rollout roll "1 clip in 1 file or static mesh_v1.005"
		(
			group "1 clip in file (or static mesh)"
			(				
				dotNetControl edtSourceFolderPath 				"TextBox" pos:[15, 28] width:255 height:34 --TextBoxTextAlign:#Center
				button  btnBrowseFileFromPath "Browse"			pos:[edtSourceFolderPath.pos.x + edtSourceFolderPath.width + 6, edtSourceFolderPath.pos.y - 1]
																width:54 height:16 tooltip:"select the folder."
				button 	btnLoadFileFromPath "Load"				pos:[btnBrowseFileFromPath.pos.x, btnBrowseFileFromPath.pos.y + 18]
																width:54 height:16 tooltip:"Load all of the max files from the path."
				
				--button 	btnSaveMaxPath "Save Folder path"		pos:[btnLoadFileFromPath.pos.x + 145, btnLoadFileFromPath.pos.y] width:136
																--tooltip:"Save the path that you typed in the left field, it will change automatically while you open the tools next time"

				Multilistbox  lboxMaxFile width:193 height:9	pos:[edtSourceFolderPath.pos.x, edtSourceFolderPath.pos.y + edtSourceFolderPath.height + 18] 
																items:g_stLoadMaxByList.aFileName				

				bitmap bmp1 bitmap:(bitmap g_stLoadMaxByList.TNWidth g_stLoadMaxByList.TNHeight color:(color 155 155 155))
																pos:[lboxMaxFile.pos.x + lboxMaxFile.width + 5, lboxMaxFile.pos.y]

				button btnOpenSelFile "Open item folder"		width:g_stLoadMaxByList.btnWidth1 height:18
																pos:[15, lboxMaxFile.pos.y + lboxMaxFile.height + 5]
																tooltip:"Open folder from selected item."
				button btnOpenCurrFile "Open max folder"		width:g_stLoadMaxByList.btnWidth1 height:18
																pos:[btnOpenSelFile.pos.x + g_stLoadMaxByList.btnWidth1 + 5, btnOpenSelFile.pos.y]
																tooltip:"Open folder from current maxfile."
				button btn_RenderTools "CreateThumbnail" 		width:g_stLoadMaxByList.btnWidth1 height:18
																pos:[btnOpenCurrFile.pos.x + g_stLoadMaxByList.btnWidth1 + 5, btnOpenSelFile.pos.y]
																tooltip:"create current max file thumbnail"
			)
			
			-- some maxfiles is copied from Other Projects, and have some Thumbnail with it, but the preview rules are different.
			-- so use the Project thumbnail rules to load and copy it for this tool.
			fn fnCopyBitmapFromProjThumbNail _sImageFileForUJProj _sMaxFilePath _sFileNameWithoutExt=
			(
				--Load the image frome file
				bitMapProj = openBitMap _sImageFileForUJProj

				nWidth = g_stLoadMaxByList.TNWidth
				nHeight = g_stLoadMaxByList.TNHeight

				--pasteBox = (box2 0 0 g_stLoadMaxByList.TNWidth g_stLoadMaxByList.TNHeight)
				--pasteBox = (box2 ((bitMapProj.width - nWidth)/ 2) ((bitMapProj.height - nHeight)/ 2) nWidth nHeight)
				pasteBox = (box2 ((bitMapProj.width - nWidth)/ 2) 0 nWidth nHeight)							
				
				newdst = bitmap nWidth nHeight color:(color 0 0 0 0)
				pos = [0,0]
				pasteBitmap bitMapProj newdst pasteBox pos
				--display newdst

				sDirPath = _sMaxFilePath + "\\Thumbnails\\@"
				if doesFileExist sDirPath == false do
					makeDir sDirPath

				newdst.filename = (sDirPath +  _sFileNameWithoutExt + ".jpg")
				save newdst
				bmp1.filename = newdst.filename
			)
			--Set Thumbnail and other Multilistbox's selection
			fn fnGetThumbnail _SourceLbx =
			(
				aSelection = (_SourceLbx.selection as array)
				if(aSelection.count > 0)do
				(
					if aSelection.count == 1 do
					(
						nSelIDInList = aSelection[1]
						sMaxFilePath = getFileNamePath g_stLoadMaxByList.aFile[nSelIDInList]
						sMaxFileName = g_stLoadMaxByList.aFileName[nSelIDInList]
						sFileNameWithoutExt = getfilenamefile sMaxFileName
						sBmpFile = (sMaxFilePath + "\\Thumbnails\\@" +  sFileNameWithoutExt + ".jpg")
						sJpgFileForUJProj = (sMaxFilePath + "\\@" +  sFileNameWithoutExt + ".jpg")
						sBmpFileForUJProj = (sMaxFilePath + "\\@" +  sFileNameWithoutExt + ".Bmp")
						if (doesFileExist sBmpFile) == true then
						(
							bmp1.filename = sBmpFile
						)
						else if (doesFileExist sJpgFileForUJProj) == true then
							fnCopyBitmapFromProjThumbNail sJpgFileForUJProj sMaxFilePath sFileNameWithoutExt
						else if (doesFileExist sBmpFileForUJProj) == true then
							fnCopyBitmapFromProjThumbNail sBmpFileForUJProj sMaxFilePath sFileNameWithoutExt
						else 
							bmp1.bitmap = bitmap g_stLoadMaxByList.TNWidth g_stLoadMaxByList.TNHeight color:(color 155 155 155)
					)
				)
			)
			
			on roll open do
			(
				edtSourceFolderPath.Multiline = true	--I can't modify the dotNetControl\TextBox if I comment this line.
				dcColor = dotnetclass "system.drawing.color"
				edtSourceFolderPath.backColor = dcColor.darkgray
				--edtSourceFolderPath.TextAlign= (dotNetClass "System.Windows.Forms.HorizontalAlignment").Center
				edtSourceFolderPath.text = g_stPathOrProp.sLoadFileFromPath
			)

			on edtSourceFolderPath KeyUp key do
			(
				g_stPathOrProp.sLoadFileFromPath = edtSourceFolderPath.text
				
			)

			on btnOpenSelFile pressed do
			(
				aSelection = (lboxMaxFile.selection as array)
				for i = 1 to aSelection.count do
				(
					nSelectID = aSelection[i]
					sExpression = "explorer /select, " + g_stLoadMaxByList.aFile[nSelectID]
					DOSCommand sExpression
				)
			)

			on btnOpenCurrFile pressed do
			(
				format "Sanlilog_Show current file: % \n" maxfilepath
				shelllaunch maxfilepath ""
			)

			on btn_RenderTools pressed do
			(
				aSelection = (lboxMaxFile.selection as array)
				
				if aSelection.count == 1 then
				(
					hidebyCategory.bones = on
					nWidth = g_stLoadMaxByList.TNWidth
					nHeight = g_stLoadMaxByList.TNHeight

					--Set grab_bmp1
					grab_tempbmp1 = gw.getViewportDib()
					range = grab_tempbmp1.width / grab_tempbmp1.height as Float
					grab_bmp1 = bitmap (nWidth * range) nHeight color:white
					copy grab_tempbmp1 grab_bmp1
					
					--Set grab_bmp2
					grab_bmp2 = bitmap nWidth nHeight color:white
					pasteBitmap grab_bmp1 grab_bmp2 (box2 ((grab_bmp1.width - nWidth)/ 2) 0 nWidth nHeight) [0,0] 					
					
					--nClipIDInList = aSelection[1]
					--sClipName = g_stTimeRange.arrAnimName[nClipIDInList]
					makeDir (maxfilepath + "\\Thumbnails")
					savefilepath =  (maxfilepath + "\\Thumbnails\\@" +  (getfilenamefile maxfilename) + ".jpg")
					grab_bmp2.filename = savefilepath
					save grab_bmp2

					bmp1.filename = savefilepath
				)
				else messageBox "Please Select 'one' file to Create thumbnail!!"				
			)

			on btnBrowseFileFromPath pressed do
			(
				--clear the roSearch.edtSearch.text
				g_SanliCustomTool.roMainRollout.ro1Clip1File.roSearch.edtSearch.text = ""

				g_stPathOrProp.sLoadFileFromPath = getSavePath ()
				if g_stPathOrProp.sLoadFileFromPath != undefined do
					edtSourceFolderPath.text = g_stPathOrProp.sLoadFileFromPath

				nState = g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.rdoLoadType.state
				enLoadType =  g_stLoadMaxByList.aLoadType[nState]
				g_stLoadMaxByList.fnLoadFileToList &lboxMaxFile edtSourceFolderPath.text _enLoadType:enLoadType
			)
			
			on btnLoadFileFromPath pressed do
			(
				--clear the roSearch.edtSearch.text
				g_SanliCustomTool.roMainRollout.ro1Clip1File.roSearch.edtSearch.text = ""
				
				nState = g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.rdoLoadType.state
				enLoadType =  g_stLoadMaxByList.aLoadType[nState]
				g_stLoadMaxByList.fnLoadFileToList &lboxMaxFile edtSourceFolderPath.text _enLoadType:enLoadType

				fnGetThumbnail lboxMaxFile
			)

			on lboxMaxFile selected index do
			(
				fnGetThumbnail lboxMaxFile
			)
			
			on lboxMaxFile doubleClicked sel do
			(
				format "Sanlilog_SelectionFile: % \n" g_stLoadMaxByList.aFile[sel]
				nState = g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.rdoLoadType.state
				enLoadType =  g_stLoadMaxByList.aLoadType[nState]
				g_stLoadMaxByList.fnLoadMergeOrImport enLoadType sel
				--loadMaxFile g_stLoadMaxByList.aFile[sel] quiet:on useFileUnits:on

				--Open Startup folder and check the virus
				g_stFixCallBack.fnCheckFixStartupFileAndScene()
			)
		)

		rollout roExportFn "Export_v1.001"
		(
			dotNetControl edtExportPath						"TextBox" height:17 width:315 --pos:[20, btnOpenSelFile.pos.y + 53]
				
			--the elements in this items have to be same with the g_stLoadMaxByList.aExportType
			label lbExportMode "ExportMode:"				pos:[edtExportPath.pos.x, edtExportPath.pos.y + 28]
			dropdownList ddlExportMode ""					pos:[lbExportMode.pos.x + 68, lbExportMode.pos.y - 2] width:163 \
															items:#("Static Mesh", "Skinned Mesh", "Animation")
															
			checkbox ckCreatefolder "CreateFolder" 			pos:[ddlExportMode.pos.x + ddlExportMode.width + 4, ddlExportMode.pos.y + 5] \
															tooltip:"Create the folder by 3dsMax's filename."
			
			--the elements in this items have to be same with the g_stLoadMaxByList.aEmbedTextureType
			label lbEmbedTexture "MediaEmbed:"				pos:[lbExportMode.pos.x, lbExportMode.pos.y + 22]
			dropdownList ddlEmbedTextureMode ""				pos:[lbEmbedTexture.pos.x + 68, lbEmbedTexture.pos.y - 2] width:163 \
															items:#("Embed Media", "Copy textures from current folder", "Don't set any textures")
			
			label lbTextureExt "Ext:"						pos:[ddlEmbedTextureMode.pos.x + ddlEmbedTextureMode.width + 3, ddlEmbedTextureMode.pos.y + 5]
			editText edtTextureExt text:".tga " 			pos:[lbTextureExt.pos.x + 20, lbTextureExt.pos.y - 3] width:58 height:10

			label lbExportAniHint1 "If you only want to export the animation,"	pos:[lbEmbedTexture.pos.x + 60, lbEmbedTexture.pos.y + 22]
			label lbExportAniHint2 "remember to hide(or freeze) the models in those animation maxfiles."
			
			button 	btnExportFile "Export FBX"				pos:[lbEmbedTexture.pos.x, lbExportAniHint2.pos.y + 24] width:98 \
															tooltip:"Export selected max files from the list."
			button 	btnSelExport "Export selection"			pos:[btnExportFile.pos.x + 108, btnExportFile.pos.y] width:98 \
															tooltip:"Export the selection that you selected in the current max file."
			button 	btnSaveExportPath "Save path" 			pos:[btnSelExport.pos.x + 108, btnSelExport.pos.y] width:98 \ --enabled:false
															tooltip:"Save the export path above"

			--fnCopyTexture edtTextureExt.text sOutputpath
			fn fnCopyTexture _sExtName _sOutputpath=
			(
				aTextures = getFiles (maxfilepath + "\\*" + _sExtName)
				if aTextures.count != 0 then
				(
					for mt in aTextures do
					(
						mapname =getFilenameFile mt
						sOutputTexturePath = _sOutputpath + "Materials\\"	--Put textures into the Materials folder.
						makeDir sOutputTexturePath
						sOutputTextureFile = sOutputTexturePath + mapname + _sExtName
						format "Sanlilog_ExportTexture: % \n" sOutputTextureFile
						deleteFile sOutputTextureFile
						copyFile mt sOutputTextureFile
					)
				)
			)

			fn fnSetFBXParameter =
			(
				FBXExporterSetParam "Skin" g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckSkin.checked
				FBXExporterSetParam "BakeAnimation" g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckBakeAnin.checked
				FBXExporterSetParam "Animation" g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckAnimation.checked
				FBXExporterSetParam "EmbedTextures" g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckEmbedTexture.checked
				--FbxExporterSetParam "TangentSpaceExport" true
			)

			fn fnCreateXmlAndRootAndGetUnityPath =
			(
				g_stLoadMaxByList.xmlDoc = tXMLDocument()

				g_SanliCustomTool.roMainRollout.ro1Clip1File.roRecordExportPath.edtRecordExportPath.text =
				 	g_stPathOrProp.fnResetUaAndEpRcPath edtExportPath.text &g_stPathOrProp.sUnityAssetPath

				sRecordExportFile = g_SanliCustomTool.roMainRollout.ro1Clip1File.roRecordExportPath.edtRecordExportPath.text
				if (doesFileExist sRecordExportFile) == true do deleteFile sRecordExportFile
				sRecordExportPath = pathConfig.removePathLeaf sRecordExportFile
				makeDir sRecordExportPath
				g_stLoadMaxByList.xmlDoc.mfCreateXML rXmlFilePath:sRecordExportFile
				g_stLoadMaxByList.ndRoot = g_stLoadMaxByList.xmlDoc.mfCreateRootNode "RecordPathRoot"
			)

			--EX: sExportFile = fnMakeDirAndExportFile sOutputpath aSelection[i].name
			fn fnMakeDirAndExportFile _sOutputpath _sName =
			(
				sExportFile = _sOutputpath  + _sName + ".FBX"
				format "Sanlilog_ExportModelFile: % \n" sExportFile
				makeDir _sOutputpath
				exportFile sExportFile #noPrompt  selectedOnly:on
				return sExportFile
			)

			--EX: fnAppendChildNodeToXml sExportFile aSelection[i].name
			fn fnAppendChildNodeToXml _sExportFile _sName =
			(
				ndChildNode = g_stLoadMaxByList.xmlDoc.mfGetNewNode _sName
				ndChildNode.mfSetText _sExportFile
				g_stLoadMaxByList.ndRoot.mfAppendChild ndChildNode
			)

			fn fnSaveXmlAndRelease =
			(
				g_stLoadMaxByList.xmlDoc.mfSaveXML()
				g_stLoadMaxByList.xmlDoc.mfReleaseXML()
			)
			
			on roExportFn open do
			(
				dcColor = dotnetclass "system.drawing.color"
				edtExportPath.Multiline = true	--I can't modify the dotNetControl\TextBox if I comment this line.
				edtExportPath.backColor = dcColor.darkgray
				edtExportPath.text = g_stPathOrProp.sExportPath
			)

			on ddlExportMode selected state do
			(
				EnumExportType = g_stLoadMaxByList.aExportType[state]
				case EnumExportType of
				(
					#StaticMesh:
					(
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckSkin.checked = false
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckAnimation.checked = false
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckBakeAnin.checked = false
					)
					#SkinMesh:
					(
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckSkin.checked = true
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckAnimation.checked = false
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckBakeAnin.checked = false
					)
					#Animation:
					(
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckSkin.checked = false
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckAnimation.checked = true
						g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckBakeAnin.checked = true
					)
				)
			)

			on ddlEmbedTextureMode selected state do
			(
				g_stLoadMaxByList.fnSetMATEmbedType state
			)

			on edtExportPath keyup key do
			(
				g_stPathOrProp.sExportPath = edtExportPath.text
			)

			on btnExportFile pressed do
			(
				--save ExportPath to xml
				bRecordExportPath = g_SanliCustomTool.roMainRollout.ro1Clip1File.roRecordExportPath.ckExportPahtRecord.checked
				g_stPathOrProp.sExportPath = edtExportPath.text
				if bRecordExportPath == true do
				(
					if (doesFileExist g_stPathOrProp.sXmlRecordFile) == true then
					(
						g_stPathOrProp.xmlDoc = tXMLDocument()
						g_stPathOrProp.xmlDoc.mfLoadXML g_stPathOrProp.sXmlRecordFile
						g_stPathOrProp.ndRoot = g_stPathOrProp.xmlDoc.mfGetRootNode()

						--revise sExportPath for xml node
						ndExportPath = g_stPathOrProp.ndRoot.mfGetChildrenNodesByName "ExportPath"
						if ndExportPath.count != 0 then
						(
							ndExportPath[1].mfSetText g_stPathOrProp.sExportPath
							--g_stPathOrProp.sLoadFileFromPath = ndLoadMaxFileFromPath[1].mfGetText()
						)
						else --create xml node if the node didn't exist
						(
							--create LoadFileFromPath node
							ndExportPath = g_stPathOrProp.xmlDoc.mfGetNewNode "ExportPath"
							ndExportPath.mfSetText g_stPathOrProp.sExportPath
							g_stPathOrProp.ndRoot.mfAppendChild ndExportPath
						)
											
						g_stPathOrProp.fnSaveXmlAndRelease()
					)
					else
					(
						--Create Xml and rootnode
						makeDir g_stPathOrProp.sXmlRecordPath
						g_stPathOrProp.xmlDoc = tXMLDocument()
						g_stPathOrProp.xmlDoc.mfCreateXML rXmlFilePath:g_stPathOrProp.sXmlRecordFile
						g_stPathOrProp.ndRoot = g_stPathOrProp.xmlDoc.mfCreateRootNode "SomePathesorProperties"

						--create ExportPath node
						ndExportPath = g_stPathOrProp.xmlDoc.mfGetNewNode "ExportPath"
						ndExportPath.mfSetText g_stPathOrProp.sExportPath
						g_stPathOrProp.ndRoot.mfAppendChild ndExportPath

						g_stPathOrProp.fnSaveXmlAndRelease()
					)
				)
				
				aExpMaxFile = #()
				for iter = 1 to g_stLoadMaxByList.aFile.count do 
				(
					if g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.lboxMaxFile.selection[iter] == true then
					(
						format "Sanlilog_Export file: % \n" g_stLoadMaxByList.aFile[iter]
						append aExpMaxFile g_stLoadMaxByList.aFile[iter]
					)
				)

				fnSetFBXParameter()

				if bRecordExportPath == true do fnCreateXmlAndRootAndGetUnityPath()

				for i = 1 to aExpMaxFile.count do 
				(
					loadMaxFile aExpMaxFile[i] quiet:on useFileUnits:on
					--macros.run "Medit Tools" "clear_medit_slots"
					
					--Set output path
					sFilename = getFileNameFile aExpMaxFile[i]
					sOutputpath =  edtExportPath.text + "\\"
					if ckCreatefolder.checked then
					(
						-- it we are export the animation, remove the animation name and keep the model name
						nAnimKeyWordMatchID = findString sFilename "@"	--get the matchID if the name has '@'
						if g_stLoadMaxByList.aExportType[ddlExportMode.selection] == #Animation and nAnimKeyWordMatchID != undefined then
						(
							sModelName = substring sFilename 1 (nAnimKeyWordMatchID-1)
							sOutputpath = edtExportPath.text + "\\" + sModelName + "\\"
						)
						else
							sOutputpath =  edtExportPath.text + "\\" + sFilename + "\\" 
					)
					
					--Export model
					max select all
					sExportFile = fnMakeDirAndExportFile sOutputpath sFilename

					--the xml file can't save the character '@' into the node, so I change to '_'
					--http://forums.cgsociety.org/archive/index.php?t-1124312.html
					nMatchIllegalID = findString sFilename "@"
					if findString sFilename "@" != undefined then
						sFilename = replace sFilename nMatchIllegalID 1 "_"

					if bRecordExportPath == true do fnAppendChildNodeToXml sExportFile sFilename

					--Copy Texture
					if g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckCopyTexture.checked == true then
					(
						fnCopyTexture edtTextureExt.text sOutputpath
					)
				)

				-- the document is saved and released
				if bRecordExportPath == true do fnSaveXmlAndRelease()

				--Copy Unity script into the unity folder if there doesn't have the script to quick select the maxfile.
				g_stPathOrProp.fnCopyCSToUFolder()

			)

			on btnSelExport pressed do
			(
				--Set output path
				sFilename = getFileNameFile maxfilename
				sOutputpath =  g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.edtExportPath.text + "\\"

				if ckCreatefolder.checked then sOutputpath =  
					g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.edtExportPath.text + "\\" + sFilename + "\\" 

				bRecordExportPath = g_SanliCustomTool.roMainRollout.ro1Clip1File.roRecordExportPath.ckExportPahtRecord.checked
				
				if selection.count > 0 then
				(
					aSelection = selection as array
					fnSetFBXParameter()
					
					if bRecordExportPath == true do fnCreateXmlAndRootAndGetUnityPath()

					for i = 1 to aSelection.count do
					(
						--Export Model						
						select aSelection[i]
						sExportFile = fnMakeDirAndExportFile sOutputpath aSelection[i].name

						if bRecordExportPath == true do fnAppendChildNodeToXml sExportFile aSelection[i].name
					)

					if bRecordExportPath == true do fnSaveXmlAndRelease()

					--Copy Texture
					if g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportSettings.ckCopyTexture.checked == true then
					(
						fnCopyTexture edtTextureExt.text sOutputpath
					)

					--Copy Unity script into the unity folder if there doesn't have the script to quick select the maxfile.
					g_stPathOrProp.fnCopyCSToUFolder()

				)
				else messageBox "No selected objects found."
			)

			on btnSaveExportPath pressed do
			(
				g_stPathOrProp.fnSaveXml()
			)


		)

		rollout roSearch "Search_v1.001"
		(
			label 		lbExportPathRecord 			"Search"	pos:[15, 8]
			dotNetControl edtSearch 				"TextBox" pos:[55, lbExportPathRecord.pos.y - 1] width:275 height:17

			fn fnSearchFilter fileList filterKey = 
			(
				tempFiles = #()
				
				for ind = 1 to fileList.count do 
				(
					isFriendy = undefined
					isFriendy = findString fileList[ind] filterKey
					if (isFriendy != undefined) do (
						append tempFiles (fileList[ind])
					)
				)
				
				return tempFiles
			)

			on roSearch open do
			(
				edtSearch.Multiline = true	--I can't modify the dotNetControl\TextBox if I comment this line.
				dcColor = dotnetclass "system.drawing.color"
				edtSearch.backColor = dcColor.darkgray

			)

			on edtSearch keyup do
			(
				tempMaxFile = #()

				g_stLoadMaxByList.aFileName = deepCopy g_stLoadMaxByList.aFileName_Backup
				g_stLoadMaxByList.aFileName = fnSearchFilter g_stLoadMaxByList.aFileName edtSearch.text 
				g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.lboxMaxFile.items = g_stLoadMaxByList.aFileName
				g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.lboxMaxFile.selection = 
					findItem g_stLoadMaxByList.aFileName g_stLoadMaxByList.aFileName[1]

				--Backup the original file array, because this array will be replaced by the filter files.
				g_stLoadMaxByList.aFile =  deepCopy g_stLoadMaxByList.aFile_Backup
				for i = 1 to g_stLoadMaxByList.aFileName.count do 
				(
					for j = 1 to g_stLoadMaxByList.aFile.count do 
					(
						str = filterString g_stLoadMaxByList.aFile[j] "\\"	
						str = str[str.count]
						str2 = g_stLoadMaxByList.aFileName[i] + ".max"
						--Put the filter files into the containter
						if str == str2 do (
							append tempMaxFile g_stLoadMaxByList.aFile[j]
							deleteItem g_stLoadMaxByList.aFile j
							exit
						)
					)
				)

				--Replace the original filearray by filter file array.
				if tempMaxFile.count != 0 do
					g_stLoadMaxByList.aFile = tempMaxFile

			)

		)

		rollout roImportOrMergeSettings "Load, merge or import_v1.004"
		(
			local l_btnWth1 = 150

			label lbLoadType "Load or import : " 	pos:[15, 6]
			radioButtons rdoLoadType "" 	 		pos:[lbLoadType.pos.x + 90, lbLoadType.pos.y] columns:2
													default:g_stLoadMaxByList.nDefaultLoadType
													labels:#("Load max file", "Merge max file", "Import Fbx file", "Import Obj file")

			--show merge or import options													
			checkbox ckShowMIOptions				"Show Options" checked:g_stLoadMaxByList.bShowMIOptions tooltip:"Show merge Or import options"
													across:2 align:#right offset:[-27,2]
			button btnLoadMergeImportFile			"Load, merge or import" width:l_btnWth1 align:#left offset:[-22,0]

			checkbox ckPrintLog						"Ptint log" across:2 align:#right offset:[-32, 2]
			button btnShowLogLocation				"Show log file location" width:l_btnWth1 align:#left offset:[-22,0]

			fn fnCheckTypeNLoadMergeImport &_aSelection=
			(
				nState = g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.rdoLoadType.state
				enLoadType =  g_stLoadMaxByList.aLoadType[nState]
				for i = 1 to _aSelection.count do
				(
					format "3lilog_We want to check % files, this % file is : % \n" _aSelection.count i g_stLoadMaxByList.aFile[_aSelection[i]]
					g_stLoadMaxByList.fnLoadMergeOrImport enLoadType _aSelection[i]
				)
			)

			on rdoLoadType changed state do
			(
				g_stLoadMaxByList.nDefaultLoadType = state
				enLoadType =  g_stLoadMaxByList.aLoadType[g_stLoadMaxByList.nDefaultLoadType]
				g_stLoadMaxByList.fnLoadFileToList 	&g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.lboxMaxFile \
													g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.edtSourceFolderPath.text \
													_enLoadType:enLoadType
			)
			on ckShowMIOptions changed bChecked do
			(
				g_stLoadMaxByList.bShowMIOptions = bChecked
			)

			on btnLoadMergeImportFile pressed do
			(
				aSelection = g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.lboxMaxFile.selection as array
				if aSelection.count > 0 do
				(
					--Create a log here, so we can check the process when the files are too many for loading.
					if ckPrintLog.checked == true then
					(
						sLoadMergeImportLogFile = g_stLoadMaxByList.fnGetScriptPath() + g_stLoadMaxByList.sLoadMergeImportLogFileNameWthExt
						nOutPutLog = openLog sLoadMergeImportLogFile mode:"w" outputOnly:true

						fnCheckTypeNLoadMergeImport &aSelection

						closeLog()
					)
					else
					(
						fnCheckTypeNLoadMergeImport &aSelection
					)
				)
			)

			on btnShowLogLocation pressed do
			(
				sLoadMergeImportLogFile = g_stLoadMaxByList.fnGetScriptPath() + g_stLoadMaxByList.sLoadMergeImportLogFileNameWthExt
				print sLoadMergeImportLogFile
				sExpression = "explorer /select, " + sLoadMergeImportLogFile
				DOSCommand sExpression
			)

		)

		rollout roExportSettings "Export FBX Settings_v1.001"
		(
			group "Export FBX Settings"
			(
				checkbox ckSkin "Skin"							align:#left	--pos:[5, 15] 
				checkbox ckAnimation "Animation"				pos:[ckSkin.pos.x + 120, ckSkin.pos.y] 
				checkbox ckBakeAnin "Bake Animation"			pos:[ckAnimation.pos.x + 100, ckSkin.pos.y] 				
				
				checkbox ckCopyTexture "CopyTextures"			pos:[ckSkin.pos.x, ckSkin.pos.y + 18]
																tooltip:"Copies all textures from current maxfile folder to the export folder"
				checkbox ckEmbedTexture "EmbedTextures"			pos:[ckCopyTexture.pos.x + 120, ckCopyTexture.pos.y]
																tooltip:"same option with 'Embed Media' in the FBX Export Option box"

				--checkbox ckEpSep "Export Separately" 			pos:[lbExportSettings.pos.x, ckBakeAnin.pos.y + 18]	checked:false enabled:false
																--tooltip:"Export the objects individually from the same max file."
				--checkbox ckTangentSpace "TangentSpace"
			)
			
			--button btnSaveExportPropertiesPath "Save Export Properties" pos:[lbExportSettings.pos.x, ckEmbedTexture.pos.y + 22] --height:18
			
			on roExportSettings open do
			(
				g_stLoadMaxByList.fnSetMATEmbedType g_SanliCustomTool.roMainRollout.ro1Clip1File.roExportFn.ddlEmbedTextureMode.selection
			)


		)

		rollout roCheckUndoCallBack "Check or cleanup some dangerous data_v1.013"
		(
			button	btnRemoveCallBackCF				"Remove dangerous data from current file"	  width:330 --align:#left
													-- height:18 pos:[btnExportHint.pos.x + 105,btnExportHint.pos.y ] 
			
			group "BatchCheck"
			(
				label lbBatchCheckMode "BatchCheckMode:" align:#left

				--aBatchCheckMode = #(#Check, #CheckAndRemove),
				--the elements in this array have to be same with the aBatchCheckMode array
				radioButtons rdoBatchCheckMode "" 		 	pos:[lbBatchCheckMode.pos.x + 120, lbBatchCheckMode.pos.y] 
															labels:#(" Check ", "Check and remove")

				button 		btnBatchCheckNRemoveCallBack	"Batch check" width:320
															pos:[lbBatchCheckMode.pos.x, lbBatchCheckMode.pos.y + 24]
			)

			fn fnCheckBuiltInSecurityToolEnable =
			(
				if g_stFixCallBack.fnCheckBuiltInSecurityToolEnable() == true do
				(
					sSecurityToolDetected = "Security tool detected, this rollout will deactivated"
					btnRemoveCallBackCF.text = sSecurityToolDetected
					btnBatchCheckNRemoveCallBack.text = sSecurityToolDetected
					btnRemoveCallBackCF.enabled = false
					rdoBatchCheckMode.enabled = false
					btnBatchCheckNRemoveCallBack.enabled = false
				)
			)

			on roCheckUndoCallBack open do
			(
				fnCheckBuiltInSecurityToolEnable()
			)

			on btnRemoveCallBackCF pressed do
			(
				g_stFixCallBack.fnRevertFileAndCallBack()
			)

			on btnBatchCheckNRemoveCallBack pressed do
			(
				enBatchCheckMode = g_stLoadMaxByList.aBatchCheckMode[rdoBatchCheckMode.state]

				--collect selected max file in multilistbox
				aCheckMaxCallbackFile = #()
				for iter = 1 to g_stLoadMaxByList.aFile.count do 
				(
					if g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.lboxMaxFile.selection[iter] == true then
						append aCheckMaxCallbackFile g_stLoadMaxByList.aFile[iter]
				)

				--Create a log here, so we can check the process when the files are too many for loading.
				bPrintLog = g_SanliCustomTool.roMainRollout.ro1Clip1File.roImportOrMergeSettings.ckPrintLog.checked
				if bPrintLog == true do
				(
					sLoadMergeImportLogFile = g_stLoadMaxByList.fnGetScriptPath() + g_stLoadMaxByList.sLoadMergeImportLogFileNameWthExt
					nOutPutLog = openLog sLoadMergeImportLogFile mode:"w" outputOnly:true
				)

				--Check dirty data from the maxfile.
				--If you got one dirty data from the file, no matter what it is, store the maxfilename into the array and continue to the next loop
				aDangerousFile = #()
				for i = 1 to aCheckMaxCallbackFile.count do 
				(
					--Clear all the dangerous data first, otherwise the log file probablly have note the virus,  but the maxfile doesn't have this virus.
					--this might report the wrong information
					g_stFixCallBack.fnRemoveDangDataWOStartup()

					if (i-1 >= 1) and enBatchCheckMode == #CheckAndRemove then
					(
						saveMaxFile aCheckMaxCallbackFile[i-1] quiet:on
					)					
					
					loadMaxFile aCheckMaxCallbackFile[i] quiet:on useFileUnits:on
					sFile = maxfilepath + maxfilename
					if bPrintLog == true do format "3lilog_We want to check % file(s), the % file is: % \n" aCheckMaxCallbackFile.count i sFile
					
					local varDirtyGlobalVar = g_stFixCallBack.fnCheckDirtyGlobalVariables()
					if varDirtyGlobalVar != undefined then
					(
						if bPrintLog == true do format "3lilog_Detect dangerous global variables in : % \n" maxfilename
						append aDangerousFile maxfilename
					)

					--Check MSCPROP was hide in the TrackViewNodes
					local ndGetDangerData = undefined
					try(ndGetDangerData = TrackViewNodes.TVProperty)catch()
					if ndGetDangerData != undefined do
					(
						if bPrintLog == true do format "3lilog_Detect dirty data - TVProperty in : % \n" maxfilename
						append aDangerousFile maxfilename
					)

					--Check PhysPlug
					local nPhysPlugProblem = g_stFixCallBack.fnCheckPhysPlug()
					if nPhysPlugProblem != 0 and (findItem aDangerousFile maxfilename == 0) then
					(
						if bPrintLog == true do format "3lilog_Detect PhysPlugProblem in : % \n" maxfilename
						append aDangerousFile maxfilename
					)
					
					--I recheck this at 2022-07-26
					--if I remove the callback function after the for loop, the last one will missed, so I have to remove it again
					if i == aCheckMaxCallbackFile.count and enBatchCheckMode == #CheckAndRemove then
					(
						g_stFixCallBack.fnRemoveDangDataWOStartup()
						saveMaxFile aCheckMaxCallbackFile[i] quiet:on
					)
				)

				--Make sure we have remove all dirty datas and starup file at last.
				local result = g_stFixCallBack.fnOpenStartupFile()
				if result != undefined do
				(
					g_stFixCallBack.fnReviseStartupScript g_stFixCallBack.sStartupScript "CRP_"
					g_stFixCallBack.fnReviseStartupScript g_stFixCallBack.sStartupScript "ADSL_"
					g_stFixCallBack.fnRemoveMscpropCbkNProp()
					g_stFixCallBack.fnRemoveCRPCallBacks()
					g_stFixCallBack.fnRemoveADSLCallBacks()
				)
				g_stFixCallBack.fnRemoveDirtyVariables()
				g_stFixCallBack.fnPhysXPluginMfx2_clean_instances()
				g_stFixCallBack.fnPhysXPluginMfx2_clean_defs()

				--ShowCustomMessageBox
				stMsgWnd = o_stMsgWnd()
				sMessageForShowWnd = ""
				if aDangerousFile.count == 0 then
					append sMessageForShowWnd "No dangerous data Detected: \n"
				else
				(
					sMessage1 = ""
					if enBatchCheckMode == #CheckAndRemove then
						sMessage1 = "The tools have removed " + (aDangerousFile.count as string)  + " maxfiles that contains the virus callback:\n"
					else
						sMessage1 = "There are " + (aDangerousFile.count as string)  + " maxfiles has contains some dangerous data:\n"

					
					append sMessageForShowWnd sMessage1
					for i = 1 to aDangerousFile.count do
					(
						append sMessageForShowWnd (aDangerousFile[i] + "\n")
					)
				)

				stMsgWnd.fnMainMsgDialog "sMsgFinishVirusCheckWthMoveROPosY" "Max File Callback virus checking complete" _sMessage:sMessageForShowWnd
				g_stFixCallBack.fnCheckDangerLocalFileAndDetectMaxShouldOpening()

				if bPrintLog == true do closeLog()
			)

		)

		rollout roRecordExportPath "Record Export Path_v1.002"
		(
			--label 		lbExportPathRecord "Export Path Record file:"
			checkbox	ckExportPahtRecord "SaveFilePathToXml" align:#center tooltip:"Create a xml file to save every export file path."
			editText 	edtRecordExportPath "" enabled: false --text: g_stPathOrProp.sExportRecordPath
						tooltip: "record every files when we export, all of the export path will save in this XML file "
			button 		btnResetPath "Reset the record path" width:edtRecordExportPath.width enabled: false	--tooltip:"reset the record path"

			on roRecordExportPath open do
			(
				edtRecordExportPath.text = g_stPathOrProp.sExportRecordPath
			)

			on ckExportPahtRecord changed state do
			(
				edtRecordExportPath.enabled = state
				btnResetPath.enabled = state
			)

			on edtRecordExportPath changed sValue do
			(
				g_stPathOrProp.sExportRecordPath = sValue
			)

			on btnResetPath pressed do
			(
				--Remove the string after 'Asssets', and replace it to "\\Editor\\Sanli\\ExrpotRecordPath.xml"
				sExportPathText = g_SanliCustomTool.roMainRollout.ro1Clip1File.roll.edtExportPath.text
				edtRecordExportPath.text = g_stPathOrProp.fnResetUaAndEpRcPath sExportPathText &g_stPathOrProp.sUnityAssetPath
			)

		)

		return true
	),

	init = Constructor()

)


