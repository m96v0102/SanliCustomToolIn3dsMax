--BatchRename' SwitchModel

struct stOthers
(
	--BatchRename
	aOriginalName = #(),
	aNewName = #(),
	nBatchRN1BtnWidth = 330,	--Batch rename in 1 button width

	--the elements in this array have to be same with the rdoSwitchModelMode labels.
	aSwitchModelMode = #(#AutoDetectLODName, #DetectBySelection),

	--switch model : Detect by selection
	arrAllModel = #(),
	ModelSelNow	= #(),
	ModelSelBefore = #(),

	--switch model : Detect by LOD Names
	aLODModels = #(),
	nLODCurID = 0,
	aCurLODShowingModel = #(),

	sInfoMessage1 = "SanliCustomTool is a script to manage animation, LOD, Batch rename or export multiple objects to FBX. ",
	sInfoMessage2 = "If you have questions, please contact me. the newer version will always update in the github website. ",

	sSwitchLODHint1 = "Show the current LOD model, and hide the others\n ",
	sSwitchLODHint2 = "The end of the model's name should be like: LOD0, LOD1, LOD2",	
	sSwitchLODHint3 = "1. You can preveiew the Models at Total + Selection statistics:",
	sSwitchLODHint4 = "UpperMenu-->Views/viewport Configuration/Stastistics/Setup",
	sSwitchLODHint5 = "2. press J if you don't want to see the selection brackets.",

	fn fnInitialize = 
	(
		--Switch LOD Model
		arrAllModel 				= #()
		ModelSelNow 				= #()
		ModelSelBefore 				= #()
		aCurLODShowingModel 		= #()
		nLODCurID					= 0
	)
)
g_stOthers = stOthers()

fn fnResetSwitchModelArray = 
(
	g_stOthers.fnInitialize()
)

global g_stPathOrProp
struct stOthersWnd
(
	roInfo,
	roBatchRename,
	roSwitchModel,
	roLODTool,
	roOtherStuff,
	roHeight = 500,

	function Constructor =
	(
		rollout roInfo "Info_V1.005"
		(
			dotNetControl lblInfo "System.Windows.Forms.Label" height:53 width:320 pos:[20,10]--align:#center
			hyperLink lbFB "GitHub" address:"https://github.com/m96v0102/SanliCustomToolIn3dsMax.git" 
									color:(color 200 128 50) visitedColor:(color 200 128 50) pos:[lblInfo.pos.x, lblInfo.pos.y + lblInfo.height + 10]
			hyperLink lblLinkMail 	"email: m96v0102@gmail.com" address:"mailto:m96v0102@gmail.com" 
									color:(color 200 128 50) visitedColor:(color 200 128 50) pos:[200, lbFB.pos.y]
			
			on roInfo open do
			(
				lblInfo.text = g_stOthers.sInfoMessage1 + g_stOthers.sInfoMessage2
				lblInfo.backcolor = lblInfo.backcolor.fromARGB 70 70 70
				lblInfo.forecolor = lblInfo.forecolor.fromARGB 200 200 200
			)
		)

		rollout roBatchRename "BatchRename_V1.001"
		(
			--(Sanli:If you uncomment the line below, the edit text input will be disabled, this is weird to me...)
			--dotNetControl lblInfo 		"System.Windows.Forms.Label" height:200 width:250 align:#center
 			label lbOLdName 	"Original name"			pos:[51, 8]
 			label lbNewName 	"New name"				pos:[250, lbOLdName.pos.y]			
			
			editText edtOldName ""	text:""		    	pos:[4 , lbOLdName.pos.y + 20]				   width:162	--fieldWidth:158 
			editText edtNewName ""	text:""		    	pos:[edtOldName.pos.x + edtOldName.width + 4, edtOldName.pos.y]		width:162
			button btnSaveName	"Save name to the list"	pos:[8 , edtOldName.pos.y + 22]	width:g_stOthers.nBatchRN1BtnWidth	--height:17
													    tooltip:"save the edit text content into the listbox below"

			multilistbox lbxOldName	width: 161 height:8 pos:[btnSaveName.pos.x, btnSaveName.pos.y + 26] items:g_stOthers.aOriginalName

			multilistbox lbxNewName	width: 161 height:8	pos:[lbxOldName.pos.x + lbxOldName.width + 5, lbxOldName.pos.y] items:g_stothers.aNewName

			
			button btnDeleteName "Delete name from the list" 	pos:[lbxOldName.pos.x, lbxOldName.pos.y + lbxOldName.width - 45 ] --height:17
													    		width:g_stOthers.nBatchRN1BtnWidth tooltip:"delete the name from the list"
			
			button btnRenameSelect	"rename selected objects"	pos:[8, btnDeleteName.pos.y + 26 ]	 width: 160	--height:17 
																tooltip:"please select the objects you want to rename, then press the button."
			button btnRenameAll		"rename all objects"		pos:[btnRenameSelect.pos.x + 170, btnRenameSelect.pos.y]	width: 160	--height:17
																tooltip:"this button will select all the 'unhide' objects, and rename it."
			button btnBatchRename	"batch rename all files"	pos:[btnRenameSelect.pos.x, btnRenameAll.pos.y + 26] --height:17 --width: 330 
																width:g_stOthers.nBatchRN1BtnWidth tooltip:"Rename all files in the current folder"
			
			--Rename Object's
			fn fnRenameObj _sOldName _sNewName=
			(
				for x in selection do 
				(
					nNum = findstring x.name _sOldName
					if (nNum != undefined) then
					(
						x.name = replace x.name nNum _sOldName.count _sNewName
					)
				)
			)

			fn fnRenameFormList=
			(
				aSelInOldNameLst = (lbxOldName.selection as array)
				aSelInNewNameLst = (lbxNewName.selection as array)
				if aSelInOldNameLst.count >= 1 then
				(
					for i = 1 to aSelInOldNameLst.count do
					(
						nOldNameLstSelID = aSelInOldNameLst[i]
						nNewNameLstSelID = aSelInNewNameLst[i]
						fnRenameObj lbxOldName.items[nOldNameLstSelID] lbxNewName.items[nNewNameLstSelID]
					)
				)
				else
					messageBox "Please at least select one name from the list above"
			)
			
			on btnSaveName pressed do
			(
				if edtOldName.text != "" and edtNewName.text != "" do
				(
					g_stOthers.aOriginalName = append lbxOldName.items edtOldName.text
					g_stothers.aNewName = append lbxNewName.items edtNewName.text
				)

				lbxOldName.items = g_stOthers.aOriginalName
				lbxNewName.items = g_stothers.aNewName
			)
			
			on lbxOldName selected index do
			(
				lbxNewName.selection = lbxOldName.selection
			)
			
			on lbxNewName selected index do
			(
				lbxOldName.selection = lbxNewName.selection
			)
			
			on btnDeleteName pressed do
			(
				aSelection = (lbxOldName.selection as array)
				if aSelection.count == 1 then
				(
					deleteitem g_stOthers.aOriginalName aSelection[1]
					deleteitem g_stothers.aNewName aSelection[1]

					lbxOldName.items = g_stOthers.aOriginalName
					lbxNewName.items = g_stothers.aNewName
				)
				else
					messageBox "Please Select 'one' name to delete!!"
			)
			
			on btnRenameSelect pressed do
			(
				fnRenameFormList()
			)
			
			on btnRenameAll pressed do
			(
				max select all
				fnRenameFormList()
			)
			
			on btnBatchRename pressed do
			(
				if (lbxOldName.selection as array).count >= 1 then
				(
					aMaxFiles = getFiles ( ( maxfilepath) + "*.max")
					for f = 1 to aMaxFiles.count do 
					(
						loadMaxFile aMaxFiles[f] quiet:true
						max select all
						fnRenameFormList()
						
						saveMaxFile aMaxFiles[f] quiet:true
					)
				)
				else messageBox "Please at least select one name from the list above"


			)
			
		)

		rollout roSwitchModel "SwitchModel_v1.004"
		(
			group "Switch LOD Model"
			(
				label lbSwitchLODModel1 ""
				label lbSwitchLODModel2 ""
			)
			

			--the elements in this array have to be same with the aSwitchModelMode array.
			label lbSwitchModelMode "Switch Model by : " 	align:#left
			radioButtons rdoSwitchModelMode "" 				pos:[lbSwitchModelMode.pos.x + 90, lbSwitchModelMode.pos.y] 
															labels:#("LOD Name Detection", "Selected Model")

			button			btnSwitchPreviousModel	"previous model"	width:100 align:#left --enabled:false--pos:[5, dd_TargetList.pos.y + 50]
			button			btnShowAllModels 		"show all model" 	pos:[btnSwitchPreviousModel.pos.x + 110,	btnSwitchPreviousModel.pos.y] width:100 --enabled:false
			button			btnSwitchNextModel 		"next model" 	 	pos:[btnShowAllModels.pos.x + 110,	btnSwitchPreviousModel.pos.y] 	width:100 --enabled:false
			label			lbSwitchModelName		"Model Name:"	 	--pos:[btnSwitchPreviousModel.pos.x,	btnSwitchPreviousModel.pos.y+30]
			editText		edtSwitchModelName		""					width:320 height:60 --align:#center
																		--pos:[lbSwitchModelName.pos.x + 55, lbSwitchModelName.pos.y]

			group "Other Hint"															
			(
				label lbSwitchLODModel3 ""
				label lbSwitchLODModel4 ""
				label lbSwitchLODModel5 ""
			)
																				
			--Switch LOD model
			fn fnShowNextPrevModel _ModelSelBefore _edtModelname _num=
			(
				local countTmp = 0
				
				local Models = for m in _ModelSelBefore where (m.ishidden == false) collect m
				if(Models.count > 1)then
				(
					for i = 1 to _ModelSelBefore.count do hide _ModelSelBefore[i]
					unhide _ModelSelBefore[1]
					_edtModelname.text = _ModelSelBefore[1].name
				)
				else if (Models.count == 1)then
				(
					for i = 1 to _ModelSelBefore.count do
					(
						if(_ModelSelBefore[i].ishidden == false)do
						(
							countTmp = i
							exit
						)
					)
					
					if(countTmp != 0)do
					(
						hide _ModelSelBefore[countTmp]
						
						if(_num < 0)then
						(
							countTmp = countTmp - 1
							if(countTmp <= 0)do countTmp = _ModelSelBefore.count
						)
						else
						(
							countTmp = countTmp + 1
							if(countTmp > _ModelSelBefore.count)do countTmp = 1
						)
						
						unhide _ModelSelBefore[countTmp]
					)
					_edtModelname.text = _ModelSelBefore[countTmp].name
				)
				
			)

			fn fnPreviewModelByLODDetect _nNum=
			(
				g_stOthers.aLODModels = for m in Geometry where ((findstring m.name "_lod") != undefined) collect m

				--search all LOD01 models in the first time
				if g_stOthers.aCurLODShowingModel.count == 0 then
				(
					--g_stOthers.aCurLODShowingModel = for m in Geometry where (findstring m.name "_lod01") collect m
					for i = 1 to g_stOthers.aLODModels.count do
					(
						nLOD01 = findstring g_stOthers.aLODModels[i].name "_lod0"
						if nLOD01 == undefined then 
							hide g_stOthers.aLODModels[i]
						else
						(
							unhide g_stOthers.aLODModels[i]
							append g_stOthers.aCurLODShowingModel g_stOthers.aLODModels[i]
						)
					)
				)
				else
				(
					--get the last word, that keywords decides wich LOD will be switched next
					sLODKeyword = g_stOthers.aCurLODShowingModel[1].Name[g_stOthers.aCurLODShowingModel[1].Name.count]
					nLODKeyword = sLODKeyword as integer
					nLODNewKeyword = nLODKeyword + _nNum
					if nLODNewKeyword <= -1 then			nLODNewKeyword = 2
					else if nLODNewKeyword >= 3 then		nLODNewKeyword = 0
					sNewLODKeyword = (nLODNewKeyword as string)
										
					--change the last word in the whole LOD Name
					aNewLODModels = #()
					for i = 1 to g_stOthers.aCurLODShowingModel.count do
					(
						sNewLODName = replace g_stOthers.aCurLODShowingModel[i].Name g_stOthers.aCurLODShowingModel[i].Name.count 1 sNewLODKeyword
						mdNewLOD = getNodeByName sNewLODName
						if mdNewLOD != undefined then
							append aNewLODModels mdNewLOD
						else
						(
							--if the LOD number is less than 2 (means it's only have LOD0 and LOD1),
							--then change the number.
							--detect what button that the user pressed(show next model or show previous model)							
							if _nNum > 0 then nLODNewKeyword = 0
							else nLODNewKeyword = nLODNewKeyword - 1
							sNewLODKeyword = (nLODNewKeyword as string)

							-- Get the current LODModel again
							sNewLODName = replace g_stOthers.aCurLODShowingModel[i].Name g_stOthers.aCurLODShowingModel[i].Name.count 1 sNewLODKeyword
							mdNewLOD = getNodeByName sNewLODName
							if mdNewLOD != undefined then
								append aNewLODModels mdNewLOD

						)							
					)
					if aNewLODModels.count > 0 do g_stOthers.aCurLODShowingModel = deepCopy aNewLODModels

					--hide and unhide the models
					for i = 1 to g_stOthers.aLODModels.count do
					(
						sNewLODName = g_stOthers.aLODModels[i].name
						bFound = findItem g_stOthers.aCurLODShowingModel g_stOthers.aLODModels[i]
						if bFound == 0 then hide g_stOthers.aLODModels[i]
						else unhide g_stOthers.aLODModels[i]
					)

					--select the models, so the statics will show the selection PolyCounts�BMeshCounts or Vertcounts
					select g_stOthers.aCurLODShowingModel
				)

				sMessage = ""
				if g_stOthers.aCurLODShowingModel.count > 0 do
				(
					for i = 1 to g_stOthers.aCurLODShowingModel.count do
						sMessage += (g_stOthers.aCurLODShowingModel[i].name + "\n")
				)
				edtSwitchModelName.text = sMessage

			)

			fn fnPreviewSelectedModel _edtModelname _num=
			(
				g_stOthers.ModelSelNow = for m in selection where (m.ishidden == false) collect m
				if g_stOthers.ModelSelNow.count >= 1 do
				(
					g_stOthers.ModelSelBefore = g_stOthers.ModelSelNow
					clearselection()
				)
				
				fnShowNextPrevModel g_stOthers.ModelSelBefore _edtModelname _num
			)

			on roSwitchModel open do
			(
				lbSwitchLODModel1.text = g_stOthers.sSwitchLODHint1
				lbSwitchLODModel2.text = g_stOthers.sSwitchLODHint2
				lbSwitchLODModel3.text = g_stOthers.sSwitchLODHint3
				lbSwitchLODModel4.text = g_stOthers.sSwitchLODHint4
				lbSwitchLODModel5.text = g_stOthers.sSwitchLODHint5
			)

			on roSwitchModel pressed do
			(
				g_stOthers.fnInitialize()
			)

			on btnSwitchPreviousModel pressed do	
			(
				enumSwitchModelMode = g_stOthers.aSwitchModelMode[rdoSwitchModelMode.state]
				case enumSwitchModelMode of
				(
					#AutoDetectLODName:
					(
						fnPreviewModelByLODDetect -1
					)
					#DetectBySelection:
					(
						if(g_stOthers.arrAllModel.count > 0) then	fnShowNextPrevModel g_stOthers.arrAllModel edtSwitchModelName 1
						else										fnPreviewSelectedModel 	edtSwitchModelName 	1
					)
				)				
			)

			on btnSwitchNextModel pressed do	
			(
				enumSwitchModelMode = g_stOthers.aSwitchModelMode[rdoSwitchModelMode.state]
				case enumSwitchModelMode of
				(
					#AutoDetectLODName:
					(
						fnPreviewModelByLODDetect 1
					)
					#DetectBySelection:
					(
						if(g_stOthers.arrAllModel.count > 0) then	fnShowNextPrevModel g_stOthers.arrAllModel edtSwitchModelName -1
						else										fnPreviewSelectedModel 	edtSwitchModelName 	-1
					)
				)
				
			)		
			
			on btnShowAllModels pressed do
			(
				enumSwitchModelMode = g_stOthers.aSwitchModelMode[rdoSwitchModelMode.state]
				case enumSwitchModelMode of
				(
					#AutoDetectLODName:
					(
						g_stOthers.aLODModels = for m in Geometry where ((findstring m.name "_lod") != undefined) collect m
						unhide g_stOthers.aLODModels

						sMessage = ""
						if g_stOthers.aLODModels.count > 0 do
						(
							for i = 1 to g_stOthers.aLODModels.count do
								sMessage += (g_stOthers.aLODModels[i].name + "\n")
						)
						edtSwitchModelName.text = sMessage
					)
					#DetectBySelection:
					(
						local arrShowAllModel = #()
						if(g_stOthers.arrAllModel.count > 0) then			arrShowAllModel = g_stOthers.arrAllModel	--�ҫ��w��
						else if(g_stOthers.ModelSelBefore.count > 0)then	arrShowAllModel = g_stOthers.ModelSelBefore	--�ҫ��ˬd
						
						if(arrShowAllModel.count > 0)do
						(
							for i = 1 to arrShowAllModel.count do	unhide arrShowAllModel[i]
							clearselection()
						)						
					)
				)
			)
		)

		rollout roOtherStuff "Others_v1.001"
		(
			button 		btnCreateToolBar "Create/Delete tool bar" 	width:320	--enabled:false

			on btnCreateToolBar pressed do
			(
				--copy all of the scripts to the HardDrive C
				sCurrentScriptFile = getThisScriptFilename()
				sCurrentScriptPath = getFilenamePath sCurrentScriptFile
				sParentPath = pathConfig.removePathLeaf sCurrentScriptPath --the last word doesn't have '\'
				
				--if the sParentPath is same with the sDestFolder, then change the sDestFolder (or it will occur an error)
				sDestFolder = @"C:\SanliCustomTool\MaxScript1" --the last word is '\'
				if sParentPath == @"C:\SanliCustomTool\MaxScript1" then
				(
					sDestFolder = @"C:\SanliCustomTool\MaxScript2" --the last word is '\'
				)
				sMainRolloutDestFile = sDestFolder + "\\MainRollout.ms"

				sMainRolloutSrcFile = sParentPath + "\\MainRollout.ms"
				aScriptInSrcFileIn = getFiles (sParentPath + "\\FileIn\\*.ms")

				aScriptInDestFileIn = #()
				for i = 1 to aScriptInSrcFileIn.count do
				(
					sFileNameWithoutExt = getfilenameFile aScriptInSrcFileIn[i]
					sDestInFileIn = sDestFolder + "\\FileIn\\" + sFileNameWithoutExt + ".ms"
					append aScriptInDestFileIn sDestInFileIn
				)

				makeDir (sDestFolder + "\\FileIn")
				copyFile sMainRolloutSrcFile sMainRolloutDestFile
				for i = 1 to aScriptInDestFileIn.count do
				(
					DeleteFile aScriptInDestFileIn[i]
					copyFile aScriptInSrcFileIn[i] aScriptInDestFileIn[i]
				)

				--if the file in the startup folder is already exist, then delete the file
				sStartupFolder = getDir #startupScripts
				sSanliCustomToolBarFileInStartupFolder = sStartupFolder + "\\FileIn\\SanliCustomToolBar.ms"
				sSanliCustomToolBarFileInDriveC = sDestFolder + "\\FileIn\\SanliCustomToolBar.ms"
				if doesFileExist sSanliCustomToolBarFileInStartupFolder then
				(
					FileIn sSanliCustomToolBarFileInDriveC
					fileClass = dotNetClass "System.IO.Directory"
					fileClass.Delete (sStartupFolder + "\\FileIn") true	--delete the folder, including the files

					--deleteFile sSanliCustomToolBarFileInStartupFolder
					--FileIn sSanliCustomToolBarFileInDriveC
				)
				else
				(
					makeDir (sStartupFolder + "\\FileIn")
					print sSanliCustomToolBarFileInStartupFolder
					copyFile sSanliCustomToolBarFileInDriveC sSanliCustomToolBarFileInStartupFolder

					-- if the OS is win10, it might block the copy, so run the script in Drive C just in case.
					if doesFileExist sSanliCustomToolBarFileInStartupFolder then
						FileIn sSanliCustomToolBarFileInStartupFolder
					else
						FileIn sSanliCustomToolBarFileInDriveC

				)

			)
		)

		return true
	),

	init = Constructor()


)


--call 'ResetSwitchModelArray' function when other maxfile open.
callbacks.addscript #systemPreReset "fnResetSwitchModelArray()" id:#SanliCustomTools
callbacks.addscript #filePreOpen 	"fnResetSwitchModelArray()" id:#SanliCustomTools
callbacks.addscript #systemPreNew 	"fnResetSwitchModelArray()" id:#SanliCustomTools
