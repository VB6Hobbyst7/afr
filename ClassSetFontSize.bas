B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=10
@EndOfDesignText@
Sub Class_Globals
	Private access As Accessiblity
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

'resize fonts to original/intended size
Sub ResetUserFontScale(p As Panel)
	For Each v As View In p
		If v.Tag Is B4XFloatTextField Then
			Dim vw As B4XFloatTextField = v.tag
			vw.LargeLabelTextSize = vw.LargeLabelTextSize/access.GetUserFontScale
			vw.SmallLabelTextSize = vw.SmallLabelTextSize/access.GetUserFontScale
			vw.Update
			Continue
		End If
		If v Is Panel Then
			ResetUserFontScale(v)
		Else If v Is Label Then
			Dim lbl As Label = v
			lbl.TextSize = lbl.TextSize / access.GetUserFontScale
		Else If v Is Spinner Then
			Dim s As Spinner = v
			s.TextSize = s.TextSize / access.GetUserFontScale
		End If
	Next
End Sub

