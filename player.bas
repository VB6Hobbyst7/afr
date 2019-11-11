B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=7.8
@EndOfDesignText@
#IgnoreWarnings: 9, 1, 10
#Region  Activity Attributes 
	#FullScreen: false
	#IncludeTitle: false
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	Public bckBtnClickCount As Int = 1
'	Private kvs As KeyValueStore
	Private processingPanel, currMusicVolume As Int
	Private pg_playing, pg_station, stationLogoPath As String
	Public pg_artistAlbum As Bitmap
	Private clsGen As clsGeneral
	Private tmr As Timer
	Dim hideTmr As clsGenTimer
	
End Sub


Sub Globals
	Dim noInetMessage As String
	Private DetailsDialog As CustomLayoutDialog
	Dim dialog As B4XDialog
	Dim selectedStationName, stream As String
	Dim selectedStationId, selectedPanel As Int
	Private clsVol As clsDeviceVolume
	Private toolbar As ACToolBarDark
	Private pnlControl As Panel
	Private acVolume As ACSeekBar
	Public mView As Map
	Public phone As Phone
	Private stationinfo As String
	Private pnlSongText As Panel
	Private pnlStation As Panel
	Private imgUrlRetry As Int = 0
	Private clvPlayer As irp_CustomListView'expClv
'	Private dirArrow As ImageView
	Private Switch As ACSwitch
	Private SwitchUpdateLogo As ACSwitch
	Private SwitchCaps As ACSwitch
	Private NavDrawer As DSNavigationDrawer
	Private ivNowPlaying As ImageView
	Private xml As XmlLayoutBuilder
	Private pnl_station_logo As Panel
	Private iv_station_logo As ImageView
	Private pnlClicked As Int = 0
	Private pnlNowPlaying As Panel
	Private img_bluetooth As ImageView
	Private ivNowPlayingStation As ImageView
	Private pnlPlayingStation As Panel
'	Private wvLyric As WebView
	Private btn_img_stop As ImageView
	Private pnl_stop_button As Panel
	Private pnl_lyric_button As Panel
	Private btn_img_lyric As ImageView
	Private pnl_store_song_button As Panel
	Private btn_img_store_song As ImageView
	Private pnl_album_info_button As Panel
	Private btn_img_album_info As ImageView
	Private pnl_new_station_button As Panel
	Private btn_img_new_station As ImageView
	Private pnlOverflow As Panel
	Private xSlider As B4XView
	
#region labels
	
	
	Private lblConnectionType As Label
	Private lblPlayingRef As Label
	Private lblPlayingButtonRef As Label
	Private lblConnectionInfo As Label
	Private lblMaxVolume As Label
	Private lblStationName As Label
	Private lblDataUsage As Label
	Private lblHeaderPlayButton As Label
'	Private lblOverflow As Label
	Private lblStationInformation As Label
	Private lblBtnStationInformation As Label
	Private lblBtnDeleteStation As Label
	Private lblDeleteStation As Label
'	Private lblStationLogo As Label
	Private lblOpenStationUrl As Label
	Private lblNowPlayingDataRate As Label
	Private lblNowPlayingStation As Label
	Private lblArtistNowPlaying As Label
	Private lblNavDrawerSubTitle As Label
	Private lblNavDrawerHeader As Label
	Private lbl_close As Label
	Private lbl_stop_playing As Label
	Private lbl_stream_lost As Label
	Private lbl_time_now As Label
	Private lbl_countdown_timer As Label
	Public lbl_toolbar_clock As Label
	Private lblGenre As Label
	Private Label1 As Label
	Private lblbtnopenurl As Label
	Private lblNavDrawerHeader As Label
'	Private ImgSvg As ImageView
	Private svgInfo As ImageView
	Private img_close As ImageView
	Private pnl_volume As Panel
	Dim clsScroll As clsScrollLabel
	Dim clsScroll1 As clsScrollLabel
	Private clsFunc As clsFunctions
	
#end region

	
	Private img_volume As ImageView
	Private pnl_volume_slider As Panel
	Private lbl_volume As Label
	Private lbl_station_name As Label
	Private pnlTimer As Panel
	Private pnl_img As Panel
	Private pnl_block As Panel
	Private ivSpotAlbum As ImageView
	Private lblSpotAlbumName As Label
	Private lblSpotTrackNr As Label
	Private lblSpotReleaseDate As Label
	Private smallStationLogo As Bitmap
'	Private lblSpotSongNow As Label
	Private btnSpotOpenInBrowser As Button
	Private lblSpotArtist As Label
	Private lblSpotSong As Label
	Private lblSpotDuration As Label
	Private ivSpotify As ImageView
	Private lbl_lyric_title As Label
	Private pnl_lyric As Panel
	
	'Private lbl_playing_text As Label
	
	Private edt_playing_format As EditText
	Private lbl_playing_text As B4XView
	Private lbl_playing_stname As B4XView
	Private lblForId As B4XView
	Private lblIsArtist As Label
	Private lblIsArtist1 As Label
	Private swIsArtist As ACSwitch
	Private swIsArtist1 As ACSwitch
	
	Private lblRandomImage As B4XView
	Private BBCodeView1 As BBCodeView
	Private xui As XUI
	Private wvLyric As WebView
End Sub


Sub Activity_Create(FirstTime As Boolean)
	'pnlRnd.Initialize("")
	tmr.Initialize("disableClickTimer", 1000)
	tmr.Enabled = False
	hideTmr.Initialize(5000, "hideOverFlow")
	'kvs.Initialize(Starter.irp_dbFolder, "settings", True)
	Starter.activeActivity = "Player"
	NavDrawer.Initialize2("NavDrawer", Activity, NavDrawer.DefaultDrawerWidth, NavDrawer.GRAVITY_START)
	
	Activity.LoadLayout("player")
	'lblRandomImage.Initialize("")
	lblRandomImage.SetRotationAnimated(0, 90)
	lblRandomImage.Top=pnlNowPlaying.Top+30dip
	pnl_volume_slider.BringToFront
	pnlPlayingStation.SetVisibleAnimated(0, False)
	'rsip.Initialize
	
'	'*************************
'	Private clsGenVol As clsGenVolumeControl
'	clsGenVol.Initialize
'	Dim volPanel As Panel = clsGenVol.setupMainVolumePanel
'	Activity.AddView(volPanel, Activity.Width-50dip, (Activity.Height-volPanel.Height)-75dip, volPanel.Width, volPanel.Height)
'	'***************************
	
	xSlider = acVolume
	clsVol.Initialize(acVolume, lbl_volume)
	xSlider.BringToFront
	xSlider.SetRotationAnimated(0, -90)
	setVolumePanel
	clsGen.Initialize
	clsFunc.Initialize
	
	setCtrlButtonsBorder
	
	
	lblDataUsage.Text	= ""
'	createToolbarClock
	NavDrawer.InitDrawerToggle
	
	toolbar.InitMenuListener
	toolbar.Title	= Starter.vAppname
	
	Dim actionViewItem As ACMenuItem
	actionViewItem = NavDrawer.NavigationView.Menu.AddWithGroup2(1, 2, 2, "Wifi only", xml.GetDrawable("ic_signal_wifi_4_bar_black_18dp"))
	Switch.Initialize("Switch")
	'Switch.Typeface=Typeface.LoadFromAssets("Montserrat-Regular.ttf")
	actionViewItem.ActionView = Switch'Switch
	
	
	Dim actionViewItem As ACMenuItem
	actionViewItem = NavDrawer.NavigationView.Menu.AddWithGroup2(1, 3, 2, "Update station logo", xml.GetDrawable("baseline_cached_black_18"))
	SwitchUpdateLogo.Initialize("SwitchUpdateLogo")
	actionViewItem.ActionView = SwitchUpdateLogo
	
	Dim actionViewItem As ACMenuItem
	actionViewItem = NavDrawer.NavigationView.Menu.AddWithGroup2(1, 4, 2, $""Now Playing""$, xml.GetDrawable("baseline_format_size_black_18"))
	SwitchCaps.Initialize("SwitchCaps")
	actionViewItem.ActionView = SwitchCaps
	
	Starter.activeActivity	= "player"
	pnlOverflow.Top	= Activity.Height+240dip
	Dim pdg As Label
	pdg.Initialize("")
	
	NavDrawer.NavigationView.LoadLayout("slidingMenu", NavDrawer.DefaultHeaderHeight)
	NavDrawer.NavigationView.Menu.AddWithGroup2(2, 10, 1000, "Add station", xml.GetDrawable("ic_radio_black_24dp"))
	NavDrawer.NavigationView.Menu.AddWithGroup2(2, 20, 1001, "Suggest station", xml.GetDrawable("outline_playlist_add_black_24"))
	
	showHideStoredSongs
	NavDrawer.NavigationView.Menu.AddWithGroup2(2, 13, 1300, "Small manual (via browser)", xml.GetDrawable("outline_contact_support_black_24"))
	NavDrawer.AddSecondaryDrawer(1dip, NavDrawer.LOCK_MODE_LOCKED_CLOSED)
	NavDrawer.NavigationView.Menu.AddWithGroup2(2, 14, 1400, "Exit", xml.GetDrawable("ic_power_settings_new_black_24dp"))
	
	NavDrawer.NavigationView.Menu.SetGroupCheckable(2, False, False)
	
	lblNavDrawerHeader.Text	= $"AdFree Radio v ${Application.VersionName}"$
	lblNowPlayingStation.Text 	= Application.LabelName & " v"&Application.VersionName
	
	
	
	If FirstTime Then
		Starter.kvs.PutSimple("app_started", 1)
		
	End If
	
	Sleep(2)
	lblPlayingRef.Initialize("")
	lblPlayingButtonRef.Initialize("")
	lblPlayingButtonRef.Gravity	= Gravity.CENTER
	
	
	lbl_close.Background			= xml.GetDrawable("ic_power_settings_new_black_24dp")
	'lbl_stream_lost.Background		= xml.GetDrawable("twotone_warning_black_24")
	btn_img_stop.Background			= xml.GetDrawable("outline_stop_black_24")
	btn_img_lyric.Background		= xml.GetDrawable("outline_subtitles_black_24")
	btn_img_store_song.Background	= xml.GetDrawable("outline_queue_music_black_24")
	btn_img_album_info.Background	= xml.GetDrawable("outline_playlist_add_black_24")
	'btn_img_new_station.Background	= xml.GetDrawable("ic_radio_black_24dp")
	'btn_img_new_station.Background	= xml.GetDrawable("ic_power_settings_new_black_24dp")
	img_volume.Background	= xml.GetDrawable("outline_volume_up_black_24")
	setSvg(img_close, "022-power-button.svg")
'	setSvg(ivTimer, "sleeptimer.svg")
	lbl_stop_playing.Gravity		= Gravity.CENTER

	'---->kvs.Initialize(Starter.irp_dbFolder, "settings", True)
	
	getSetSettings
	
	
	Dim vCurrVol As Int			=  clsVol.currVolume
	acVolume.Value				= vCurrVol
	Starter.currentMusicVolume	= vCurrVol
	currMusicVolume 			= vCurrVol
	If vCurrVol < 1 Then
		img_volume.Background	= xml.GetDrawable("outline_volume_off_black_24")
	End If
	
	CallSub(Starter, "getConnectionType")
	
	Starter.ivAlbumArtHeight 	= ivNowPlaying.Height
	Starter.ivAlbumArtwidth		= ivNowPlaying.Width
	
	Sleep(2)
	
	If FirstTime Or Starter.vPlayerSelectedPanel = 999 Then
		restorePlayingInfo
	End If
	
	'pnl_new_station_button.Visible	= False
	pnl_new_station_button.SetElevationAnimated(500, 8dip)
	handleControlButtons(False, 0dip, 500)
	pnl_lyric_button.Enabled = False
	pnl_lyric_button.SetElevationAnimated(0, 0dip)
	pnl_store_song_button.Enabled = False
	pnl_store_song_button.SetElevationAnimated(0, 0dip)
	getSetButtonState(False)
	
	clsScroll.Initialize
	clsScroll.runMarquee(lblArtistNowPlaying, "Click station to start streaming", "MARQUEE")
	clsScroll1.Initialize
	clsScroll1.runMarquee(lblRandomImage, "No song information found, random image is shown", "MARQUEE")
	dialog.Initialize(Activity)
	
		
End Sub






Sub setCtrlButtonsBorder
	drawPanelBorder(pnl_stop_button, pnl_stop_button.Elevation = 0)
	drawPanelBorder(pnl_lyric_button, pnl_lyric_button.Elevation = 0)
	drawPanelBorder(pnl_store_song_button, pnl_store_song_button.Elevation = 0)
	drawPanelBorder(pnl_album_info_button, pnl_album_info_button.Elevation = 0)
	drawPanelBorder(pnl_volume, pnl_volume.Elevation = 0)
	
End Sub


Sub disableInfoPanels
	pnl_store_song_button.SetElevationAnimated(1000, 0)
	pnl_lyric_button.SetElevationAnimated(1000, 0)
End Sub


Sub pnlImgColor(isRndImage As Boolean)
	lblRandomImage.BringToFront
	lblRandomImage.SetVisibleAnimated(500, isRndImage)

End Sub

Sub setSongPlaying(songPlaying As String)
	lblArtistNowPlaying.Text = Starter.clsFunc.TitleCase(songPlaying)
End Sub


Sub restorePlayingInfo
	Dim hasLirycs As String = CallSub(Starter,"getSetSongLyric")
	Dim img As Bitmap = LoadBitmap(File.DirAssets, "logo_afr.png")
	Try
		getStations
		setControlButtonsState
		setPanelElevation(Starter.vPlayerSelectedPanel)
		If hasLirycs <> "noLyric" Then
			showHideLyricsButton(True)
		Else
			showHideLyricsButton(False)
		End If
	
		If Starter.vStationName <> "" And CallSub(Starter, "getSongPlaying") <> "" Then
			lblArtistNowPlaying.Text	= CallSub(Starter, "getSongPlaying")
		
			lblNowPlayingStation.Text	= Starter.vStationName  'pg_station
			ivNowPlaying.Bitmap = img
		Else
			ivNowPlaying.Bitmap = img
		End If
	
	Catch
		Starter.clsFunc.showLog("Error in restorePlayinInfo >> " & LastException, 0)
	End Try
End Sub


Sub toastphn(number As String)
	Starter.rp.CheckAndRequest(Starter.rp.PERMISSION_READ_PHONE_STATE)
	Wait For Activity_PermissionResult (Permission As String, Result As Boolean)
	If Result Then
		For i = currMusicVolume To 0 Step -1
			phone.SetVolume(phone.VOLUME_MUSIC, i, False)
			acVolume.Value	= i
			Sleep(10)
		Next
	End If
End Sub


Sub toastphnResume(number As String)
	Starter.rp.CheckAndRequest(Starter.rp.PERMISSION_READ_PHONE_STATE)
	Wait For Activity_PermissionResult (Permission As String, Result As Boolean)
	
	If Result Then
		For i = 0 To currMusicVolume
			phone.SetVolume(phone.VOLUME_MUSIC, i, False)
			acVolume.Value	= i
			Sleep(10)
		Next
	End If
End Sub


Sub Activity_Resume
	Dim in As Intent
	Starter.activeActivity = "Player"
	Starter.tmrInactive.Enabled = False
	acVolume.Value = clsVol.currVolume
	acVolume_ValueChanged (clsVol.currVolume, False)
	If Starter.streamLost = True Then
		resetKvsPnlButtons
		AppCrash
	End If
	
	Dim in As Intent = Activity.GetStartingIntent
	in = Activity.GetStartingIntent
	
	If in.HasExtra("Notification_Action_Tag") Then
		If in.GetExtra("Notification_Action_Tag") = "exit" Then
			exitPlayer
		End If
	End If
	
	Starter.activeActivity	= "player"
	
	If Starter.vPlayerSelectedPanel <> 999 Then
		Starter.lastSong = "resume"
		CallSub2(Starter, "tmrGetSongEnable", True)
		Starter.streamTimer.Enabled = True
		'CallSub(Starter, "icyMetaData")
		restorePlayingInfo
		Starter.clsFunc.songPlaying = "resume"
		Starter.clsSngData.icyMetaData
		'Dim songdata As clsHttp
		'songdata.Initialize(Starter, "peter")
		'CallSubDelayed3(songdata,"spBearer", Starter.chartArtist, Starter.chartSong)'scrobbler.processPlaying(Starter.lastSong))
	Else
		If Starter.stationAdded = 1 Then
			restorePlayingInfo
			Starter.stationAdded = 0
		End If
		
		pg_playing	= ""
		pg_playing	= ""
		pg_station	= ""
		Starter.vAlbumTrack = ""
		Starter.vAlbumName	= ""
		Starter.vPlayerSelectedPanel = 999
		lblNowPlayingStation.Text	= "" '"Click on a station to start streaming"
		If Starter.streamLost = True Then
			Starter.streamLost = False
		Else
			lblArtistNowPlaying.Text	= "Click station to start streaming"
		End If
		lblNowPlayingDataRate.Text	= ""
	End If
'	Starter.clsFunc.showLog($"END ACTIVITY RESUME $Time{DateTime.Now}"$, Colors.Black)
End Sub


Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed Then
		Starter.kvs.PutSimple("app_started", 0)
		resetKvsPnlButtons
		exitPlayer
	Else
		Starter.streamTimer.Enabled = False
		Starter.kvs.PutSimple("app_started", 1)
		pnl_volume_slider.Visible = False
		'pnlSongText.SetVisibleAnimated(0, False)
		getSetButtonState(True)
		Starter.tmrInactive.Enabled = True
		
		If pg_artistAlbum.IsInitialized Then
			pg_artistAlbum = CallSub(Starter, "getAlbumArt")
		End If
	End If
End Sub


Sub resetKvsPnlButtons
	Starter.kvs.PutSimple("app_started", 0)
	Starter.kvs.PutSimple("pnl_stop_button",  0)
	Starter.kvs.PutSimple("pnl_lyric_button",  0)
	Starter.kvs.PutSimple("pnl_store_song_button", 0)
	Starter.kvs.PutSimple("pnl_album_info_button", 0)
	Starter.kvs.PutSimple("lbl_time_now", "")
	Starter.kvs.PutSimple("lblNowPlayingDataRate", "")
	Starter.kvs.Remove("player_station_logo")
End Sub


Sub getStations
	Dim rs As ResultSet
	Dim list As List
	
	clvPlayer.Clear
	list.Initialize
	rs	= genDb.getPresetStations
	
	Do While rs.NextRow
		list.Initialize
		list.AddAll(Array As String(rs.GetString("stname"), rs.GetString("genre"), rs.GetString("stream1"), rs.GetString("description"),rs.GetString("pref_id"), rs.GetString("country"), rs.GetString("img_path"), rs.GetString("pref_id")))
		
		clvPlayer.Add(setStation(list),"")
	Loop
End Sub


Sub setStation(lst As List) As Panel
	Dim p As Panel
	p.Initialize("")
	'p.SetLayout(0,0,clvPlayer.AsView.Width, 104dip)
	p.SetLayout(0,0,clvPlayer.AsView.Width, 110dip)
	p.LoadLayout("playerStation")

	
	Dim tCanvas As Canvas
	'tCanvas.Initialize(ImgSvg)

	Dim SVG As ioxSVG
	
	tCanvas.Initialize(svgInfo)
	SVG.Initialize("027-information.svg")
	SVG.DocumentWidth = svgInfo.Width
	SVG.DocumentHeight = svgInfo.Height
	SVG.RenderToCanvas(tCanvas)
	
	Dim listPlayButton As List
	listPlayButton.Initialize
	listPlayButton.AddAll(Array As String("headerPlayButton",lst.Get(2), lst.Get(7)))
	
	pnlStation.Tag			= "headerColor"
	lblHeaderPlayButton.Tag	= listPlayButton
	lblStationName.Text 	= lst.Get(0)
'	lblOverflow.Tag			= lst.Get(3)
	lblGenre.Text			= $"Genre : ${lst.Get(1)}"$
	svgInfo.Tag				= lst.Get(3)
	lblForId.Tag			= $"stationid_${lst.Get(7)}"$
	
	'Log($"stationid_${lst.Get(7)}"$)
	
	lblHeaderPlayButton.Background	= xml.GetDrawable("outline_play_arrow_black_36")
	If lst.get(6) <> Null And File.Exists("", lst.get(6))Then
		Dim bm As Bitmap = LoadBitmap(lst.Get(6),"")
		iv_station_logo.Bitmap = bm
'		lblStationLogo.Tag	= lst.Get(6)
		iv_station_logo.Tag	= lst.Get(6)
		
	Else
		Dim bm As Bitmap = LoadBitmap(File.DirAssets, "no_logo.png")
		iv_station_logo.Bitmap = bm
		iv_station_logo.Tag	= "nologo"	
	End If
	
	p.Tag	= False
	Return p
End Sub


Sub acVolume_ValueChanged (Value As Int, UserChanged As Boolean)
	clsVol.disableVolumeTimer
	
	If UserChanged Then
		clsVol.userVolume(Value)
		Starter.currentMusicVolume	= Value
		currMusicVolume = Value
	End If
	
	clsVol.enableVolumeTimer
	setLabelVolumeColor
	If Value < 1 Then
		img_volume.Bitmap	=  LoadBitmap(File.DirAssets,"outline_volume_off_black_24.png")' xml.GetDrawable("outline_volume_off_black_24")
	Else
		img_volume.Bitmap	= LoadBitmap(File.DirAssets,"outline_volume_up_black_24.png")'xml.GetDrawable("outline_volume_up_black_24")
	End If
End Sub


Sub setLabelVolumeColor
	Dim value As Int = acVolume.Value
	
	lblMaxVolume.Visible = True
	If value < 10 Then
		lblMaxVolume.Text = Starter.clsFunc.padString(value, "0", 0, 1)
	Else
		lblMaxVolume.Text = value
	End If	
		
	If value > 5 And  value < 10 Then
		lbl_volume.TextColor = 0xFFFF8C00
		lblMaxVolume.TextColor = 0xFFFF8C00
	Else If value >= 10 Then
		lbl_volume.textColor = Colors.Red
		lblMaxVolume.TextColor = Colors.Red
	Else if value > 0 Then
		lbl_volume.textColor = 0xFF107A00
		lblMaxVolume.TextColor = 0xFF107A00
	Else
		lblMaxVolume.Visible = False
	End If
End Sub

Public Sub SetBitmapWithFitOrFill (vTargetView As B4XView, bmp As B4XBitmap)
	vTargetView.SetBitmap(bmp)
   #if B4A
	'B4XView.SetBitmap sets the gravity in B4A to CENTER. This will prevent the bitmap from being scaled as needed so
	'we switch to FILL
	Dim iv As ImageView = vTargetView
	iv.Gravity = Gravity.FILL
   #End If
End Sub


Sub setAlbumArtFading(vArt As Bitmap)
	pg_artistAlbum	= vArt
	ivNowPlaying.SetVisibleAnimated(100, True)
	ivNowPlaying.Bitmap = vArt
End Sub


Sub nowPlaying(playing As String)
	If playing = "" Then
		
		setPLayingSmall("")
		clearAlbumArt
		setDuration(0)
		lblPlayingRef.Text = ""
		Return
	End If
	
	pg_playing	= playing
	pg_station	= cmGen.getStationRecord(getStation, "stname")
	
	lblPlayingRef.Text			= pg_playing
	lblArtistNowPlaying.Text	= pg_playing
	lblNowPlayingStation.Text	= pg_station
	
End Sub

Sub lblDelete_Click
	Dim lbl As Label = Sender
	Dim index As Int = clvPlayer.GetItemFromView(Sender)
	
	genDb.removePreset(lbl.Tag)
	clvPlayer.RemoveAt(index)
End Sub


Sub lblConnectionType_Click
	StartActivity(getSetStation)
End Sub


Sub setConnectionIcon(connectionType As String)', connType As String)
	Dim cs As CSBuilder
	cs.Initialize.Append(connectionType).PopAll
	lblNavDrawerSubTitle.TextSize = 11
	lblNavDrawerSubTitle.SingleLine = False
	lblNavDrawerSubTitle.Text	= cs 'Chr(0xF1EB) & " " &connectionType
	lbl_countdown_timer.Text = connectionType
	clsScroll.Initialize
	clsScroll.runMarquee(lbl_countdown_timer, connectionType, "MARQUEE")
	lbl_countdown_timer.Visible = True
End Sub


Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	
	If NavDrawer.IsDrawerOpen2(NavDrawer.GRAVITY_START) Or NavDrawer.IsDrawerOpen2(NavDrawer.GRAVITY_END) Then
		NavDrawer.CloseDrawers
		Return True
	End If
	
	If pnlOverflow.Visible = True Then
		hideOverflow
		Return True
	End If
	
	Dim musicVolume As Int = phone.GetVolume(phone.VOLUME_MUSIC)
	

	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
'		If pnlSongText.Visible = True Then
'			btnCloseSongText_Click
'			Return True
'		End If
	End If

'	If KeyCode = KeyCodes.KEYCODE_BACK Then
'
'		If bckBtnClickCount = 2 Then
'		bckBtnClickCount = 1
'
'			exitPlayer
'			Return False
'		End If
'		
'		bckBtnClickCount = bckBtnClickCount +1
'		showSnackbar("Tap back key again to exit application")
'	End If
	
	If KeyCode = KeyCodes.KEYCODE_VOLUME_UP Or KeyCode = KeyCodes.KEYCODE_VOLUME_DOWN Then
		pnl_volume_Click
	End If
	
	If KeyCode = KeyCodes.KEYCODE_VOLUME_UP Then
		clsVol.userVolume(musicVolume+1)
		currMusicVolume	= acVolume.Value
		Return True
	End If
   
	If KeyCode = KeyCodes.KEYCODE_VOLUME_DOWN Then
		If musicVolume = 0 Then Return True
		
		clsVol.userVolume(musicVolume-1)
		currMusicVolume	= acVolume.Value
		Return True
	End If
	
	
	Return True
End Sub

Sub setStationLogo(img As Bitmap)
	Dim panel, pnl_logo As Panel
	Dim ivLogo As ImageView'Label
	
	ivLogo.Initialize("")
	panel= clvPlayer.GetPanel(Starter.vPlayerSelectedPanel)
	For Each v As View In panel.GetAllViewsRecursive
		If v.Tag = "pnl_station_logo" Then
			pnl_logo = v
			ivLogo = pnl_logo.GetView(0)
			ivNowPlayingStation.Bitmap = img
			pnlPlayingStation.Visible = True
			panelStationLogo(img)
			Exit
		End If
	Next
	
End Sub


Sub clearAlbumArt
	
	Dim panel As Panel
	
	panel= clvPlayer.GetPanel(processingPanel)
	For Each v As View In panel.GetAllViewsRecursive
		If v.Tag = "albumart" Then
			v.Visible = False
			Exit
		End If
	Next
End Sub


Sub getStation As String
	Dim panel As Panel
	Dim lbl As Label
	If Starter.vPlayerSelectedPanel > clvPlayer.Size + 1 Then
		Return ""	
	End If
	
	lbl.Initialize("")
	panel= clvPlayer.GetPanel(Starter.vPlayerSelectedPanel)
	For Each labl In panel.GetAllViewsRecursive
		
		If labl Is Label Then
			lbl = labl
			If lbl.Tag = "station_name" Then
				Return lbl.Text
			End If
			
		End If
	Next
	Return ""
End Sub


Sub setDuration(duration As Double)
	Dim panel As Panel
	Dim lbl As Label
	Dim vDuration As String
	Dim vTimeDuration As String
	
	vTimeDuration	= DateTime.Time(duration)
	
	If duration = 0 Then
		vDuration = ""
	Else
		vDuration = Starter.clsFunc.stringSplit(":", vTimeDuration, 0, False, 1, False) &":"&Starter.clsFunc.stringSplit(":", vTimeDuration, 0, False, 2, False)
	End If	
	
	lbl.Initialize("")
	panel= clvPlayer.GetPanel(processingPanel)
	For Each labl In panel.GetAllViewsRecursive
		
		If labl Is Label Then
			lbl = labl
			If lbl.Tag = "duration" Then
				lbl.Text = vDuration
			End If
			
		End If
	Next
End Sub


Sub showHideLyricsButton(show As Boolean)
	If show = True Then
		pnl_lyric_button.SetElevationAnimated(500, 8dip)
		pnl_lyric_button.Enabled = True
	Else
		pnl_lyric_button.SetElevationAnimated(500, 0dip)
		pnl_lyric_button.Enabled = False
	End If
End Sub


Sub btnCloseSongText_Click
	'pnlSongText.SetVisibleAnimated(1000, False)
End Sub


Sub FindExapnded As Int 'ignore
	For i = 0 To clvPlayer.GetSize - 1
		If clvPlayer.GetPanel(i).Tag = True Then Return i
	Next
	Return -1
End Sub


Sub setPLayingSmall(playing As String)
	Dim p As Panel		= clvPlayer.GetPanel(processingPanel)
	Dim lbl As Label
	
	For Each v As View In p.GetAllViewsRecursive
		If v.tag = "nowplayingsmall" Then
			lbl.Initialize("")
			lbl	= v
			lbl.Text	= playing
			Exit
		End If
	Next
	
End Sub


Sub start_stopStreamResetLabels
	CallSub2(Starter, "setSongLyric", "noLyric")
	
	lblNowPlayingStation.Text	= "Not Playing"'Application.LabelName & " v" & Application.VersionName
	lblArtistNowPlaying.Text	= "Click station to start streaming"
	lblNowPlayingDataRate.Text	= ""
	CallSub2(Starter, "setSongTitle", "Select Station")
End Sub


Private Sub handleControlButtons(enable As Boolean, elevation As Float, duration As Int)
	pnl_stop_button.Enabled	= enable
	pnl_stop_button.SetElevationAnimated(duration, elevation)
	pnl_album_info_button.Enabled = enable
	pnl_album_info_button.SetElevationAnimated(duration, elevation)
	
	setCtrlButtonsBorder
End Sub

Sub setPanelElevation(index As Int)
	For i = 0 To clvPlayer.Size - 1
	
		For Each v As View In clvPlayer.GetPanel(i).GetAllViewsRecursive
			If v.Tag = "headerColor" Then
				If v Is Panel Then
					Dim pnl As Panel = v
					pnl.Elevation = 1dip
					'pnl.SetElevationAnimated(500, 1dip)
					If i = index Then
						pnl.SetElevationAnimated(500, 4dip)
						'Sleep(700)
					Else
					'	pnl.Elevation = 1dip
					End If
				End If
			End If

		Next
	Next
End Sub

Sub start_stopStream(index As Int) As ResumableSub
	Dim dataCleared, isSamePanel As Boolean = False
	
	
	If Starter.clsFunc.IsMusicPlaying Then
		CallSub2(Starter, "tmrGetSongEnable", False)
		dataCleared = True

		isSamePanel = Starter.clsSngData.clearSongData(index)
		handleControlButtons(False, 0dip, 500)
		Starter.clsFunc.shadowLayer(lblArtistNowPlaying,0,0,0, Colors.White)
		If index > clvPlayer.Size-1  Then
			Return False
		Else	
		'	Return False
		End If
		If isSamePanel Then 
			stream = ""
			pnlClicked = 0
			Return True
		End If
	End If
	

	Try
		'STOP STREAM
		If dataCleared = False Then
			Starter.clsSngData.clearSongData(index)
		End If

	
		If index = -1 Then
			index = Starter.vPlayerSelectedPanel
		End If
		
		If index = 999 Then
'			CallSub2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "logo_afr.png").Resize(Starter.ivAlbumArtHeight, Starter.ivAlbumArtwidth, True))
			pnlClicked = 0
			Return True
		End If
	
		If checkWifiOnly = False Then
			Return True
		End If
	
	
		modGlobal.PlayerStarted = True
		lblNowPlayingStation.Text	= ""
		lblArtistNowPlaying.Text	= ""
	
		'set the play button on the select panel and return stream url
		stationLogoPath = "null"
		stream = setPlayButton(index)
		
		Starter.sStationLogoPath = stationLogoPath
		If stream = "" Then
			'doe iets
		End If
		Starter.vPlayerSelectedPanel = index
		Starter.selectedStream = stream

		handleControlButtons(True, 8dip, 500)
		
		CallSub2(Starter, "startPlayer", stream)
		Starter.clsSngData.icyMetaData
		setPanelElevation(index)
'		clvPlayer.JumpToItem(index)
		If stationLogoPath <> "null" And stationLogoPath <> "" Then
			smallStationLogo.Initialize(stationLogoPath,"")
		
			ivNowPlayingStation.Bitmap = LoadBitmap(stationLogoPath,"")
			showHideSmallStationLogo(True)
		Else
			showHideSmallStationLogo(False)
		End If
		
		Starter.clsFunc.shadowLayer(lblArtistNowPlaying, 2, 3dip, 2dip,0xFFE7E7E7)
'		showStreamWarning(False)
		Starter.streamLost = False
		Starter.streamLostInfo = ""
'		lblArtistNowPlaying.Text = "Getting information"
'		CallSub2(Starter, "run_streamTimer", True)
		modGlobal.PlayerStarted = True
		Starter.startAccPlayerTime = DateTime.Now
		pnlClicked = 0
	Catch
		clearLabels
	End Try
	
	Return True
End Sub


Sub showHideSmallStationLogo(show As Boolean)
	pnlPlayingStation.SetVisibleAnimated(500, show)
	
	
End Sub


Sub setPlayButton(index As Int) As String
	
	Dim pnl As Panel = pnlStation
	Dim xml As XmlLayoutBuilder
	Dim listPlayButton As List
	
	If clvPlayer.Size = 0 Then
		Return ""
	End If
	
	listPlayButton.Initialize
	pnl = clvPlayer.GetPanel(index)
	
	'GET STATION LOGO PATH
	stationLogoPath	= "null"
	For Each v As View In pnl.GetAllViewsRecursive
		Dim str As String = v.Tag
		If str.IndexOf("/storage/") > -1  Then
			stationLogoPath	= v.Tag
			Exit
		End If
		
	Next
	
	For Each l As View In pnl.GetAllViewsRecursive
		If l.Tag = "station_name" Then
			Dim lbl As Label	= l
			lblNowPlayingStation.Text = lbl.Text
			Exit
		End If
		
	Next

	'GET STATION ID
	Dim tag As String
	For Each v As View In pnl.GetAllViewsRecursive
		If v.Tag Is B4XView Then
			tag = v.Tag
			If tag.IndexOf("stationid_") > -1 Then
				Dim idLst As List = Regex.Split("_", tag)
				Starter.playingStationId = idLst.Get(1)
				Exit
			End If
		End If
	Next
	
			
	For Each v As View In pnl.GetAllViewsRecursive
		If v.Tag Is List Then
			listPlayButton	= v.Tag
			If listPlayButton.Get(0)= "headerPlayButton" Then
				Starter.currStationId = listPlayButton.Get(2)
				Return listPlayButton.Get(1)
			End If
		End If
	Next
	Return ""
End Sub


Sub lblOverflow_Click
	Dim index As Int 	= clvPlayer.GetItemFromView(Sender)
	Dim lbl As ImageView	= Sender
	Dim stationId As Int
	
	stationinfo				= lbl.Tag
	lblOpenStationUrl.Tag	= index
	lblDeleteStation.Tag	= cmGen.getStationRecord(getStationByIndex(index), "pref_id")
	stationId				= cmGen.getStationRecord(getStationByIndex(index), "pref_id")
	lbl_station_name.Color	= 0xFF004BA0
	lbl_station_name.Text	= getStationByIndex(index)
	
	If pnlOverflow.Visible = False Then
		showOverflow	
	Else
		hideOverflow
	End If
		
End Sub


Sub showOverflow
'	Dim hideTmr As clsGenTimer

	'hideTmr.Initialize(5000, "hideOverFlow")
	hideTmr.timer.Enabled = True
	
	pnlOverflow.SetVisibleAnimated(0, True)
	pnlOverflow.SetLayoutAnimated(500, pnlOverflow.Left, (Activity.Height- pnlOverflow.Height)-pnlControl.Height, pnlOverflow.Width, pnlOverflow.Height)
End Sub


Sub hideOverflow
	pnlOverflow.SetLayoutAnimated(1000, pnlOverflow.Left, Activity.Height-110dip, pnlOverflow.Width, pnlOverflow.Height)
	'pnlOverflow.SetLayoutAnimated(1000, pnlOverflow.Left, pnlControl.Top+130dip, pnlOverflow.Width, pnlOverflow.Height)
	
	Sleep(1000)
	Sleep(300)
	pnlOverflow.SetLayoutAnimated(1000, pnlOverflow.Left, Activity.Height+40dip, pnlOverflow.Width, pnlOverflow.Height)
	Sleep(1000)
	pnlOverflow.SetVisibleAnimated(0, False)
	Try
	hideTmr.timer.Enabled = False
	Catch
		Log("")
	End Try
End Sub


Sub lblStationInformation_Click
	hideOverflow
	Msgbox2Async(stationinfo, "Station Info",  "OK", "", "", Null, False)
	
End Sub


Sub lblBtnStationInformation_Click
	
End Sub


Sub lblBtnDeleteStation_Click
	
End Sub


Sub lblDeleteStation_Click
	Dim result As Int
	Dim stationName As String
	hideOverflow
	stationName = genDb.getStationNameFromPreflist(lblDeleteStation.Tag)
	Msgbox2Async($"Delete ${stationName}"$, Starter.vAppname, "Yes", "", "No", Null, False)
	
	Wait For Msgbox_Result (result As Int)
	
	If result = DialogResponse.POSITIVE Then
		genDb.removePreset(lblDeleteStation.Tag)
		clvPlayer.RemoveAt(lblOpenStationUrl.Tag)
	End If
	

End Sub


Sub panelStationLogo(bm As Bitmap)
	Dim pnl As Panel = clvPlayer.GetPanel(Starter.vPlayerSelectedPanel)
	
	For Each v As View In pnl.GetAllViewsRecursive
		If v Is ImageView And v.Tag = "nologo" Then
			Dim stLogo As ImageView
			stLogo = v
			stLogo.Bitmap = bm
			Exit
		End If
	Next
End Sub

Sub getStationLogo(link As String)
	If link = "" Or link = Null Or link.IndexOf("ull") > -1 Then Return
	Dim url As String
	
	
	Try
		Dim stationName As String	 = getStation
		If stationName = "" Then
			Return
		End If
		Dim stationId As String		 = genDb.getStationIdByName(stationName)
		
		genDb.vCurs.Close
		If stationId = "null" Then
			Return
		End If
	Catch
		Log("PLAYER @ 1141 : "&LastException)
		Return
	End Try
	If stationId < 1 Then
		Return
	End If
	Dim hasLogoPath As String	 = genDb.getStationLogoPathOnId(stationId)
	
	If genDb.checkStationLogo(stationId) = False Then
		If Starter.vUpdateLogo = False Or hasLogoPath.Length > 0  Then
			setStationLogo(LoadBitmap(hasLogoPath, ""))
			Starter.sStationLogoPath = hasLogoPath
			Return
		End If
	End If
	cmGen.setStationUrlToRecord(link, stationId)
	
	If link = "" Then
		Return
	End If
	
	Try
		
	

	url = $"https://logo.clearbit.com/${link.Trim}/?size=150&format=png"$
	Dim j As HttpJob

	j.Initialize("", Me)
	j.Download(url)
	j.GetRequest.Timeout = Starter.jobTimeOut
	
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		Dim stationPng As String	= stationName.Replace(" ", "")
		Dim stationFolder As String = Starter.irp_dbFolder & "/station_logo"
		
		If File.Exists(stationFolder, "") = False Then
			File.MakeDir(Starter.irp_dbFolder, "station_logo")
		End If
		
		Dim bm As Bitmap = j.GetBitmap
		bm.Resize(150, 150, True)
		Dim out As OutputStream
		
		out= File.Openoutput(stationFolder, stationPng &".png", False)
		bm.WriteToStream(out, 100, "PNG")
		out.Close
		writePngNameToTable(stationId, stationFolder&"/"&stationPng &".png")
		setStationLogo(bm)
		j.Release
	Else
		'try new url only once
		If imgUrlRetry = 1 Then
			imgUrlRetry = 0
			Return
		End If
		j.Release			
		imgUrlRetry = imgUrlRetry + 1
		cmGen.stripUrl(link)
	End If
	Catch
		Log("PLAYER @ 1200 : "&LastException)
	End Try
	
End Sub


Sub writePngNameToTable(stationPng As String, stId As String)
	genDb.writeStationImgPath(stId, stationPng)
End Sub


Sub lblOpenStationUrl_Click
	showNowPlayingFormat
End Sub


Sub getStationByIndex(index As Int) As String
	Dim panel As Panel
	Dim lbl As Label
	
	lbl.Initialize("")
	panel = clvPlayer.GetPanel(index)
	For Each labl In panel.GetAllViewsRecursive
		
		If labl Is Label Then
			lbl = labl
			If lbl.Tag = "station_name" Then
				Return lbl.Text
			End If
			
		End If
	Next
	Return ""
End Sub


Sub hideLyrics
'	Dim html As String = File.ReadString(File.DirAssets, "lyric.html")
'	If pnlSongText.Visible = True Then
'		wvLyric.LoadHtml(html)
'		pnlSongText.SetVisibleAnimated(1000, False)
'		Sleep(700)
'	End If
End Sub


Sub lblNowPlayingLyric_Click
'	Dim html As String = File.ReadString(File.DirAssets, "lyric.html")
'
'	If pnlSongText.Visible Then
'		pnlSongText.SetVisibleAnimated(500, False)
'		Return
'	End If
'	Dim vLyric As String = CallSub(Starter, "getSetSongLyric")
'	
'	wvLyric.LoadHtml(html)
'	
'	html = html.Replace("_header_", CallSub(Starter,"getSongTitle"))
'	html = html.Replace("_text_", cmGen.RegexReplace("\n", vLyric, "<br/>"))
'	
'	wvLyric.LoadHtml(html)
'	pnlSongText.SetVisibleAnimated(500, True)
	
End Sub


#Region ToolBar Events
'Open or Close the drawer if the Toolbar HomeButton is clicked.
Sub toolbar_NavigationItemClick
	If NavDrawer.IsDrawerOpen Then
		NavDrawer.CloseDrawer
	Else
		NavDrawer.OpenDrawer
		lblNavDrawerHeader.Text	= "AdFree Radio v"&Application.VersionName
		showHideStoredSongs
		
	End If
End Sub


Sub NavDrawer_DrawerOpened (DrawerGravity As Int)
'	lblNavDrawerHeader.Text	= $"AdFree Radio v ${Application.VersionName}"$
	showHideStoredSongs
End Sub


Sub NavDrawer_NavigationItemSelected (MenuItem As ACMenuItem, DrawerGravity As Int)


	If MenuItem.Title = "Reset data usage" Then
		NavDrawer.CloseDrawer
		Dim result As Int
		result = Msgbox2("Reset usage data", Starter.vAppname, "Yes", "", "No", Null)
		If result = DialogResponse.POSITIVE Then
			Starter.kvs.PutSimple("data_usage", 0)
		End If
	else If MenuItem.id = 11 Then
		NavDrawer.CloseDrawer2(DrawerGravity)
		StartActivity(stored_songs)
	else If MenuItem.Title = "Add station" Then
		NavDrawer.CloseDrawer
		
		CallSub(Starter, "stopPlayer")
		startOrStopStream(Starter.vPlayerSelectedPanel)
		Starter.vPlayerSelectedPanel = 999
		If genDb.getCountryBookmark = "" Then
			StartActivity(getSetStation)
		Else
			StartActivity(searchStation)
		End If
	else If MenuItem.Title = "Exit" Then
		exitPlayer
	else If MenuItem.Title = "Small manual (via browser)" Then
		showManual
		NavDrawer.CloseDrawer
	Else If MenuItem.id = 20 Then
		StartActivity(editStation)
		NavDrawer.CloseDrawer
	End If
End Sub
#End Region


Sub showManual
	Dim intent1 As Intent
	intent1.Initialize(intent1.ACTION_VIEW, "https://peter.pdeg.nl")
	StartActivity(intent1)
			
End Sub


Sub lblHeaderPlayButton_Click
	startOrStopStream(-1)
End Sub


Sub pnlStation_Click
	startOrStopStream(clvPlayer.GetItemFromView(Sender))

End Sub


Sub getSetSettings
	'get wifi only setting
	If Starter.kvs.GetSimple("wifionly") = 1 Then
		Switch.Checked		= True
		Starter.vWifiOnly	= True
	Else
		Switch.Checked		= False
		Starter.vWifiOnly	= False
	End If
	
	If Starter.kvs.GetSimple("capnowplaying") = 1 Then
		SwitchCaps.Checked		= True
		Starter.capNowPlaying	= True
	Else
		SwitchCaps.Checked		= False
		Starter.capNowPlaying	= False
	End If
	
	If Starter.kvs.GetSimple("updatelogo") = 1 Then
		SwitchUpdateLogo.Checked = True
		Starter.vUpdateLogo = True
	Else
		SwitchUpdateLogo.Checked = False
		Starter.vUpdateLogo = False
	End If

End Sub


Sub Switch_CheckedChange(Checked As Boolean)
	If Starter.kvs.ContainsKey("wifionly") = True Then
		Starter.kvs.PutSimple("wifionly", Checked)
		Starter.vWifiOnly	= Checked
	End If
End Sub


Sub SwitchUpdateLogo_CheckedChange(Checked As Boolean)
	If Starter.kvs.ContainsKey("updatelogo") = True Then
		Starter.kvs.PutSimple("updatelogo", Checked)
		Starter.vUpdateLogo = Checked
	End If
End Sub

Sub SwitchCaps_CheckedChange(Checked As Boolean)
	If Starter.kvs.ContainsKey("capnowplaying") = True Then
		Starter.kvs.PutSimple("capnowplaying", Checked)
		End If
	Starter.capNowPlaying	= Checked
End Sub

Sub checkWifiOnly As Boolean
	
	If Starter.vWifiOnly = True And Starter.vWifiConnected = False Then
		Msgbox("No Wifi connection unable to start stream or change the 'Wifi only' property","IRP")
		initPlayer
		Return False
	End If
	Return True
End Sub


Sub initPlayer
	CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
	'CallSub(Starter, "showNoImage")
	CallSubDelayed2(Starter, "setSongLyric", "noLyric")
	CallSubDelayed2(Starter, "setSongTitle", "")
	lblNowPlayingStation.Text 	= Application.LabelName & " v"&Application.VersionName
	lblArtistNowPlaying.Text	= ""
	lblNowPlayingDataRate.Text	= ""
	Sleep(0)
End Sub



Sub getSetButtonState(set As Boolean)
	If set = True Then
			
		Starter.kvs.PutSimple("pnl_stop_button",  0)
		Starter.kvs.PutSimple("pnl_lyric_button",  0)
		Starter.kvs.PutSimple("pnl_store_song_button", 0)
		Starter.kvs.PutSimple("pnl_album_info_button", 0)
		'kvs.PutBitmap("player_station_logo", ivNowPlayingStation.Bitmap)
		Starter.kvs.PutSimple("lbl_time_now", lbl_time_now.Text)
		Starter.kvs.PutSimple("lblNowPlayingDataRate", lblNowPlayingDataRate.Text)
		
		If  pnl_stop_button.Enabled Then
			Starter.kvs.PutSimple("pnl_stop_button",  1)
		End If
		If pnl_lyric_button.Enabled Then
			Starter.kvs.PutSimple("pnl_lyric_button",  1)
		End If
		If pnl_store_song_button.Enabled Then
			Starter.kvs.PutSimple("pnl_store_song_button",  1)
		End If
		If pnl_album_info_button.Enabled Then
			Starter.kvs.PutSimple("pnl_album_info_button",  1)
		End If
	Else
		Dim bm As Bitmap = Starter.kvs.GetBitmap("player_station_logo")
		
		If bm.IsInitialized = False Then
			pnlPlayingStation.Visible =  False
		Else
			pnlPlayingStation.Visible =  True
		End If
		
		lblNowPlayingDataRate.Text = Starter.kvs.GetSimple("lblNowPlayingDataRate")
		lbl_time_now.Text = Starter.kvs.GetSimple("lbl_time_now")
		If bm.IsInitialized = True Then
			ivNowPlayingStation.Bitmap = bm
		End If
		
		If bm.IsInitialized = True Then
			showHideSmallStationLogo(True)
		End If
		If Starter.kvs.GetSimple("pnl_stop_button") = 1 Then
			pnl_stop_button.Enabled = True
			pnl_stop_button.Elevation = 5dip
		End If
		If Starter.kvs.GetSimple("pnl_lyric_button") = 1 Then
			pnl_lyric_button.Enabled = True
			pnl_lyric_button.Elevation = 5dip
		End If
		If Starter.kvs.GetSimple("pnl_store_song_button") = 1 Then
			pnl_store_song_button.Enabled = True
			pnl_store_song_button.Elevation = 5dip
		End If
		If Starter.kvs.GetSimple("pnl_album_info_button") = 1 Then
			pnl_album_info_button.Enabled = True
			pnl_album_info_button.Elevation = 5dip
		End If
		
		If Starter.kvs.GetSimple("capnowplaying") = 1 Then
			Starter.capNowPlaying = True
			Starter.capNowPlaying = True
		End If
		
	End If
End Sub


Public Sub exitPlayer

	Starter.clsFunc.exitPlayer
	Activity.Finish
	Return
	'***END WAKELOCK
	CallSub2(Starter, "setWakeLock", False)
	
	'***END ACTIVITIES***
	CallSub(getSetStation,"endActivity")
	CallSub(searchStation, "endActivity")
	'***STOP PLAYER***
	CallSub(Starter, "stopPlayer")
	
	
	genDb.closeConnection
	resetKvsPnlButtons
	Starter.kvs.PutSimple("app_started", 0)
	Starter.kvs.PutSimple("app_normal_exit", 1)
	
	'Sleep(200)
	pg_playing	= ""
	pg_playing	= ""
	pg_station	= ""
	Starter.vAlbumTrack = ""
	Starter.vAlbumName	= ""
	Starter.vPlayerSelectedPanel = 999
	lblNowPlayingStation.Text	= "" '"Click on a station to start streaming"
	lblArtistNowPlaying.Text	= ""
	lblNowPlayingDataRate.Text	= ""
	
	If File.Exists(Starter.irp_dbFolder, "imgPlaying.png") Then
		File.Delete(Starter.irp_dbFolder, "imgPlaying.png")
	End If
		
	CallSub2(Starter, "setSongLyric", "noLyric")
	CallSubDelayed(Starter, "initPlayerVars")
	StopService(Starter)
	
	CallSub(Starter, "Service_Destroy")
	CallSub2(Starter, "run_streamTimer", False)
	CallSub2(Starter, "tmrGetSongEnable", False)
	CallSub(Starter, "endForeGround")
	Starter.tmrGetSong.Enabled = False
	Starter.streamTimer.Enabled = False
	Starter.tmrInetConnection.Enabled = False
	Starter.connectionTimer.Enabled = False
	Starter.tmrInactive.Enabled = False
	'Activity.Finish
	
End Sub


Public Sub showHideStoredSongs
	Dim count As Int = genDb.countStoredSong
	If count >=1 Then
		NavDrawer.NavigationView.Menu.RemoveItem(11)
		NavDrawer.NavigationView.Menu.AddWithGroup2(2, 11, 1100, $"Stored songs (${count})"$, xml.GetDrawable("ic_library_music_black_24dp"))
	Else
		NavDrawer.NavigationView.Menu.RemoveItem(11)
	End If
End Sub


Sub lbl_close_Click
	exitPlayer
End Sub


Sub lbl_stop_playing_Click
End Sub


Sub clearLabels
	lblNowPlayingDataRate.Text	= ""
	lbl_time_now.Text			= ""
	Starter.chartArtist			= ""
	Starter.chartSong			= ""
	Starter.streamRestartCount	= 0
	Starter.lastSong			= ""
	lblArtistNowPlaying.Text	= ""
End Sub


Sub setStationBitrate(bitrate As CSBuilder)
	lblNowPlayingDataRate.Text	= bitrate
End Sub



Sub pnl_store_song_button_Click
	iets
End Sub

Sub sw_response_onConfirm()
End Sub

Sub pnl_lyric_button_Click
	showLyricDialog
End Sub


Sub enableAlbumButton(enable As Boolean)
	If enable = True Then
		pnl_store_song_button.SetElevationAnimated(500, 8dip)
		pnl_store_song_button.Enabled = True
	Else
		pnl_store_song_button.SetElevationAnimated(500, 0dip)
		pnl_store_song_button.Enabled = False
	End If
	setCtrlButtonsBorder
End Sub

Sub enableAlbumInfo
	If Starter.lyricFound = True Then
		pnl_lyric_button.SetElevationAnimated(700, 8dip)
		pnl_lyric_button.Enabled = True
	Else
		pnl_lyric_button.SetElevationAnimated(700, 0dip)
		pnl_lyric_button.Enabled = False
	End If
	setCtrlButtonsBorder
End Sub


Sub pnl_album_info_button_Click
	If Starter.clsFunc.IsMusicPlaying = False Then Return
	If lblArtistNowPlaying.Text = "" Then Return
	Dim result As Int
	
	result = Msgbox2("Store selected song", Starter.vAppname, "Yes", "", "No", Null)
	If result = DialogResponse.POSITIVE Then
		genDb.addSongToStoredSongs(lblArtistNowPlaying.Text, "", lblNowPlayingStation.Text, DateTime.Now, ivNowPlayingStation.Bitmap, ivNowPlaying.Bitmap)
		showHideStoredSongs		
		ToastMessageShow("Song/artist stored for future referencee", False)
	End If
End Sub


Sub setControlButtonsState
	If 	pnl_store_song_button.Elevation > 0dip Then
		Starter.pnl_store_song_button	= True
	Else 
		Starter.pnl_store_song_button	= False
	End If
		
	If 	pnl_lyric_button.Elevation > 0dip Then
		Starter.pnl_lyric_button	= True
	Else
		Starter.pnl_lyric_button	= False
	End If
	
	If 	pnl_stop_button.Elevation > 0dip Then
		Starter.pnl_stop_button	= True
	Else 
		Starter.pnl_stop_button	= False
	End If
		
	If 	pnl_album_info_button.Elevation > 0dip Then
		Starter.pnl_album_info_button	= True
	Else
		Starter.pnl_album_info_button	= False
	End If
		
End Sub


Sub setGenre(genre As String)
	Return
	lbl_time_now.Text = $"Genre : ${genre}"$
	Starter.currStationGerne = genre
	'CHECK IF GERNE MATCHES GERNE IN TABLE, IF NOT UPDATE GENRE IN TABLE
	genDb.updateStationGenre
End Sub


Sub startOrStopStream(index As Int)
	freeze(True)
	Wait For(start_stopStream(index)) Complete (result As Boolean)
	
End Sub

'Sub getStationId(index As Int)
'	
'End Sub

Private Sub disableClickTimer_Tick
	freeze(False)	
End Sub

Sub freeze(show As Boolean) 
'	Log("FREEZE ENABLED : "& show)
	tmr.Enabled = show
	pnl_block.Visible = show
End Sub

Sub pnl_block_Touch (Action As Int, X As Float, Y As Float)
	'Starter.clsFunc.showLog("pnl_lock_Touch", 0)
End Sub

Sub setWifiPhoneImage(isWifi As Boolean, text As String)
	lbl_stop_playing.Visible	= True
	If isWifi Then
		lbl_stop_playing.SetBackgroundImage(LoadBitmap(File.DirAssets, "wifi.png"))
		lbl_stop_playing.Visible = False
		lbl_countdown_timer.Visible = False
	Else
		lbl_stop_playing.SetBackgroundImage(LoadBitmap(File.DirAssets, "no_wifi.png"))
		lbl_stop_playing.Visible = True
		lbl_countdown_timer.Text = text
		lbl_countdown_timer.Visible = True
		clsScroll.Initialize
		clsScroll.runMarquee(lbl_countdown_timer, text, "MARQUEE")
	End If
End Sub


Sub drawPanelBorder(pnl As Panel, setBorder As Boolean)
	Dim c As ColorDrawable
	If setBorder Then
		c.Initialize2(Colors.White,4dip,1dip,0xFFEFECEC)
	Else 
		c.Initialize2(Colors.White,4dip,0dip,0xFFEFECEC)
	End If	
	
	pnl.Background = c
End Sub

Sub setSvg(view As ImageView, svg As String)
	Dim tCanvas As Canvas
	tCanvas.Initialize(view)

	Dim svgGen As ioxSVG
	svgGen.Initialize(svg)
	svgGen.DocumentWidth = view.Width
	svgGen.DocumentHeight = view.Height
	svgGen.RenderToCanvas(tCanvas)
End Sub

Sub img_close_Click
	exitPlayer
End Sub

Sub streamLostText(lostText As String)
	lblArtistNowPlaying.Text = lostText
	
End Sub


Sub setVolumePanel
	Dim middle, top As Int
	'SHOW VOLUME PANEL
	middle	= pnl_volume.Left
	top		= (pnlControl.Top-pnl_volume_slider.Height) + 10
	
	pnl_volume_slider.Left	= middle-(pnl_volume_slider.Width/2)+(pnl_volume.Width/2)
	pnl_volume_slider.Top	= top
	
	'SET SEEKBAR
	xSlider.Width	= pnl_volume_slider.Height - 15dip
	xSlider.Left 	= 0dip '(xSlider.Height-xSlider.Width/3)+8dip
	
End Sub

Sub pnl_volume_Click
	If clsVol.timerActive = True Then Return
	If pnl_volume_slider.Visible = False Then
		clsVol.enableVolumeTimer
		pnl_volume_slider.SetVisibleAnimated(1000, True)
		pnl_volume.SetElevationAnimated(500, 5dip)
	Else
		pnl_volume_slider.SetVisibleAnimated(1000, False)
		pnl_volume.SetElevationAnimated(500, 0dip)
	End If
	
End Sub

Sub pnl_stop_button_Click
	lblHeaderPlayButton_Click
End Sub

Sub showVolumeBar
	pnl_volume_slider.SetVisibleAnimated(1000, False)
	pnl_volume.SetElevationAnimated(500, 0dip)
End Sub


Sub iv_station_logo__LongClick
	Dim selLogo As ImageView = Sender
	Dim index As Int = clvPlayer.GetItemFromView(selLogo)
	Dim stationName As String
	Dim stationId As Int
	
	stationId	= cmGen.getStationRecord(getStationByIndex(index), "pref_id")
	stationName = getStationByIndex(index)
	
	LogoFromFile(stationName, stationId, index)
End Sub


Public Sub LogoFromFile(stationName As String, stationId As Int, pnlIndex As Int)
	Dim cc As ContentChooser
	selectedStationName = stationName.Replace(" ", "")
	selectedStationId	= stationId
	selectedPanel		= pnlIndex
	cc.Initialize("cc")
	cc.Show("image/png","Select station logo")
End Sub

Private Sub cc_Result (Success As Boolean, Dir As String, Filename As String)
	Dim logoFolder As String = Starter.irp_dbFolder & "/station_logo/"
	Dim newFileName As String
	Dim logo As Bitmap
	Dim failed As Boolean = False
    
    
	If File.IsDirectory(logoFolder, "") = False Then
		ToastMessageShow("Logo folder not found", True)
		Return
	End If
    
	If Success Then
        
		newFileName = selectedStationName&".png"
        
		Wait For (File.CopyAsync(Dir, Filename, logoFolder, newFileName)) Complete (Success As Boolean)
		If Success Then
			logo.Initialize(logoFolder, newFileName)
			logo.Resize(150, 150, True)
			Dim Out As OutputStream
			Out = File.OpenOutput(logoFolder, newFileName, False)
			logo.WriteToStream(Out, 100, "PNG")
			Out.Close
		Else
			failed = True
		End If
	Else
		failed = True
	End If
    
	If failed = False And Success Then
		genDb.writeStationImgPath(logoFolder&"/"&newFileName, selectedStationId)
		CallSub3(Me, "setNewLogo", logoFolder&"/"&newFileName, selectedPanel)
	End If
    
	clearLogoVars
    
    
End Sub

Sub setNewLogo(newStationLogoPath As String, index As Int)
	Dim bm As Bitmap = LoadBitmap(newStationLogoPath,"")
	Dim pnl As Panel = clvPlayer.GetPanel(index)
    
	For Each v In pnl.GetAllViewsRecursive
		Dim vi As B4XView = v
		If vi.Tag = "pnl_station_logo" Then
			Dim vi2 As ImageView = vi.GetView(0)
			vi2.Bitmap = bm
			Exit
		End If
	Next
    
    
End Sub


Private Sub clearLogoVars
	selectedStationName = ""
	selectedStationId    = 0
	selectedPanel        = -1
End Sub

Public Sub AppCrash
	If File.Exists(Starter.irp_dbFolder, "imgPlaying.png") Then
		File.Delete(Starter.irp_dbFolder, "imgPlaying.png")
	End If
		
	CallSub2(Starter, "setSongLyric", "noLyric")
	CallSubDelayed(Starter, "initPlayerVars")
	Starter.vAlbumTrack = ""
	Starter.vAlbumName	= ""
	Starter.vPlayerSelectedPanel = 999
	lblArtistNowPlaying.Text = Starter.streamLostInfo
	pnlPlayingStation.Visible = False
	ivNowPlaying.Bitmap = LoadBitmap(File.DirAssets, "logo_afr.png")
	pnl_volume.Elevation = 0dip
	pnl_stop_button.Elevation = 0dip
	pnl_lyric_button.Elevation = 0dip
	pnl_store_song_button.Elevation = 0dip
	pnl_album_info_button.Elevation = 0dip
	setCtrlButtonsBorder
	lblNowPlayingStation.Text = "" '"Click on a station to start streaming"
	Starter.streamLostInfo = ""
End Sub

'CONNECTION LOST HANDLE SETTINGS
Public Sub connectionLost
	CallSub(Starter, "stopPlayer")
	startOrStopStream(Starter.vPlayerSelectedPanel)
	'MUST BE GLOBAL CODE
	pg_playing	= ""
	pg_playing	= ""
	pg_station	= ""
	Starter.vAlbumTrack = ""
	Starter.vAlbumName	= ""
	Starter.vPlayerSelectedPanel = 999
	lblNowPlayingStation.Text	= "" '"Click on a station to start streaming"
	lblArtistNowPlaying.Text	= ""
	lblNowPlayingDataRate.Text	= ""
	pnlPlayingStation.Visible = False
	ivNowPlaying.Bitmap = LoadBitmap(File.DirAssets, "logo_afr.png")
End Sub



Sub pnl_img_Click
	pnl_store_song_button_Click
End Sub

Sub showNoConnectionText(txt As String)
	lbl_countdown_timer.Visible = True
	lbl_countdown_timer.Text = txt
End Sub


Sub CheckTimer_CheckedChange(Checked As Boolean)
	Dim pnl As Panel = pnlTimer
	Dim box, boxClicked As CheckBox
	
	boxClicked = Sender
	For Each v As View In pnl.GetAllViewsRecursive
		If v Is CheckBox Then
			box = v
			box.Checked = False
		End If
		
	Next
	
	boxClicked.Checked = Checked
End Sub



Sub lblPreventClick_Click
	
End Sub


Sub pnl_block_Click
	Return
End Sub


Sub iets
	If Starter.spotMap.Size < 1 Then
		Return
	End If
	
	Dim sf As Object = DetailsDialog.ShowAsync("", "OK", "", "", Null, True)
	DetailsDialog.SetSize(100%X, 500dip)
	Dim minute, second As String
	minute = "00"
	second = "00"
	If Starter.spotMap.Get("duration") <> "" Then
		minute = NumberFormat2(DateTime.GetMinute(Starter.spotMap.Get("duration")), 2, 2, 0, False)
		second = NumberFormat2(DateTime.GetSecond(Starter.spotMap.Get("duration")), 2, 2, 0, False)
	End If
	
	Wait For (sf) Dialog_Ready(pnl As Panel)
	pnl.LoadLayout("dlgSongInfo")
	ivSpotAlbum.Bitmap = Starter.vSongAlbumArt
	lblSpotAlbumName.Text = Starter.vAlbumName
	lblSpotReleaseDate.Text = Starter.vAlbumReleaseDate
	lblSpotTrackNr.Text = Starter.vAlbumTrack
	lblSpotArtist.Text = Starter.spotMap.Get("artistname")
	lblSpotSong.Text = Starter.spotMap.Get("artistsong")
	lblSpotDuration.Text =$"${minute}:${second}"$
	
End Sub


Sub btnSpotOpenInBrowser_Click
	Dim intent1 As Intent
	intent1.Initialize(intent1.ACTION_VIEW, Starter.vSpotUrl)
	StartActivity(intent1)
End Sub


Sub lblNowPlayingStation_Click
End Sub

Public Sub SetElevation(v As View, e As Float)
	Dim jo As JavaObject
	Dim p As Phone
	If p.SdkVersion >= 21 Then
		jo = v
		jo.RunMethod("setElevation", Array As Object(e))
	End If
End Sub

Sub ivSpotify_Click
	Dim intent1 As Intent
	intent1.Initialize(intent1.ACTION_VIEW, Starter.vSpotUrl)
	StartActivity(intent1)
End Sub

Sub btn_lyric_close_Click
	
End Sub

'Sub showStationInfo(index As Int)
'	Dim sfFormat As Object = DetailsDialog.ShowAsync("", "OK", "", "", Null, True)
'	
'	DetailsDialog.SetSize(100%X, pnlOverflow.Height+120dip)
'	Wait For (sfFormat) Dialog_Ready(pnl As Panel)
'	pnlOverflow.Top = 0
'	lbl_station_name.Color	= 0xFF004BA0
'	pnl.LoadLayout("dlgStationInfo")
'	lbl_station_name.Text	= getStationByIndex(index)
'	Log(lbl_station_name.Text)
'End Sub

Sub showNowPlayingFormat
	Dim sfFormat As Object = DetailsDialog.ShowAsync("", "OK", "CANCEL", "", Null, True)
	'DetailsDialog.SetSize(100%X, 500dip)
	'lbl_playing_text.Initialize("")
	Log(lblArtistNowPlaying.Text)
	
	Log(Starter.chartArtist)
	Log(Starter.chartSong)
	
	Wait For (sfFormat) Dialog_Ready(pnl As Panel)
	pnl.LoadLayout("player_playing_format")
	lbl_playing_text.Text = lblArtistNowPlaying.Text
	lbl_playing_stname.Text = lblNowPlayingStation.Text
	lblIsArtist.Text = Starter.chartSong
	lblIsArtist1.Text	= Starter.chartArtist
	Wait For (sfFormat) Dialog_Result(Result As Int)
	If Result = DialogResponse.POSITIVE Then
		Log(Result)
	End If
	Log(Result)
End Sub

Sub showLyricDialog
	'Private TextEngine As BCTextEngine
	
	Dim html As String = File.ReadString(File.DirAssets, "lyric.html")
	Dim vLyric As String = CallSub(Starter, "getSetSongLyric")
'	LogColor(vLyric, Colors.Red)
	html = html.Replace("_text_", cmGen.RegexReplace("\n", vLyric, "<br><br>"))
	
	Dim sf As Object = DetailsDialog.ShowAsync("", "OK", "", "", Null, True)
	DetailsDialog.SetSize(100%X, Activity.Height - 200dip)
	Wait For (sf) Dialog_Ready(pnl As Panel)
	pnl.LoadLayout("dlgSongLyric")
	
	'TextEngine.Initialize(pnl)
	
	lbl_lyric_title.Text = retSongPlaying'Starter.spotMap.Get("artistname")& " - " &Starter.spotMap.Get("artistsong")
	'vLyric = vLyric.Replace("<!-- Usage of azlyrics.com content by any third-party lyrics provider Is prohibited by our licensing agreement. Sorry about that. -->", "")
	'Dim txt As String = vLyric.Replace("<!-- Usage of azlyrics.com content by any third-party lyrics provider Is prohibited by our licensing agreement. Sorry about that. -->", "")
	wvLyric.LoadHtml(html)
	'BBCodeView1.Text = clsFunc.processLyric(vLyric)'vLyric.Replace("<br>", $"${CRLF}${CRLF}"$)

	
End Sub


Sub btn_img_new_station_Click
	img_close_Click
End Sub


Sub swIsArtist_CheckedChange(Checked As Boolean)
	
End Sub

Sub swIsArtist1_CheckedChange(Checked As Boolean)
	
End Sub

Public Sub retSongPlaying As String
	Return lblArtistNowPlaying.Text
End Sub

Sub lblArtistNowPlaying_Click
End Sub



Sub pnlOverflow_Click As Boolean
	Return True
End Sub