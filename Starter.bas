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


Sub Process_Globals
	Public sleepTimerDuration As Long
	Public AacMp3Player As JavaObject
	Private logs As StringBuilder
	Private logcat As LogCat
	Private const emailAddress As String = "pieter09@gmail.com"
	Private streamTimer As Timer
	Public clsFunc As clsFunctions
	Private vSongPlaying As String	= "Click on a station to start streaming"
	Public vSongLyric As String	= "noLyric"
	Private vSongTitle As String
	Private songdata As clsHttp
	Private clsChart As clsChartlyrics
	Private PlayerCallback As Object
	'Private logo As Bitmap = LoadBitmapResize(File.DirAssets, "radio_flat.png", 24dip, 24dip, False)
	Private logo As Bitmap = LoadBitmapResize(File.DirAssets, "radio_notif.png", 24dip, 24dip, False)
	Public phoneKeepAlive As PhoneWakeState
	Private clsImage As clsRandomImage
	Public spotMap As Map
	
	'STRING
	Public dbL, Username, Password, activeActivity, playerUsed, lastfmapi, countryCode As String
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
	Public chatDataLyric, lyricsOnDemand, pnl_store_song_button, lyricFound, albumArtFound, albumArtSet, streamLost As Boolean = False
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
	Dim tmrInetConnection As Timer
	Dim clsGen As clsGeneral
End Sub


Sub Service_Create
	clsFunc.Initialize
	clsChart.Initialize
	clsImage.Initialize
	spotMap.Initialize
	clsGen.Initialize
	Service.AutomaticForegroundMode = Service.AUTOMATIC_FOREGROUND_ALWAYS

	If rp.Check(rp.PERMISSION_READ_PHONE_STATE) Then 
		PE.InitializeWithPhoneState("PE",PhoneId)
	End If
	
	mManualFolder	= rp.GetSafeDirDefaultExternal("shared")
	irp_dbFolder	= rp.GetSafeDirDefaultExternal("IRP")
	smallIcon		= LoadBitmapResize(File.DirAssets, "radio_notif.png", 24dip, 24dip, True)
	logs.Initialize
#if RELEASE
	logcat.LogCatStart(Array As String("-v","raw","*:F","B4A:v"), "logcat")
#end if
	
	'need to disable it as reading from large JdbcResultSet will cause network requests to be sent on the main thread.
	DisableStrictMode
	connectionTimer.Initialize("connectionTimer", 5*1000)
	connectionTimer.Enabled	= True
	setupPlaybackEvent
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
	connectionTimer.Enabled		= True
End Sub

Public Sub initPlayerVars
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
		vSongAlbumArt	= vAlbum.Resize(ivAlbumArtwidth, ivAlbumArtHeight, True)
		Dim Out As OutputStream
		
		Out = File.OpenOutput(mManualFolder, "imgPlaying.png", False)
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


Sub connectionTimer_Tick
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
		StartPlayer(selectedStream)
	Else
		streamTimer.Enabled = True
		tryRestartStream = False	
	End If
	
	
End Sub



public Sub IsStreamActive(Stream As Int) As Boolean
	Dim jo As JavaObject
	Return jo.InitializeStatic("android.media.AudioSystem").RunMethod("isStreamActive", Array(Stream, 0))
End Sub


Sub PlayerCallback_Event (MethodName As String, Args() As Object) As Object 'ignore
	lastAccPlayerTime = DateTime.Now
	
'	If Args <> Null Then
'		Return
'	Else
'		Dim dummyObj As Object
'		
'		'Return Args
'	End If
	Try
		vSong	= "No song information"
		If MethodName = "playerPCMFeedBuffer" Then
			If Args(0) = False Then
				ToastMessageShow("Stream active, but no audio", True)
				CallSubDelayed2(player, "showStreamWarning", True)
				restartStream
			End If
		End If
		If MethodName = "playerMetadata" Then
		
			streamWebSite = ""
			If Args(0) <> Null And Args(1) <> Null Then
					
				If Args(0) = "icy-genre" Then
					CallSub2(player, "setGenre", Args(1))
				End If
			
				If Args(0) = "icy-url" Then
					streamWebSite	= Args(1)
					Dim stUrl As String = Args(1)
					If activeActivity = "searchStation" And stUrl.Length > 0 Then
						CallSub2(searchStation, "pullStationUrl", stUrl)
					End If
					If IsPaused(player) = False Then
						vStationUrl = Args(1)
						CallSub2(player, "getStationLogo", Args(1))
					End If
				End If
			End If
			Try
				If Args(0) <> Null And Args(1) <> Null And Args(0) = "icy-br" Then
					If activeActivity = "searchStation" Then
						CallSub2(searchStation, "setStreamBitRate", "Bitrate : " & Args(1))
					Else
						CallSub2(player,"setStationBitrate", "Station bitrate : "& Args(1))
					End If
				End If
				If Args(0) <> Null And Args(1) <> Null And Args(0) = "ice-audio-info" Then
					If activeActivity = "searchStation" Then
						CallSub2(searchStation, "setStreamBitRate", Args(1))
					End If
				End If
			
				If Args(0) <> Null And Args(1) <> Null And Args(0) = "icy-name" Then
					vStationName	= Args(1)
					If activeActivity = "searchStation" Then
						'CallSub2(searchStation, "getStationUrl", vStationUrl)
						'CallSub2(searchStation, "pullStationUrl", vStationUrl)
						searchStation.stationUrl = vStationUrl
					End If

					If vStationName = "" Then
						vStationName = "AdFree Radio"
					End If
								
				
				End If
			Catch
				Log("")
			End Try
		
			Try
				If Args = Null Or Args.Length = 0 Then
				End If
			
				If Args(0) <> Null And Args(1) <> Null And Args(0) = "StreamTitle" Or Args(0) = "StreamNext" Then ' And vIsPreset = False Then
					If Args(1) <> ""  Then
						
						vSong	= Args(1)
						vSong	= clsFunc.ReplaceRaros(vSong)
						If lastSong = "" Or lastSong <> vSong Then
							'DISABLE SONG-INFO & SONG-LYRICS BUTTON
							spotMap.Clear
							CallSub(player, "disableInfoPanels")
							setAlbumArt(LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
							lastSong = vSong
							setSongPlaying(vSong)
							clearNotif(vSong)
							If activeActivity = "player" Then
								CallSub2(Me, "setSongPlaying", vSong)
								CallSub2(Me, "setSongLyric", "noLyric")
								CallSub(player, "hideLyrics")
								vAlbumName  		= ""
								vAlbumTrack 		= ""
								vAlbumReleaseDate	= ""
								vSpotUrl			= ""
								albumArtSet = False
						
								Dim mySong As String		= scrobbler.processPlaying(vSong)
								Try
								
									If IsPaused(player) Then Return True
									'CallSubDelayed2(songdata,"spBearer", mySong)
									CallSubDelayed3(songdata,"spBearer", chartArtist, chartSong)
									CallSubDelayed(player, "enableAlbumInfo")
'									If spotMap.Size > 0 Then
'										CallSub2(Me, "setSongPlaying", $"${spotMap.Get("artistname")} - ${spotMap.Get("artistsong")}"$)
'									End If
									
									If albumArtSet Then
										CallSub2(player, "enableAlbumButton", False)
									Else 'TRY CHARTLYRICS
										If albumArtSet = False Then
											'clsImage.newRandomImage
										End If
									End If
									
								Catch
									LogColor($"ERROR IN SPBEARER ${LastException}"$, Colors.Magenta)
								End Try
							End If
						End If
						If IsPaused(player) = False Or IsPaused(searchStation) = False Then
							CallSub2(activeActivity, "nowPlaying", vSong) 'Starter.activeActivity holds active activity
						
						End If
					Else
						CallSub2(activeActivity, "nowPlaying", "No artist information")
						CallSub2(Me, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
					End If
			
				End If
			Catch
				clsFunc.showLog(">>> " & LastException.Message, 0)
			End Try
		End If
		
		If MethodName = "playerStarted" Then ' Player START playing
			modGlobal.PlayerStarted = True
		End If
		
		If MethodName = "playerStopped" Then ' Player STOP playing
			modGlobal.PlayerStarted = False
		End If
	
		If MethodName = "playerException" Then ' Player EXCEPTION, check LOG for errors
			Try
				If Args(0) <> Null Then
					If activeActivity = "searchStation" Then
						CallSub2(searchStation,"streamPlaying", False)
					End If
					If activeActivity = "player" Then
					End If
				End If
			Catch
				clsFunc.showLog("srvPlayer--Error--", 0)
			End Try
			modGlobal.PlayerError = "playing"
		End If
	Catch
		clsFunc.showLog("srvPlayer--Error--", 0)
		Log(LastException)
	End Try
End Sub


'#If JAVA
'	public void RegisterIcyURLStreamHandler(){
'	try {
'	        java.net.URL.setURLStreamHandlerFactory( new java.net.URLStreamHandlerFactory(){
'	            public java.net.URLStreamHandler createURLStreamHandler( String protocol ) {
'	                if ("icy".equals( protocol )) return new com.spoledge.aacdecoder.IcyURLStreamHandler();
'	                return null;
'	            }
'	        });
'	    }
'	    catch (Throwable t) {
'	     
'	    }
'	}
'#End If



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


Sub setupPlaybackEvent
	Dim jo As JavaObject
	jo =  jo.InitializeStatic("com.spoledge.aacdecoder.PlayerCallback") ' initialize PlayerCallback
	PlayerCallback = jo.CreateEvent("com.spoledge.aacdecoder.PlayerCallback", "PlayerCallback", Null) ' Set PlayerCallback
	'modGlobal.AacMp3Player = jo.InitializeNewInstance("com.spoledge.aacdecoder.MultiPlayer", Array As Object(PlayerCallback)) ' Set MultiPlayer (AAC + MPEG/MP3 decode)
	'modGlobal.AacMp3Player.RunMethod("setMetadataCharEnc", Array("ISO-8859-1")) ' 99% of radio station use Western charset, if you comment this line UTF-8 will be used
	AacMp3Player = jo.InitializeNewInstance("com.spoledge.aacdecoder.MultiPlayer", Array As Object(PlayerCallback)) ' Set MultiPlayer (AAC + MPEG/MP3 decode)
	'AacMp3Player.RunMethod("setMetadataCharEnc", Array("ISO-8859-1")) ' 99% of radio station use Western charset, if you comment this line UTF-8 will be used
End Sub

Sub StartPlayer (RadioStationURL As String)
	Try
		AacMp3Player.RunMethod("playAsync", Array(RadioStationURL, 128))
		Sleep(2000)
	Catch
		Log(LastException)
	End Try
	
End Sub

Sub StopPlayer
	AacMp3Player.RunMethod("stop", Null)
	Sleep(2000)
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
	StopPlayer
	StartPlayer(selectedStream)
	If clsFunc.IsMusicPlaying = False And tryRestartCount < 5 Then
		streamEnded
		Return
	Else
		tryRestartStream = False
		Sleep(3000)
		CallSubDelayed2(player, "showStreamWarning", False)
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
		CallSubDelayed2(player, "showStreamWarning", True)
	End If
	clearNotif($"Connection to stream lost at $DateTime{DateTime.Now}"$)
End Sub

