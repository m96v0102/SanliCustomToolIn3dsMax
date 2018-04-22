--刪除外包回傳回來的一些CallbackScript
--callbacks.show()可以觀看目前的max有哪些監聽程式

struct o_stFixCallBack
(
	sStartupScript = "",
	
	--刪除檔案裡不乾淨的callback
	fn fnRemoveCallBacks = 
	(
		callbacks.removeScripts id:#ID_CRP_viewportChangeP
		callbacks.removeScripts id:#ID_CRP_filePostOpen
		callbacks.removeScripts id:#ID_CRP_filePostOpenP
		callbacks.removeScripts id:#ID_CRP_filePostMerge
		callbacks.removeScripts id:#ID_CRP_preRenderP
		callbacks.removeScripts id:#ID_CRP_postImport
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

	--查看記事本裡面有無CRP這類的字眼(有的話應該就是病毒)
	fn fnCheckCRPContent _sFile=
	(
		if _sFile != undefined do
		(
			startupfileHandle = openfile _sFile
			
			--檢查有沒有可疑的字串(CRP_這個字串很可疑)
			local result = skipToString startupfileHandle "CRP_" --"CRP_WriteBScript"
			close startupfileHandle
			return result
		)
	),

	--查看Max檔的callback(max檔要先開好)
	fn fnCheckMaxCallbackScript=
	(
		sCallBackLog = "C:\\SanliCustomTool\\MaxScriptCallback_Sanli.log" 
		if (getfiles sCallBackLog).count == 0 then
			makeDir "C:\\SanliCustomTool\\"

		--sCallBackLog =  "d:\\MaxScriptCallback_Sanli.log"
		fnSaveCallbacksToHDD sCallBackLog
		local result = fnCheckCRPContent sCallBackLog
		return result
	),
	
	--開啟Startup資料夾裡的檔案
	fn fnOpenStartupFile =
	(
		sStartupScript = fnGetStartupFile()
		local result = fnCheckCRPContent sStartupScript
		return result
	),
	
	--顯示常駐程式處理後的訊息
	fn fnGetMessage _sStartupScript _bSaveMax=
	(
		sClearCallBackMSG = "1. 檔案釋放出來的常駐程式已經刪除。\n"
		sMessage = sClearCallBackMSG + "2. 被改寫的路徑: " + _sStartupScript + " 已經刪除"
		if _bSaveMax == true do
			sMessage = sMessage + "\n3. 藏在Max檔裡的常駐程式已經刪除"
		return sMessage
	),

	--revise the virus script in the startup folder
	--EX：fnReviseStartupScript sStartupScript
	fn fnReviseStartupScript _sStartupScript=
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

	--打開並檢查Startup資料夾裡的檔案有無問題，若有問題就嘗試修復(通常專案工具一打開就會呼叫這個函式)
	fn fnCheckAndFixStartupFile =
	(
		local result = fnOpenStartupFile()
		
		--發現可疑字串，準備處理
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			--yesNoCancelBox <message_string> [title:<window_title_string>] [beep:<boolean>] 
			sMessage = "發現Startup資料夾的" + sStartupScriptName + "有病毒，是否要立即處理: \n"
			sResultYes = "yes = 嘗試清除病毒(清除後，記得手動存max檔)\n"
			sResultCancel = "No or Cancel = 不做任何事情\n"
			sMessage  = sMessage + sResultYes + sResultCancel
			result = yesNoCancelBox sMessage title:"發現不明檔案"	-- [beep:<boolean>] 
			
			if result == #yes then
			(
				fnReviseStartupScript sStartupScript
				fnRemoveCallBacks()

				savemaxfile (maxfilepath + maxfilename) quiet:true
				sMessage = fnGetMessage sStartupScript true	--最後的true代表函式裡的第三段字串也顯示			
			)
			else
				sMessage = "修復常駐程式的作業取消"
			messagebox sMessage
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
			sMessage = "發現Startup資料夾的" + sStartupScriptName + "有病毒，是否要立即處理: \n"
			sResultYes = "yes = 嘗試清除病毒、並且儲存這個max檔\n"
			sResultNo = "No = 只嘗試清除病毒，但不存max檔\n"
			sResultCancel = "Cancel = 不做任何事情\n"
			sMessage  = sMessage + sResultYes + sResultNo + sResultCancel
			result = yesNoCancelBox sMessage title:"發現不明檔案"	-- [beep:<boolean>] 
			
			if result == #yes then
			(
				fnReviseStartupScript sStartupScript
				fnRemoveCallBacks()

				savemaxfile (maxfilepath + maxfilename) quiet:true
				sMessage = fnGetMessage sStartupScript true	--最後的true代表函式裡的第三段字串也顯示
			)
			else if result == #no then
			(
				fnReviseStartupScript sStartupScript
				fnRemoveCallBacks()
				sMessage = fnGetMessage sStartupScript false	--最後的false代表函式裡的第三段字串不用顯示
			)
			else
				sMessage = "修復常駐程式的作業取消"
			
			messagebox sMessage
		)

		--查看maxfile裡的callbackscript是否異常
		local result = fnCheckMaxCallbackScript()
		if result != undefined do
		(
			messagebox "偵測到max檔有病毒，請執行【刪除潛伏病毒】後，再存檔"
		)
	),

	--還原Startup被改的檔案和檔案裡的Callback
	fn fnRevertFileAndCallBack =
	(
		fnRemoveCallBacks()
		
		sStartupScript = fnGetStartupFile()
		if sStartupScript == undefined do
			return 0				

		--發現可疑字串，準備處理
		local result = fnOpenStartupFile()
		if result != undefined then
		(
			fnReviseStartupScript sStartupScript
			sMessage = "fixing complete"
		)
		
		messagebox sMessage
	)
)




