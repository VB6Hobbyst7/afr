B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private toolbar As ACToolBarDark
	Private spnrCountry As ACSpinner
	Private spnrGenre As ACSpinner
	Private spnrLanguage As ACSpinner
	Private clvNewStation As irp_CustomListView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("addNewStations")

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub spnrCountry_ItemClick (Position As Int, Value As Object)
	
End Sub

Sub spnrGenre_ItemClick (Position As Int, Value As Object)
	
End Sub

Sub spnrLanguage_ItemClick (Position As Int, Value As Object)
	
End Sub