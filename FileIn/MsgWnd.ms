--Display Message Window

struct o_stMsgWnd
(
	--arrMessageTmpString = #(),

	--Display Message window
	fn fnMainMsgDialog _MessageType _sMessageInfo _sMessage:"" =
	(
		try(DestroyDialog roMsgInMainWnd) catch()
		
		case _MessageType of
		(
			"sMsgFinishVirusCheck":
			(
				--sMessageTmp = ""
				--for i =1 to arrMessageTmpString.count do
					--append sMessageTmp arrMessageTmpString[i]

				rollout roMsgInMainWnd _sMessageInfo width:530
				(
					edittext edtInfoData "" width: 500	height:120
					button btnFinish 	"Close"
					on btnFinish pressed do
						try(DestroyDialog roMsgInMainWnd) catch()
				)

				CreateDialog roMsgInMainWnd
				roMsgInMainWnd.edtInfoData.text = _sMessage
			)

			"sMsgFinishVirusCheckWthMoveROPosY":
			(
				rollout roMsgInMainWnd _sMessageInfo width:530
				(
					edittext edtInfoData "" width: 500	height:120
					button btnFinish 	"Close"
					on btnFinish pressed do
						try(DestroyDialog roMsgInMainWnd) catch()
				)

				CreateDialog roMsgInMainWnd
				roMsgInMainWnd.edtInfoData.text = _sMessage

				v2OldPos = GetDialogPos roMsgInMainWnd
				v2NewPos = [v2OldPos[1], v2OldPos[2] - 150]
				SetDialogPos roMsgInMainWnd v2NewPos
			)

			"sMsgProcessCompleted":
			(
				try(DestroyDialog roMsgInMainWnd) catch()
				rollout roMsgInMainWnd _sMessageInfo width: 400
				(
					--label lbFinish		"FileProperties setting Complete, please remember to save the Maxfile!!"
					label lbFinish		"Proccess completed"
					button btnFinish 	"Close"
					on btnFinish pressed do
						try(DestroyDialog roMsgInMainWnd) catch()
				)
				CreateDialog roMsgInMainWnd
			)
			--default:
		)
	)
)




