
sStartUpFolder = getDir #startupScripts

if roSanliCustomToolBar != undefined then
(
	try
	(
		cui.unRegisterDialogBar roSanliCustomToolBar;destroydialog  roSanliCustomToolBar
	)
	catch()

	if (roSanliCustomToolBar != undefined) then
	(
		format "Sanlilog_roSanliCustomToolBar有東西，我準備重新移除 \n"
		roSanliCustomToolBar = undefined
	)
)
else
(
	rollout roSanliCustomToolBar "SanliCustomToolBar" width:1884 height:35
	(
		button btn3liCustomTools "Sanli Custom Tools"  width:120 height:22	pos:[0,4]
		button btn3liExporer "Sanli Scene Explorer" width:120 height:22 pos:[125, 4]  --align:#Left 

		on btn3liCustomTools pressed do
		(
			fileIn @"C:\SanliCustomTool\MaxScript1\MainRollout.ms"
		)

		on btn3liExporer pressed do
		(
			fileIn  @"C:\SanliCustomTool\MaxScript1\FileIn\SanliSceneExplorer.ms"
		)		


	)
	createdialog roSanliCustomToolBar 1520 30 style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
	cui.RegisterDialogBar roSanliCustomToolBar style:#(#cui_dock_bottom, #cui_floatable, #style_toolwindow)
	cui.DockDialogBar roSanliCustomToolBar #cui_dock_bottom
	--cui.getExpertMode() 
	--updateToolbarButtons()

)
			

