B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
#Event: RequestFinished
#IgnoreWarnings: 9

Sub Class_Globals
	Private cbObj As Object
	Private cbEN As String
	Private songReversed As Boolean = False
	Dim SpotToken1, SpotGrant1, SpotBase64, SpotClientID1, SpotClientSecret1 As String
	Dim SpotQuery1, SourceWeb1, SourceText1 As String
	
	Private clsGeneral_ As clsGeneral
	Private clsFunc As clsFunctions

End Sub


Sub Initialize(callbackModule As Object, callbackEventName As String)
	cbObj = callbackModule
    cbEN = callbackEventName
End Sub

Sub spBearer(song As String)
	Dim su As StringUtils
	song = su.EncodeUrl(song, "UTF8")
	clsGeneral_.Initialize
	clsFunc.Initialize
	
	Starter.chartDataFound	= True
	Starter.chatDataLyric	= False
	Starter.lyricFound		= False
	Starter.albumArtFound	= False
	
	Starter.vAlbumName = ""
	Starter.vAlbumTrack = ""
	Starter.vAlbumReleaseDate = ""
	
	
'	wait for(clsGeneral_.getLyricFromOvh) Complete (result As Boolean)
	
	Starter.lyricFound = False

	If Starter.lyricFound = False Then
		getSongLyrics
	End If
	
	Dim B64 As Base64
	Dim n As Long
	Dim m As Long
	
	
	SpotGrant1       	= "client_credentials"
	SpotClientID1    	= Starter.SpotClientID1'  'Use your own Spotify Client ID!
	SpotClientSecret1	= Starter.SpotClientSecret1 '  'Use your own Spotify Client Secret key!
	SourceWeb1        	= Starter.SourceWeb1 '"https://accounts.spotify.com/api/token"

	If clsFunc.checkUrl(SourceWeb1) = False Then
		Return
	End If

	SpotBase64 = B64.EncodeStoS(SpotClientID1 & ":" & SpotClientSecret1,"UTF8")
		
	Dim j As HttpJob
	
	j.Initialize("", Me)
	j.PostString(SourceWeb1, "grant_type=" & SpotGrant1)
	j.GetRequest.SetContentType("application/x-www-form-urlencoded")
	j.GetRequest.SetHeader("Authorization", "Basic " & SpotBase64)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		SourceText1 = j.GetString2("ISO-8859-1")
		n=SourceText1.IndexOf2(":",0)+2            'Dubbele punt en aanhalingsteken moeten weg!
		m=SourceText1.IndexOf2(Chr(34),n+8)
		SpotToken1=SourceText1.SubString2(n,m)
		SpotQuery1 = song.Replace(" - ", " ")'"queen i want it all"
		SourceWeb1 = "https://api.spotify.com/v1/search?query=" & SpotQuery1 & "&type=track&access_token=" & SpotToken1 & "&token_type=Bearer&expires_in=3600&limit=1"

		If SpotQuery1.Length < 8  Then
			Return
		End If
		'SpotTrack1 is te vinden in de json onder item, 0 _> id
		j.Release
		
		Dim j1 As HttpJob
		j1.Initialize("", Me)
		j1.Download(SourceWeb1)
	
		Wait For (j1) JobDone(j1 As HttpJob)
		If j1.Success Then
			
			Dim j1String As String = j1.GetString
		'	LogColor(j1String, Colors.Red)
			j1.Release
			getSpotifySongData(j1String)
			If Starter.chartDataFound = True Then
				Return
			End If
			
		Else
			If songReversed = False Then
				songReversed	= True
'				LogColor("songReversed", Colors.Green)
				spBearer(Starter.chartSong & " " & Starter.chartArtist)
			End If
			Starter.vSpotError = "No data"
			Starter.clsFunc.Initialize
			Starter.clsFunc.showLog($"NO SPOTIFY DATA ${Starter.vSpotError}"$, 0)

			If File.Exists(Starter.sStationLogoPath, "") Then
				CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(Starter.sStationLogoPath, ""))
			Else
				CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
			End If
		End If
			
	End If
	Return
	
End Sub

Sub getSpotifySongData(jsonData As String)
	Dim Parser1 As JSONParser
	Parser1.Initialize(jsonData)
	Dim root As Map =Parser1.NextObject

	If root.ContainsKey("error") And Starter.chartDataFound = False Then
		noSongData
		Return
	End If
		
	
	If root.ContainsKey("tracks") Then
		Dim tracks As Map = root.Get("tracks")
		'Dim Next As String = tracks.Get("next" )
		'Dim total As Int = tracks.Get("total")
		'Dim offset As Int = tracks.Get("offset")
		'Dim previous As String = tracks.Get("previous")
		'Dim limit As Int = tracks.Get("limit")
		'Dim href As String = tracks.Get("href")
		
		Dim items As List = tracks.Get("items")
		If items.Size < 1 Then
			noSongData
			Return
		End If
		For Each colitems As Map In items
			'Dim duration_ms As Int = colitems.Get("duration_ms")
			'''setDuration(duration_ms)
			Dim album As Map			= colitems.Get("album")
'			Dim artists As List			= album.Get("artists")
			Starter.vAlbumName  		= album.Get("name")
			Starter.vAlbumTrack 		= colitems.Get("track_number")
			Starter.vAlbumReleaseDate	= album.Get("release_date")
			
			Starter.clsFunc.showLog("ALBUM INFO/NAME : "&Starter.vAlbumName, Colors.Red)
			If Starter.vAlbumName.Length < 1 Then
				CallSub2(player, "enableAlbumButton", False)
			Else
				CallSub2(player, "enableAlbumButton", True)
			End If
			
			If Starter.albumArtFound = True Then
				Return
			End If
			
'			For Each colartists As Map In artists
'				Dim name As String = colartists.Get("name")
'				Dim href As String = colartists.Get("href")
'				Dim id As String = colartists.Get("id")
'				Dim Type As String = colartists.Get("type")
'				Dim external_urls As Map = colartists.Get("external_urls")
'				Dim spotify As String = external_urls.Get("spotify")
'				Dim uri As String = colartists.Get("uri")
'			Next
			
			Dim images As List = album.Get("images")
			For Each colimages As Map In images
				Dim width As Int = colimages.Get("width")
				Dim url As String = colimages.Get("url")
				Dim height As Int = colimages.Get("height")
			
				If height = 640 Or width = 640 And clsFunc.checkUrl(url) Then
					DownloadImage(url)
					Exit
					Return
				Else
					noSongData
				End If
			Next
		Next
		
		If Starter.chatDataLyric = False Then
		End If

	End If

	
End Sub



Sub DownloadImage(Link As String)
	If clsFunc.checkUrl(Link) = False Then
		CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
	Else
		Dim j As HttpJob
		j.Initialize("", Me)
		j.Download(Link)
		Wait For (j) JobDone(j As HttpJob)
		If j.Success Then
			CallSubDelayed2(Starter, "setAlbumArt", j.GetBitmap)
		Else
			CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		End If
	j.Release
	End If
End Sub


public Sub getSongLyrics
	Dim urlStream, http As String
	
	If Starter.lyricFound = True Then 
		Return
	End If

	Starter.clsFunc.Initialize
	
	http = "https://lyric-api.herokuapp.com/api/find/"
	
	urlStream	= scrobbler.processLyrics(CallSub(Starter,"getSongPlaying"), False)
	Starter.clsFunc.showLog("HEROKU " & urlStream, Colors.Red)
	
	Starter.clsFunc.showLog("HEROKU " & urlStream, 0)
	
	Wait For (processUrl(urlStream)) Complete (result As Boolean)

	If result Then Return
	
	'****TRY REVERSE
	urlStream	= scrobbler.processLyrics(CallSub(Starter,"getSongPlaying"), True)
	Starter.clsFunc.showLog("HEROKU " & urlStream, Colors.Green)
	
	Wait For (processUrl(urlStream)) Complete (result As Boolean)
	
	If result = False Then
		Starter.clsFunc.showLog("no lyric", 0)
		CallSubDelayed2(Starter, "setSongLyric", "noLyric")
	End If
End Sub


Private Sub processUrl(url As String) As ResumableSub
	Dim j As HttpJob
	
	If url = "" Or clsFunc.checkUrl(url) = False Then
		Return False
	End If
	
	j.Initialize("",  Me)
	j.Download(url)
	Wait For (j) JobDone(j As HttpJob)
	
	If j.Success Then
		Dim json As String = j.GetString()'("UTF-16")
		j.Release
		
		Dim Parser As JSONParser
		Parser.Initialize(json)
		Dim root As Map = Parser.NextObject
		Dim err As String = root.Get("err")
		Dim lyric As String = root.Get("lyric")
		Starter.clsFunc.showLog("error : " & err, Colors.Red)
		If lyric.Length < 10 Then
			Return False	
		End If
		If err = "not found" Then
			Starter.clsFunc.showLog("no lyric", 0)
			CallSubDelayed2(Starter, "setSongLyric", "noLyric")
		Else
			File.WriteString(Starter.irp_dbFolder, "ini.txt", lyric)
			CallSubDelayed2(Starter, "setSongLyric", lyric)
		End If
		Return True
	End If
	
	Return False
End Sub


Sub noSongData
	CallSub2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
End Sub

