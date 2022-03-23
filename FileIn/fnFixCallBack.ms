--Clean up some dangerous data.
--The most dangerous data is the callbacks, you can use callbacks.show() to check in the editor log.

--Detect max version and get the relative path.
global g_sMaxVerPath
if g_sMaxVerPath == undefined do (fileIn @"D:\ADoc\MaxScript\_Function\fnGetMScriptInitPathByMaxVer.ms")

--if SecurityToolsDialogs_instance == undefined then
(
	fileIn  (g_sMaxVerPath + @"_Common\SanliCustomTool\FromGitHub\FileIn\STDScript\SecurityToolsDialogs.ms")
)

struct o_stFixCallBack
(
	sStartupScript = "",
	aDirtyGlobalVars = #(#CRP_AScript, #CRP_BScript, #ADSL_AScript, #ADSL_BScript, #PhysXPluginMfx, #PhysXPluginGup),
	
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

	--刪除檔案裡不乾淨的ADSL callback
	fn fnRemoveADSLCallBacks = 
	(
		callbacks.removeScripts id:#ID_ADSL_viewportChangeP
		callbacks.removeScripts id:#ID_ADSL_filePostOpen
		callbacks.removeScripts id:#ID_ADSL_filePostOpenP
		callbacks.removeScripts id:#ID_ADSL_filePostMerge
		callbacks.removeScripts id:#ID_ADSL_preRenderP
		callbacks.removeScripts id:#ID_ADSL_postImport
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

	--Remove all of the dangerous data, include the startup file.
	fn fnRemoveAllDangerousData=
	(
		fnReviseCRPStartupScript sStartupScript
		fnReviseADSLStartupScript sStartupScript
		fnRemoveCRPCallBacks()
		fnRemoveADSLCallBacks()
		fnRemoveDirtyVariables()
		fnPhysXPluginMfx2_clean_instances()
		fnPhysXPluginMfx2_clean_defs()
	),

	--Remove all of the dangerous data, except the startup file.
	fn fnRemoveDangDataWOStartup=
	(
		fnRemoveCRPCallBacks()
		fnRemoveADSLCallBacks()
		fnRemoveDirtyVariables()
		fnPhysXPluginMfx2_clean_instances()
		fnPhysXPluginMfx2_clean_defs()
	),

	--先確認startup資料的日期，載入max檔後再確認有無被改寫
	fn fnGetStartupFile =
	(
		sStartScriptsDir = (getDir #startupScripts)
		aStartScripts = getFiles (sStartScriptsDir + "\\*.ms")
		sStartupScript = aStartScripts[1]
		return sStartupScript
	),

	--將callbacks.show()印成記事本，並存在硬碟裡(相關網址：http://forums.cgsociety.org/archive/index.php?t-621261.html)
	--D:\ADoc\MaxScript\_Project\pj_pkm\o_roIndexTools.ms\fnInitialize()也有類似的code
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
			
			--檢查有沒有CPR_這個可疑字串(若搜尋到CRP_、result就會得到true，反之取得undefined)
			local result = skipToString startupfileHandle "CRP_" --"CRP_WriteBScript"

			--如果偵測到的是原廠寫的防毒callback(CRP_SecurityTool)，就避掉
			if result != undefined then
			(
				sChar = undefined
				sSecurityTool = "SecurityTool"
				try(sChar = readChars startupfileHandle sSecurityTool.count)catch()

				format "Sanlilog_Char: % \n" sChar
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
			
			--檢查有沒有CPR_這個可疑字串(若搜尋到CRP_、result就會得到true，反之取得undefined)
			local result = skipToString startupfileHandle "ADSL_"

			--如果偵測到的是原廠寫的防毒callback(CRP_SecurityTool)，就避掉
			if result != undefined then
			(
				sChar = undefined
				sSecurityTool = "SecurityTool"
				try(sChar = readChars startupfileHandle sSecurityTool.count)catch()

				format "Sanlilog_Char: % \n" sChar
				if sChar == "SecurityTool" then
					result = undefined
			)

			close startupfileHandle

			if result != undefined then result = "ADSL callback"
			return result
		)
	),

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
	
	--開啟Startup資料夾裡的檔案
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
	
	--顯示常駐程式處理後的訊息
	fn fnGetMessage _sStartupScript _bSaveMax=
	(
		sClearCallBackMSG = "1. Virus delete completed。\n"
		sMessage = sClearCallBackMSG + "2. The path : " + _sStartupScript + " was repaired"
		if _bSaveMax == true do
			sMessage = sMessage + "\n3. The Virus in the MaxFile has been deleted."
		return sMessage
	),

	--revise the virus script in the startup folder
	--EX：fnReviseCRPStartupScript sStartupScript
	fn fnReviseCRPStartupScript _sStartupScript=
	(
		--read the whole content in the virus ms file line by line, and save it to the sContent
		--The last line will get eof(end of file)
		--http://forums.cgsociety.org/archive/index.php?t-69988.html
		posFile = openFile _sStartupScript
		sContent = ""
		while not eof posFile do
		(
			nNum = filePos posFile
			--format "Sanlilog_filePos % \n" nNum
			new_line = readLine posFile

			--seek posFile 0
			--if (findstring new_line "CRP_") != undefined do exit
			if (findstring new_line "CRP_") == undefined then
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

		nMyoutputstream  = openfile _sStartupScript mode:"w"

		format "%" sContent to:nMyoutputstream
		--flushLog() -- flush the log
		--closeLog() -- close the log
	),

	fn fnReviseADSLStartupScript _sStartupScript=
	(
		--read the whole content in the virus ms file, and save it to the sContent
		--逐行讀取(最後一行是eof)
		--http://forums.cgsociety.org/archive/index.php?t-69988.html
		posFile = openFile _sStartupScript
		sContent = ""
		while not eof posFile do
		(
			nNum = filePos posFile
			--format "Sanlilog_filePos % \n" nNum
			new_line = readLine posFile

			--seek posFile 0
			if (findstring new_line "ADSL_") == undefined then
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

		nMyoutputstream  = openfile _sStartupScript mode:"w"

		format "%" sContent to:nMyoutputstream
		--flushLog() -- flush the log
		--closeLog() -- close the log
	),

	--打開並檢查Startup資料夾裡的檔案有無問題，若有問題就嘗試修復(通常專案工具一打開就會呼叫這個函式)
	fn fnCheckAndFixStartupFile =
	(
		local result = fnOpenStartupFile()
		
		--發現可疑字串，準備處理
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			--yesNoCancelBox <message_string> [title:<window_title_string>] [beep:<boolean>] 
			sMessage = "Startup\\" + sStartupScriptName + "Has detected the virus: \n"
			sResultYes = "yes = Clean the virus and autosave the maxfile\n"
			sResultCancel = "No or Cancel = Don't do anything\n"
			sMessage  = sMessage + sResultYes + sResultCancel
			result = yesNoCancelBox sMessage title:"Virus detected"	-- [beep:<boolean>] 
			
			if result == #yes then
			(
				fnReviseCRPStartupScript sStartupScript
				fnReviseADSLStartupScript sStartupScript
				fnRemoveCRPCallBacks()
				fnRemoveADSLCallBacks()

				savemaxfile (maxfilepath + maxfilename) quiet:true
				sMessage = fnGetMessage sStartupScript true	--最後的true代表函式裡的第三段字串也顯示			
			)
			else
				sMessage = "Cancel the Virus repair."	--修復常駐程式的作業取消
			messagebox sMessage
		)
		
		--Check callbacks and global variables from the maxfile.
		local result = fnCheckMaxCallbackScript()
		if result != undefined then
		(
			messagebox "Max virus detected, \nPlease visit the Check or delete undoMax subrollout."
			--messagebox "偵測到max檔有病毒，請執行【刪除潛伏病毒】後，再存檔"
		)
		else	--Check some dirty global variables
		(
			local varDirtyGlobalVar = fnCheckDirtyGlobalVariables()
			if varDirtyGlobalVar != undefined do
			(
				sMessage = "Dirty variables (" + (varDirtyGlobalVar as string) + ") detected, \nPlease visit the Check or delete undoMax subrollout."
				messagebox sMessage
			)
		)

		--Check the dagerous data 'PhysXPluginMfx2' was exist
		local nPhysPlugProblem = fnCheckPhysPlug()
		if nPhysPlugProblem != 0 then
		(
			messagebox "Dangerous data (PhysXPluginMfx2) detected, \nPlease visit the Check or delete undoMax subrollout."
		)
	),

	--打開並檢查Startup資料夾裡的檔案有無問題，若有問題就嘗試修復Startup檔和max檔
	fn fnCheckFixStartupFileAndScene = 
	(
		local result = fnOpenStartupFile()
		
		--發現可疑字串，準備處理
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			sMessage = "Startup\\" + sStartupScriptName + " Has detected the virus: \n"
			sResultYes = "yes = Clean the virus and save the file \n"
			sResultNo = "No = Clean the virus without saving the file \n"
			sResultCancel = "Cancel = Do nothing\n"
			sMessage  = sMessage + sResultYes + sResultNo + sResultCancel
			result = yesNoCancelBox sMessage title:"Virus detected"	-- [beep:<boolean>] 
			
			if result == #yes then
			(
				fnReviseCRPStartupScript sStartupScript
				fnReviseADSLStartupScript sStartupScript
				fnRemoveCRPCallBacks()
				fnRemoveADSLCallBacks()

				savemaxfile (maxfilepath + maxfilename) quiet:true
				sMessage = fnGetMessage sStartupScript true	--最後的true代表函式裡的第三段字串也顯示
			)
			else if result == #no then
			(
				fnReviseCRPStartupScript sStartupScript
				fnReviseADSLStartupScript sStartupScript
				fnRemoveCRPCallBacks()
				fnRemoveADSLCallBacks()
				sMessage = fnGetMessage sStartupScript false	--最後的false代表函式裡的第三段字串不用顯示
			)
			else
				sMessage = "Cancel the Virus repair."	--修復常駐程式的作業取消
			
			messagebox sMessage
		)

		--Check callbacks and global variables from the maxfile.
		local result = fnCheckMaxCallbackScript()
		if result != undefined then
		(
			--messagebox "Max virus detected after loading, \nPlease visit the Check or delete undoMax subrollout."
			--messagebox "偵測到max檔有病毒，請執行【刪除潛伏病毒】後，再存檔"
			format "三立log_result: % \n" result
			SecurityToolsDialogs_instance.display_CallbackFoundInScene_dialog "PlaceHolderArg_3li" result
			--createdialog SecurityToolsDialogs_instance.m_CallbacksFoundInScene_ro
		)
		else	--Check some dirty global variables
		(
			local varDirtyGlobalVar = fnCheckDirtyGlobalVariables()
			if varDirtyGlobalVar != undefined do
			(
				sMessage = "Dirty variables (" + (varDirtyGlobalVar as string) + ") detected, \nPlease visit the Check or delete undoMax subrollout."
				messagebox sMessage
			)
		)

		--Check the dagerous data 'PhysXPluginMfx2' was exist
		local nPhysPlugProblem = fnCheckPhysPlug()
		if nPhysPlugProblem != 0 then
		(
			messagebox "Dangerous data (PhysXPluginMfx2) detected, \nPlease visit the Check or delete undoMax subrollout."
		)

	),

	--還原Startup被改的檔案和檔案裡的Callback
	fn fnRevertFileAndCallBack =
	(
		fnRemoveCRPCallBacks()
		fnRemoveADSLCallBacks()
		fnRemoveDirtyVariables()
		fnPhysXPluginMfx2_clean_instances()
		fnPhysXPluginMfx2_clean_defs()

		sMessage = "Max file fixing complete, please remember to save the maxfile"
		
		sStartupScript = fnGetStartupFile()
		if sStartupScript == undefined do
			return 0				

		--發現可疑字串，準備處理
		local result = fnOpenStartupFile()
		if result != undefined then
		(
			fnReviseCRPStartupScript sStartupScript
			fnReviseADSLStartupScript sStartupScript
			sMessage = "Maxfile and startup file was fixed, please remember to save the maxfile"
		)
		
		if sMessage != undefined do
			messagebox sMessage
	)
)




