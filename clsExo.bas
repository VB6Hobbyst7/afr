B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
Sub Class_Globals
	Private exoPlayer As SimpleExoPlayer
	Dim tm As Timer
	Dim bufferCount As Int = 0
	Dim maxCount As Int = 5
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	exoPlayer.Initialize("player")
		
End Sub

Public Sub startPlayer(url As String)
	exoPlayer.Initialize("")
	Dim sources As List
	sources.Initialize
	exoPlayer.Prepare(exoPlayer.CreateURISource(url))
	
	exoPlayer.Volume = 1
	exoPlayer.Play
	CallSub2(Starter, "setWakeLock", True)
	tm.Initialize ("tm",1000)
	tm.Enabled = True
	CallSub2(Starter, "tmrGetSongEnable", True)
End Sub

Public Sub stopPlayer
'	Log("STOP PLAYER")
	exoPlayer.Pause
	exoPlayer.Release
	tm.Enabled=False
	bufferCount=0
	CallSub2(Starter, "setWakeLock", False)
	CallSub2(Starter, "tmrGetSongEnable", False)
End Sub


Sub tm_Tick
	bufferCount = bufferCount+1
	If Starter.clsFunc.IsStreamActive(3) = True Then
		CallSub(searchStation, "showUserGettingRDS")
		tm.Enabled = False
		bufferCount = 0
		Return
	End If
	
	CallSub2(searchStation, "showUserTryingToStartStream", (maxCount - bufferCount))
	
	If bufferCount = maxCount And Starter.clsFunc.IsStreamActive(3) = False Then
		CallSub(searchStation, "unableToPlaySTream")
		bufferCount = 0
		stopPlayer
	End If

End Sub