--�R���~�]�^�Ǧ^�Ӫ��@��CallbackScript
--callbacks.show()�i�H�[�ݥثe��max�����Ǻ�ť�{��

struct o_stFixCallBack
(
	sStartupScript = "",
	
	--�R���ɮ׸̤����b��callback
	fn fnRemoveCallBacks = 
	(
		callbacks.removeScripts id:#ID_CRP_viewportChangeP
		callbacks.removeScripts id:#ID_CRP_filePostOpen
		callbacks.removeScripts id:#ID_CRP_filePostOpenP
		callbacks.removeScripts id:#ID_CRP_filePostMerge
		callbacks.removeScripts id:#ID_CRP_preRenderP
		callbacks.removeScripts id:#ID_CRP_postImport
	),

	--���T�{startup��ƪ�����A���Jmax�ɫ�A�T�{���L�Q��g
	fn fnGetStartupFile =
	(
		sStartScriptsDir = (getDir #startupScripts)
		aStartScripts = getFiles (sStartScriptsDir + "\\*.ms")
		sStartupScript = aStartScripts[1]
		return sStartupScript
	),

	--�Ncallbacks.show()�L���O�ƥ��A�æs�b�w�и�(�������}�Ghttp://forums.cgsociety.org/archive/index.php?t-621261.html)
	--D:\ADoc\MaxScript\_Project\pj_pkm\o_roIndexTools.ms\fnInitialize()�]��������code
	fn fnSaveCallbacksToHDD _sCallBackLog=
	(
		closeLog() -- close the listener log file, if any
		openLog _sCallBackLog mode:"w" outputOnly:true -- log listener output
		callbacks.show() -- get all the callbacks. This output will now be in "c:\\listener.log" as well
		flushLog() -- flush the log
		closeLog() -- close the log
	),

	--�d�ݰO�ƥ��̭����LCRP�o�����r��(���������ӴN�O�f�r)
	fn fnCheckCRPContent _sFile=
	(
		if _sFile != undefined do
		(
			startupfileHandle = openfile _sFile
			
			--�ˬd���S���i�ê��r��(CRP_�o�Ӧr��ܥi��)
			local result = skipToString startupfileHandle "CRP_" --"CRP_WriteBScript"
			close startupfileHandle
			return result
		)
	),

	--�d��Max�ɪ�callback(max�ɭn���}�n)
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
	
	--�}��Startup��Ƨ��̪��ɮ�
	fn fnOpenStartupFile =
	(
		sStartupScript = fnGetStartupFile()
		local result = fnCheckCRPContent sStartupScript
		return result
	),
	
	--��ܱ`�n�{���B�z�᪺�T��
	fn fnGetMessage _sStartupScript _bSaveMax=
	(
		sClearCallBackMSG = "1. �ɮ�����X�Ӫ��`�n�{���w�g�R���C\n"
		sMessage = sClearCallBackMSG + "2. �Q��g�����|: " + _sStartupScript + " �w�g�R��"
		if _bSaveMax == true do
			sMessage = sMessage + "\n3. �æbMax�ɸ̪��`�n�{���w�g�R��"
		return sMessage
	),

	--revise the virus script in the startup folder
	--EX�GfnReviseStartupScript sStartupScript
	fn fnReviseStartupScript _sStartupScript=
	(
		--read the whole content in the virus ms file, and save it to the sContent
		--�v��Ū��(�̫�@��Oeof)
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

	--���}���ˬdStartup��Ƨ��̪��ɮצ��L���D�A�Y�����D�N���խ״_(�q�`�M�פu��@���}�N�|�I�s�o�Ө禡)
	fn fnCheckAndFixStartupFile =
	(
		local result = fnOpenStartupFile()
		
		--�o�{�i�ær��A�ǳƳB�z
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			--yesNoCancelBox <message_string> [title:<window_title_string>] [beep:<boolean>] 
			sMessage = "�o�{Startup��Ƨ���" + sStartupScriptName + "���f�r�A�O�_�n�ߧY�B�z: \n"
			sResultYes = "yes = ���ղM���f�r(�M����A�O�o��ʦsmax��)\n"
			sResultCancel = "No or Cancel = ��������Ʊ�\n"
			sMessage  = sMessage + sResultYes + sResultCancel
			result = yesNoCancelBox sMessage title:"�o�{�����ɮ�"	-- [beep:<boolean>] 
			
			if result == #yes then
			(
				fnReviseStartupScript sStartupScript
				fnRemoveCallBacks()

				savemaxfile (maxfilepath + maxfilename) quiet:true
				sMessage = fnGetMessage sStartupScript true	--�̫᪺true�N���禡�̪��ĤT�q�r��]���			
			)
			else
				sMessage = "�״_�`�n�{�����@�~����"
			messagebox sMessage
		)
	),

	--���}���ˬdStartup��Ƨ��̪��ɮצ��L���D�A�Y�����D�N���խ״_Startup�ɩMmax��
	fn fnCheckFixStartupFileAndScene = 
	(
		local result = fnOpenStartupFile()
		
		--�o�{�i�ær��A�ǳƳB�z
		if result != undefined do
		(
			sStartupScriptName = getFilenameFile sStartupScript + ".ms"
			sMessage = "�o�{Startup��Ƨ���" + sStartupScriptName + "���f�r�A�O�_�n�ߧY�B�z: \n"
			sResultYes = "yes = ���ղM���f�r�B�åB�x�s�o��max��\n"
			sResultNo = "No = �u���ղM���f�r�A�����smax��\n"
			sResultCancel = "Cancel = ��������Ʊ�\n"
			sMessage  = sMessage + sResultYes + sResultNo + sResultCancel
			result = yesNoCancelBox sMessage title:"�o�{�����ɮ�"	-- [beep:<boolean>] 
			
			if result == #yes then
			(
				fnReviseStartupScript sStartupScript
				fnRemoveCallBacks()

				savemaxfile (maxfilepath + maxfilename) quiet:true
				sMessage = fnGetMessage sStartupScript true	--�̫᪺true�N���禡�̪��ĤT�q�r��]���
			)
			else if result == #no then
			(
				fnReviseStartupScript sStartupScript
				fnRemoveCallBacks()
				sMessage = fnGetMessage sStartupScript false	--�̫᪺false�N���禡�̪��ĤT�q�r�ꤣ�����
			)
			else
				sMessage = "�״_�`�n�{�����@�~����"
			
			messagebox sMessage
		)

		--�d��maxfile�̪�callbackscript�O�_���`
		local result = fnCheckMaxCallbackScript()
		if result != undefined do
		(
			messagebox "������max�ɦ��f�r�A�а���i�R�����f�r�j��A�A�s��"
		)
	),

	--�٭�Startup�Q�諸�ɮשM�ɮ׸̪�Callback
	fn fnRevertFileAndCallBack =
	(
		fnRemoveCallBacks()
		
		sStartupScript = fnGetStartupFile()
		if sStartupScript == undefined do
			return 0				

		--�o�{�i�ær��A�ǳƳB�z
		local result = fnOpenStartupFile()
		if result != undefined then
		(
			fnReviseStartupScript sStartupScript
			sMessage = "fixing complete"
		)
		
		messagebox sMessage
	)
)



