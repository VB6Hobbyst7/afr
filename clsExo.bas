B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
Sub Class_Globals
	Private exoPlayer As SimpleExoPlayer
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	exoPlayer.Initialize("player")
		
End Sub

Public Sub startPlayer(url As String)
	'Log("INIT " &url)
	'Log("INIT " &url)
	exoPlayer.Initialize("")
	Dim sources As List
	sources.Initialize
	sources.Add(exoPlayer.CreateUriSource(url))
	exoPlayer.Prepare(exoPlayer.CreateUriSource(url))
	
	exoPlayer.Volume = 1
	exoPlayer.Play
	CallSub2(Starter, "setWakeLock", True)
End Sub

Public Sub stopPlayer
	Log("STOP PLAYER")
	exoPlayer.Pause
	exoPlayer.Release
	CallSub2(Starter, "setWakeLock", False)
End Sub