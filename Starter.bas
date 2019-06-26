B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region
#IgnoreWarnings: 

Sub Process_Globals
	Public exoPlayer As SimpleExoPlayer
	'Public clsExoPlayer As clsExo
	Public sleepTimerDuration As Long
	'Public AacMp3Player As JavaObject
	Private logs As StringBuilder
	Private logcat As LogCat
	Private const emailAddress As String = "pieter09@gmail.com"
	Public streamTimer As Timer
	Public clsFunc As clsFunctions
	Private vSongPlaying As String	= "Click station to start streaming"
	Public vSongLyric As String	= "noLyric"
	Private vSongTitle As String
	Private songdata As clsHttp
	Private clsChart As clsChartlyrics
'	Private PlayerCallback As Object
	'Private logo As Bitmap = LoadBitmapResize(File.DirAssets, "radio_flat.png", 24dip, 24dip, False)
	Private logo As Bitmap = LoadBitmapResize(File.DirAssets, "radio_notif.png", 24dip, 24dip, False)
	Public phoneKeepAlive As PhoneWakeState
	Private clsImage As clsRandomImage
	Public spotMap As Map
	
	'STRING
	Public dbL, Username, Password, activeActivity, playerUsed, lastfmapi, countryCode, updateFile As String
	Public SpotClientID1, SpotClientSecret1, SourceWeb1, mManualFolder, vAlbumTrack As String
	Public vAlbumName, vAlbumReleaseDate, irp_dbFolder, vSong, vStationName As String
	
	Public chartArtist, chartSong, streamLostInfo, vSpotError, vSpotUrl, localeDatFormat As String
	Public selectedStream, currStationId, currStationGerne As String
	Public streamWebSite, vStationUrl, lastSong As String	= ""
	Public driver As String = "com.mysql.jdbc.Driver"
	Public vAppname As String	= Application.LabelName
	Public sStationLogoPath As String = "null"
	Public mobileData As String = ""
	Public doy As String ="pdegrootafr", moy As String ="hkWpXtB1!"
	'BOOLEAN
	Public vWifiOnly, vUpdateLogo, vWifiConnected, chartDataFound As Boolean
	Public streamStarted, vIsPreset, pnl_album_info_button, pnl_stop_button, pnl_lyric_button, tryRestartStream As Boolean = False
	Public chatDataLyric, lyricsOnDemand, pnl_store_song_button, lyricFound, albumArtFound, albumArtSet, streamLost, getUpdate As Boolean = False
	'FLOAT
	Public vDataUsage, ivAlbumArtHeight, ivAlbumArtwidth As Float
	'INT
	Public currentMusicVolume As Int
	Public streamRestartCount, stationAdded, tryRestartCount As Int = 0
	Public vPlayerSelectedPanel As Int = 999
	Public notifId As Int = 1
	'LONG
	Public lastAccPlayerTime, startAccPlayerTime As Long
	'BITMAP
	Public smallIcon, vSongAlbumArt As Bitmap
	'TYPED
	Public rp As RuntimePermissions
'	Public mysql As JdbcSQL
	Public connectionTimer As Timer
	Public notif As Notification
	Dim PE As PhoneEvents
	Dim PhoneId As PhoneId
	Public hasWakeLock As Boolean = False
	Public tmrInetConnection, tmrGetSong As Timer
	Dim clsGen As clsGeneral
	'Private albumTag="91f924c1eace4879ba9c4c0f5061e925" as String, songTag="b4fb29e9e2b0490bad9489c28dae6b89" As String
End Sub


Sub Service_Create
	clsFunc.Initialize
	clsChart.Initialize
	clsImage.Initialize
	spotMap.Initialize
	clsGen.Initialize
	exoPlayer.Initialize("player")
	Service.AutomaticForegroundMode = Service.AUTOMATIC_FOREGROUND_ALWAYS

	If rp.Check(rp.PERMISSION_READ_PHONE_STATE) Then 
		PE.InitializeWithPhoneState("PE",PhoneId)
	End If
	
	'mManualFolder	= rp.GetSafeDirDefaultExternal("shared")
	'irp_dbFolder	= rp.GetSafeDirDefaultExternal("")
	irp_dbFolder	= File.DirInternal
	smallIcon		= LoadBitmapResize(File.DirAssets, "radio_notif.png", 24dip, 24dip, True)
	logs.Initialize
#if RELEASE
	logcat.LogCatStart(Array As String("-v","raw","*:F","B4A:v"), "logcat")
#end if
	
	'need to disable it as reading from large JdbcResultSet will cause network requests to be sent on the main thread.
	DisableStrictMode
	tmrGetSong.Initialize("tmrGetSong", 5*1000)
	tmrGetSong.Enabled = True
	connectionTimer.Initialize("connectionTimer", 5*1000)
	connectionTimer.Enabled	= True
	tmrInetConnection.Initialize("inetConnected", 1000)
	tmrInetConnection.Enabled = False
	localeDatFormat = GetDeviceDateFormatSettings
	
End Sub


Sub Service_Start (StartingIntent As Intent)
	Service.StartForeground(notifId, createNotif("Not streaming.."))
	songdata.Initialize(Me, "test12")
End Sub


Sub GetDeviceDateFormatSettings As String
	Dim r As Reflector
	r.Target = r.RunStaticMethod("android.text.format.DateFormat", "getDateFormat", Array As Object(r.GetContext), _
      Array As String("android.content.Context"))
	Return r.RunMethod("toPattern")
End Sub

Sub inetConnected_Tick
	Wait For(CheckConnected) Complete (result As Boolean)
End Sub

Sub CheckConnected As ResumableSub
	'Requires Phone Library
	Dim p As Phone
	'Ping Google DNS
	Wait For (p.ShellAsync("ping", Array As String("-c", "1", "8.8.8.8"))) Complete (Success As Boolean, ExitValue As Int, StdOut As String, StdErr As String)
	If StdErr = "" And StdOut.Contains("Destination Host Unreachable")=False Then
		Return True
	Else
		Return False
	End If
End Sub

Sub Service_Destroy
	clearNotif("cancel")
	PE.StopListening()
	Service.AutomaticForegroundMode = Service.AUTOMATIC_FOREGROUND_NEVER
	Service.StopForeground(notifId)
	
	streamTimer.Enabled			= False
	tmrInetConnection.Enabled	= False
	connectionTimer.Enabled		= False
End Sub



Public Sub initPlayerVars
	vSongAlbumArt.Initialize(File.DirAssets, "NoImageAvailable.png")
	vSongAlbumArt	= LoadBitmap(File.DirAssets, "NoImageAvailable.png")
	vSongLyric		= "noLyric"
	vSongLyric		= ""
	vSongTitle		= ""
	vSongPlaying	= ""
	albumArtFound	= False
	lyricFound		= False
End Sub

Public Sub getDbPath As String
	Return irp_dbFolder
End Sub

Public Sub setSongTitle(vSTitle As String)
	vSongTitle = vSTitle
End Sub

Public Sub getSongTitle As String
	Return vSongTitle
End Sub

Public Sub setSongLyric(vLyric As String)
	vSongLyric	= vLyric
	CallSub2(player, "showHideLyricsButton", vSongLyric.Length > 20)
	
End Sub

Public Sub getSetSongLyric As String
	Return vSongLyric
End Sub

Public Sub setAlbumArt(vAlbum As Bitmap)
	If IsPaused(player) Then 
		Return
	
		If vSongAlbumArt.IsInitialized = False Then
			vSongAlbumArt.Initialize(File.DirAssets, "NoImageAvailable.png")
		End If
		vSongAlbumArt	= vAlbum.Resize(ivAlbumArtwidth, ivAlbumArtHeight, True)
		Dim Out As OutputStream
		
		Out = File.OpenOutput(irp_dbFolder, "imgPlaying.png", False)
		vAlbum.WriteToStream(Out, 100, "PNG")
		Out.Close
		Return
	End If
	albumArtSet = True
	vSongAlbumArt	= vAlbum.Resize(ivAlbumArtwidth, ivAlbumArtHeight, True)
	
	CallSubDelayed2(player, "setAlbumArtFading", vSongAlbumArt)
End Sub

Public Sub getAlbumArt As Bitmap
	Return vSongAlbumArt
End Sub

Public Sub setSongPlaying(vPlayingSong As String)
	vSongPlaying	= vPlayingSong	
	CallSub2(player, "setSongPlaying", vSongPlaying)
End Sub

Public Sub getSongPlaying As String
	Return vSongPlaying
End Sub

Public Sub endForeGround
	Service.StopAutomaticForeground
	Service.StopForeground(notifId)
	Service.StopForeground(51042)
	
End Sub


Private Sub logcat_LogCatData (Buffer() As Byte, Length As Int)
	logs.Append(BytesToString(Buffer, 0, Length, "utf8"))
	If logs.Length > 5000 Then
		logs.Remove(0, logs.Length - 4000)
	End If
End Sub

Sub Service_TaskRemoved
	streamTimer.Enabled = False
End Sub

Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
'Return true to allow the OS default exceptions handler to handle the uncaught exception.
	'wait for 500ms to allow the logs to be updated.
	'Return True
	
	Dim jo As JavaObject
	Dim l As Long = 500
	jo.InitializeStatic("java.lang.Thread").RunMethod("sleep", Array(l))
	logcat.LogCatStop
	logs.Append(StackTrace)
	Dim email As Email
	email.To.Add(emailAddress)
	email.Subject = "Program crashed"
	email.Body = logs
	StartActivity(email.GetIntent)
	CallSub(player, "exitPlayer")
	Return False 
End Sub

Sub DisableStrictMode
	Dim jo As JavaObject
	jo.InitializeStatic("android.os.Build.VERSION")
	If jo.GetField("SDK_INT") > 9 Then
		Dim policy As JavaObject
		policy = policy.InitializeNewInstance("android.os.StrictMode.ThreadPolicy.Builder", Null)
		policy = policy.RunMethodJO("permitAll", Null).RunMethodJO("build", Null)
		Dim sm As JavaObject
		sm.InitializeStatic("android.os.StrictMode").RunMethod("setThreadPolicy", Array(policy))
	End If
End Sub


Sub tmrGetSongEnable(isEnabled As Boolean)
	tmrGetSong.Enabled = isEnabled
End Sub

Public Sub tmrGetSong_tick
	If clsFunc.IsStreamActive(3) = False Then 
		Return
	End If
'	LogColor($"tmrGetSong_tick $DateTime{DateTime.Now}"$, Colors.Red)
	If clsFunc.IsMusicPlaying = True Then
		icyMetaData
	End If
End Sub

Public Sub icyMetaData
	Dim url, nSong, newSong As String
	Dim job As HttpJob
		
	url = $"http://ice.pdeg.nl/getIcy.php?url=${selectedStream}"$
'	Log(url)
	job.Initialize("", Me)
	job.Download(url)
	Wait For (job) JobDone(job As HttpJob)
	If job.Success Then
		nSong = job.GetString
		'Log(nSong)
		newSong = clsFunc.parseIcy(nSong)
'		LogColor($"NEWSONG ${newSong} LASTSONG ${lastSong}"$, Colors.Red)
		clsFunc.ReplaceRaros(newSong)
		If newSong <> lastSong Or lastSong = "" Then
			processSong(newSong)
		End If
	Else
'		LogColor($"NEWSONG ${newSong} LASTSONG ${lastSong}"$, Colors.Green)
		processSong(lastSong)
	End If
	job.Release
			
End Sub



Sub processSong(song As String)
	If(song.Length > 3) Then
		song	= clsFunc.ReplaceRaros(song)
'	song	= clsFunc.NameToProperCase(song)
	End If
	'LogColor(song, Colors.Red)
	If song.Length > 3 Then
		clearNotif(song)
	End If
	If lastSong = "" Or lastSong <> song And song.Length > 0 Then
		
		'DISABLE SONG-INFO & SONG-LYRICS BUTTON
		spotMap.Clear
		CallSub(player, "disableInfoPanels")
		setAlbumArt(LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		lastSong = song
'		LogColor(song, Colors.Red)
'		clearNotif(song)
		setSongPlaying(song)
		If song = "" Then song = "No information found"
		If activeActivity = "player" Then
			CallSub2(Me, "setSongPlaying", song)
			CallSub2(Me, "setSongLyric", "noLyric")
			CallSub(player, "hideLyrics")
			vAlbumName  		= ""
			vAlbumTrack 		= ""
			vAlbumReleaseDate	= ""
			vSpotUrl			= ""
			albumArtSet = False
				
			If song <> "No information found" Then
				Dim mySong As String		= scrobbler.processPlaying(clsFunc.ReplaceRaros(song))
								
'				If IsPaused(player) Then Return
				CallSubDelayed3(songdata,"spBearer", chartArtist, chartSong)
				If IsPaused(player) = False Then
					CallSubDelayed(player, "enableAlbumInfo")
					If albumArtSet Then
						CallSub2(player, "enableAlbumButton", False)
					Else
					End If
				End If
			End If
		End If
		If activeActivity = "searchStation" Then
'			Log("searchStation")
			CallSub2(activeActivity, "nowPlaying", song)
		End If
	End If
End Sub




Sub connectionTimer_Tick
'	If IsPaused(player) Then Return
	player.bckBtnClickCount = 1
	clsFunc.getConnectionType
End Sub

Sub run_streamTimer(enable As Boolean)
	streamTimer.Initialize("streamTimer",2000)
	streamTimer.Enabled = enable
End Sub

Sub streamTimer_tick
	Dim ticksNow, tickPlayer, tickDiff As Int
	
	startAccPlayerTime = DateTime.Now
	ticksNow = clsFunc.ConvertMillisecondsToString(startAccPlayerTime)
	tickPlayer = clsFunc.ConvertMillisecondsToString( lastAccPlayerTime)
	tickDiff = ticksNow-tickPlayer
	'GET CONNECTION TYPE WIFI OFR MOBILE
	clsFunc.getConnectionType
	'CHECK IF THERE IS A INTERNET CONNECTION
	wait for (clsFunc.CheckConnected) Complete (result As Boolean)
	
	If result = False Then 'STOP STREAM AND RESET PLAYER
		CallSub2(player, "startOrStopStream", (vPlayerSelectedPanel))
		CallSub2(player, "showNoConnectionText", "Please check your internet connection")
		Return
	End If
	
	
	If clsFunc.IsMusicPlaying = False Or tickDiff > 4 Then
		tryRestartStream = True
'		StartPlayer(selectedStream)
	Else
		streamTimer.Enabled = True
		tryRestartStream = False	
	End If
	
	
End Sub



public Sub IsStreamActive(Stream As Int) As Boolean
	Dim jo As JavaObject
	Return jo.InitializeStatic("android.media.AudioSystem").RunMethod("isStreamActive", Array(Stream, 0))
End Sub

Sub PE_PhoneStateChanged (State As String, IncomingNumber As String, Intent As Intent)
	Select State
		Case "RINGING"
			CallSubDelayed2(player, "toastphn", IncomingNumber)
			
		Case "IDLE"
			CallSubDelayed2(player, "toastphnResume", IncomingNumber)
	End Select
End Sub

#Region notification
Public Sub clearNotif(nText As String)
	'Log("NTEXT : " & nText)
	Dim n As Notification = createNotif(nText)
	n.Notify(notifId)
	If nText = "cancel" Then
		n.Cancel(notifId)
	End If
End Sub


Sub createNotif(nText As String) As Notification
	Dim content, title As String
	
	If nText.IndexOf("-") > -1 Then
		title = clsFunc.stringSplit(" - ", nText, 0, False, 0, False)
		content = clsFunc.stringSplit(" - ", nText, 0, False, 1, False)
	Else 
		title = nText
	End If	
	
	If sStationLogoPath <> "null" Then
		Dim largeIcon As Bitmap = LoadBitmapResize("", sStationLogoPath, 256dip, 256dip, True)
	Else
		Dim largeIcon As Bitmap = LoadBitmapResize(File.DirAssets, "radio_flat.png", 256dip, 256dip, True)
	End If
	
	Dim n1 As NB6
	n1.Initialize("irp", Application.LabelName, "LOW")
	n1.Color(0xFF0059FF)
	n1.setOngoing(False)
	n1.SmallIcon(logo)
	n1.ShowWhen(-1)

	n1.SubText(vStationName)
	n1.LargeIcon(largeIcon)
	
	n1.SetDefaults(False, False, False)
	n1.OnlyAlertOnce(True)
	Return n1.Build(title, content, "tag", player)
End Sub
#End Region




'Sub StartPlayer (RadioStationURL As String)
'	
'	Try
'	'	clsExo.startPlayer(RadioStationURL)
'		'AacMp3Player.RunMethod("playAsync", Array(RadioStationURL, 128))
'		Sleep(2000)
'		setWakeLock(True)
'	Catch
'		setWakeLock(False)
'		Log(LastException)
'	End Try
'	
'End Sub

'Sub StopPlayer
'	'clsExo.stopPlayer
'	'setWakeLock(False)
'	AacMp3Player.RunMethod("stop", Null)
'	Sleep(2000)
'End Sub

Public Sub setWakeLock(keepAlive As Boolean)
	If keepAlive = True Then
		phoneKeepAlive.KeepAlive(True)
		phoneKeepAlive.PartialLock
	Else	
		phoneKeepAlive.ReleaseKeepAlive
		phoneKeepAlive.ReleasePartialLock
	End If
	
End Sub

Public Sub restartStream
	run_streamTimer(False)
	If tryRestartCount > 4 Then
		tryRestartCount = 0
		tryRestartStream = False
		streamEnded
		Return
	End If

	tryRestartCount = tryRestartCount + 1
	'StopPlayer
	'clsExoPlayer.stopPlayer
	stopPlayer
	'StartPlayer(selectedStream)
	'clsExoPlayer.startPlayer(selectedStream)
	startPlayer(selectedStream)
	If clsFunc.IsMusicPlaying = False And tryRestartCount < 5 Then
		streamEnded
		Return
	Else
		tryRestartStream = False
		Sleep(3000)
'		CallSubDelayed2(player, "showStreamWarning", False)
		tryRestartCount = 0
		run_streamTimer(True)
	End If
	
	Return
End Sub


Private Sub streamEnded
	streamLost	= True
	streamLostInfo	= $"STREAM LOST.... at $DateTime{DateTime.Now}"$
	ToastMessageShow("Stream lost", True)
	CallSub(player, "connectionLost")
	Sleep(2000)
	If IsPaused(player) = False Then
		CallSubDelayed2(player, "streamLostText", $"STREAM LOST.... at $DateTime{DateTime.Now}"$)
'		CallSubDelayed2(player, "showStreamWarning", True)
	End If
	clearNotif($"Connection to stream lost at $DateTime{DateTime.Now}"$)
End Sub

Public Sub startPlayer(url As String)
	exoPlayer.Initialize("")
	Dim sources As List
	sources.Initialize
	exoPlayer.Prepare(exoPlayer.CreateURISource(url))
	
	exoPlayer.Volume = 1
	exoPlayer.Play
	setWakeLock(True)
	''tm.Initialize ("tm",1000)
	''tm.Enabled = True
	tmrGetSongEnable(True)
End Sub

Public Sub stopPlayer
'	Log("STOP PLAYER")
	exoPlayer.Pause
	exoPlayer.Release
	
	setWakeLock(False)
	tmrGetSongEnable(False)
End Sub