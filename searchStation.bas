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
	Private lbl_stationname As Label
	Private pnl_stationname As Panel
	Private lblAppHeader As Label
	Private ivCountry As ImageView
	Private lblSelectedCountry As Label
	Private ivSelectCountry As ImageView
#End Region	

#Region Vars
	Private panelPlaying As String
	Private xml As XmlLayoutBuilder
	Private panelLabelPlaying As Label
	Private panelLabelplayingText As String
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
	Private lbl_dispStationName As Label
	Private pnl_language As Panel
	Private lbl_language As Label
	Private clv_language As irp_CustomListView
	Private lblLanguageClear As Label
	Private pnlNoSearch As Panel
	Private lblStationCount As Label
	Private lblPnlNoFind As Label
	Private ivNothingFound As ImageView
	Private chkIgnoreCountry As ACCheckBox
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Starter.activeActivity = "searchStation"
	'Activity.LoadLayout("searchStation")
	Activity.LoadLayout("tsSearchStation")
	
	tsSearchMain.LoadLayout("searchStation", "Find station")
	tsSearchMain.LoadLayout("searchStationGenre", "Genre")
	tsSearchMain.LoadLayout("clvLanguage", "Language")
	
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
	
	ivNothingFound.Bitmap = LoadBitmap(File.DirAssets, "start_search.png")
	ivCountry.Bitmap = LoadBitmap(File.DirAssets,flagname)
	genGenreList
	genLanguage
	
	If FirstTime Then
		
	End If
'	lblAppHeader.Text	= Starter.vAppname
'	lblSelectedCountry.Text = vDefCountry
'	setSvg(ivSelectCountry, "baseline-language-24px.svg")
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
		Starter.clsExoPlayer.stopPlayer
		'CallSub(Starter, "StopPlayer")
		'StartActivity(player)
		If IsPaused(player) = True Then
			StartActivity(player)
		End If
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
	
	p.Initialize("")
	p.SetLayout(0,0, width, 65dip)
	p.LoadLayout("lstStat1") 
	
	pnl_stationname.Tag	= $"stationname-${stname}"$
	p.Tag = $"stationname-${stname}"$
	lbl_dispStationName.Text = stname
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
	'lblSongPlaying.Text	= playing
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
	Starter.clsExoPlayer.stopPlayer
	'CallSub(Starter, "StopPlayer")

	Starter.playerUsed	= ""
'	lblSongPlaying.Text	= ""
	lblStreamBitrate.Text = ""
End Sub

Sub streamPlaying(playing As Boolean)
	If playing = False Then
'		Log(Starter.vStationUrl)
		Starter.clsExoPlayer.stopPlayer
		'CallSub(Starter, "StopPlayer")
		ToastMessageShow("Unable to play stream..", False)
		lblStreamBitrate.Text = ""
		panelLabelPlaying.Text = "Click to start"'panelLabelplayingText
		'RESET PLAY BUTTON
		restorePanelPlayButton
		
		lblStreamBitrate.Text = ""
	End If
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
	Dim curs As Cursor = genDb.getSearchStation(params.Get(0), params.Get(1), params.Get(2), params.Get(3))
	
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
	Dim lblTag As String
	
	For i = 0 To clvStationList.Size-1
		Dim pnl As Panel = clvStationList.GetPanel(i)
		For Each v As B4XView In pnl.GetAllViewsRecursive
			lblTag =  v.Tag
			If v Is Label Then
'			Log(lblTag)
				If lblTag.IndexOf("stationname") > -1 Then
				'If v.TextColor = 0xFF0098FF Then
					If v.Color = 0xFF7fa5cf Then
					v.TextColor = Colors.Black
					v.Color = 0x00FFFFFF
				End If
				If i = index Then
						v.Color = 0xFF7fa5cf
					'v.Color = 0xFF004ba0
					v.TextColor = 0xFFFFFFFF'0xFF0098FF
				End If
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
	lbl_stream1.Text = "Click to start"
	lbl_stream2.Text = "Click to start"
	lbl_stream3.Text = "Click to start"
	
	pnl_stream1.SetElevationAnimated(0, 1dip)
	pnl_stream2.SetElevationAnimated(0, 1dip)
	pnl_stream3.SetElevationAnimated(0, 1dip)
	pnl_stream1.Enabled = False
	pnl_stream2.Enabled = False
	pnl_stream3.Enabled = False
	iv_add_favorite1.Visible = False
	iv_add_favorite2.Visible = False
	iv_add_favorite3.Visible = False
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
			'	lbl_stationname.Text = Starter.clsFunc.stringSplit("-", pnlTag, 1, True, -1, False)
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
			pnl_stream1.SetElevationAnimated(100, 3dip)
			pnl_stream1.Enabled = True
			iv_add_favorite1.Visible = True
		else If i = 1 Then
			pnl_stream2.Tag = lstStream.Get(i)
			pnl_stream2.SetElevationAnimated(210, 3dip)
			pnl_stream2.Enabled = True
			iv_add_favorite2.Visible = True
		Else
			pnl_stream3.Tag = lstStream.Get(i)
			pnl_stream3.SetElevationAnimated(300, 3dip)
			pnl_stream3.Enabled = True
			iv_add_favorite3.Visible = True
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
	Starter.lastSong = ""
	Starter.selectedStream = selectedStream
	Starter.clsExoPlayer.startPlayer(selectedStream)
	'CallSub2(Starter, "StartPlayer", selectedStream)
	Sleep(1000)
	
End Sub

Sub checkStreamplaying
	Starter.clsExoPlayer.stopPlayer
'	If modGlobal.PlayerStarted = True Then 
'		CallSub(Starter, "StopPlayer")
'		Sleep(1000)
'	End If
		
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
	Dim streamCount, rowCnt As Int
	Dim genre, lang, vCountry As String = ""
	
	If chkIgnoreCountry.Checked Then
		vCountry = "%"
	Else 
		vCountry = $"%${vDefCountry}%"$	
	End If
	lblStationCount.Text = ""
	
	If lblGenre.Text <> "Genre" Then
		genre = lblGenre.Text
	End If
	
	If lblLanguage.Text <> "Language" Then
		lang = "%"&lblLanguage.Text&"%"
	End If
	params.Initialize

	If vText.Length < 2 And lblGenre.Text = "" And lblLanguage.Text = "" Then
		Return
	End If
	
	
	checkAarPlaying
'	ProgressBar1.Visible = True
	Sleep(10)
'	If vText.Length > 0 Then
	vText	= "%"&vText&"%"
	params.Add(vText)
	params.Add(vDefCountry)
		
		
	clvStationList.Clear
	clvStationList.sv.Visible = False
	'Dim rs As Cursor = genDb.getSearchStation(vText, vDefCountry, genre, lang)
	Dim rs As Cursor = genDb.getSearchStation(vText, vCountry, genre, lang)
'	Log($"ROW COUNT ${rs.RowCount}"$)
	If rs.RowCount < 0 Then
		rowCnt = 0
	Else
		rowCnt = rs.RowCount
	End If
		
	If rs.RowCount <= 0 Then
		'lblPnlNoFind.Text = $"${rowCnt} ${Starter.clsFunc.singularPlural("station", rowCnt)} found"$
		ivNothingFound.Bitmap = LoadBitmap(File.DirAssets, "nothing_found.png")
	End If
		pnlNoSearch.Visible = rs.RowCount <= 0
		
	lblStationCount.Text = $"${rowCnt} ${Starter.clsFunc.singularPlural("station", rowCnt)} found"$
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
'			ProgressBar1.Visible	= False
'		ToastMessageShow("Nothing found..", False)
		Return
	End If
		
	clvStationList.ScrollToItem(0)
'		ProgressBar1.Visible	= False
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
	'CallSub(Starter,"StopPlayer")
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
'	lbl_stationname.Text = "Tap above to search"
	reflect.Target = edt_find
	reflect.RunMethod("clearFocus")
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
		Starter.clsExoPlayer.stopPlayer
		'CallSub(Starter, "StopPlayer")
		'Sleep(500)
		
'		lblSongPlaying.Text = ""
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
	
	lbl_stream1.Text = "Loading stream.."
	If pnl_stream1.tag = "" Then Return
	panelPlaying = "pnl_stream1"
	lbl_stream1.Tag = "Click to start"
	panelLabelPlaying = lbl_stream1
	panelLabelPlaying.Tag = lbl_stream1.Tag
	panelLabelplayingText = lbl_stream1.Text
	createPanelStopButton(iv_start_stop1)
	
	
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
	lbl_stream2.Text = "Loading stream.."
	If pnl_stream2.tag = "" Then Return
	panelPlaying = "pnl_stream2"
	lbl_stream2.Tag = "Click to start"
	panelLabelPlaying = lbl_stream2
	panelLabelplayingText = lbl_stream2.Text
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
	lbl_stream3.Text = "Loading stream.."
	If pnl_stream3.tag = "" Then Return
	panelPlaying = "pnl_stream3"
	lbl_stream3.Tag = "Click to start"
	panelLabelPlaying = lbl_stream3
	panelLabelplayingText = lbl_stream3.Text
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

Sub showUserGettingRDS
	panelLabelPlaying.Text = "Search for song playing.."
	Sleep(10)
End Sub

Sub showUserTryingToStartStream (tryCount As Int)
	panelLabelPlaying.Text = $"Opening stream [ ${tryCount} ]"$
	Sleep(0)
End Sub

Sub unableToPlaySTream
	ToastMessageShow("Unable to play stream..", False)
	panelLabelPlaying.Text = "Click to start"
End Sub

Sub clvCountryGenre_ItemClick (Index As Int, Value As Object)
	Dim pnl As Panel = clvCountryGenre.GetPanel(Index)
	lblGenre.Text = pnl.Tag
	
	tsSearchMain.ScrollTo(0, False)
	lblGenreClear.Visible = True
	edt_find_EnterPressed
End Sub

Sub lblGenreClear_Click
	lblGenre.Text = "Genre"
	
	lblGenreClear.Visible = False
End Sub

Sub genLanguage
	Dim curs As Cursor = genDb.languageCountry(vDefCountry)
	
	For i = 0 To curs.RowCount-1
		curs.Position = i
		clv_language.Add(genListGenre(curs.GetString("language"), clv_language.AsView.Width),"")
	Next
	
End Sub

Sub genListLanguage(lang As String, width As Int ) As Panel
	
	Dim p As Panel
	p.Initialize("")
	p.SetLayout(0,0, width, 61dip)
	p.LoadLayout("lstLanguage") 
	
	p.Tag = lang
	lbl_language.Text = lang
	Return p
End Sub


Sub pnl_language_Click
	
End Sub

Sub lblLanguage_Click
	tsSearchMain.ScrollTo(2, True)
End Sub

Sub clv_language_ItemClick (Index As Int, Value As Object)
	Dim pnl As Panel = clv_language.GetPanel(Index)
	lblLanguage.Text = pnl.Tag
	
	tsSearchMain.ScrollTo(0, False)
	lblLanguageClear.Visible = True
	edt_find_EnterPressed
End Sub

Sub lblLanguageClear_Click
	lblLanguageClear.Visible = False
	lblLanguage.Text = "Language"
End Sub