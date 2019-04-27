B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.3
@EndOfDesignText@
Sub Class_Globals
	Dim timer As Timer
	Dim retLabel As Label
End Sub


Public Sub Initialize(interval As Long, lbl As Label)
	DateTime.TimeFormat = "HH:mm"
	retLabel = lbl
	retLabel.Text	=  DateTime.Time(DateTime.Now)
	initTimer(interval)
End Sub

Private Sub initTimer(interval As Long)
	timer.Initialize("tmr", interval)
	timer.Enabled	= True
End Sub

Private Sub tmr_Tick 'As String
	retLabel.Text	=  DateTime.Time(DateTime.Now)
End Sub

Public Sub timerEnabled(enable As Boolean)
	timer.Enabled = enable
End Sub
