B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
Sub Class_Globals
	Private vol As Phone
	Private volBar As SeekBar
	Private volLabel As Label
	Private volumeHideTimer As Timer
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(volBarPassed As SeekBar, vLabel As Label)
	volBar.Initialize("")
	volLabel.Initialize("")
	
	volBar			= volBarPassed
	volLabel		= vLabel
	volBar.Max		= vol.GetMaxVolume(vol.VOLUME_MUSIC)
	volBar.Value 	= vol.GetVolume(vol.VOLUME_MUSIC)
	If volBar.Value < 10 Then
		volLabel.Text	= Starter.clsFunc.padString(volBar.Value, "0", 0, 1)
	Else
		volLabel.Text	= volBar.Value
	End If
	
	initTimer
End Sub


Public Sub userVolume(getVolume As Int)
	vol.SetVolume(vol.VOLUME_MUSIC, getVolume, False)
	volBar.Value	= getVolume
	If volBar.Value < 10 Then
		volLabel.Text	= Starter.clsFunc.padString(volBar.Value, "0", 0, 1)
	Else
		volLabel.Text	= volBar.Value
	End If
	setViews(getVolume)
End Sub

Private Sub setViews(value As Int)
	volBar.Value	= value
	If volBar.Value < 10 Then
		volLabel.Text	= Starter.clsFunc.padString(volBar.Value, "0", 0, 1)
	Else
		volLabel.Text	= volBar.Value
	End If
End Sub

Public Sub MaxVolume 'As Int
	volBar.Max	= vol.GetMaxVolume(vol.VOLUME_MUSIC)
End Sub

Public Sub currVolume As Int
	volLabel.Text	= vol.GetVolume(vol.VOLUME_MUSIC)
	Return vol.GetVolume(vol.VOLUME_MUSIC)
End Sub

Private Sub initTimer
	volumeHideTimer.Initialize("volumeHideTimer", 3000)
	volumeHideTimer.Enabled = False
End Sub

Public Sub enableVolumeTimer
	volumeHideTimer.Enabled = True
End Sub

Public Sub disableVolumeTimer
	volumeHideTimer.Enabled = False
End Sub

Private Sub volumeHideTimer_Tick
	volumeHideTimer.Enabled = False
	CallSub(player, "showVolumeBar")
End Sub

Public Sub timerActive As Boolean
	Return volumeHideTimer.Enabled
End Sub
