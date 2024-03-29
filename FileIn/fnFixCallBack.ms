--Clean up some dangerous data.
--The most dangerous data is the callbacks, you can use callbacks.show() to check in the editor log.

--Filein the SecurityToolsDialogs(We might get this file from gitHub, so we will detect this file under the STDScript folder)
--if SecurityToolsDialogs_instance == undefined then
(
	local myPath = pathconfig.removePathLeaf (getThisScriptFilename())
	global sCurrDirPath = myPath
	filein (pathconfig.appendPath sCurrDirPath @"STDScript\SecurityToolsDialogs.ms")
)

struct o_stFixCallBack
(
	bFinishProcess = false,	--After we pressed "Leave corruption" from danger local file warning dialog, this variable will prevent m_CleanAndSave_ro or m_CleanWithoutSaving_ro showing up
	sStartupScript = "",
	aDirtyGlobalVars = #(#ThePropParameterNodes, #CRP_AScript, #CRP_BScript, #ADSL_AScript, #ADSL_BScript, #PhysXPluginMfx, #PhysXPluginGup),
	sLocalTempFile = sysInfo.tempdir +"Local_temp.ms",
	sMaxRoot = getdir #maxroot,
	sDangerMscpropDll = sMaxRoot + "mscprop.dll",
	sDangerPropPrmLcMSE = sMaxRoot + "stdplugs\\PropertyParametersLocal.mse",

	fn fnCheckBuiltInSecurityToolEnable =
	(
		sMaxINIFile = getMAXIniFile()
		sBuiltInSecurityEnable = getINISetting sMaxINIFile "SecurityTools" "LoadSecurityTools"
		if sBuiltInSecurityEnable == "1" then
		(
			return true
		)

		--If sBuiltInSecurityEnable is "0" or empty string(Means there is no SecurityTools in this 3dsMax), then return false.
		else return false
	),

	--Remove callbacks and relevant properties which associated with MSCPROP
	fn fnRemoveMscpropCbkNProp =
	(
		local ndGetDangerData = undefined
		try(ndGetDangerData = TrackViewNodes.TVProperty)catch()

		if globalVars.isglobal #ThePropParameterNodes == true or ndGetDangerData != undefined do
		(
			callbacks.removeScripts id:#PropertyParameters

			--Delete customattributes - TrackViewNodes.TVProperty
			aCustAttr = custAttributes.getSceneDefs() as array
			for i = 1 to aCustAttr.count do
			(
				if aCustAttr[i].name == #TVProperty do
				(	
					--Remove connection from the TrackViewNodes first.
					custAttributes.delete TrackViewNodes aCustAttr[i]
					
					--Delete custom attribute.
					try(custAttributes.deleteDef aCustAttr[i])catch()
					
					--Sometimes there were 2 #TVProperty in the array, so I comment out the exit line.
					--exit
				)
			)
		)
		
	),

	fn fnRemoveDirtyVariables =
	(
		for var in aDirtyGlobalVars do 
		(
			if (persistents.isPersistent var) do
				persistents.remove var
			globalVars.remove var
		)	
	),

	--Check and remove callbacks and relevant properties which associated with MSCPROP
	fn fnCheckNRemoveMscpropCbkNProp _sFile=
	(
		local bMaxOpening = true
		fnRemoveMscpropCbkNProp()	--this function must run before we remove dirty Variables, otherwise the callbacks won't remove.
		
		if (persistents.isPersistent #ThePropParameterNodes) do
			persistents.remove #ThePropParameterNodes
		globalVars.remove #ThePropParameterNodes

		if _sFile != sLocalTempFile and (doesFileExist _sFile) == true then
		(
			sDelResult = deleteFile _sFile
			if sDelResult == false do
			(
				SecurityToolsDialogs_instance.display_PleaseDelByAdmin_dialog #(_sFile)
			)
		)
		else if _sFile == sLocalTempFile and (doesFileExist sLocalTempFile) == true do
		(
			sDelResult = deleteFile sLocalTempFile
			if sDelResult == false do
			(
				bMaxOpening = SecurityToolsDialogs_instance.display_DeleteFileIssue_dialog #(sLocalTempFile)
			)
		)
		return bMaxOpening
	),
	
	--Remove CRP callbacks
	fn fnRemoveCRPCallBacks = 
	(
		callbacks.removeScripts id:#ID_CRP_viewportChangeP
		callbacks.removeScripts id:#ID_CRP_filePostOpen
		callbacks.removeScripts id:#ID_CRP_filePostOpenP
		callbacks.removeScripts id:#ID_CRP_filePostMerge
		callbacks.removeScripts id:#ID_CRP_preRenderP
		callbacks.removeScripts id:#ID_CRP_postImport
	),

	--Remove ADSL callbacks
	fn fnRemoveADSLCallBacks = 
	(
		callbacks.removeScripts id:#ID_ADSL_viewportChangeP
		callbacks.removeScripts id:#ID_ADSL_filePostOpen
		callbacks.removeScripts id:#ID_ADSL_filePostOpenP
		callbacks.removeScripts id:#ID_ADSL_filePostMerge
		callbacks.removeScripts id:#ID_ADSL_preRenderP
		callbacks.removeScripts id:#ID_ADSL_postImport
	),
	
	-- function to count PhysXPluginMfx2 Anim Tracks instances
	fn fnPhysXPluginMfx2_count_instances = 
	(
		local count = 0
		if (isProperty TrackViewNodes #AnimLayerControlManager) do
		(
			local cac = TrackViewNodes.AnimLayerControlManager.custattributes
			local alcm_cas = for ca in cac collect ca
			for ca in alcm_cas where (local cid = ca.classid; cid[1] == 0x511b21e8 and cid[2] == 0x30b189f) do
			(
				count += 1
			)
		)
		count -- return value
	),
	
	-- function to see if have PhysXPluginMfx2 Anim Tracks source with original source
	fn fnPhysXPluginMfx2_find_def = 
	(
		local found = false
		for ca_def in AttributeDef.classes where (local cid = ca_Def.classid; cid[1] == 0x511b21e8 and cid[2] == 0x30b189f) do
		(
			if (findString ca_def.source "do(try(execute ParamName)catch())") != undefined do
			(
				found = true
			)
			exit;
		)
		found -- return value
	),
	
	fn fnCheckPhysPlug=
	(
		local m_problem_found_count = 0
		local num_PhysXPluginMfx2_instance = fnPhysXPluginMfx2_count_instances()
		local found_PhysXPluginMfx2_def = fnPhysXPluginMfx2_find_def()
		local process_corruption_found = (num_PhysXPluginMfx2_instance != 0) or found_PhysXPluginMfx2_def
		m_problem_found_count += (num_PhysXPluginMfx2_instance + (if found_PhysXPluginMfx2_def then 1 else 0))
		return m_problem_found_count
	),
	
	-- function to remove PhysXPluginMfx2 Anim Tracks instances
	-- Called from test_for_PhysXPluginMfx2_process_corruption, dialogs displayed from there
	fn fnPhysXPluginMfx2_clean_instances = 
	(
		local numCleaned = 0
		if (isProperty TrackViewNodes #AnimLayerControlManager) do
		(
			local cac = TrackViewNodes.AnimLayerControlManager.custattributes
			local alcm_cas = for ca in cac collect ca
			for ca in alcm_cas where (local cid = ca.classid; cid[1] == 0x511b21e8 and cid[2] == 0x30b189f) do
			(
				deleteitem cac (finditem cac ca)
				numCleaned += 1
				--m_problem_fixed_count += 1
			)
		)
	),
	
	-- function to test PhysXPluginMfx2 Anim Tracks source to see if original source, and if so tweak the source to cause instances to be deleted
	fn fnPhysXPluginMfx2_clean_defs = 
	(
		local numCleaned = 0
		for ca_def in AttributeDef.classes where (local cid = ca_Def.classid; cid[1] == 0x511b21e8 and cid[2] == 0x30b189f) do
		(
			if (findString ca_def.source "do(try(execute ParamName)catch())") != undefined do
			(
				custattributes.redefine ca_def "attributes 'Anim Tracks' attribID:#(0x511b21e8, 0x30b189f) silentErrors:true (on load do if ::PhysXPluginMfx2_SecurityTool != undefined do PhysXPluginMfx2_SecurityTool.PhysXPluginMfx2_clean_instance this)"
				numCleaned += 1
				--m_problem_fixed_count += 1
			)
			exit;
		)
	),

	--fnReviseStartupScript sStartupScript "CRP_"
	--fnReviseStartupScript sStartupScript "ADSL_"
	fn fnReviseStartupScript _sStartupScript _sVirusKeyWord=
	(
		--read the whole content in the virus ms file, and save it to the sContent
		--The last line will get eof(end of file)
		--http://forums.cgsociety.org/archive/index.php?t-69988.html
		posFile = openFile _sStartupScript
		if posFile == undefined do
		(
			SecurityToolsDialogs_instance.display_PleaseDelByAdmin_dialog #(_sStartupScript)
			return 0
		)

		sContent = ""
		while not eof posFile do
		(
			nNum = filePos posFile
			--format "Sanlilog_filePos % \n" nNum
			new_line = readLine posFile

			--seek posFile 0
			if (findstring new_line _sVirusKeyWord) == undefined then
			(
				--the first line don't need to add "\n"
				if nNum == 0 then
					sContent += new_line
				else 
					sContent += ("\n" + new_line)
			)
			else
			(
				format "the last word: % \n" sContent[sContent.count]
				exit
			)
		)
		close posFile

		try fileMyoutputstream  = openfile _sStartupScript mode:"wt"	-- try to open with write access
		catch()
		if fileMyoutputstream == undefined do
		(
			messagebox "Unable to rewrite the file!!"
		)

		try(format "%" sContent to:fileMyoutputstream)catch()
	),

	--Remove all of the dangerous data, include the startup file.
	--This function was called when the callback was detected in the startup file.
	fn fnRemoveAllDangerousData=
	(
		fnReviseStartupScript sStartupScript "CRP_"
		fnReviseStartupScript sStartupScript "ADSL_"
		fnRemoveMscpropCbkNProp()
		fnRemoveCRPCallBacks()
		fnRemoveADSLCallBacks()
		fnRemoveDirtyVariables()
		fnPhysXPluginMfx2_clean_instances()
		fnPhysXPluginMfx2_clean_defs()
	),

	--Remove all of the dangerous data, except the startup file.
	fn fnRemoveDangDataWOStartup=
	(
		fnRemoveMscpropCbkNProp()
		fnRemoveCRPCallBacks()
		fnRemoveADSLCallBacks()
		fnRemoveDirtyVariables()
		fnPhysXPluginMfx2_clean_instances()
		fnPhysXPluginMfx2_clean_defs()
	),

	--Get the 1st startup file.
	fn fnGetStartupFile =
	(
		sStartScriptsDir = (getDir #startupScripts)
		aStartScripts = getFiles (sStartScriptsDir + "\\*.ms")
		sStartupScript = aStartScripts[1]
		return sStartupScript
	),

	--Print all message from callbacks.show() and save it into the harddrive(ref:http://forums.cgsociety.org/archive/index.php?t-621261.html)
	fn fnSaveCallbacksToHDD _sCallBackLog=
	(
		closeLog() -- close the listener log file, if any
		openLog _sCallBackLog mode:"w" outputOnly:true -- log listener output
		callbacks.show() -- get all the callbacks. This output will now be in "c:\\listener.log" as well
		flushLog() -- flush the log
		closeLog() -- close the log
	),

	--Check the startup file contains some dangerous string - CRP
	--It's safe if the returned value was undefined, otherwise this startup file might probably bring the virus.
	fn fnCheckCRPContent _sFile=
	(
		if _sFile != undefined do
		(
			startupfileHandle = openfile _sFile
			
			--Check the CRP string(return the relevant string if we get "CRP_", otherwise we will get undefined)
			local result = skipToString startupfileHandle "CRP_" --"CRP_WriteBScript"

			--If we get the callback is from Autodesk built-in CRP_SecurityTool, ignore it.
			if result != undefined then
			(
				sChar = undefined
				sSecurityTool = "SecurityTool"
				try(sChar = readChars startupfileHandle sSecurityTool.count)catch()

				if sChar == "SecurityTool" then
					result = undefined
			)

			close startupfileHandle

			if result != undefined then result = "CRP callback"
			return result
		)
	),

	--Check the startup file contains some dangerous string - ADSL
	--It's safe if the returned value was undefined, otherwise this startup file might probably bring the virus.
	fn fnCheckADSLContent _sFile=
	(
		if _sFile != undefined do
		(
			startupfileHandle = openfile _sFile
			
			--Check the CRP string(return true if we get "ADSL_", otherwise we will get undefined)
			local result = skipToString startupfileHandle "ADSL_"

			--If we get the callback is from Autodesk built-in ADSL_SecurityTool, ignore it.
			if result != undefined then
			(
				sChar = undefined
				sSecurityTool = "SecurityTool"
				try(sChar = readChars startupfileHandle sSecurityTool.count)catch()

				if sChar == "SecurityTool" then
					result = undefined
			)

			close startupfileHandle

			if result != undefined then result = "ADSL callback"
			return result
		)
	),

	--This function was used in old version, we don't need it for now, but I keep it just in case. 
	--EX: local result = fnCheckMaxCallbackScript()
	fn fnCheckMaxCallbackScript=
	(
		sCallBackLog = "C:\\SanliCustomTool\\MaxScriptCallback_Sanli.log" 
		if (getfiles sCallBackLog).count == 0 then
			makeDir "C:\\SanliCustomTool\\"

		--sCallBackLog =  "d:\\MaxScriptCallback_Sanli.log"
		fnSaveCallbacksToHDD sCallBackLog
		local result = fnCheckCRPContent sCallBackLog
		if result == undefined then
			result = fnCheckADSLContent sCallBackLog

		return result
	),

	fn fnOpenStartupFile =
	(
		sStartupScript = fnGetStartupFile()
		local result = fnCheckCRPContent sStartupScript
		if result == undefined then
			result = fnCheckADSLContent sStartupScript
		return result
	),

	--EX:local bDirtyGlobalVarFound = fnCheckDirtyGlobalVariables()
	fn fnCheckDirtyGlobalVariables=
	(
		--bCRPGlobalFound = bADSLGlobalFound = false
		bDirtyGlobalFound = false
		local varDirtyGlobalVar = undefined
		for var in aDirtyGlobalVars do
		(
			bDirtyGlobalFound = globalVars.isGlobal var
			if bDirtyGlobalFound == true do
			(
				varDirtyGlobalVar = var
				exit
			)
		)

		return varDirtyGlobalVar
	),

	-- This function will propably shut down the max(To delete the localtemp file), so we should run this first,
	--      otherwise this will cause a file damage while the max was shutting down when he was saving the max file.
	--      We also should return true of false to let the rest of the code known the process should be continue or not.
	fn fnCheckDangerLocalFileAndDetectMaxShouldOpening =
	(
		bMaxOpening = true
		bDangerMscpropDllExist = doesFileExist sDangerMscpropDll
		bDangerPropPrmLcMSE = doesFileExist sDangerPropPrmLcMSE
		bLocalTempFile = doesFileExist sLocalTempFile
		if bDangerMscpropDllExist == true then
			SecurityToolsDialogs_instance.display_DangerLocalFile_dialog #(sDangerMscpropDll)
		if bDangerPropPrmLcMSE == true then
			SecurityToolsDialogs_instance.display_DangerLocalFile_dialog #(sDangerPropPrmLcMSE)
		if bLocalTempFile == true then
			bMaxOpening = SecurityToolsDialogs_instance.display_DangerLocalFile_dialog #(sLocalTempFile)

		-- If one of the dangerous file was exist before, remind the user to save the file.
		-- But if the user press btnLeave without cleaning any dangerous data, don't show this display_CleanWithoutSave_dialog.
		if bMaxOpening == true and bFinishProcess == true and (bDangerMscpropDllExist == true or bDangerPropPrmLcMSE == true or bLocalTempFile == true) do
			SecurityToolsDialogs_instance.display_CleanWithoutSave_dialog()

		return bMaxOpening
	),

	--This function will be called when the tools open.
	--At the beginning, this function doesn't support scene saving until I do some test and ensure there's no issue while we save the reset scene.
	fn fnCheckAndFixStartupFile =
	(
		if fnCheckBuiltInSecurityToolEnable() == true do return 0
		if fnCheckDangerLocalFileAndDetectMaxShouldOpening() == false do return 0

		local result = fnOpenStartupFile()
		
		--Show the error message if we get the virus string.
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			SecurityToolsDialogs_instance.display_VirusFound_dialog sStartupScriptName
		)
		
		--Check some dirty global variables
		local varDirtyGlobalVar = fnCheckDirtyGlobalVariables()
		if varDirtyGlobalVar != undefined do
		(
			sDirtyGlobalVar = "Dirty variables_" + (varDirtyGlobalVar as string)
			SecurityToolsDialogs_instance.display_DangerDataFound_dialog sDirtyGlobalVar
		)

		--Check MSCPROP was hide in the TrackViewNodes
		local ndGetDangerData = undefined
		try(ndGetDangerData = TrackViewNodes.TVProperty)catch()
		if ndGetDangerData != undefined do
		(
			sDirtyGlobalVar = "Dirty datas_" + (ndGetDangerData as string)
			SecurityToolsDialogs_instance.display_DangerDataFound_dialog sDirtyGlobalVar
		)

		--Check the dagerous data 'PhysXPluginMfx2' was exist
		local nPhysPlugProblem = fnCheckPhysPlug()
		if nPhysPlugProblem != 0 then
		(
			SecurityToolsDialogs_instance.display_DangerDataFound_dialog "PhysXPluginMfx2"
		)
			
	),

	--This function will be called when we load the file by tools.
	fn fnCheckFixStartupFileAndScene = 
	(
		if fnCheckBuiltInSecurityToolEnable() == true do return 0
		if fnCheckDangerLocalFileAndDetectMaxShouldOpening() == false do return 0

		local result = fnOpenStartupFile()
		
		--Show the error message if we get the virus string.
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			SecurityToolsDialogs_instance.display_VirusFound_dialog sStartupScriptName
		)
		
		--Check some dirty global variables
		local varDirtyGlobalVar = fnCheckDirtyGlobalVariables()
		if varDirtyGlobalVar != undefined do
		(
			sDirtyGlobalVar = "Dirty variables_" + (varDirtyGlobalVar as string)
			SecurityToolsDialogs_instance.display_DangerDataFound_dialog sDirtyGlobalVar
		)

		--Check MSCPROP was hide in the TrackViewNodes
		local ndGetDangerData = undefined
		try(ndGetDangerData = TrackViewNodes.TVProperty)catch()
		if ndGetDangerData != undefined do
		(
			sDirtyGlobalVar = "Dirty datas_" + (ndGetDangerData as string)
			SecurityToolsDialogs_instance.display_DangerDataFound_dialog sDirtyGlobalVar
		)

		--Check the dagerous data 'PhysXPluginMfx2' was exist
		local nPhysPlugProblem = fnCheckPhysPlug()
		if nPhysPlugProblem != 0 then
		(
			SecurityToolsDialogs_instance.display_DangerDataFound_dialog "PhysXPluginMfx2"
		)

	),

	--Clean all of the dangerous data.
	fn fnRevertFileAndCallBack =
	(
		if fnCheckBuiltInSecurityToolEnable() == true do
		(
			Messagebox "Detect the 3dsMax Security tool was enabled, so this function won't be activated!!"
			return 0
		)
		fnRemoveMscpropCbkNProp()
		fnRemoveCRPCallBacks()
		fnRemoveADSLCallBacks()
		fnRemoveDirtyVariables()
		fnPhysXPluginMfx2_clean_instances()
		fnPhysXPluginMfx2_clean_defs()
		
		sStartupScript = fnGetStartupFile()
		if sStartupScript == undefined do
			return 0				

		--Clean the startup file if we get the virus string.
		local result = fnOpenStartupFile()
		if result != undefined then
		(
			fnReviseStartupScript sStartupScript "CRP_"
			fnReviseStartupScript sStartupScript "ADSL_"
		)

		if fnCheckDangerLocalFileAndDetectMaxShouldOpening() == false do return 0
		
		SecurityToolsDialogs_instance.display_CleanWithoutSave_dialog()
	)
)




