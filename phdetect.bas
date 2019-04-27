B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#StartCommandReturnValue: android.app.Service.START_STICKY
#End Region

Sub Process_Globals

	Dim PE As PhoneEvents
	Dim PhoneId As PhoneId
	
 
End Sub

Sub Service_Create
	PE.InitializeWithPhoneState("PE",PhoneId)
End Sub

Sub Service_Start (StartingIntent As Intent)
	
End Sub

Sub Service_Destroy
	PE.StopListening()
	Service.StopForeground(1)
End Sub

Sub PE_PhoneStateChanged (State As String, IncomingNumber As String, Intent As Intent)
	Select State
		Case "RINGING"
			CallSubDelayed2(player, "toastphn", IncomingNumber)
			
		Case "IDLE"	
			CallSubDelayed2(player, "toastphnResume", IncomingNumber)
	End Select
End Sub