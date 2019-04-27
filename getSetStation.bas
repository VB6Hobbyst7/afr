B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=7.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.
#Region views
	Private clv_main As irp_CustomListView
	Private toolbar As ACToolBarDark
	Private lblCountry As Label
	
	Private lblStationCount As Label
	Private clv_letter As irp_CustomListView
	Private btn_2letter As Button 
	Private lblDefaultCountry As Label
	Private lblSkip As Label
	
#End Region
	
#Region vars
	Private btnClicked As Button
	Private switchTrue As ACSwitch
	
	Private pnlCountry As Panel
	Private ProgressBar1 As ProgressBar
	

	Private ACSwitch1 As ACSwitch
	Private btnSkip As Button
	Private imgFlag As ImageView
	Private pnlLetter_ As Panel
	Private lbl_letters As Label
	Private lblClicked As Label
#End Region
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Dim vDefCountry As String =  genDb.getCountryBookmark
	Starter.activeActivity = "getSetStation"
	Activity.LoadLayout("getSetStation")
	
	lblClicked.Initialize("")
	If vDefCountry.Length > 0 Then
		btnSkip.Text	= "Next"
		btnSkip.Visible	= True
	Else 
		lblSkip.Visible	=False
		btnSkip.Visible	= False	
	End If

	toolbar.Title	= Starter.vAppname
	toolbar.SubTitle	= "Select default country"
	
	btnClicked.Initialize("")
	switchTrue.Initialize("")
	setCountryLetters

	If clv_main.Size = 0 Then
	
	getCountries("", "")
	
	End If
End Sub


Sub endActivity
	Activity.Finish
	
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub ACButton1_Click
	
	
	
End Sub

Sub setCountryLetters
	Dim vLetters As List
	Dim vCount As Int = 1
	
	vLetters.Initialize
	vLetters.AddAll(Array As String("A - B", "C - D", "E - F", "G - H", "I - J", "K - L", "M - N", _
								 "O - P", "Q - R", "S - T", "U - V", "W - X", "Y - Z"))
	
	clv_letter.Clear
	
	For Each btn In vLetters
		If vCount = 1 Then
			clv_letter.Add(setLetters(btn, clv_letter.AsView.Height, Colors.Blue),"")
			btnClicked	= btn_2letter
			lblClicked	= lbl_letters
		Else 
			clv_letter.Add(setLetters(btn, clv_letter.AsView.Height, Colors.Black),"")
		End If
		
		vCount	= vCount +1
	Next
	
End Sub


Sub setLetters(vLetters As String, vHeight As Int, vColor As String) As Panel
	Dim p As Panel
	
	p.Initialize("")
	p.SetLayout(0,0, 80dip, vHeight+10dip)
	p.LoadLayout("letters_")
	
	lbl_letters.Text		= vLetters
	lbl_letters.Tag			= vLetters
	lbl_letters.TextColor	= vColor
	
	Return p
End Sub


Sub getCountries(firstLetter As String, secondLetter As String)
	Dim countryName, stationCount As String
	Dim defaultCountry As String	= genDb.getCountryBookmark
	ProgressBar1.Visible = True
	Sleep(10)
	If firstLetter 	= "" Then firstLetter = "A"
	If secondLetter	= "" Then secondLetter	= "B"
	
	If defaultCountry.Length > 0 Then
		toolbar.SubTitle	= "Default country selected"
		lblDefaultCountry.Text	= "Default country : " & defaultCountry
	End If
	
	clv_main.Clear	
	clv_main.sv.Visible = False
	Dim params As List
	params.Initialize
	params.Add(firstLetter)
	params.Add(secondLetter)
	
	Wait For (CallSub2(Me, "getCountryOnLetter", params)) Complete (rs1 As JdbcResultSet)
	
	Do While rs1.NextRow
		countryName		= rs1.GetString("country")
		stationCount	= rs1.GetString("total_stations")
		
		clv_main.Add(genCountryClv(countryName, stationCount, clv_main.AsView.Width, defaultCountry),"")
	Loop
	rs1.Close
	If clv_main.Size > 0 Then
		clv_main.ScrollToItem(0)
	Else 
		ToastMessageShow("Nothing found...", False)
	End If
	ProgressBar1.Visible = False
	clv_main.sv.Visible	= True
End Sub


Sub genCountryClv(countryName As String, stationCount As String, width As Int, defaultCountry As String) As Panel
	Dim p As Panel
	Dim stationCountText, flagName As String
	
	If countryName = "USA" Then
		flagName	= "united states of america.png"
		Else
		flagName	= countryName & ".png"
	End If
	
	If stationCount = 1 Then
		stationCountText	= " station"' available"
	Else 
		stationCountText	= " stations"' available"
	End If
	
	p.Initialize("")
	p.SetLayout(0,0, width, 85dip)
	
	p.LoadLayout("lstCountry")
	
	lblCountry.Text			= countryName
	lblCountry.Tag			= countryName
	lblStationCount.Text	= $"${stationCount} ${stationCountText}"$
	ACSwitch1.Tag			= countryName
	
	If File.Exists(File.DirAssets, flagName.ToLowerCase) Then
		imgFlag.Bitmap = LoadBitmap(File.DirAssets, flagName.ToLowerCase)
	End If
	
	If countryName = defaultCountry Then
		ACSwitch1.Checked		= True
		switchTrue				= ACSwitch1
	End If
		
	Return p
	
End Sub




Sub lblCountry_Click
	
End Sub



Sub ACSwitch1_CheckedChange(Checked As Boolean)
	Dim vDef As ACSwitch = Sender
	
	Dim vTag As String = vDef.Tag
	
	switchTrue.Tag 		= vDef.Tag
	switchTrue.Checked = False
	genDb.deleteDefCountry
	
	
	If Checked = True Then	
		
		genDb.setBookmark("bookmark_country", vDef.Tag)
		toolbar.SubTitle		= "Default country selected"
		lblDefaultCountry.Text	= "Default country : " & vDef.Tag
		switchTrue				= vDef
		switchTrue.Tag			= vTag
		vDef.Checked			= True
		vDef.Tag				= vTag
		btnSkip.Text			= "Next"
		btnSkip.Visible			= True
	Else 
		toolbar.SubTitle		= "Select default country"
		lblDefaultCountry.Text	= ""
		btnSkip.Visible	= False
		lblSkip.Visible	= False
	End If
End Sub



Sub getButtonLetters(lbl As Label)
	Dim firstLetter, secondLetter As String
	
	If lblClicked <> Null Then
		lblClicked.TextColor = Colors.Black
	End If
	
	lblClicked	= lbl

	lbl.TextColor	= Colors.Blue
	firstLetter		= Starter.clsFunc.stringSplit(" - ", lbl.Text, 0, False, 0, False)
	secondLetter	= Starter.clsFunc.stringSplit(" - ", lbl.Text, 0, False, 1, False)
	
	getCountries(firstLetter, secondLetter)
End Sub


Sub clv_letter_ItemClick (Index As Int, Value As Object)
End Sub


Sub btn_2letter_Click
	Dim btn As Button = Sender
	getButtonLetters(btn)
End Sub

Sub lblSkip_Click
	StartActivity(searchStation)
End Sub



Sub Connect As ResumableSub
	Starter.mysql.InitializeAsync("mysql", Starter.driver, Starter.dbl, Starter.Username, Starter.Password)
	
	Wait For MySQL_Ready (Success As Boolean)
	If Success = False Then
		Log("Check unfiltered logs for JDBC errors.")
		
	End If
	Sleep(500)
	Return Success
End Sub




Sub getCountryOnLetter(params As List) As ResumableSub
	Wait For (Connect) Complete (Success As Boolean)
	If Success Then
		Try
			Connect
			Dim sf As Object = Starter.mysql.ExecQueryAsync("mysql", "SELECT country AS country, count(*) AS total_stations FROM rdolist WHERE (SUBSTR(country,1,1) = ? OR SUBSTR(country,1,1) = ?) GROUP BY country", params)
			Wait For (sf) mysql_QueryComplete (Success As Boolean, Crsr As JdbcResultSet)
			If Success Then
				
				Return Crsr
			End If
		Catch
			Success = False
			Log(LastException)
		End Try
		
	End If
	Starter.mysql.Close
	Return Crsr
End Sub


Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		
			StartActivity(player)
			Activity.Finish
			Return True
		
		
		
		
	End If
	Return True
End Sub

Sub btnSkip_Click
	StartActivity(searchStation)
	Activity.Finish
End Sub

Sub pnlLetter__Click

End Sub


Sub lbl_letters_Click
	Dim btn As Label = Sender
	getButtonLetters(btn)
End Sub


