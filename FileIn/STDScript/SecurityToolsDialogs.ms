/**********************************************************************
// Sanli: Copy the file from Autodesk SecurityTools and do some modify
// This file is under the 'STDScript' folder, wich stands for 'SecurityToolsDialog script'
**********************************************************************/

global g_stFixCallBack

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
	
	-- the display_DangerDataFound_dialog function return value
	m_display_DangerDataFound_dialog_return_value,
	
	-- the name of the 3rd party script found
	m_which_script,

	-- Rollout definition - Clean and save the maxfile(Original name - m_corruptionCleanedInEnv_ro)
	m_CleanAndSave_ro = rollout m_CleanAndSave_ro "Corruption Successfully Cleaned by 3ds Max Security Tools" width:400
	(
		local autobackup_enabled -- whether autobackup was enabled when opening the dialog
		imgtag icon width:32 height:32 align:#left style:#bmp_center applyUIScaling:false
		--label l1 "All corrupt script files were cleaned successfully" offset:[50, -26] align:#left
		label l1 "The current file was cleaned and saved successfully" offset:[50, -26] align:#left
		label l2 ""
		button b_close "Close" align:#right
		
		on m_CleanAndSave_ro open do
		(
			set_imgtag_bitmap icon m_success_icon_filename
			autobackup_enabled = autobackup.enabled  -- disable autobackup while dialog is displayed
			autobackup.enabled = false
		)
		on m_CleanAndSave_ro close do
		(
			autobackup.enabled = autobackup_enabled
		)
		on b_close pressed do
		(
			destroyDialog m_CleanAndSave_ro
		)
	),

	-- Display dialog - Clean and save the maxfile.(Original name - display_corruptionCleanedInEnv_dialog)
	fn display_CleanAndSave_dialog =
	(
		createdialog m_CleanAndSave_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
	),

	-- Rollout definition -Clean the dangerous data without saving the maxfile(Original name - m_corruptionCleanedInScene_ro)
	m_CleanWithoutSaving_ro = rollout m_CleanWithoutSaving_ro "Corruption Successfully Cleaned by 3ds Max Security Tools" width:400
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
		)
		on bCleanAndSave pressed do
		(
			destroyDialog m_DangerDataFound_ro
			g_stFixCallBack.fnRemoveDangDataWOStartup()
			savemaxfile (maxfilepath + maxfilename) quiet:true
			display_CleanAndSave_dialog()
		)
		on bCleanWOSave pressed do
		(
			destroyDialog m_DangerDataFound_ro

			g_stFixCallBack.fnRemoveDangDataWOStartup()
			display_CleanWithoutSave_dialog()
		)
		on b_leave pressed do
		(
			destroyDialog m_DangerDataFound_ro
		)
	),

	-- Display dialog - found dangerous data in scene. (Original name - display_corruptionFoundInScene_dialog)
	fn display_DangerDataFound_dialog which_script =
	(
		m_which_script = which_script
		createdialog m_DangerDataFound_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
		m_display_DangerDataFound_dialog_return_value -- return value
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
		)
		on bCleanAndSave pressed do
		(
			destroyDialog m_VirusFound_ro
			g_stFixCallBack.fnRemoveAllDangerousData()
			savemaxfile (maxfilepath + maxfilename) quiet:true
			display_CleanAndSave_dialog()
		)
		on bCleanWOSave pressed do
		(
			destroyDialog m_VirusFound_ro
			g_stFixCallBack.fnRemoveAllDangerousData()
			display_CleanWithoutSave_dialog()
		)
		on b_leave pressed do
		(
			destroyDialog m_VirusFound_ro
		)
	),

	-- Display dialog - found virus.
	fn display_VirusFound_dialog which_script =
	(
		m_which_script = which_script
		createdialog m_VirusFound_ro bgcolor:m_dialog_background_color modal:true escapeEnable:true
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
::SecurityToolsDialogs_instance = SecurityToolsDialogs_structdef()

