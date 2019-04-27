B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize()
	
	
End Sub

Public Sub runMarquee(view As Label, txt As String, mode As String)
	view.Text = txt
	Dim r As Reflector
	r.Target = view
	r.RunMethod2("setLines", 1, "java.lang.int")
	r.RunMethod2("setHorizontallyScrolling", True, "java.lang.boolean")
	r.RunMethod2("setEllipsize", mode, "android.text.TextUtils$TruncateAt")
	r.RunMethod2("setHorizontalFadingEdgeEnabled", True, "java.lang.boolean")
	r.RunMethod2("setMarqueeRepeatLimit", -1, "java.lang.int")
	r.RunMethod2("setSelected", True, "java.lang.boolean")
End Sub	
	