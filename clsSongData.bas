B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private songdata As clsHttp
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	songdata.Initialize(Me, "test12")
End Sub


Public Sub icyMetaData
	Dim url, nSong As String
	Dim job As HttpJob
	
	If Starter.selectedStream = "" Then
		Return
	End If
		
	url = $"http://ice.pdeg.nl/getIcy.php?url=${Starter.selectedStream}"$

	job.Initialize("", Me)
	job.Download(url)
	job.GetRequest.Timeout = Starter.jobTimeOut
	Wait For (job) JobDone(job As HttpJob)
		
		
	If job.Success Then
		nSong = job.GetString
		job.Release
		preProcessSongData(nSong)
	Else
		LogColor("IN JOB ERROR", Colors.Red)
		job.Release
		showNoImage
		preProcessSongData("No song information")
	End If
		
	job.Release
End Sub

Sub preProcessSongData(nSong As String)
	Dim newSong As String = Starter.clsFunc.parseIcy(nSong)
	
	If CallSub(Starter, "playerPaused") Then Return
			
	If Starter.newTitle = False Then 
		Return		
	End If
					
	If Starter.newTitle = True Then
		'Log($"$DateTime{DateTime.Now} - ${newSong}"$)
		
	'	CallSub2(Starter, "clearNotif", newSong)
	
		
		Starter.chartSong = ""
		Starter.chartArtist = ""
		CallSub(player, "disableInfoPanels")
		CallSub2(Starter, "setSongLyric", "noLyric")
		Starter.spotMap.Clear
		CallSub2(Starter, "setSongPlaying", Starter.icy_playing)
		processSong(newSong)
	End If
End Sub




Sub processSong(song As String)
	
	
	If(song.Length > 3) Then
		song	= Starter.clsFunc.ReplaceRaros(song)
	Else
		CallSubDelayed2(player, "showHideLyricsButton", False)
		CallSubDelayed2(player, "enableAlbumButton", False)
		CallSub2(player, "setSongPlaying", "No information")
		showNoImage
		Return
	End If
	
	If Starter.newTitle Then
		If Starter.activeActivity = "searchStation" Then
			CallSub2(Starter.activeActivity, "nowPlaying", song)
			Return
		End If
		'DISABLE SONG-INFO & SONG-LYRICS BUTTON
		Starter.spotMap.Clear
		CallSub(player, "disableInfoPanels")
		Starter.lastSong = song
		If song = "" Then song = "No information found"
		If Starter.activeActivity = "player" Then
			CallSub(Starter, "clearVars")
				
			If CallSub(player, "retSongPlaying") <> "No information found" Then
				songdata.songReversed	= False
				Dim mySong As String	= scrobbler.processPlaying(song)
				If mySong = "" Then
					showNoImage
					Return
				End If
				Starter.playingSong = $"${Starter.chartSong} - ${Starter.chartArtist}"$

				wait for(CallSub3(songdata,"spBearer", Starter.chartArtist, Starter.chartSong)) Complete (result As Boolean)
				
				If IsPaused(player) = False Then
					CallSubDelayed(player, "enableAlbumInfo")
					If Starter.albumArtSet Then
						CallSub2(player, "enableAlbumButton", False)
					Else
					End If
				End If
			Else
				showNoImage	
			End If
		End If
	Else
	End If
End Sub




Sub showNoImage
	Starter.clsRndImage.newRandomImage
End Sub


Public Sub clearSongData (pnlIndex As Int) As Boolean
	If pnlIndex = -1 Then
		pnlIndex = Starter.vPlayerSelectedPanel
	End If
	
	CallSub2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "logo_afr.png").Resize(Starter.ivAlbumArtHeight, Starter.ivAlbumArtwidth, True))
	CallSub(Starter, "stopPlayer")
	CallSub(player, "clearLabels")
	Starter.chartSong = ""
	Starter.chartArtist = ""
	Starter.lastSong = ""
	Starter.rndImgSet = 0
	modGlobal.PlayerStarted = False
	Starter.sStationLogoPath = "null"
	CallSub2(Starter, "run_streamTimer", False)
	CallSub2(player, "pnlImgColor", False)
	CallSub2(Starter, "clearNotif", "Not streaming")
	CallSubDelayed2(Starter, "setSongLyric", "noLyric")
	CallSub(player, "hideOverflow")
	CallSub(Starter,"initPlayerVars")
	CallSub2(player, "showHideLyricsButton", False)
	CallSub2(player, "enableAlbumButton", False)
	CallSub2(player, "setPanelElevation", -1)

	
	'SAME PANEL IS CLICK
	If Starter.vPlayerSelectedPanel = pnlIndex Then
		'reset info screen
		CallSub(player, "start_stopStreamResetLabels")
		Starter.vPlayerSelectedPanel = 999
		CallSub2(player, "showHideSmallStationLogo", False)
		CallSub2(Starter, "run_streamTimer", False)
		modGlobal.PlayerStarted = False
		Starter.lastAccPlayerTime = 0
		Starter.startAccPlayerTime = 0
		Return True
	Else 
		Return False	
	End If
	
End Sub
