--Create by Sanli
--Set MultipleTimeRange to preview animation quickly

fileIn "MsgWnd.ms"			--Show Dialog Messagebox

global g_SanliCustomTool	--³o¦æ­Yµù¸Ñ±¼¡B©Î±ß¤@ÂI¤~°õ¦æªº¸Ü¡A²Ä¤@¦¸°õ¦æexport selection¥i¯à·|¦³error

struct stTimeRange
(
	nAnimStartFrame = 0,
	nAnimEndFrame = 1,
	sAnimationName = "",
	arrAnimName = #(),
	arrAnimName_Backup = #(),
	arrAnimStartFrame = #(),
	arrAnimStartFrame_Backup = #(),
	arrAnimEndFrame = #(),
	arrAnimEndFrame_Backup = #(),
	
	arrAnimStringInFileProp = #(),

	--grpTNWidth = 150,		--thumbnail group width
	--grpEtWidth = 150,		--Export group width
	TNWidth = 105,			--ThumbnailWidth
	TNHeight = 105,			--ThumbnailHeight
	btnRnWidth = 105,		--button of render tool's width

	xmlDoc = undefined,
	ndRoot = undefined,

	--the elements in this array have to be same with the ddlExportMode items.
	aExportType = #(#SkinMesh, #Animation),
	
	--the elements in this array have to be same with the ddlEmbedTextureMode items.
	aEmbedTextureType = #(#EmbedTexture, #CopyTexture, #None),
	
	--the elements in this array have to be same with the rdoSavingMethods items.
	aSaveLoadAnimMethods = #(#Xml, #FileProperties),
	
	fn fnSetAnimRange _sStartFrame _sEndFrame=
	(
		stopAnimation()--¦pªG°Ê§@¦³¦b¼½©ñ¡A¥ý°±¤U¨Ó¡A³o¼Ë¤ltimeslider¤~¤ñ¸û¤£·|¶Ã±¼
		nAnimStartFrame = _sStartFrame as integer
		nAnimEndFrame = _sEndFrame as integer
		animationRange = interval nAnimStartFrame nAnimEndFrame
		slidertime = nAnimStartFrame
	),
	
	fn fnSetAnimRangeToFileProp =
	(
		arrAnimStringInFileProp = #()
		for i = 1 to arrAnimName.count do
		(
			sAnimStringinFileProp = arrAnimStartFrame[i] + "," + arrAnimEndFrame[i]
			fileProperties.addProperty #custom arrAnimName[i] (sAnimStringinFileProp)
			--append arrAnimStringInFileProp sAnimStringinFileProp
		)
	),
	
	fn fnSetFilePropToArray =
	(
		arrAnimName = #()
		arrAnimStartFrame = #()
		arrAnimEndFrame = #()
		numFileProp = fileProperties.getNumProperties #custom
		if(numFileProp > 0)then
		(
			for i = 1 to numFileProp do
			(
				sAnimStringInFileProp = fileProperties.getpropertyvalue #custom i 
				aAnimStringInFileProp = filterstring sAnimStringInFileProp ","
				sAnimNameInFileProp = fileproperties.getpropertyname #custom i
				
				--format "Ãþ§O¤Á´« :%  % \n" aFileClassArray[nCgySelect] nCgySelect
				format "Sanlilog_FilePropÄÝ©Ê: % % % \n" sAnimNameInFileProp aAnimStringInFileProp[1] aAnimStringInFileProp[2]
				
				append arrAnimName sAnimNameInFileProp
				append arrAnimStartFrame aAnimStringInFileProp[1]
				append arrAnimEndFrame aAnimStringInFileProp[2]
			)
		)
	),

	fn fnSetExportMode _state=
	(
		EnumExportType = aExportType[_state]
		case EnumExportType of
		(
			#SkinMesh:
			(
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckSkin.checked = true
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckAnimation.checked = false
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckBakeAnin.checked = false
			)
			#Animation:
			(
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckSkin.checked = false
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckAnimation.checked = true
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckBakeAnin.checked = true
			)
		)
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
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckCopyTexture.checked = false
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckEmbedTexture.checked = true
				)
				#CopyTexture:
				(
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckCopyTexture.checked = true
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckEmbedTexture.checked = false
				)
				#None:
				(
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckCopyTexture.checked = false
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckEmbedTexture.checked = false
				)
			)
		)
	)
)
global g_stTimeRange = stTimeRange()

struct stMultiClipsIn1FileWnd
(
	public roll,
	roSearch,	
	roExportSetAndAniSLMethods,	--Export Settings and Anim List Save/Load Methods
	roSeperateAnim,
	roRecordExportPath,
	roHeight = 700,

	function Constructor =
	(
		rollout roll "Multiclips in one file_v1.002"
		(
			group "SetAnimationRange"
			(
				label lbAnimationName 				"Animation Name" pos:[15, 30]
				dotNetControl edtAniName 			"TextBox" pos:[lbAnimationName.pos.x + 90, lbAnimationName.pos.y - 2] width:217 height:17

				label lbStartFrame 					"Start Frame" pos:[lbAnimationName.pos.x, lbAnimationName.pos.y + 22]
				dotNetControl edtStartFrame 		"TextBox" pos:[lbStartFrame.pos.x + 90, lbStartFrame.pos.y - 2] width:75 height:17
				label lbEndFrame 					"EndFrame" pos:[(edtStartFrame.pos.x + edtStartFrame.width + 7), lbStartFrame.pos.y]
				dotNetControl edtEndFrame 			"TextBox" pos:[lbEndFrame.pos.x + 60, edtStartFrame.pos.y] width:75 height:17
				
				button btnCreateNewClip				"Create New Clip" pos:[lbStartFrame.pos.x, lbStartFrame.pos.y + 22] width: 166
				button btnResetCurrClip				"Reset Current Clip" pos:[lbEndFrame.pos.x, btnCreateNewClip.pos.y] width: 135
				
				label lbSAniRangeName				"AnimName" 			pos:[45, btnCreateNewClip.pos.y + 32]
				label lbSAniRangeStartFrame			"Start" 			pos:[130, lbSAniRangeName.pos.y]
				label lbSAniRangeEndFrame			"End" 				pos:[185, lbSAniRangeName.pos.y]
				label lbThumbnail					"Thumbnail" 		pos:[245, lbSAniRangeName.pos.y]
				MultiListBox lbxAniRangeName		pos:[lbStartFrame.pos.x, lbSAniRangeName.pos.y + 16] 	
													items:g_stTimeRange.arrAnimName			width: 100	height:8
				MultiListBox lbxAniRangeStartFrame	pos:[lbxAniRangeName.pos.x + lbxAniRangeName.width + 3, lbxAniRangeName.pos.y] 	
													items:g_stTimeRange.arrAnimStartFrame	width: 50	height:8
				MultiListBox lbxAniRangeEndFrame	pos:[lbxAniRangeStartFrame.pos.x + lbxAniRangeStartFrame.width + 3, lbxAniRangeName.pos.y]
													items:g_stTimeRange.arrAnimEndFrame		width: 50	height:8

				bitmap bmp1 						bitmap:(bitmap g_stTimeRange.TNWidth g_stTimeRange.TNHeight color:(color 155 155 155))
													pos:[lbxAniRangeEndFrame.pos.x + lbxAniRangeEndFrame.width + 3, lbxAniRangeEndFrame.pos.y]

				
				
				button btnLoadAnim					"LoadAnim" 			pos:[lbxAniRangeName.pos.x - 1, lbxAniRangeName.pos.y + lbxAniRangeName.height + 6] width:62 height:18
																	tooltip:"Open Animation list by Xml or FileProperties"
				button btnSaveAnim					"SaveAnim" 			pos:[btnLoadAnim.pos.x + 68, btnLoadAnim.pos.y] width:62 height:18
																	tooltip:"Save Animation list to Xml or FileProperties"
				button btnDelOneAnimRange			"DeleteAni"			pos:[btnSaveAnim.pos.x + 68, btnLoadAnim.pos.y]
																	width:62 height:18 tooltip:"Delete Selected animation"																		
				button btn_RenderTools 				"CreateThumbnail" 	width:g_stTimeRange.btnRnWidth height:18	--height:58
																		pos:[bmp1.pos.x, btnLoadAnim.pos.y] 
																		tooltip:"create current max file thumbnail"
				--button btnLoadAniRangeByXml			"LoadXml" 				pos:[btnDelOneAnimRange.pos.x, btnLoadAnim.pos.y + 20] width:90 height:18
																			--tooltip:"Open Animation list by Xml"
				--button btnSaveToXml					"SaveXml" 				pos:[btnDelAllAnimRange.pos.x, btnLoadAniRangeByXml.pos.y] width:90 height:18
																			--tooltip:"Save Animation list to Xml"

				
			)

			group "Export"
			(
				dotNetControl edtExportPath						"TextBox" height:17 width:315 
																pos:[btnLoadAnim.pos.x, btn_RenderTools.pos.y + 53]
				
				--the elements in this items have to be same with the g_stTimeRange.aExportType
				label lbExportMode "ExportMode:"				pos:[edtExportPath.pos.x, edtExportPath.pos.y + 28]
				dropdownList ddlExportMode ""					pos:[lbExportMode.pos.x + 68, lbExportMode.pos.y - 2] width:163
																items:#("Skinned Mesh", "Animation")
																
				--label lbCreateFolder "CreateFolder"				pos:[ddlExportMode.pos.x + 160, ddlExportMode.pos.y + 5]
				checkbox ckCreatefolder "CreateFolder" 			pos:[ddlExportMode.pos.x + ddlExportMode.width + 4, ddlExportMode.pos.y + 5]
																tooltip:"Create the folder by 3dsMax's filename."
				
				--the elements in this items have to be same with the g_stTimeRange.aEmbedTextureType
				label lbEmbedTexture "MediaEmbed:"				pos:[lbExportMode.pos.x, lbExportMode.pos.y + 22]
				dropdownList ddlEmbedTextureMode ""				pos:[lbEmbedTexture.pos.x + 68, lbEmbedTexture.pos.y - 2] width:163
																items:#("Embed Media", "CopyTexture from current folder", "Don't set any textures")
				
				label lbTextureExt "Ext:"						pos:[ddlEmbedTextureMode.pos.x + ddlEmbedTextureMode.width + 5, ddlEmbedTextureMode.pos.y + 5]
				editText edtTextureExt text:".tga " 			pos:[lbTextureExt.pos.x + 20, lbTextureExt.pos.y - 3] width:58 height:10
				
				button 	btnExportFile "Export FBX"				pos:[lbEmbedTexture.pos.x, lbEmbedTexture.pos.y + 28] width:315
																tooltip:"Export selected max files from the list."
				--button 	btnSelExport "Export selection"			pos:[btnExportFile.pos.x + 95, btnExportFile.pos.y] width:100
																--tooltip:"Export the selection that you selected in the current max file."
			)
			
			fn fnSetlistItemToArray =
			(
				g_stTimeRange.arrAnimName = lbxAniRangeName.items as array
				g_stTimeRange.arrAnimStartFrame = lbxAniRangeStartFrame.items as array
				g_stTimeRange.arrAnimEndFrame = lbxAniRangeEndFrame.items as array
			)
			fn fnSetArrayToListItem =
			(
				--clear the roSearch.edtSearch.text
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roSearch.edtSearch.text = ""

				g_sttimerange.arrAnimName_Backup = deepCopy g_stTimeRange.arrAnimName
				g_sttimerange.arrAnimStartFrame_Backup = deepCopy g_stTimeRange.arrAnimStartFrame
				g_sttimerange.arrAnimEndFrame_Backup = deepCopy g_stTimeRange.arrAnimEndFrame

				lbxAniRangeName.items = g_stTimeRange.arrAnimName
				lbxAniRangeStartFrame.items = g_stTimeRange.arrAnimStartFrame
				lbxAniRangeEndFrame.items = g_stTimeRange.arrAnimEndFrame
			)
			
			fn fnSaveAnimRange =
			(
				nStartFrame = edtStartFrame.text as integer
				nEndFrame = edtEndFrame.text as integer
				sAnimationName = edtAniName.text
				
				if(nStartFrame != undefined and nEndFrame != undefined and sAnimationName != "")then
				(
					if (findItem g_stTimeRange.arrAnimName edtAniName.text) == 0 then
					(
						append g_stTimeRange.arrAnimName edtAniName.text
						append g_stTimeRange.arrAnimStartFrame edtStartFrame.text
						append g_stTimeRange.arrAnimEndFrame edtEndFrame.text
						fnSetArrayToListItem()
					)
					else
					(
						sMessage = "There is already have a name '" + edtAniName.text + "' in the list"
						messageBox sMessage
					)											
				)
				else
					messageBox "Please input the numbers in 'StartFrame' and 'Endframe', and give a Name in the 'Anim Name'."
			)

			--Set Thumbnail and other Multilistbox's selection
			fn fnSetThumbnailAndOtherSel _SourceLbx _DestLbx1 _DestLbx2 =
			(
				aSelection = (_SourceLbx.selection as array)
				if(aSelection.count > 0)do
				(
					_DestLbx1.selection = _SourceLbx.selection
					_DestLbx2.selection = _SourceLbx.selection

					if aSelection.count == 1 do
					(
						nClipIDInList = aSelection[1]
						sClipName = g_stTimeRange.arrAnimName[nClipIDInList]
						bmpfile = (maxfilepath + "\\Thumbnails\\@" +  (getfilenamefile maxfilename) + "_" + sClipName + ".jpg")

						if (doesFileExist bmpfile) == true then
							bmp1.filename = bmpfile
						else	
							bmp1.bitmap = 
							(bitmap g_stTimeRange.TNWidth g_stTimeRange.TNHeight color:(color 150 150 150))
					)
				)
			)

			fn fnCreateXmlAndSetNdRoot =
			(
				g_stTimeRange.xmlDoc = tXMLDocument()
				sRecordExportFile = g_SanliCustomTool.roMainRollout.roMultiClip1File.roRecordExportPath.edtExportPathRecord.text
				if (doesFileExist sRecordExportFile) == true do deleteFile sRecordExportFile
				sRecordExportPath = pathConfig.removePathLeaf sRecordExportFile
				makeDir sRecordExportPath
				g_stTimeRange.xmlDoc.mfCreateXML rXmlFilePath:sRecordExportFile
				g_stTimeRange.ndRoot = g_stTimeRange.xmlDoc.mfCreateRootNode "RecordPathRoot"
			)

			--EX: fnAppendChildNodeToXml sExportFile aSelection[i].name
			fn fnAppendChildNodeToXml _sExportFile _sName =
			(
				ndChildNode = g_stTimeRange.xmlDoc.mfGetNewNode _sName
				ndChildNode.mfSetText _sExportFile
				g_stTimeRange.ndRoot.mfAppendChild ndChildNode
			)

			fn fnSaveXmlAndRelease =
			(
				g_stTimeRange.xmlDoc.mfSaveXML()
				g_stTimeRange.xmlDoc.mfReleaseXML()
			)

			fn fnSetFBXParameter =
			(
				FBXExporterSetParam "Skin" g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckSkin.checked
				FBXExporterSetParam "BakeAnimation" g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckBakeAnin.checked
				FBXExporterSetParam "Animation" g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckAnimation.checked
				FBXExporterSetParam "EmbedTextures" g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckEmbedTexture.checked
				--FbxExporterSetParam "TangentSpaceExport" true
			)

			--Make Dir And Export SkinnedMesh File From MutilClip
			--sExportFile = fnMkDrAndExpSKMFromMtClip sOutputpath sFilename
			fn fnMkDrAndExpSKMFromMtClip _sOutputpath _sFileName=
			(
				sExportFile = _sOutputpath  + _sFileName + ".FBX"
				format "Sanlilog_ExportSKMFromMultiClip: % \n" sExportFile
				makeDir _sOutputpath
				exportFile sExportFile #noPrompt  selectedOnly:on
				return sExportFile
			)

			--Make Dir And Export Animation File From MutilClip
			--sExportFile = fnMkDrAndExpAnimFromMtClip sOutputpath sFilename sAnimName sStartFrame sEndFrame
			fn fnMkDrAndExpAnimFromMtClip _sOutputpath _sFileName _sAnimName _sStartFrame _sEndFrame=
			(
				nStartFrame = _sStartFrame as integer
				nEndFrame = _sEndFrame as integer

				animationRange = interval nStartFrame nEndFrame
				FBXExporterSetParam "BakeFrameStart" nStartFrame
				FBXExporterSetParam "BakeFrameEnd" nEndFrame

				sExportFile = _sOutputpath  + _sFileName + "@" + _sAnimName + ".FBX"
				format "Sanlilog_ExportAnimFromMultiClip: % \n" sExportFile
				makeDir _sOutputpath
				exportFile sExportFile #noPrompt  selectedOnly:on
				return sExportFile
			)

			--fnExportSkinMesh edtExportPath.text ckCreatefolder.checked sFilename
			fn fnExportSkinMesh _sExportPath _bCreateFolder _sFilename=
			(
				sOutputpath = undefined
				sExportFile = undefined
				sOutputpath =  _sExportPath + "\\"
				if _bCreateFolder then
					sOutputpath =  _sExportPath + "\\" + _sFilename + "\\" 

				sExportFile = fnMkDrAndExpSKMFromMtClip sOutputpath _sFilename
				fnAppendChildNodeToXml sExportFile _sFilename
				return sOutputpath
			)

			--fnExportClip (lbxAniRangeName.selection as array) edtExportPath.text sFilename
			fn fnExportClip _aExpMaxClipID _sExportPath _sFilename=
			(
				sOutputpath = undefined
				sExportFile = undefined
				for i = 1 to _aExpMaxClipID.count do 
				(
					nIDInLstBox = _aExpMaxClipID[i]

					--loadMaxFile aExpMaxFile[i] quiet:on useFileUnits:on
					--macros.run "Medit Tools" "clear_medit_slots"

					--Set output path
					sOutputpath =  _sExportPath + "\\"
					if ckCreatefolder.checked then
						sOutputpath =  _sExportPath + "\\" + _sFilename + "\\"

					sAnimName = g_stTimeRange.arrAnimName[nIDInLstBox]
					nStartFrame = g_stTimeRange.arrAnimStartFrame[nIDInLstBox]
					nEndFrame = g_stTimeRange.arrAnimEndFrame[nIDInLstBox]
					sExportFile = fnMkDrAndExpAnimFromMtClip sOutputpath _sFilename sAnimName nStartFrame nEndFrame

					--the xml file can't save the character '@' into the node, so I change to '_'
					--http://forums.cgsociety.org/archive/index.php?t-1124312.html
					sFileName = _sFileName + "_" + sAnimName
					fnAppendChildNodeToXml sExportFile sFileName

				)--end for i = 1 to _aExpMaxClipID.count do 
				--return sExportFile
				return sOutputpath
			)

			--fnCopyTexture edtTextureExt.text sOutputpath
			fn fnCopyTexture _sExtName _sOutputpath= 
			(
				aTextures = getFiles (maxfilepath + "\\*" + _sExtName)
				if aTextures.count != 0 then
				(
					for mt in aTextures do
					(
						mapname =getFilenameFile mt
						sOutputTexturePath = _sOutputpath + "Materials\\"	--¶K¹Ï­n©ñ¨ìMaterials¸ê®Æ§¨¤º
						makeDir sOutputTexturePath
						sOutputTextureFile = sOutputTexturePath + mapname + _sExtName
						format "Sanlilog_ExportTexture: % \n" sOutputTextureFile
						deleteFile sOutputTextureFile
						copyFile mt sOutputTextureFile
					)
				)
			)
			
			on roll open do
			(
				edtStartFrame.Multiline = true	--¨S¦³³o¦æªº¸Ü¡AdotNectControl\TextBoxªº°ª«×´NµLªk³Q­×§ï
				edtEndFrame.Multiline = true
				edtAniName.Multiline = true
				dcColor = dotnetclass "system.drawing.color"
				edtStartFrame.backColor = dcColor.darkgray
				edtEndFrame.backColor = dcColor.darkgray
				edtAniName.backColor = dcColor.darkgray
				edtStartFrame.text = "5"
				edtEndFrame.text = "10"

				edtExportPath.Multiline = true	--¨S¦³³o¦æªº¸Ü¡AdotNectControl\TextBoxªº°ª«×´NµLªk³Q­×§ï
				edtExportPath.backColor = dcColor.darkgray
				edtExportPath.text = g_stPathOrProp.sExportPath

				ddlEmbedTextureMode.selection = 3
				g_stTimeRange.fnSetMATEmbedType ddlEmbedTextureMode.selection
				ddlExportMode.selection = 2
				g_stTimeRange.fnSetExportMode ddlExportMode.selection
			)

			on edtExportPath keyup key do
			(
				g_stPathOrProp.sExportPath = edtExportPath.text
			)

			on btn_RenderTools pressed do
			(
				aSelection = (lbxAniRangeName.selection as array)
				
				if aSelection.count == 1 then
				(
					hidebyCategory.bones = on
					sWidth = g_stTimeRange.TNWidth
					sHeight = g_stTimeRange.TNHeight

					--Set grab_bmp1
					grab_tempbmp1 = gw.getViewportDib()
					range = grab_tempbmp1.width / grab_tempbmp1.height as Float
					grab_bmp1 = bitmap (sWidth * range) sHeight color:white
					copy grab_tempbmp1 grab_bmp1
					
					--Set grab_bmp2
					grab_bmp2 = bitmap sWidth sHeight color:white
					pasteBitmap grab_bmp1 grab_bmp2 (box2 ((grab_bmp1.width - sWidth)/ 2) 0 sWidth sHeight) [0,0] 					
					
					nClipIDInList = aSelection[1]
					sClipName = g_stTimeRange.arrAnimName[nClipIDInList]
					makeDir (maxfilepath + "\\Thumbnails")
					savefilepath =  (maxfilepath + "\\Thumbnails\\@" +  (getfilenamefile maxfilename) + "_" + sClipName + ".jpg")
					grab_bmp2.filename = savefilepath
					save grab_bmp2

					bmp1.filename = savefilepath
				)
				else messageBox "Please Select 'one' clip to Create thumbnail!!"				
			)

			on btnExportFile pressed do
			(
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roRecordExportPath.edtExportPathRecord.text =
				 		g_stPathOrProp.fnResetUaAndEpRcPath edtExportPath.text &g_stPathOrProp.sUnityAssetPath

				--save ExportPath to xml
				g_stPathOrProp.sExportPath = edtExportPath.text
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


				sFilename = getFileNameFile maxfilename
				sOutputpath =undefined

				sExpMaxfile = maxfilepath + maxfilename
				aExpMaxClipID = (lbxAniRangeName.selection as array)

				fnSetFBXParameter()
				fnCreateXmlAndSetNdRoot()
				
				--Export model or animation
				max select all
				EnumExportType = g_stTimeRange.aExportType[ddlExportMode.selection]
				case EnumExportType of
				(
					#SkinMesh:
					(
						sOutputpath = fnExportSkinMesh edtExportPath.text ckCreatefolder.checked sFilename
					)
					#Animation:
					(
						sOutputpath = fnExportClip (lbxAniRangeName.selection as array) edtExportPath.text sFilename
					)
				)

				-- the document is saved and released
				fnSaveXmlAndRelease()
				
				--Copy Texture
				if g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckCopyTexture.checked == true then
				(
					fnCopyTexture edtTextureExt.text sOutputpath
				)

				--Copy Unity script into the unity folder if there doesn't have the script to quick select the maxfile.
				g_stPathOrProp.fnCopyCSToUFolder()

			)

			on ddlExportMode selected state do
			(
				EnumExportType = g_stTimeRange.aExportType[state]
				case EnumExportType of
				(
					#SkinMesh:
					(
						g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckSkin.checked = true
						g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckAnimation.checked = false
						g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckBakeAnin.checked = false
					)
					#Animation:
					(
						g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckSkin.checked = false
						g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckAnimation.checked = true
						g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.ckBakeAnin.checked = true
					)
				)
			)

			on ddlEmbedTextureMode selected state do
			(
				g_stTimeRange.fnSetMATEmbedType state
			)

			on btnDelOneAnimRange pressed do
			(
				aSelection = (lbxAniRangeName.selection as array)
				if aSelection.count == 1 then
				(
					deleteitem g_stTimeRange.arrAnimName aSelection[1]
					deleteitem g_stTimeRange.arrAnimStartFrame aSelection[1]
					deleteitem g_stTimeRange.arrAnimEndFrame aSelection[1]
					fnSetArrayToListItem()
				)
				else
					messageBox "Please Select 'one' clip to delete!!"
			)
			
			on btnDelAllAnimRange pressed do
			(
				g_stTimeRange = stTimeRange()
				fnSetArrayToListItem()
			)
			
			on btnLoadAnim pressed do
			(
				state = g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.rdoSavingMethods.state
				enSaveAnimListType = g_stTimeRange.aSaveLoadAnimMethods[state]
				case enSaveAnimListType of
				(
					#Xml:
					(
						g_stTimeRange.arrAnimName = #()
						g_stTimeRange.arrAnimStartFrame = #()
						g_stTimeRange.arrAnimEndFrame = #()

						sAnimLstFileName = (getFilenameFile maxfilename) + "AnimList.xml"
						sAnimLstFile = maxfilepath + sAnimLstFileName

						if (doesFileExist sAnimLstFile) == true then
						(
							g_stTimeRange.xmlDoc = tXMLDocument()
							--sAnimLstFile = maxfilepath + sAnimLstFileName
							g_stTimeRange.xmlDoc.mfLoadXML  sAnimLstFile
							chunkRoot = g_stTimeRange.xmlDoc.mfGetRootNode()
							ndAnimName = chunkRoot.mfGetChildren()		--¨ú±o<attack_1> ¡B <idle_1>¡Betc

							for i = 1 to ndAnimName.count do
							(
								sAnimationName = ndAnimName[i].mfGetName()
								ndStartFrame = ndAnimName[i].mfGetChildrenNodesByName "StartFrame"
								ndEndFrame = ndAnimName[i].mfGetChildrenNodesByName "EndFrame"
								sStartFrame = ndStartFrame[1].mfGetText()
								sEndFrame = ndEndFrame[1].mfGetText()
								--format "¤T¥ßlog_Name %  StartFrame: % EndFrame: % \n" sAnimationName sStartFrame sEndFrame

								append g_stTimeRange.arrAnimName sAnimationName
								append g_stTimeRange.arrAnimStartFrame sStartFrame
								append g_sttimerange.arrAnimEndFrame sEndFrame
							)
						)
						else
							format "Sanlilog_Can't find the xml path: % \n" sAnimLstFile

					)
					#FileProperties:
					(
						g_stTimeRange.fnSetFilePropToArray()
						
					)
				)

				--if the buttons if disabled by search field, remember to enable
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnCreateNewClip.enabled = true
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnResetCurrClip.enabled = true
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnSaveAnim.enabled = true
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnDelOneAnimRange.enabled = true

				fnSetArrayToListItem()
			)
			
			on btnSaveAnim pressed do
			(
				stMsgWnd = o_stMsgWnd()						--fileIn o_stMsgWnd®É·|¥Î¨ìªºµ²ºc
				fnSetlistItemToArray()

				--aSaveLoadAnimMethods = #(#Xml, #FileProperties),
				state = g_SanliCustomTool.roMainRollout.roMultiClip1File.roExportSetAndAniSLMethods.rdoSavingMethods.state
				enSaveAnimListType = g_stTimeRange.aSaveLoadAnimMethods[state]
				case enSaveAnimListType of
				(
					#Xml:
					(
						sAnimLstFileName = (getFilenameFile maxfilename) + "AnimList.xml"
				
						--fnCreateXmlAndSetNdRoot
						g_stTimeRange.xmlDoc = tXMLDocument()
						sAnimLstFile = maxfilepath + sAnimLstFileName						--differenct with fnCreateXmlAndSetNdRoot
						if (doesFileExist sAnimLstFile) == true do deleteFile sAnimLstFile	--differenct with fnCreateXmlAndSetNdRoot
						--sAnimLstPath = pathConfig.removePathLeaf sAnimLstFile				--differenct with fnCreateXmlAndSetNdRoot
						--makeDir sRecordExportPath											--differenct with fnCreateXmlAndSetNdRoot
						g_stTimeRange.xmlDoc.mfCreateXML rXmlFilePath:sAnimLstFile			--differenct with fnCreateXmlAndSetNdRoot
						g_stTimeRange.ndRoot = g_stTimeRange.xmlDoc.mfCreateRootNode "AnimListRoot"	--differenct with fnCreateXmlAndSetNdRoot
						
						for i = 1 to g_stTimeRange.arrAnimName.count do
						(
							--fnAppendChildNodeToXml
							--Create ChildNode : Animation name
							ndAnimNode = g_stTimeRange.xmlDoc.mfGetNewNode g_stTimeRange.arrAnimName[i]
							
							--Create Child1stNode : StartFrame
							ndAnimStartFrameNode = g_stTimeRange.xmlDoc.mfGetNewNode "StartFrame"
							ndAnimStartFrameNode.mfSetText g_stTimeRange.arrAnimStartFrame[i]
							ndAnimNode.mfAppendChild ndAnimStartFrameNode
							
							--Create child2ndNode : EndFrame
							ndAnimEndFrameNode = g_stTimeRange.xmlDoc.mfGetNewNode "EndFrame"
							ndAnimEndFrameNode.mfSetText g_stTimeRange.arrAnimEndFrame[i]
							ndAnimNode.mfAppendChild ndAnimEndFrameNode

							g_stTimeRange.ndRoot.mfAppendChild ndAnimNode
						)

						-- the document is saved and released
						fnSaveXmlAndRelease()
					)
					#FileProperties:
					(
						g_stTimeRange.fnSetAnimRangeToFileProp()
					)
				)

				stMsgWnd.fnMainMsgDialog "sMsgProcessCompleted" "Animation list Saving Complete"
			)
			
			on btnCreateNewClip pressed do
			(
				fnSaveAnimRange()
			)
			on btnResetCurrClip pressed do
			(
				aSelection = (lbxAniRangeName.selection as array)
				print aSelection.count
				if(aSelection.count == 1) then
				(
					nStartFrame = edtStartFrame.text as integer
					nEndFrame = edtEndFrame.text as integer
					sAnimationName = edtAniName.text
					
					if(nStartFrame != undefined and nEndFrame != undefined and sAnimationName != "")then
					(
						nIndex = aSelection[1]
						--If the list already have a same name, and that name is not the item that I select, then return it.
						if ((findItem g_stTimeRange.arrAnimName edtAniName.text) == 0) or
							((findItem g_stTimeRange.arrAnimName edtAniName.text) == nIndex ) then
						(
							g_stTimeRange.arrAnimName[nIndex] = edtAniName.text
							g_stTimeRange.arrAnimStartFrame[nIndex] = edtStartFrame.text
							g_stTimeRange.arrAnimEndFrame[nIndex] = edtEndFrame.text
							fnSetArrayToListItem()
						)
						else messageBox "There is already have a same name in the list!!"
					)
					else messageBox "Please input the numbers in 'StartFrame' and 'Endframe', and give a Name in the 'Anim Name'."
				)
				else
					messageBox "Please select 'one' clip to reset!!"
			)

			on edtStartFrame KeyUp key do
			(
				if key.keyCode == key.KeyCode.Enter then
					fnSaveAnimRange()
				else if key.keyCode == key.KeyCode.Tab then
					edtEndFrame.Focus()
			)
			on edtEndFrame KeyUp key do
			(
				if key.keyCode == key.KeyCode.Enter then
					fnSaveAnimRange()
				else if key.keyCode == key.KeyCode.Tab then
					edtAniName.Focus()
			)
			on edtAniName KeyUp key do
			(
				if key.keyCode == key.KeyCode.Enter then
					fnSaveAnimRange()
				else if key.keyCode == key.KeyCode.Tab then
					edtStartFrame.Focus()
			)

			on lbxAniRangeName doubleClicked ID do
			(
				fnSetlistItemToArray()
				g_stTimeRange.fnSetAnimRange g_stTimeRange.arrAnimStartFrame[ID] g_stTimeRange.arrAnimEndFrame[ID]
			)

			on lbxAniRangeStartFrame doubleClicked ID do
			(
				fnSetlistItemToArray()
				g_stTimeRange.fnSetAnimRange g_stTimeRange.arrAnimStartFrame[ID] g_stTimeRange.arrAnimEndFrame[ID]
			)

			on lbxAniRangeEndFrame doubleClicked ID do
			(
				fnSetlistItemToArray()
				g_stTimeRange.fnSetAnimRange g_stTimeRange.arrAnimStartFrame[ID] g_stTimeRange.arrAnimEndFrame[ID]
			)

			on lbxAniRangeName selected index do
			(
				fnSetThumbnailAndOtherSel lbxAniRangeName lbxAniRangeStartFrame lbxAniRangeEndFrame
			)
			on lbxAniRangeStartFrame selected index do
			(
				fnSetThumbnailAndOtherSel lbxAniRangeStartFrame lbxAniRangeName lbxAniRangeEndFrame
			)
			on lbxAniRangeEndFrame selected index do
			(
				fnSetThumbnailAndOtherSel lbxAniRangeEndFrame lbxAniRangeName lbxAniRangeStartFrame
			)

		)

		rollout roSearch "Search_v1.001"
		(
			label 		lbExportPathRecord 			"Search"	pos:[15, 8]
			dotNetControl edtSearch 				"TextBox" pos:[55, lbExportPathRecord.pos.y - 1] width:275 height:17

			fn fnSearchFilterForMultiAnim _filterKey = 
			(
				aTempAnimName = #()
				aTempAnimStartFrame = #()
				aTempAnimEndFrame = #()
				
				for ind = 1 to g_stTimeRange.arrAnimName.count do 
				(
					isFriendy = undefined
					isFriendy = findString g_stTimeRange.arrAnimName[ind] _filterKey
					if (isFriendy != undefined) do 
					(
						append aTempAnimName (g_stTimeRange.arrAnimName[ind])
						append aTempAnimStartFrame (g_stTimeRange.arrAnimStartFrame[ind])
						append aTempAnimEndFrame (g_stTimeRange.arrAnimEndFrame[ind])
					)
				)

				g_stTimeRange.arrAnimName = deepCopy aTempAnimName
				g_stTimeRange.arrAnimStartFrame = deepCopy aTempAnimStartFrame
				g_stTimeRange.arrAnimEndFrame = deepCopy aTempAnimEndFrame

			)

			on roSearch open do
			(
				edtSearch.Multiline = true	--¨S¦³³o¦æªº¸Ü¡AdotNectControl\TextBoxªº°ª«×´NµLªk³Q­×§ï
				dcColor = dotnetclass "system.drawing.color"
				edtSearch.backColor = dcColor.darkgray

			)

			on edtSearch keyup do
			(
				--disable 4 buttons or these buttons will disturb this function
				--Create new clip¡Breset current clip' saveanim' deleteani
				if edtSearch.text.count >= 1 then
				(
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnCreateNewClip.enabled = false
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnResetCurrClip.enabled = false
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnSaveAnim.enabled = false
					g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.btnDelOneAnimRange.enabled = false
				)

				--tempMaxFile = #()
				g_stTimeRange.arrAnimName = deepCopy g_stTimeRange.arrAnimName_Backup
				g_stTimeRange.arrAnimStartFrame = deepCopy g_stTimeRange.arrAnimStartFrame_Backup
				g_stTimeRange.arrAnimEndFrame = deepCopy g_stTimeRange.arrAnimEndFrame_Backup
				fnSearchFilterForMultiAnim edtSearch.text

				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.lbxAniRangeName.items = g_stTimeRange.arrAnimName
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.lbxAniRangeStartFrame.items = g_stTimeRange.arrAnimStartFrame
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.lbxAniRangeEndFrame.items = g_stTimeRange.arrAnimEndFrame

				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.lbxAniRangeName.selection = 
					findItem g_stTimeRange.arrAnimName g_stTimeRange.arrAnimName[1]
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.lbxAniRangeStartFrame.selection = 
					findItem g_stTimeRange.arrAnimStartFrame g_stTimeRange.arrAnimStartFrame[1]
				g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.lbxAniRangeEndFrame.selection = 
					findItem g_stTimeRange.arrAnimEndFrame g_stTimeRange.arrAnimEndFrame[1]
			)

		)

		rollout roExportSetAndAniSLMethods "Export Settings and Anim List Save/Load Methods_v1.001"
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
			group "Other Settings"
			(
				--the elements in this array have to be same with the aSaveLoadAnimMethods array.
				label lbSavingMethods "Save/Load Animlist by : " align:#left
				radioButtons rdoSavingMethods "" 				pos:[lbSavingMethods.pos.x + 120, lbSavingMethods.pos.y] 
																labels:#(" Xml ", "File Propeties")
				button btnOpenFile "Open current max folder"	align:#left width:160 --height:18
				button btnSaveExportPropertiesPath "Save Export Properties" width:160 pos:[btnOpenFile.pos.x + 165, btnOpenFile.pos.y] --height:18
			)

			on roExportSetAndAniSLMethods open do
			(
				g_stTimeRange.fnSetMATEmbedType g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.ddlEmbedTextureMode.selection
				g_stTimeRange.fnSetExportMode g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.ddlExportMode.selection
			)

			on btnOpenFile pressed do
			(
				format "Åã¥Ü¸ÓÀÉ®×ªº¸ô®| % \n" maxfilepath
				shelllaunch maxfilepath ""
			)
		)

		rollout roSeperateAnim "Seperate Animation"
		(
			button 	btnAnimSplit 	"¤À³Î°Ê§@"		width:330  tooltip:"±N¸Ó¸ê®Æ§¨©Ò¦³ªº°Ê§@m©î¦¨¤@­Ó­Óªº3ds maxÀÉ" 

			on btnAnimSplit pressed do
			(
				if g_stTimeRange.arrAnimName.count > 0 then
				(
					sAnimPath = maxFilePath + "\\SeperateAnimation\\"
					makeDir sAnimPath
					for i = 1 to g_stTimeRange.arrAnimName.count do
					(
						--GetName
						actionName = g_stTimeRange.arrAnimName[i]
						
						--GetStartFrame
						startnum = g_stTimeRange.arrAnimStartFrame[i] as integer
						
						--¨ú±oµ²§ô¼v®æ
						endnum = g_stTimeRange.arrAnimEndFrame[i] as integer

						animationRange = interval startnum endnum
						uframe = slidertime
						sMaxFile = sAnimPath + actionName + ".max"
						saveMaxFile   sMaxFile quiet:true
					)
					stMsgWnd = o_stMsgWnd()
					stMsgWnd.fnMainMsgDialog "sMsgProcessCompleted" "Animation File Seperate Complete"
				)
				else
					messageBox "There is no animation in the list box"				
			)

		)
		
		rollout roRecordExportPath "Record Export Path_v1.001"
		(
			label 		lbExportPathRecord "Export Path Record file:"
			editText 	edtExportPathRecord "" --text: g_stPathOrProp.sExportRecordPath
						tooltip: "record every files when we export, all of the export path will save in this XML file "
			button 		btnResetPath "Reset the record path" width:edtExportPathRecord.width			--tooltip:"reset the record path"

			on roRecordExportPath open do
			(
				edtExportPathRecord.text = g_stPathOrProp.sExportRecordPath
			)
			
			--on edtExportPathRecord keyup key do
			on edtExportPathRecord changed sValue do
			(
				g_stPathOrProp.sExportRecordPath = sValue
			)

			on btnResetPath pressed do
			(
				--±NAssets¥H«áªº¦r¦ê®³±¼¡AµM«á§ï¦¨\\Editor\\Sanli\\ExrpotRecordPath.xml
				sExportPathText = g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.edtExportPath.text
				edtExportPathRecord.text = g_stPathOrProp.fnResetUaAndEpRcPath sExportPathText &g_stPathOrProp.sUnityAssetPath

				sRecordExportXmlPath = ""
				aFilterRecordExportXmlPath = filterString g_SanliCustomTool.roMainRollout.roMultiClip1File.roll.edtExportPath.text "\\"
				for i = 1 to aFilterRecordExportXmlPath.count do
				(
					sRecordExportXmlPath += aFilterRecordExportXmlPath[i] + "\\"
					if aFilterRecordExportXmlPath[i] == "Assets" do exit
				)

				edtExportPathRecord.text = 	sRecordExportXmlPath + "Editor\\Sanli\\ExrpotRecordPath.xml"
			)

		)

		return true
	),

	init = Constructor()
)






