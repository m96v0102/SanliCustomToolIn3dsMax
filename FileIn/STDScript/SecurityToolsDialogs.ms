/**********************************************************************
// This file is under the 'STDScript' folder, wich stands for 'SecurityToolsDialog script'
**********************************************************************/

global g_stFixCallBack

--We shoud define an empty SecurityToolsDialogs_structdef and do a simple instantiation, 
-- otherwise we will get an error when we run through the m_DeleteFileIssue rollout
struct SecurityToolsDialogs_structdef 
(
	m_filelist = #()
)
SecurityToolsDialogs_instance = SecurityToolsDialogs_structdef()

struct SecurityToolsDialogs_structdef 
(
	--private
	-- icon file names. Includes whether light/dark theme and size. Set by create handler.
	m_error_icon_filename,
	m_info_icon_filename,
	m_success_icon_filename,
	m_warning_icon_filename,

	-- The dialog background color. Set by create handler. Used when creating the dialogs and for alpha compositing of icons.
	m_dialog_background_color,
	
	-- this works around maxscript issues with using bitmaps containing alpha channel as imgtag bitmaps.
	fn set_imgtag_bitmap theImgTag theBitmap_filename =
	(
		-- alpha blend the icon image with a bitmap of same color as dialog background.
		local theBitmap = openBitMap theBitmap_filename --gamma:1
		if theBitmap != undefined do
		(
			local result_bitmap = bitmap theBitmap.width theBitmap.height color:m_dialog_background_color gamma:1.
			pasteBitmap theBitmap result_bitmap [0,0] [0,0] type:#blend 
			-- need to turn off display gamma when setting the imgtag bitmap
			local old_colorCorrectionMode = iDisplayGamma.colorCorrectionMode
			iDisplayGamma.colorCorrectionMode = #none
			theImgTag.bitmap = result_bitmap
			iDisplayGamma.colorCorrectionMode = old_colorCorrectionMode
		)
		ok
	),
	
	m_filelist = #(),

	bMaxOpening = true,
	
	-- the name of the 3rd party script found
	m_which_script,

	-- Rollout definition - Delete the file completed
	m_DelFileCompleted_ro = rollout m_DelFileCompleted_ro "File delete completed" width:400
	(
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		--label l1 "All corrupt script files were cleaned successfully" offset:[50, -26] align:#left
		label l1 "The dangerous local file was deleted successfully" offset:[50, -26] align:#left
		label l2 ""
		button b_close "Close" align:#right
		
		on m_DelFileCompleted_ro open do
		(
			set_imgtag_bitmap icon m_success_icon_filename
		)
		on b_close pressed do
		(
			destroyDialog m_DelFileCompleted_ro
		)
	),

	-- Display dialog - Delete the file completed
	fn display_DelFileCompleted_dialog =
	(
		createdialog m_DelFileCompleted_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),

	-- Rollout definition - Clean and save the maxfile
	m_CleanAndSave_ro = rollout m_CleanAndSave_ro "Corruption successfully cleaned with saving the file" width:400
	(
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		--label l1 "All corrupt script files were cleaned successfully" offset:[50, -26] align:#left
		label l1 "The current file was cleaned and saved successfully" offset:[50, -26] align:#left
		label l2 ""
		button b_close "Close" align:#right
		
		on m_CleanAndSave_ro open do
		(
			set_imgtag_bitmap icon m_success_icon_filename
		)
		on b_close pressed do
		(
			destroyDialog m_CleanAndSave_ro
		)
	),

	-- Display dialog - Clean and save the maxfile.
	fn display_CleanAndSave_dialog =
	(
		createdialog m_CleanAndSave_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),

	-- Rollout definition -Clean the dangerous data without saving the maxfile(Original name - m_corruptionCleanedInScene_ro)
	m_CleanWithoutSaving_ro = rollout m_CleanWithoutSaving_ro "Corruption successfully cleaned without saving" width:400
	(
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		label l1 "Next steps" offset:[50, -26] align:#left
		label l2 "The dangerous data was cleaning complete."						offset:[0, 10] align:#left
		label l3 "Remember to save the current scene to prevent future corruption." align:#left
		label l4 ""
		button b_close "Close" align:#right
		
		on m_CleanWithoutSaving_ro open do
		(
			set_imgtag_bitmap icon m_info_icon_filename
		)
		on b_close pressed do
		(
			destroyDialog m_CleanWithoutSaving_ro
		)
	),

	-- Display dialog - clean dangerous data without saving the maxfile(Original name - display_corruptionCleanedInScene_dialog)
	fn display_CleanWithoutSave_dialog=
	(
		createdialog m_CleanWithoutSaving_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),
	
	-- Rollout definition - found dangerous data in scene(Original name - m_corruptionFoundInScene_ro)
	m_DangerDataFound_ro = rollout m_DangerDataFound_ro "Dangerous data Found" width:545
	(
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		label l1 "Dangerous data detected" offset:[50, -26] align:#left
		label l2 ""
		label l3 "The tool detects (%) which might caused some problems and instability. \nAny scene you save will probably spread the corruption to copies of 3ds Max in which the scene is loaded."  align:#left height:(2*13)
		--label l3 "The current scene is corrupt by a 3rd party script (%) that can cause data loss and instability. \nAny scene you save will spread the corruption to copies of 3ds Max in which the scene is loaded."  align:#left height:(2*13)
		label l4 "We strongly recommend you allow the corruption to be cleaned." align:#left
		label l5 ""
		button bCleanAndSave "Clean and save" across:3 align:#left
		button bCleanWOSave "Clean without saving" align:#right offset:[-25,0]
		button b_leave "Leave corruption" align:#right
		
		on m_DangerDataFound_ro open do
		(
			set_imgtag_bitmap icon m_warning_icon_filename
			l3.text = substituteString l3.text "%" m_which_script
			g_stFixCallBack.bFinishProcess = true
		)
		on bCleanAndSave pressed do
		(
			destroyDialog m_DangerDataFound_ro
			g_stFixCallBack.fnRemoveDangDataWOStartup()
			savemaxfile (maxfilepath + maxfilename) quiet:true
			if g_stFixCallBack.bFinishProcess == true do display_CleanAndSave_dialog()
		)
		on bCleanWOSave pressed do
		(
			destroyDialog m_DangerDataFound_ro

			g_stFixCallBack.fnRemoveDangDataWOStartup()
			if g_stFixCallBack.bFinishProcess == true do display_CleanWithoutSave_dialog()
		)
		on b_leave pressed do
		(
			if g_stFixCallBack.bFinishProcess == true do
			(
				g_stFixCallBack.bFinishProcess = false
				destroyDialog m_DangerDataFound_ro
			)
		)
	),

	-- Display dialog - found dangerous data in scene. (Original name - display_corruptionFoundInScene_dialog)
	fn display_DangerDataFound_dialog which_script =
	(
		m_which_script = which_script
		createdialog m_DangerDataFound_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),

	-- Rollout definition - found virus.
	m_VirusFound_ro = rollout m_VirusFound_ro "Virus Found" width:545
	(
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		label l1 "Virus detected" offset:[50, -26] align:#left
		label l2 ""
		label l3 "Your startup file (%) was affected, this might caused some problems and instability. \nAny scene you save will probably spread the corruption to copies of 3ds Max in which the scene is loaded."  align:#left height:(2*13)
		--label l3 "The current scene is corrupt by a 3rd party script (%) that can cause data loss and instability. \nAny scene you save will spread the corruption to copies of 3ds Max in which the scene is loaded."  align:#left height:(2*13)
		label l4 "We strongly recommend you allow the corruption to be cleaned." align:#left
		label l5 ""
		button bCleanAndSave "Clean and save" across:3 align:#left
		button bCleanWOSave "Clean without saving" align:#right offset:[-25,0]
		button b_leave "Leave corruption" align:#right
		
		on m_VirusFound_ro open do
		(
			set_imgtag_bitmap icon m_error_icon_filename
			l3.text = substituteString l3.text "%" m_which_script
			g_stFixCallBack.bFinishProcess = true
		)
		on bCleanAndSave pressed do
		(
			destroyDialog m_VirusFound_ro
			g_stFixCallBack.fnRemoveAllDangerousData()
			savemaxfile (maxfilepath + maxfilename) quiet:true
			if g_stFixCallBack.bFinishProcess == true do display_CleanAndSave_dialog()
		)
		on bCleanWOSave pressed do
		(
			destroyDialog m_VirusFound_ro
			g_stFixCallBack.fnRemoveAllDangerousData()
			if g_stFixCallBack.bFinishProcess == true do display_CleanWithoutSave_dialog()
		)
		on b_leave pressed do
		(
			if g_stFixCallBack.bFinishProcess == true do
			(
				g_stFixCallBack.bFinishProcess = false
				destroyDialog m_VirusFound_ro
			)
		)
	),

	-- Display dialog - found virus.
	fn display_VirusFound_dialog which_script =
	(
		m_which_script = which_script
		createdialog m_VirusFound_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),

	--In win10, we need to use administrator to delete some files
	m_PleaseDelByAdmin = rollout m_PleaseDelByAdmin "Please delete the file by administrator" width:580
	(
		-- local initial values are evaluated at compile time. We use m_filelist_height as the height for edtFileList so that controls under it are laid out correctly and the rollout height is ok.
		local m_filelist_height = if SecurityToolsDialogs_instance.m_filelist == undefined then 16 else SecurityToolsDialogs_instance.m_filelist.count * 16
		local m_orig_height -- restore initial rollout height in close handler
			
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		label l1 "The file cannot be delete in current mode," offset:[50, -26] align:#left
		label l2 ""
		label l3 "Please delete the following file by administrator." align:#left height:(18)
		--label l4 "We strongly recommend to delete the following file:" align:#left
		edittext edtFileList height:m_filelist_height readOnly:true offset:[-6, 0]
		label l5 ""
		button btnLeave "Leave corruption" align:#right
		
		on m_PleaseDelByAdmin open do
		(
			set_imgtag_bitmap icon m_warning_icon_filename
			local content = ""
			local first_entry = true
			for sFile in m_filelist do 
			(
				if not first_entry do content += "\n"
				first_entry = false
				content += sFile
			)
			edtFileList.text = content
			
			-- futz with height of rollout. May be easier to not use m_filelist_height as param for edtFileList, but rather set the height in this open handler
			-- and manually reposition controls below it.
			m_orig_height = m_PleaseDelByAdmin.height
			if m_PleaseDelByAdmin_first_filelist_count == undefined then
				m_PleaseDelByAdmin_first_filelist_count = m_filelist.count
			m_PleaseDelByAdmin.height += (m_filelist.count - m_PleaseDelByAdmin_first_filelist_count) * 16 
			-- for 3ds Max 2016 and earlier following is needed to get the dialog height to update when inside the open handler
			if ((maxVersion())[1] < 19000) do
			(
				--https://www.cnblogs.com/ibingshan/p/12101560.html
				--Calling this method will process all pending messages. It can be used inside a MAXScript loop which would otherwise cause a "white screen" in Windows 7
				try(windows.processpostedmessages())
				catch()
			)

			g_stFixCallBack.bFinishProcess = false
		)
		on m_PleaseDelByAdmin close do
		(
			m_PleaseDelByAdmin.height = m_orig_height
		)
		on btnLeave pressed do
		(
			destroyDialog m_PleaseDelByAdmin
		)
	),

	fn display_PleaseDelByAdmin_dialog aFileList =
	(
		m_filelist = aFileList
		createdialog m_PleaseDelByAdmin bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),

	m_DeleteFileIssue = rollout m_DeleteFileIssue "File deleting issue by 3ds Max Security Tools" width:580
	(
		-- local initial values are evaluated at compile time. We use m_filelist_height as the height for edtFileList so that controls under it are laid out correctly and the rollout height is ok.
		local m_filelist_height = if SecurityToolsDialogs_instance.m_filelist == undefined then 16 else SecurityToolsDialogs_instance.m_filelist.count * 16
		local m_orig_height -- restore initial rollout height in close handler
			
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		label l1 "File deleting issue" offset:[50, -26] align:#left
		label l2 ""
		label l3 "The following file was created by the third party script and can't delete it immediately" align:#left height:(14*2)
		label l4 "We strongly recommend to close all of the 3dsMax and delete the following file:" align:#left
		edittext edtFileList height:m_filelist_height readOnly:true offset:[-6,0]
		label l5 ""
		button bShowLocalFile "Show up this local file" across:4 align:#right --offset:[160,0]
		button bCloseWSave "Save and close 3dsMax" align:#right tooltip: "Save maxfile, close all 3dsMax and delete the file." offset:[15,0]
		button bCloseWOSave "Close without saving" align:#right tooltip: "Close all 3dsMax and delete the file without saving" offset:[15,0]
		button btnLeave "Leave corruption" align:#right
		
		on m_DeleteFileIssue open do
		(
			set_imgtag_bitmap icon m_warning_icon_filename
			local content = ""
			local first_entry = true
			for sFile in m_filelist do 
			(
				if not first_entry do content += "\n"
				first_entry = false
				content += sFile
			)
			edtFileList.text = content
			
			-- futz with height of rollout. May be easier to not use m_filelist_height as param for edtFileList, but rather set the height in this open handler
			-- and manually reposition controls below it.
			m_orig_height = m_DeleteFileIssue.height
			if m_DeleteFileIssue_first_filelist_count == undefined then
				m_DeleteFileIssue_first_filelist_count = m_filelist.count
			m_DeleteFileIssue.height += (m_filelist.count - m_DeleteFileIssue_first_filelist_count) * 16 
			-- for 3ds Max 2016 and earlier following is needed to get the dialog height to update when inside the open handler
			if ((maxVersion())[1] < 19000) do
			(
				--https://www.cnblogs.com/ibingshan/p/12101560.html
				--Calling this method will process all pending messages. It can be used inside a MAXScript loop which would otherwise cause a "white screen" in Windows 7
				try(windows.processpostedmessages())
				catch()
			)

			g_stFixCallBack.bFinishProcess = false
		)
		on m_DeleteFileIssue close do
		(
			m_DeleteFileIssue.height = m_orig_height
		)
		on bShowLocalFile pressed do
		(
			--Open the file browser and select a specifice file, let the use know this file will going to be deleted.
			sExpression = "explorer /select, " + g_stFixCallBack.sLocalTempFile
			DOSCommand sExpression
		)
		on bCloseWSave pressed do
		(
			savemaxfile (maxfilepath + maxfilename) quiet:true
			bCloseWOSave.pressed()
		)
		on bCloseWOSave pressed do
		(
			bMaxOpening = false
			destroyDialog m_DeleteFileIssue

			if doesFileExist g_stFixCallBack.sLocalTempFile == true do
			(
				--Execute "D:\ADoc\MaxScript\_Common\SanliCustomTool\FromGitHub\FileIn\STDScript\DelLocalTemp.bat",
				--  this will close the 3dsMax and delte the "Local_temp.ms".
				sDelLocalTmpBatFile = (pathconfig.appendPath (pathconfig.removePathLeaf (getThisScriptFilename())) "DelLocalTemp.bat")
				shelllaunch sDelLocalTmpBatFile ""
			)
			
		)
		on btnLeave pressed do
		(
			destroyDialog m_DeleteFileIssue
		)
	),

	fn display_DeleteFileIssue_dialog aFileList =
	(
		m_filelist = aFileList
		createdialog m_DeleteFileIssue bgcolor:m_dialog_background_color modal:true escapeEnable:true
		return bMaxOpening
	),

	m_DangerLocalFile = rollout m_DangerLocalFile "Danger local file found by 3ds Max Security Tools" width:580
	(
		-- local initial values are evaluated at compile time. We use m_filelist_height as the height for edtFileList so that controls under it are laid out correctly and the rollout height is ok.
		local m_filelist_height = if SecurityToolsDialogs_instance.m_filelist == undefined then 16 else SecurityToolsDialogs_instance.m_filelist.count * 16
		local m_orig_height -- restore initial rollout height in close handler
			
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		label l1 "Detect dangerous local file!" offset:[50, -26] align:#left
		label l2 ""
		label l3 "The following local file was created by the third party script" align:#left height:(14*2)
		label l4 "We strongly recommend to delete the following file:" align:#left
		edittext edtFileList height:m_filelist_height readOnly:true	offset:[-6, 0]
		label l5 ""
		button bShowLocalFile "Show up this local file" across:3 align:#right --offset:[160,0]
		button bDeleteLocalFile "Delete this local file" align:#right offset:[10,0]
		button btnLeave "Leave corruption" align:#right
		
		on m_DangerLocalFile open do
		(
			set_imgtag_bitmap icon m_warning_icon_filename
			local content = ""
			local first_entry = true
			for sFile in m_filelist do 
			(
				if not first_entry do content += "\n"
				first_entry = false
				content += sFile
			)
			edtFileList.text = content
			
			-- futz with height of rollout. May be easier to not use m_filelist_height as param for edtFileList, but rather set the height in this open handler
			-- and manually reposition controls below it.
			m_orig_height = m_DangerLocalFile.height
			if m_DangerLocalFile_first_filelist_count == undefined then
				m_DangerLocalFile_first_filelist_count = m_filelist.count
			m_DangerLocalFile.height += (m_filelist.count - m_DangerLocalFile_first_filelist_count) * 16 
			-- for 3ds Max 2016 and earlier following is needed to get the dialog height to update when inside the open handler
			if ((maxVersion())[1] < 19000) do
			(
				--https://www.cnblogs.com/ibingshan/p/12101560.html
				--Calling this method will process all pending messages. It can be used inside a MAXScript loop which would otherwise cause a "white screen" in Windows 7
				try(windows.processpostedmessages())
				catch()
			)

			g_stFixCallBack.bFinishProcess = false
		)
		on m_DangerLocalFile close do
		(
			m_DangerLocalFile.height = m_orig_height
		)
		on bShowLocalFile pressed do
		(
			--Open the file browser and select a specifice file, let the use know this file will going to be deleted.
			sExpression = "explorer /select, " + m_filelist[1]
			DOSCommand sExpression
		)
		on bDeleteLocalFile pressed do
		(
			destroyDialog m_DangerLocalFile
			
			if doesFileExist m_filelist[1] == true do
			(
				bMaxOpening = g_stFixCallBack.fnCheckNRemoveMscpropCbkNProp m_filelist[1]
			)
			
		)
		on btnLeave pressed do
		(
			destroyDialog m_DangerLocalFile
		)
	),

	fn display_DangerLocalFile_dialog aFileList =
	(
		m_filelist = aFileList

		-- In some cases, we will show this dialog after batch check, so we should see 2 dialogs, but we will got some issues below:
		-- If I set the modal argument to true, I can't change the position for this dialog, 
		-- If I set the modal argument to false, I can't access the content in m_filelist, 
		-- To solve this problem, I decided to move the MsgWnd position.
		createdialog m_DangerLocalFile bgcolor:m_dialog_background_color modal:true escapeEnable:true
		
		return bMaxOpening
	),

	on create do
	(
		m_dialog_background_color = ((colorman.getcolor #window)*255) as color
		
		local security_tools_scripts_dir = pathconfig.removePathLeaf (getThisScriptFilename())
		local security_tools_icon_dir = pathconfig.appendPath (pathconfig.removePathLeaf security_tools_scripts_dir) "icons"
		local color_theme = "dark"
		if isproperty colorman #getColorTheme then 
			color_theme = colorman.getColorTheme() as string -- "light" or "dark"
		else
		(
			local icon_folder = colorman.getIconFolder() -- something like: "E:\Program Files\Autodesk\3ds Max 2016\UI_ln\IconsDark"
			if icon_folder.count >= 5 do
			(
				local maybe_light = substring icon_folder (icon_folder.count-4) 5 -- "Light" or "sDark"
				if (stricmp maybe_light "light") == 0 then
					color_theme = "light"
				else
					color_theme = "dark"
			)
		)
		security_tools_icon_dir = pathconfig.appendPath security_tools_icon_dir color_theme
		local dpi_scaling = 1.
		if (globalvars.isGlobal #CustomControlsOptions) do 
		(
			dpi_scaling = CustomControlsOptions.UIUserScaleFactor
			if dpi_scaling == 0. do
				dpi_scaling = GetUIScaleFactor()
		)
		-- supported scaling values: 1, 1.25, 1.5, 2.0
		local icon_size = case of 
		(
			(dpi_scaling < 1.2): "32"
			(dpi_scaling < 1.4): "40"
			(dpi_scaling < 1.9): "48"
			default: "64"
		)

		m_error_icon_filename = pathconfig.appendPath security_tools_icon_dir ("error_" + icon_size + ".png")
		m_info_icon_filename = pathconfig.appendPath security_tools_icon_dir ("info_" + icon_size + ".png")
		m_success_icon_filename = pathconfig.appendPath security_tools_icon_dir ("success_" + icon_size + ".png")
		m_warning_icon_filename = pathconfig.appendPath security_tools_icon_dir ("warning_" + icon_size + ".png")

	)
)
SecurityToolsDialogs_instance = SecurityToolsDialogs_structdef()

