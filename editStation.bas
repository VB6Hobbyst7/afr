B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=7.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.
	Private suggestionEmail As String = "pieter09@gmail.com"
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
	Dim cs As CSBuilder
	
#Region Vars

#End Region	

	
#Region views
	Private pnl_suggest_station As Panel
	Private lbl_station_name As Label
	Private lbl_station_url As Label
	Private lbl_station_description As Label
	Private edt_station_name As EditText
	Private edt_station_url As EditText
	Private edt_station_description As EditText
	Private btnSave As ACButton
#End Region	
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("editStation")
	cs.Initialize.Color(Colors.black).Append("Submit suggestion ")
	cs.Bold.Color(Colors.red).Append("via email").Popall
	btnSave.Text = cs
	
	edt_station_name.InputType			= Bit.Or(edt_station_name.InputType, 524288)
	edt_station_url.InputType			= Bit.Or(edt_station_url.InputType, 524288)
	edt_station_description.InputType	= Bit.Or(edt_station_description.InputType, 524288)
	edt_station_name.RequestFocus
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	Activity.Finish
	Return True
End Sub

Sub btnSave_Click
	Dim email As Email
	
	If edt_station_name.Text ="" Then
		Msgbox("Provide a station name", "Adfree Radio")
		edt_station_name.Hint = "e.g. Rocking the nation FM"
		Return
	End If
	
	If edt_station_url.Text = "" Then
		Msgbox("Provide station url", "Adfree Radio")
		edt_station_url.Hint = "e.g. https://radio.stream.com"
		Return
	End If
	
	cs.Initialize.color(Colors.Black).Underline.Append("Station name").Append(CRLF)
	cs.bold.Append(edt_station_name.Text).Append(CRLF).Append(CRLF)
	cs.Append("Station url").Typeface(Typeface.DEFAULT_BOLD).Append(CRLF)
	cs.bold.Append(edt_station_url.Text).Append(CRLF).Append(CRLF)
	cs.Append("Station description").Typeface(Typeface.DEFAULT_BOLD).Append(CRLF)
	cs.bold.Append(edt_station_description.Text).PopAll
	
	email.To.Add(suggestionEmail)
	email.Subject = "Adfee Radio : Station suggestion"
	email.Body	= cs			   
	StartActivity(email.GetIntent)
	Activity.Finish
End Sub