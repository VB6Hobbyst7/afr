B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	Public AacMp3Player As JavaObject
	Public PlayerStarted As Boolean
	Public PlayerError As String = ""
	
End Sub


Sub StartPlayer (RadioStationURL As String)
	
	AacMp3Player.RunMethod("playAsync", Array(RadioStationURL, 64))
	PlayerStarted = True
End Sub

Sub StopPlayer
	AacMp3Player.RunMethod("stop", Null)
End Sub


