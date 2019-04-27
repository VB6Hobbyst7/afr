B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6
@EndOfDesignText@
'***************************
'DraggableView class module
Sub Class_Globals
   Public innerView As View
   Private panel1 As Panel
   Private downx, downy As Int
   Private ACTION_DOWN, ACTION_MOVE, ACTION_UP As Int

End Sub

Sub Initialize(Activity As Activity, v As View)
   innerView = v
   panel1.Initialize("")
   panel1.Color = Colors.Transparent
   Activity.AddView(panel1, v.Left, v.Top, v.Width, v.Height)
   ACTION_DOWN = Activity.ACTION_DOWN
   ACTION_MOVE = Activity.ACTION_MOVE
   ACTION_UP = Activity.ACTION_UP
   Dim r As Reflector
   r.Target = panel1
   r.SetOnTouchListener("Panel1_Touch") 'why reflection instead of the regular Panel_Touch event? Good question which deserves a forum thread of its own (not related to classes)...
End Sub

Private Sub Panel1_Touch (o As Object, ACTION As Int, x As Float, y As Float, motion As Object) As Boolean
	
	If innerView.IsInitialized = False Then
		Return False
	End If
	If ACTION = ACTION_UP Then
		innerView = Null
		Return False
	End If
   
	If ACTION = ACTION_DOWN Then
		downx = x
		downy = y
	Else
		innerView.Left = innerView.Left + x - downx
		innerView.Top = innerView.Top + y - downy
		panel1.Left = innerView.Left
		panel1.Top = innerView.Top
	End If
	
	Return True
End Sub

