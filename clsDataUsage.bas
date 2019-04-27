B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
Sub Class_Globals
	Dim in1 As Intent
	Dim id As Object
	Dim bytes As Double
	Dim ts As JavaObject
	Dim tmr As Timer
	Dim tmrInterval As Int = 4*1000
	Dim vLabelAvg As Label
	Dim prevBytes As Float
	Dim prevByteCount As Int = 0
	Dim showAvg As Boolean
	Dim streamReconnectCound As Int = 0
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(lbl As Label)
	in1.Initialize("android.settings.APP_NOTIFICATION_SETTINGS", "")
	Dim jo As JavaObject
	in1.PutExtra("app_uid", jo.InitializeContext.RunMethodJO("getApplicationInfo", Null).GetField("uid"))
	in1.PutExtra("app_package", Application.PackageName)
	ts.InitializeStatic("android.net.TrafficStats")
	id= Array As Object( in1.GetExtra("app_uid"))
	
	initTimer
End Sub


Public Sub initAvgBytes(lbl As Label)
	vLabelAvg	= lbl
End Sub

Public Sub showAvgUsage(show As Boolean)
	showAvg	= show
End Sub

Sub initTimer
	
	tmr.Initialize("tmr", tmrInterval)
	tmr.Enabled	= True
	
End Sub

Sub tmr_Tick
	Dim vBytes As Float
	Dim vBytesSecond, vBytesReturnValue As Float
	Dim vByteDiv As Float
	
	vBytes				= getBytesReceived
	If vBytes = 0 Then
		Return
	End If
	Starter.vDataUsage	= vBytes
	
	If prevBytes <= 0 Then
		prevBytes = vBytes
	End If
	
	vBytesReturnValue = vBytes-prevBytes
	If prevBytes > 0 Then
		prevByteCount = prevByteCount+1
		vByteDiv	= (prevBytes - vBytes)/4
		
		vBytesSecond = vByteDiv/prevByteCount
		
		If showAvg = True And vBytesSecond <> 0 Then
			vLabelAvg.Text	= "Avg. data usage "& cmGen.FormatFileSize(vBytesSecond) & " per second"
		End If
		
		If Starter.streamStarted = True Then
			CallSub2(player, "showStreamWarning", False)
			If IsStreamActive(3) = False Then
				CallSub2(player, "showStreamWarning", True)
				streamReconnectCound = streamReconnectCound+1
				ToastMessageShow("Stream lost trying to reconnect", True)
				'TRY TO RESTART THE STREAM
				CallSubDelayed(player, "restartStream")
			End If
		End If
		prevBytes = vBytes
	Else 
			
	End If

	If vBytesReturnValue <> 0 Then
		CallSub2(player, "writeDataUsageToKvs",  vBytesReturnValue)
	End If
End Sub


Sub IsStreamActive(Stream As Int) As Boolean
	Dim jo As JavaObject
	Return jo.InitializeStatic("android.media.AudioSystem").RunMethod("isStreamActive", Array(Stream, 0))
End Sub

Sub getBytesReceived As String
	bytes	= ts.RunMethod("getUidRxBytes", id)
	Return bytes
End Sub

