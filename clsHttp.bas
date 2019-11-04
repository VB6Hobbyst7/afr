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
	Public songReversed As Boolean = False
	Dim SpotToken1, SpotGrant1, SpotBase64, SpotClientID1, SpotClientSecret1 As String
	Dim SourceWeb1, SourceText1 As String
	
	Private clsGeneral_ As clsGeneral
	Private clsFunc As clsFunctions
	Private clsLyrics As clsChartlyrics

End Sub


Sub Initialize(callbackModule As Object, callbackEventName As String)
	cbObj = callbackModule
    cbEN = callbackEventName
End Sub

'Sub spBearer(song As String)
Sub spBearer(artist As String, song As String)
	If artist = "" Then
	'	Return
	End If
	
	Dim su As StringUtils
	song = su.EncodeUrl(song, "UTF8")
	clsGeneral_.Initialize
	clsFunc.Initialize
	clsLyrics.Initialize
	
	Starter.chartDataFound	= True
	Starter.chatDataLyric	= False
	Starter.lyricFound		= False
	Starter.albumArtFound	= False
	
	Starter.vAlbumName = ""
	Starter.vAlbumTrack = ""
	Starter.vAlbumReleaseDate = ""
	
	
	Starter.lyricFound = False

	If Starter.lyricFound = False Then
		'getSongLyrics
	End If
	'CallSub2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
'''	CallSub(Starter, "showNoImage")

	Dim B64 As Base64
	Dim n As Long
	Dim m As Long
	
	
	SpotGrant1       	= "client_credentials"
	SpotClientID1    	= Starter.SpotClientID1'  'Use your own Spotify Client ID!
	SpotClientSecret1	= Starter.SpotClientSecret1 '  'Use your own Spotify Client Secret key!
	SourceWeb1        	= "https://accounts.spotify.com/api/token" 'Starter.SourceWeb1 '"https://accounts.spotify.com/api/token"

	If clsFunc.checkUrl(SourceWeb1) = False Then
		Return
	End If

	'SpotBase64 = B64.EncodeStoS(SpotClientID1 & ":" & SpotClientSecret1,"UTF8")
	SpotBase64 = B64.EncodeStoS("91f924c1eace4879ba9c4c0f5061e925" & ":" & "b4fb29e9e2b0490bad9489c28dae6b89","UTF8")
	Dim j As HttpJob
	
	j.Initialize("", Me)
	j.PostString(SourceWeb1, "grant_type=" & SpotGrant1)
	j.GetRequest.SetContentType("application/x-www-form-urlencoded")
	j.GetRequest.SetHeader("Authorization", "Basic " & SpotBase64)
	j.GetRequest.Timeout = Starter.jobTimeOut
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		SourceText1 = j.GetString2("ISO-8859-1")
		n=SourceText1.IndexOf2(":",0)+2            'Dubbele punt en aanhalingsteken moeten weg!
		m=SourceText1.IndexOf2(Chr(34),n+8)
		SpotToken1=SourceText1.SubString2(n,m)
		'SourceWeb1 = "https://api.spotify.com/v1/search?query=" & SpotQuery1 & "&type=track&access_token=" & SpotToken1 & "&token_type=Bearer&expires_in=3600&limit=1"
		'SourceWeb1 = "https://api.spotify.com/v1/search?query=" & SpotQuery1 & "&type=track&access_token=" & SpotToken1 & "&token_type=Bearer&expires_in=3600&limit=1"
		
'		artist = artist.Replace(" ", "%20")
'		artist = artist.Replace("+", "%20")
'		artist = artist.Replace(" ", "+")
		song = song.Replace(" ", "%20")
		
		'Dim qry As String = $"track:${artist} artist:${song}&type=track%2Cartist&limit=1&offset=0"$
		Dim qry As String = $"track:${clsFunc.removeBetween(artist, "(-)")} artist:${clsFunc.removeBetween(song, "(-)")}&type=track%2Cartist&limit=1&offset=1"$
		
'		Log("QRY : " & qry)
		SourceWeb1 = $"https://api.spotify.com/v1/search?q=${qry}&access_token=${SpotToken1}&token_type=Bearer&expires_in=3600&limit=1"$
		
		'SpotTrack1 is te vinden in de json onder item, 0 _> id
		j.Release
		
		'songReversed = False
		Dim j1 As HttpJob
		
		j1.Initialize("", Me)
		j1.Download(SourceWeb1)
		j1.GetRequest.Timeout = Starter.jobTimeOut
		Wait For (j1) JobDone(j1 As HttpJob)
		If j1.Success Then
			Dim j1String As String = j1.GetString
			j1.Release
			getSpotifySongData(j1String)
			If Starter.chartDataFound = True Then
				Return
			End If
			
		Else
			j1.Release
			Log($"SONG REVERSED = ${songReversed}"$)
			If songReversed = False Then
				songReversed	= True
				clsFunc.showLog("CLSHTTP REVERSE", Colors.green)
				'spBearer(Starter.chartSong, Starter.chartArtist)
				spBearer(song, artist)
			End If
			Starter.vSpotError = "No data"
			Starter.clsFunc.Initialize

			If File.Exists(Starter.sStationLogoPath, "") Then
				CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(Starter.sStationLogoPath, ""))
			Else
				CallSub(Starter, "showNoImage")
			End If
		End If
		Else 
			Log("ERROR " & j.ErrorMessage)
			CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(Starter.sStationLogoPath, ""))
			j.Release
	End If
	
	Return
	
End Sub

Sub getSpotifySongData(jsonData As String)As ResumableSub
	'File.WriteString(Starter.irp_dbFolder, $"test-${DateTime.Now}.txt"$, jsonData)
	Dim Parser1 As JSONParser
	Parser1.Initialize(jsonData)
	Dim root As Map =Parser1.NextObject
'	Log(jsonData)
	Dim mDate As String
	Starter.albumArtSet = False
	Starter.albumArtFound = False
	
	If Starter.spotMap.IsInitialized Then
		Starter.spotMap.Clear
	Else
		Starter.spotMap.Initialize
	End If
	
	If root.ContainsKey("error") Then 'And Starter.chartDataFound = False Then
		
		noSongData
		Return True
	End If
		
	
	If root.ContainsKey("tracks") Then
		Dim tracks As Map = root.Get("tracks")
		Dim items As List = tracks.Get("items")

		If items.Size < 1 Then
			If songReversed = False And Starter.chartSong <> "" And Starter.chartArtist <> "" Then
				songReversed	= True
				spBearer(Starter.chartSong, Starter.chartArtist) 'LEEG
			End If
			
			noSongData
			Return True
		End If
		
		For Each colitems As Map In items
			Dim duration_ms As Long		= colitems.Get("duration_ms")'
			Dim album As Map			= colitems.Get("album")'
			Dim artists As List			= album.Get("artists")
			Dim external_urls As Map	= colitems.Get("external_urls")'
			Dim spotify As String 		= external_urls.Get("spotify")'
			Starter.vSpotUrl 			= spotify
			
			Starter.vAlbumName  		= album.Get("name")'
			Starter.vAlbumTrack 		= colitems.Get("track_number")'
			Starter.vAlbumReleaseDate	= album.Get("release_date")'
			Dim lDate As List
			lDate.Initialize
			mDate = Starter.vAlbumReleaseDate
			lDate = Regex.Split("-", mDate)
			
			Try
				If lDate.Size = 3 Then
					Dim newTime As Long	= DateUtils.SetDate(lDate.Get(0), lDate.Get(1), lDate.Get(2))
					DateTime.DateFormat ="MMMM yyyy"
					Starter.vAlbumReleaseDate = $"$Date{newTime}"$
				Else
					Starter.vAlbumReleaseDate = $"${mDate}"$
				End If
			Catch
				Starter.vAlbumReleaseDate	= album.Get("release_date")
				Log("ERROR " & LastException)
			End Try
			Starter.spotMap.Put("duration", colitems.Get("duration_ms"))
			Starter.spotMap.Put("album",album.Get("name"))
			Starter.spotMap.Put("url", spotify)
			Starter.spotMap.Put("track",colitems.Get("track_number"))
			Starter.spotMap.Put("date",album.Get("release_date"))
			
			
			If Starter.vAlbumName.Length < 1 Then
				CallSub2(player, "enableAlbumButton", False)
			Else
				CallSub2(player, "enableAlbumButton", True)
			End If
			
			If Starter.albumArtFound = True Then
				Return True
			End If
			
			For Each colartists As Map In artists
				Dim name As String = colartists.Get("name")
				Dim href As String = colartists.Get("href")
				Dim id As String = colartists.Get("id")
				Dim Type As String = colartists.Get("type")
				Dim external_urls As Map = colartists.Get("external_urls")
				Dim spotify As String = external_urls.Get("spotify")
				Dim uri As String = colartists.Get("uri")
			Next
			Starter.spotMap.Put("artistname",colartists.Get("name"))
			Starter.spotMap.Put("artistsong",colitems.Get("name"))
			
'			Log($"${colartists.Get("name")} - ${colitems.Get("name")}"$)
			Starter.chartArtist = colartists.Get("name")
			Starter.chartSong = colitems.Get("name")
			Starter.playingSong = $"${colartists.Get("name")} - ${colitems.Get("name")}"$
			
			Dim spSong As String = Starter.spotMap.Get("artistsong")
			
			
			Starter.vSongLyric = "noLyric"
			clsLyrics.tryLyrics

			Dim images As List = album.Get("images")
			For Each colimages As Map In images
				Dim width As Int = colimages.Get("width")
				Dim url As String = colimages.Get("url")
				Dim height As Int = colimages.Get("height")
				If height = 640 Or width = 640 And clsFunc.checkUrl(url) Then
					DownloadImage(url)
					Exit
					Return True
				Else
					noSongData
					
				End If
			Next
		Next
		
		If Starter.chatDataLyric = False Then
		End If
	Else
		
	End If
	Return True
	
End Sub



Sub DownloadImage(Link As String)
	
	Try
		If clsFunc.checkUrl(Link) = False Then
			'CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
			CallSub(Starter, "showNoImage")
		Else
			Dim j As HttpJob
			
			j.Initialize("", Me)
			j.Download(Link)
			j.GetRequest.Timeout = Starter.jobTimeOut
			Wait For (j) JobDone(j As HttpJob)
			If j.Success Then
				Starter.albumArtSet = True
				CallSubDelayed2(Starter, "setAlbumArt", j.GetBitmap)
				CallSub2(player, "pnlImgColor", False)
				Starter.rndImgSet = 0
			j.Release
			Else
			j.Release
				'clsLyrics.checkAlbumart
			End If
		End If
		
	Catch
			j.Release
		Log("CLSHTTP @ 322 : "&LastException)
	End Try
End Sub


public Sub getSongLyrics As ResumableSub
	Dim urlStream, http As String
'	Starter.clsFunc.showLog("getSongLyrics", Colors.Green)

	
	http = "https://lyric-api.herokuapp.com/api/find/"
	
	urlStream	= scrobbler.processLyrics(CallSub(player, "retSongPlaying"), False)
	'Log(urlStream)
	'Starter.clsFunc.showLog(urlStream, Colors.Green)
	Wait For (processUrl(urlStream)) Complete (result As Boolean)

	If result Then Return result
	
	'****TRY REVERSE
	urlStream	= scrobbler.processLyrics(CallSub(player, "retSongPlaying"), True)
	'Starter.clsFunc.showLog(urlStream, Colors.Green)
	
	Wait For (processUrl(urlStream)) Complete (result As Boolean)
	
	If result = False Then
		Starter.vSong = "noLyric"
		CallSubDelayed2(Starter, "setSongLyric", "noLyric")
	End If
	Return result
End Sub


Private Sub processUrl(url As String) As ResumableSub
	Dim j As HttpJob
	
	If url = "" Or clsFunc.checkUrl(url) = False Then
		Return False
	End If
	
	j.Initialize("",  Me)
	j.Download(url)
	j.GetRequest.Timeout = Starter.jobTimeOut
	Wait For (j) JobDone(j As HttpJob)
	
	If j.Success Then
		Dim json As String = j.GetString()'("UTF-16")
		j.Release
		
		Dim Parser As JSONParser
		Parser.Initialize(json)
		Dim root As Map = Parser.NextObject
		Dim err As String = root.Get("err")
		Dim lyric As String = root.Get("lyric")
		If lyric.Length < 10 Then
			Return False	
		End If
		If err = "not found" Then
			Starter.vSong = "noLyric"
			CallSubDelayed2(Starter, "setSongLyric", "noLyric")
		Else
			File.WriteString(Starter.irp_dbFolder, "ini.txt", lyric)
			Starter.vSong = lyric
			CallSubDelayed2(Starter, "setSongLyric", lyric)
		End If
		j.Release
		Return True
	End If
	
	j.Release
	Return False
End Sub


Sub noSongData
	Starter.clsRndImage.newRandomImage
	clsLyrics.tryLyrics
End Sub
