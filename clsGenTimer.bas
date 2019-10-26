B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
Sub Class_Globals
	Public timer As Timer
	Dim func As String
End Sub


Public Sub Initialize(interval As Long, tmrFunc As String)
	func	= tmrFunc
	initTimer(interval)
End Sub

Private Sub initTimer(interval As Long)
	timer.Initialize("tmr", interval)
	timer.Enabled	= False
End Sub

Private Sub tmr_Tick
	timer.Enabled = False
	getFunction
End Sub


Private Sub getFunction
	Select func
		Case "hideOverFlow"
			hideOverFlow
				
	End Select
End Sub

Private Sub hideOverFlow
	func = Null
	CallSub(player, "hideOverFlow")
End Sub

public Sub timerEnabled(state As Boolean)
	timer.Enabled = state
End Sub
