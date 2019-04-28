B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=7.8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
	#IgnoreWarnings: 9, 10, 12
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	Public stationUrl As String
	Dim bm As Bitmap
End Sub

Sub Globals
	Private clsScrllLabel As clsScrollLabel
	
#Region Views 
	Private clvStationList As irp_CustomListView
	Private lblStreamCount As Label
	Private ProgressBar1 As ProgressBar
	Private pnlStation As Panel
	Private pnlStationData As Panel
	Private lblStreamBitrate As Label
	Private edt_find As EditText
	Private btn_clear_search As Label
	Private edt_station_name As EmphasisTextView
	Private lbl_stationname As Label
	Private pnl_stationname As Panel
	Private lblAppHeader As Label
	Private ivCountry As ImageView
	Private lblSelectedCountry As Label
	Private ivSelectCountry As ImageView
	Private edt_dummy As EditText
#End Region	

#Region Vars
	Private panelPlaying As String
	Private xml As XmlLayoutBuilder
	Private panelLabelPlaying As Label
	Private vDefCountry As String
	Private vStreamLst As List
	Private panelIndex As Int = -1
	Private panelStationId As String
	Private selected_playButton As Button
	Private showRestartInfo As Int = 0
	Private imgUrlRetry As Int = 0
	Private stationName As String
	Private lblSongPlaying As Label
	
	
#End Region	
	
	Private flagname As String
	
	Private pnl_stream1 As Panel
	Private iv_start_stop1 As ImageView
	Private iv_add_favorite1 As ImageView
	
	Private pnl_stream2 As Panel
	Private iv_start_stop2 As ImageView
	Private iv_add_favorite2 As ImageView
	Private pnl_stream3 As Panel
	Private iv_start_stop3 As ImageView
	Private iv_add_favorite3 As ImageView
	Private lbl_stream1 As Label
	Private lbl_stream2 As Label
	Private lbl_stream3 As Label
	
	Private nowPlayingText As String
	Private clsScrllLabel As clsScrollLabel
	Private tsSearchMain As TabStrip
	Private lblSearch As Label
	Private lblGenreName As Label
	Private pnlGenreName As Panel
	Private pnlClvGenre As Panel
	Private clvCountryGenre As irp_CustomListView
	Private pnlGenre As Panel
	Private pnlListGenreName As Panel
	Private lblGenre As Label
	Private lblLanguage As Label
	Private lblGenreClear As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Starter.activeActivity = "searchStation"
	'Activity.LoadLayout("searchStation")
	Activity.LoadLayout("tsSearchStation")
	
	tsSearchMain.LoadLayout("searchStation", "Find station")
	tsSearchMain.LoadLayout("searchStationGenre", "Genre")
	
	Private cd As ColorDrawable
	cd.Initialize(Colors.Transparent, 0)
	edt_find.Background = cd
	'****SHOW VOLUMEBAR FROM CLASS*********************
	Private clsGenVol As clsGenVolumeControl
	clsGenVol.Initialize
	Dim volPanel As Panel = clsGenVol.setupMainVolumePanel
	Activity.AddView(volPanel, Activity.Width-50dip, (Activity.Height-volPanel.Height)-20, volPanel.Width, volPanel.Height)
	'***************************
	
	clsScrllLabel.Initialize
	vDefCountry	= genDb.getCountryBookmark
	If vDefCountry = "USA" Then
		flagname	= "united states of america.png"
	Else
		flagname	= vDefCountry & ".png"
	End If
	
	ivCountry.Bitmap = LoadBitmap(File.DirAssets,flagname)
	genGenreList
	
	If FirstTime Then
		
	End If
	lblAppHeader.Text	= Starter.vAppname
	lblSelectedCountry.Text = vDefCountry
	setSvg(ivSelectCountry, "baseline-language-24px.svg")
	Starter.activeActivity		= "searchStation"
	createStreamPanel(pnl_stream1, iv_start_stop1, iv_add_favorite1)
	createStreamPanel(pnl_stream2, iv_start_stop2, iv_add_favorite2)
	createStreamPanel(pnl_stream3, iv_start_stop3, iv_add_favorite3)
	panelLabelPlaying.Initialize("")
	getGenryCountry
End Sub

Sub Activity_Resume
	
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		CallSub(Starter, "StopPlayer")
		Activity.Finish
		Return False
	End If
	Return True
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
	End If
End Sub

Sub getStationStreams(rs As Cursor) As String
	
	Dim vStream As String = "stream"
	Dim i As Int
	Dim vStreamCount As Int	= 0
	
	
	vStreamLst.Initialize
	vStreamLst.Clear
	For i = 1 To 4
	
		If rs.GetString(vStream&i) <> "-" And rs.GetString(vStream&i) <> Null And rs.GetString(vStream&i).SubString2(0,1) <> "+" Then
			vStreamLst.Add(rs.GetString(vStream&i)&","& vStream&i)
			vStreamCount	= vStreamCount+1
		End If
		
	Next
	
	Return vStreamCount
End Sub

Sub genStationList(stname As String, genre As String, info As String, width As Int, streams As String, language As String, rdoId As String) As Panel
	
	Dim p As Panel
	Dim streamText As String = " Stream"
	Dim streamCount As Int = 1
	Dim vFind As String	= edt_find.Text
	
	p.Initialize("")
	p.SetLayout(0,0, width, 61dip)
	p.LoadLayout("lstStat1") 
	
	pnl_stationname.Tag						= $"stationname-${stname}"$
	p.Tag = $"stationname-${stname}"$
	edt_station_name.Enabled				= True
	edt_station_name.CaseInsensitive		= True
	edt_station_name.Text					= stname
	edt_station_name.TextToHighlight		= vFind
	edt_station_name.TextHighlightColor		= "#C5C5C5"
	edt_station_name.highlight
	edt_station_name.TextSize				= 18
	edt_station_name.TextColor				= Colors.Black

	p.Tag	= rdoId

	If vStreamLst.Size > 3 Then
		streamCount = 3
	Else
		streamCount	= vStreamLst.Size
	End If
	
	If streamCount > 1 Then
		streamText = " streams"
	End If
	
	lblStreamCount.Text	= streamCount & streamText
	Return p
End Sub

Sub lblStationInfo_Click
	Dim lbl As Label = Sender
		
End Sub

Sub nowPlaying(playing As String)
	lblSongPlaying.Text	= playing
	panelLabelPlaying.Text = playing
	nowPlayingText = playing
	
	clsScrllLabel.runMarquee(panelLabelPlaying, playing, "MARQUEE")
End Sub

Private Sub scrollTimer_Tick
	Dim strTemp As String
	strTemp = nowPlayingText.SubString2(0,1)
	nowPlayingText = nowPlayingText.SubString(1) & strTemp
	lbl_stream1.Ellipsize = "MARQUEE"
	Dim jo As JavaObject = lbl_stream1
	Sleep(0)
	jo.RunMethod ("setSelected", Array (True))
	lbl_stream1.Text = nowPlayingText
End Sub

Sub checkAarPlaying
	CallSub(Starter, "StopPlayer")

	Starter.playerUsed	= ""
	lblSongPlaying.Text	= ""
	lblStreamBitrate.Text = ""
End Sub

Sub streamPlaying(playing As Boolean)
	If playing = False Then
		Log(Starter.vStationUrl)
		
		If Starter.playerUsed	= "aac" Then
			CallSub(Starter, "StopPlayer")
			ToastMessageShow("Unable to play stream..", False)
			lblStreamBitrate.Text = ""
			'RESET PLAY BUTTON
			restorePanelPlayButton
			Return
	
		End If
	End If
	lblStreamBitrate.Text = ""
End Sub

Sub showSnackbar(msg As String)
	Dim snack As DSSnackbar
	snack.Initialize("Snack", Activity, msg, snack.DURATION_LONG)
	snack.Show
End Sub

Sub lblEditStation_Click
	StartActivity(editStation)
End Sub



Sub getsearchStation(params As List) As Cursor
	Dim curs As Cursor = genDb.getSearchStation(params.Get(0), params.Get(1), params.Get(2))
	
	Return curs
End Sub


Sub getStationStream(params As List) As Cursor
	Dim rs As Cursor = genDb.getStationStream(params.Get(0))
	
	Return rs

End Sub

Sub lblstream_LongClick
	Dim lbl As Label = Sender
	Dim stationId As String
	Dim params As List
		
	stationId = Starter.clsFunc.stringSplit(",", lbl.Tag, -1, False, 1, False)
	
	If genDb.checkStationInPresets(stationId, Starter.clsFunc.stringSplit(",", lbl.Tag, -1, False,0, False)) = False Then
		genDb.getPresetStations
		showSnackbar("Station exists in station list")
		Return
	End If

	params.Initialize
	params.Add(stationId)
	
End Sub

Sub addStation(stationId As String, stream As String)
	
	Dim params As List
	
	
	If genDb.checkStationInPresetsNew(panelStationId) = False Then
		genDb.getPresetStations
		showSnackbar("Station exists in station list")
		Return
	End If

	params.Initialize
	params.Add(panelStationId)
	
	getStationData(panelStationId, stream, panelIndex)
	Starter.stationAdded = 1
	
End Sub

Sub getStationData(id As String, stream As String, stationId As String)
	Dim curs As Cursor = genDb.getStationForPreset(id)
	
	curs.Position = 0
	genDb.addStationToPreset(curs.GetString("stname"), curs.GetString("description"), curs.GetString("genre"),curs.GetString("country"), curs.GetString("language"),stream, curs.GetString("rdo_id"))
	ToastMessageShow(curs.GetString("stname") & " added to presets", False)
 
End Sub

Sub clvStationList_ItemClick (Index As Int, Value As Object)
	checkAarPlaying
	setClickedPanelColor(Index)
	
	panelIndex = Index
	
	getStationInfo(Index)
End Sub

Private Sub setStationTextColor(color As Int, index As Int)
	Dim i As Int
	Dim pnl As Panel
	
	For i = 0 To clvStationList.Size-1
		Dim pnl As Panel = clvStationList.GetPanel(i)
		For Each v As B4XView In pnl.GetAllViewsRecursive
			If v Is Label Then
				If v.TextColor = 0xFF0098FF Then
					v.TextColor = Colors.Black
				End If
				If i = index Then
				v.TextColor = 0xFF0098FF
				End If
			End If
		Next
	Next
	
End Sub

Private Sub resetPanels
	clsScrllLabel.Initialize
	pnl_stream1.Tag = ""
	pnl_stream2.Tag = ""
	pnl_stream3.Tag = ""
	lbl_stream1.Text = "Stream 1"
	lbl_stream2.Text = "Stream 2"
	lbl_stream3.Text = "Stream 3"
	
	pnl_stream1.SetElevationAnimated(0, 1dip)
	pnl_stream2.SetElevationAnimated(0, 1dip)
	pnl_stream3.SetElevationAnimated(0, 1dip)
End Sub

'PANEL CLICKED
Sub getStationInfo(index As Int)
	setStationTextColor(0, index)
	
	resetPanels
	'STATION PANEL CLICK
	Dim pnl As Panel = clvStationList.GetPanel(index)
	Dim param, lstStream As List
	Dim  pnlTag As String

	For Each v As B4XView In pnl.GetAllViewsRecursive
		If v Is Panel Then
			pnlTag = v.Tag
			If pnlTag.IndexOf("stationname-") > -1 Then
				lbl_stationname.Text = Starter.clsFunc.stringSplit("-", pnlTag, 1, True, -1, False)
				Exit
			End If
		End If
	Next
	
	panelStationId = pnl.tag

	param.Initialize
	param.Add(panelStationId)
	
	Dim rs As Cursor = getStationStream(param)
	lstStream.Initialize

	For i = 0 To rs.RowCount-1
		rs.Position = i
		pnlStationData.Tag = rs.GetString("rdo_id")
		lstStream.Add(rs.GetString("stream1"))
		lstStream.Add(rs.GetString("stream2"))
		lstStream.Add(rs.GetString("stream3"))
	Next
	rs.Close
	
	
	Dim stream As String
	
	For i = lstStream.Size-1 To 0 Step -1
		stream = lstStream.Get(i)
		
		If stream.IndexOf("+") > -1 Or stream.Length < 4 Then
			lstStream.RemoveAt(i)
		End If
		
	Next
	
	
	For i = 0 To lstStream.Size -1
		If i = 0 Then
			pnl_stream1.Tag = lstStream.Get(i)
			pnl_stream1.SetElevationAnimated(100, 4dip)
		else If i = 1 Then
			pnl_stream2.Tag = lstStream.Get(i)
			pnl_stream2.SetElevationAnimated(210, 4dip)
		Else
			pnl_stream3.Tag = lstStream.Get(i)
			pnl_stream3.SetElevationAnimated(300, 4dip)
		End If
	Next
	Sleep(300)
End Sub

'SET CLICKED PANEL COLOR
Sub setClickedPanelColor(index As Int)
	For pnlIndex = 0 To clvStationList.Size-1
		Dim pnl As Panel = clvStationList.GetPanel(pnlIndex)
		pnl.Elevation = 0dip
		If(index = pnlIndex) Then
			pnl.Elevation = 8dip
		End If
		
	Next
	
End Sub

Sub playSelectedStream(selectedStream As String)
	Starter.playerUsed	= "aac"
	checkStreamplaying
	
	CallSub2(Starter, "StartPlayer", selectedStream)
	Sleep(1000)
	
End Sub

Sub checkStreamplaying
	If modGlobal.PlayerStarted = True Then 
		CallSub(Starter, "StopPlayer")
		Sleep(1000)
	End If
		
End Sub

Sub setStreamBitRate(bitrate As String)
	lblStreamBitrate.Text	= "" & bitrate
End Sub

Sub endActivity
	Activity.Finish
End Sub

Sub edt_find_FocusChanged (HasFocus As Boolean)
	If HasFocus = True Then
		edt_find.Typeface	= Typeface.SANS_SERIF
		Return
	End If
	
	If HasFocus = False	And edt_find.TextSize = 0 Then
		edt_find.Typeface = Typeface.MATERIALICONS
	End If
		
End Sub

Sub edt_find_TextChanged (Old As String, New As String)
'	If New <> "" Then
'		edt_find.Typeface = Typeface.SANS_SERIF
'	Else 
'		edt_find.Typeface = Typeface.MATERIALICONS
'	End If
	
	If New.Length < 2 Then
		edt_find.TextColor = Colors.Red
	Else 
		edt_find.TextColor = Colors.Black	
	End If
	
End Sub

Sub edt_find_EnterPressed
	Dim vText As String	= edt_find.Text
	Dim params As List
	Dim streamCount As Int
	Dim genre As String = ""
	
	If lblGenre.Text <> "Genre" Then
		genre = lblGenre.Text
	End If
	params.Initialize

	If vText.Length < 2 And lblGenre.Text = "" And lblLanguage.Text = "" Then
		Return
	End If
	
	
	checkAarPlaying
	ProgressBar1.Visible = True
	Sleep(10)
'	If vText.Length > 0 Then
		vText	= "%"&vText&"%"
		params.Add(vText)
		params.Add(vDefCountry)
		
		
		clvStationList.Clear
		clvStationList.sv.Visible = False
		Dim rs As Cursor = genDb.getSearchStation(vText, vDefCountry, genre)
		
		For i = 0 To rs.RowCount-1
			rs.Position = i
			
			streamCount = getStationStreams(rs)
			If streamCount = 0 Then
				Continue
			End If
			clvStationList.Add(genStationList(rs.GetString("stname"), rs.GetString("genre"), rs.GetString("description"), _
											   clvStationList.AsView.Width, streamCount, rs.GetString("language"), rs.GetInt("rdo_id")),"")
		Next
		
		rs.Close
		clvStationList.sv.Visible = True
		If clvStationList.Size = 0 Then
			ProgressBar1.Visible	= False
			ToastMessageShow("Nothing found..", False)
			Return
		End If
		
		clvStationList.ScrollToItem(0)
		ProgressBar1.Visible	= False
		panelIndex		= 0
		Sleep(0)
		getStationInfo(0)
'	End If
End Sub

Sub ivCountry_Click
	showCountryList
End Sub

Sub lblSelectedCountry_Click
	showCountryList
End Sub

Private Sub showCountryList
	CallSub(Starter,"StopPlayer")
	StartActivity(getSetStation)
	Activity.Finish
End Sub

Sub ivSelectCountry_Click
	showCountryList
End Sub

Private Sub setSvg(view As ImageView, svg As String)
	Dim tCanvas As Canvas
	tCanvas.Initialize(view)

	Dim svgGen As ioxSVG
	
	svgGen.Initialize(svg)
	svgGen.DocumentWidth = view.Width
	svgGen.DocumentHeight = view.Height
	svgGen.RenderToCanvas(tCanvas)
End Sub

Sub btn_clear_search_Click
	Dim im As IME
	Dim reflect As Reflector

	im.Initialize("")
	im.HideKeyboard
	edt_find.Text = ""
	clvStationList.Clear
	edt_find.Hint = "station name"
	lbl_stationname.Text = "Tap above to search"
	reflect.Target = edt_find
	reflect.RunMethod("clearFocus")
	edt_dummy.RequestFocus
End Sub

Private Sub createStreamPanel(pnl As Panel, startStop As ImageView, addFavorite As ImageView)
	startStop.Bitmap = LoadBitmap(File.DirAssets, "play32.png")
	addFavorite.Background = xml.GetDrawable("outline_playlist_add_black_24")
End Sub

Private Sub createStreamTag(streamCount As Int, stream As String)
	If streamCount = 1 Then
		pnl_stream1.Tag = stream
		pnl_stream1.SetElevationAnimated(0, 8dip)
	else If streamCount = 2 Then
		pnl_stream2.Tag = stream
		pnl_stream2.SetElevationAnimated(0, 8dip)
	else If streamCount = 3 Then
		pnl_stream3.Tag = stream
		pnl_stream3.SetElevationAnimated(0, 8dip)
	End If
End Sub

Private Sub restorePanelPlayButton
	createStreamPanel(pnl_stream1, iv_start_stop1, iv_add_favorite1)
	createStreamPanel(pnl_stream2, iv_start_stop2, iv_add_favorite2)
	createStreamPanel(pnl_stream3, iv_start_stop3, iv_add_favorite3)
End Sub

Private Sub createPanelStopButton(startStop As ImageView)
	startStop.Bitmap = LoadBitmap(File.DirAssets, "stop.png")
End Sub

Private Sub panel_clicked(tag As String) As Boolean
	Dim retVal As Boolean = False
	
	
	If Starter.clsFunc.IsStreamActive(3) = True And tag = panelLabelPlaying.Tag Then
		retVal = True
		
	End If
	
	If Starter.clsFunc.IsStreamActive(3) = True Then
		CallSub(Starter, "StopPlayer")
		'Sleep(500)
		
		lblSongPlaying.Text = ""
		lblStreamBitrate.Text = ""
		clsScrllLabel.runMarquee(panelLabelPlaying, panelLabelPlaying.Tag, "MARQUEE")
		clsScrllLabel.Initialize
		panelLabelPlaying.Text = panelLabelPlaying.Tag
		
		restorePanelPlayButton
	End If
	
	Return retVal
End Sub

Sub pnl_stream1_Click
	Dim panelIsPanel As Boolean = panel_clicked(lbl_stream1.Tag)
	
	Sleep(500)
	If(panelIsPanel) Then Return
	

	If pnl_stream1.tag = "" Then Return
	panelPlaying = "pnl_stream1"
	lbl_stream1.Tag = "Stream 1"
	panelLabelPlaying = lbl_stream1
	panelLabelPlaying.Tag = lbl_stream1.Tag
	createPanelStopButton(iv_start_stop1)
	Log(pnl_stream1.Tag)
	playSelectedStream(pnl_stream1.Tag)
End Sub

Sub iv_start_stop1_Click
	
End Sub

Sub iv_add_favorite1_Click
	addStation(pnlStationData.Tag, pnl_stream1.Tag)
End Sub

Sub pnl_stream2_Click
	Dim panelIsPanel As Boolean = panel_clicked(lbl_stream2.Tag)
	
	Sleep(500)
	If(panelIsPanel) Then Return

	If pnl_stream2.tag = "" Then Return
	panelPlaying = "pnl_stream2"
	lbl_stream2.Tag = "Stream 2"
	panelLabelPlaying = lbl_stream2
	createPanelStopButton(iv_start_stop2)
	playSelectedStream(pnl_stream2.Tag)
	
	
End Sub

Sub iv_add_favorite2_Click
	addStation(pnlStationData.Tag, pnl_stream2.Tag)
End Sub

Sub iv_add_favorite3_Click
	addStation(pnlStationData.Tag, pnl_stream3.Tag)
End Sub

Sub pnl_stream3_Click
	Dim panelIsPanel As Boolean = panel_clicked(lbl_stream3.Tag)
	
	Sleep(500)
	If(panelIsPanel) Then Return
	
	If pnl_stream3.tag = "" Then Return
	panelPlaying = "pnl_stream3"
	lbl_stream3.Tag = "Stream 3"
	panelLabelPlaying = lbl_stream3
	createPanelStopButton(iv_start_stop3)
	playSelectedStream(pnl_stream3.Tag)
End Sub


Sub getGenryCountry
	Dim cur As Cursor = genDb.genrneCountry(vDefCountry)
End Sub
'
'Sub pullStationUrl(stUrl As String)
'	Return
'	Dim url As String
'	Log("SEARCHSTATION : " &stUrl)
'	
'	If bm.IsInitialized = False Then
'		
'	End If
'	url = $"https://logo.clearbit.com/${stUrl}/?size=150&format=png"$
'	Dim j As HttpJob
'	j.Initialize("", Me)
'	j.Download(url)
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		bm = j.GetBitmap
'		bm.Resize(150, 150, True)
'		ivLogoStation.Bitmap = bm
'		j.Release
'		Return
'	Else 
'		j.Release
'		pullStationUrl(stripUrl(stUrl))
'	End If
'	
'End Sub


'Sub stripUrl(url As String) As String
'	Dim countSlash, slashIndex As Int
'	Dim newUrl As String
'	
'	countSlash = cmGen.CountChar(url, "/")
'	
'	If countSlash > 2 Then
'		slashIndex	= cmGen.getFirstSlash(url,"/")
'		newUrl		= url.SubString2(0, slashIndex)
'	End If
'	
'	If newUrl.Length > 0 Then
'		Return newUrl
'	End If
'	
'End Sub

Sub lblSearch_Click
	edt_find_EnterPressed
End Sub

Sub pnlGenreName_Click
	tsSearchMain.ScrollTo(2, True)
End Sub

Sub genGenreList
	Dim curs As Cursor = genDb.genrneCountry(vDefCountry)
	
	For i = 0 To curs.RowCount-1
		curs.Position = i
		clvCountryGenre.Add(genListGenre(curs.GetString("genre"), clvCountryGenre.AsView.Width),"")
	Next
End Sub

Sub genListGenre(genre As String, width As Int ) As Panel
	
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 61dip)
	p.LoadLayout("genreList") 
	
	p.Tag = genre
	lblGenreName.Text = genre
	Return p
End Sub

Sub pnlGenre_Click
	tsSearchMain.ScrollTo(1, True)
End Sub


Sub clvCountryGenre_ItemClick (Index As Int, Value As Object)
	Dim pnl As Panel = clvCountryGenre.GetPanel(Index)
	lblGenre.Text = pnl.Tag
	
	tsSearchMain.ScrollTo(0, True)
	lblGenreClear.Visible = True
End Sub

Sub lblGenreClear_Click
	lblGenre.Text = "Genre"
	
	lblGenreClear.Visible = False
End Sub