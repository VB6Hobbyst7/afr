B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
Sub Class_Globals
	Private tmr As Timer
	Private tmrInterval As Long
	Private tmrReached As Long
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(interval As Long, endTimer As Long)
	tmrInterval = interval
	tmrReached	= endTimer + DateTime.Now
	
	tmr.Initialize("sleepTimer", tmrInterval)
	tmr.Enabled	= False
End Sub

Sub sleepTimer_Tick
	Log($"SLEEPTIMER $DateTime{DateTime.Now}"$)
	If DateTime.Now >= tmrReached Then
		enableSleepTimer(False)
		CallSub(player, "exitPlayer")
	End If
End Sub

Sub setInterval(interval As Long)
	tmrInterval = interval
End Sub

Sub enableSleepTimer(enable As Boolean)
	tmr.Enabled = enable
End Sub