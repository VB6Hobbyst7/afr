B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.8
@EndOfDesignText@
 #IgnoreWarnings: 9, 1
 #Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	Public clsRndImage As clsRandomImage
	Public exoPlayer As SimpleExoPlayer
	'Public clsExoPlayer As clsExo
	Public sleepTimerDuration As Long
	Private logs As StringBuilder
	Private logcat As LogCat
	Private const emailAddress As String = "pieter09@gmail.com"
	Public streamTimer As Timer
	Public clsFunc As clsFunctions
	Private vSongPlaying As String	= "Click station to start streaming"
	Public vSongLyric As String	= "noLyric"
	Private vSongTitle As String
	Private songdata As clsHttp
'	Private clsChart As clsChartlyrics
'	Private PlayerCallback As Object
	'Private logo As Bitmap = LoadBitmapResize(File.DirAssets, "radio_flat.png", 24dip, 24dip, False)
	Private logo As Bitmap = LoadBitmapResize(File.DirAssets, "radio_notif.png", 24dip, 24dip, False)
	Public phoneKeepAlive As PhoneWakeState
	Private clsImage As clsRandomImage
	Public spotMap As Map
	Public kvs As KeyValueStore
	
	'STRING
	Public dbL, Username, Password, activeActivity, playerUsed, lastfmapi, countryCode, updateFile As String
	Public SpotClientID1, SpotClientSecret1, SourceWeb1, mManualFolder, vAlbumTrack As String
	Public vAlbumName, vAlbumReleaseDate, irp_dbFolder, vSong, vStationName, songPlayingNow As String
	Public spotArtist, spotSong As String
	Public chartArtist, chartSong, streamLostInfo, vSpotError, vSpotUrl, localeDatFormat As String
	Public selectedStream, currStationId, currStationGerne As String
	Public streamWebSite, vStationUrl, lastSong As String	= ""
	Public driver As String = "com.mysql.jdbc.Driver"
	Public vAppname As String	= Application.LabelName
	Public sStationLogoPath As String = "null"
	Public mobileData As String = ""
	Public doy As String ="pdegrootafr", moy As String ="hkWpXtB1!"
	'BOOLEAN
	Public vWifiOnly, vUpdateLogo, vWifiConnected, chartDataFound, capNowPlaying, newTitle, triedGetStation As Boolean
	Public streamStarted, vIsPreset, pnl_album_info_button, pnl_stop_button, pnl_lyric_button, tryRestartStream As Boolean = False
	Public chatDataLyric, lyricsOnDemand, pnl_store_song_button, lyricFound, albumArtFound, albumArtSet, streamLost, getUpdate As Boolean = False
	Public chartLyricsDown, triedLyrics As Boolean = True
	'FLOAT
	Public vDataUsage, ivAlbumArtHeight, ivAlbumArtwidth As Float
	'INT
	Public currentMusicVolume, playingStationId, rndImgSet = 0 As Int
	Public streamRestartCount, stationAdded, tryRestartCount As Int = 0
	Public vPlayerSelectedPanel As Int = 999
	Public notifId As Int = 1
	'LONG
	Public lastAccPlayerTime, startAccPlayerTime, jobTimeOut = 60*1000 As Long
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
	Public tmrInetConnection, tmrGetSong, tmrInactive As Timer
	Dim clsGen As clsGeneral
	
	Dim clsSngData As clsSongData
	Dim csChartLyric As clsChartlyrics
	Public playingSong, icy_playing As String
	'Private albumTag="91f924c1eace4879ba9c4c0f5061e925" as String, songTag="b4fb29e9e2b0490bad9489c28dae6b89" As String
End Sub


Sub Service_Create
	startAccPlayerTime	= DateTime.Now
	triedGetStation = False
	clsRndImage.Initialize
	clsFunc.Initialize
	'clsChart.Initialize
	clsImage.Initialize
	spotMap.Initialize
	clsGen.Initialize
	csChartLyric.Initialize
	clsSngData.Initialize
	exoPlayer.Initialize("player")
	
	Service.AutomaticForegroundMode = Service.AUTOMATIC_FOREGROUND_ALWAYS

	If rp.Check(rp.PERMISSION_READ_PHONE_STATE) Then 
		PE.InitializeWithPhoneState("PE",PhoneId)
	End If
	
	'mManualFolder	= rp.GetSafeDirDefaultExternal("shared")
	'irp_dbFolder	= rp.GetSafeDirDefaultExternal("")
	irp_dbFolder	= rp.GetSafeDirDefaultExternal("irp_files") 'File.DirInternal
	kvs.Initialize(irp_dbFolder, "settings", True)
	smallIcon		= LoadBitmapResize(File.DirAssets, "radio_notif.png", 24dip, 24dip, True)
	logs.Initialize
	
#if RELEASE
	logcat.LogCatStart(Array As String("-v","raw","*:F","B4A:v"), "logcat")
#end if
	
	'need to disable it as reading from large JdbcResultSet will cause network requests to be sent on the main thread.
	DisableStrictMode
	tmrInactive.Initialize("tmrInactive", 10*60000)
	tmrInactive.Enabled = False
	tmrGetSong.Initialize("tmrGetSong", 8*1000)
	'tmrGetSong.Enabled = True
	connectionTimer.Initialize("connectionTimer", 5*1000)
	connectionTimer.Enabled	= True
	tmrInetConnection.Initialize("inetConnected", 1000)
	tmrInetConnection.Enabled = True
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

Sub tmrInactive_Tick
'	Log("tmrInactive_Tick")
	Dim streamActive As Boolean = clsFunc.IsStreamActive(3)
	If IsPaused(player) And streamActive = False Then
		clsFunc.exitPlayer
	End If
End Sub

Sub inetConnected_Tick
	'If clsFunc.IsMusicPlaying = False Then Return
	
	Wait For(CheckConnected) Complete (result As Boolean)
	
	If result = False Then
		'GIVE A FEW SECONDS TO RETRY TO CONNECT
		Sleep(10*1000)
		stopPlayer
		CallSub2(player, "startOrStopStream", vPlayerSelectedPanel)
	End If
	
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
	End If
	albumArtSet = True
	vSongAlbumArt	= vAlbum.Resize(ivAlbumArtwidth, ivAlbumArtHeight, True)
	
	CallSub2(player, "setAlbumArtFading", vSongAlbumArt)
	'CallSub2(player, "pnlImgColor", False)
	
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
'	LogColor("ERROR", Colors.Red)
	Return False
	
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
	
'	eventExo = joExo.CreateEvent("com.google.android.exoplayer2.Player$EventListener", "addMetadataOutput", False)'"MetadataOutput")
'	joExo.GetFieldJO("player").RunMethod("addListener", Array(eventExo))

	If clsFunc.IsMusicPlaying = False Then
		Return
	End If
	
'	Dim jo As JavaObject = exoPlayer   'i declared my player as exoplay
'	jo = jo.GetField("player")
'	Dim state As JavaObject = jo.RunMethod("getMetadataComponent", Null)
'	Dim state As JavaObject = jo.RunMethod("addMetadataOutput", Null)
	
	'LogColor($"tmrGetSong_tick $DateTime{DateTime.Now}"$, Colors.Red)
	If clsFunc.IsMusicPlaying = True Then
		clsSngData.icyMetaData
	End If
End Sub


Sub addmetadataoutput_event(MethodName As String,Args() As Object)
'	Log($"addmetadataoutput_event $DateTime{DateTime.Now} METHOD ${MethodName}"$)
	
'	Dim TrackGroups As JavaObject = joExo.GetFieldJO("exoplayer").RunMethod("getCurrentTrackGroups",Null)
'	Dim metaData As JavaObject = joExo.GetFieldJO("exoplayer").RunMethod("getMetadataComponent",Null)
'	Dim metaData1 As JavaObject = joExo.GetFieldJO("exoplayer").RunMethod("getTextComponent",Null)
    Dim x As String	
End Sub



Sub clearVars
	CallSub2(Me, "setSongLyric", "noLyric")
	vAlbumName  		= ""
	vAlbumTrack 		= ""
	vAlbumReleaseDate	= ""
	vSpotUrl			= ""
	albumArtSet 		= False
End Sub

Sub connectionTimer_Tick
'	If IsPaused(player) Then Return
	player.bckBtnClickCount = 1
	clsFunc.getConnectionType
	CallSub(player, "setTimeActive")
End Sub

Sub run_streamTimer(enable As Boolean)
	streamTimer.Initialize("streamTimer",2000)
	streamTimer.Enabled = enable
End Sub

Sub streamTimer_tick
	Dim ticksNow, tickPlayer, tickDiff As Int
	
'	startAccPlayerTime = DateTime.Now
'	ticksNow = clsFunc.ConvertMillisecondsToString(startAccPlayerTime)
'	tickPlayer = clsFunc.ConvertMillisecondsToString( lastAccPlayerTime)
'	tickDiff = ticksNow-tickPlayer
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

#Region exoplayer1
Public Sub startPlayer(url As String)
	triedGetStation = False
	selectedStream = url
	exoPlayer.Initialize("player")
	exoPlayer.Prepare(exoPlayer.CreateURISource(url))
	exoPlayer.Volume = 1
	exoPlayer.Play
	
		
End Sub

Sub player_Error(msg As String)
	If activeActivity = "searchStation" Then
		CallSub2(searchStation, "nowPlaying", "Unable to start selected stream")
	End If
	stopPlayer
End Sub

Sub Player_Ready
	setWakeLock(True)
	clsSngData.icyMetaData
	tmrGetSongEnable(True)
End Sub


Public Sub stopPlayer
	tmrGetSongEnable(False)
	triedGetStation = False
	exoPlayer.Pause
	exoPlayer.Release
	
	setWakeLock(False)
	clearNotif("Not streaming")
End Sub

#End Region



public Sub showNoImage
	clsRndImage.newRandomImage
End Sub

Public Sub hideSongData
	CallSub2(Me, "setSongLyric", "noLyric")
	CallSub(player, "hideLyrics")
End Sub

Public Sub playerPaused As Boolean
	Return IsPaused(player)
End Sub

#if Java
import anywheresoftware.b4a.keywords.B4AApplication;
import android.content.pm.PackageManager.NameNotFoundException;
import anywheresoftware.b4a.objects.SimpleExoPlayerWrapper;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
public static class MySimpleExoPlayerWrapper extends SimpleExoPlayerWrapper {
@Override
public DefaultDataSourceFactory createDefaultDataFactory() {
     return new DefaultDataSourceFactory(BA.applicationContext, "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36");
   }
  
}

#End If