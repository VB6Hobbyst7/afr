B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9
@EndOfDesignText@
#IgnoreWarnings: 9, 1
Sub Class_Globals
	Dim url, coverArtUrl As String
	'Dim parser As SaxParser
	Dim reverseSearch As Boolean = False
	Dim reverseCount As Int = 0
	Dim clsFunc As clsFunctions
	Public songPlaying As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
End Sub


#Region remark
'Public Sub checkAlbumart As ResumableSub
'	If Starter.chartLyricsDown = True Then
'		
'		Return False
'	End If
''	Log("CHARTLYRICS")
'	If reverseCount = 1 Then
'		reverseCount = 0
'		reverseSearch = False
'		Return False
'	End If
'	
'	scrobbler.processPlaying(Starter.vSong)
'	If reverseSearch = False Then
'		url = $"http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=${Starter.chartSong}&song=${Starter.chartArtist}"$
'	Else
'		reverseCount = reverseCount+1
'		url = $"http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=${Starter.chartArtist}&song=${Starter.chartSong}"$
'	End If
'	wait for (processUrl) Complete (result As Boolean)
'	Return result
'	
'End Sub


'Private Sub processUrl As ResumableSub
'	reverseSearch = False
'	Dim j As HttpJob
'	
'	If url = "" Or Starter.clsFunc.checkUrl(url) = False Or url = "http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=&song=" Then
'		Return False
'	End If
'	
'	j.Initialize("",  Me)
'	j.Download(url)
'	j.GetRequest.Timeout = Starter.jobTimeOut
'	Wait For (j) JobDone(j As HttpJob)
'	
'	If j.Success Then
'		File.WriteString(Starter.irp_dbFolder,"file.xml", j.GetString)
'		j.Release
'		processXml
'		Return True
'	Else
'		Starter.chartLyricsDown = True	
'	End If
'	j.Release
'	Return False
'End Sub


'Private Sub processXml()
'	Dim in As InputStream
'	in = File.OpenInput(Starter.irp_dbFolder,"file.xml")
'	
'	parser.Initialize
'	parser.Parse(in,"parser")
'	
'	
'End Sub

'Sub Parser_EndElement (Uri As String, Name As String, Text As StringBuilder)
'	'Log(Name)
'	If Name = "Lyric" Then
'		Starter.vSongLyric = Text.ToString
'		CallSubDelayed2(Starter, "setSongLyric", Text.ToString)
'		'Log(Text.ToString)
'	End If
'	If Name = "LyricCovertArtUrl" Then
'		coverArtUrl = Text.ToString
'	'	Starter.clsFunc.showLog($"ALBUMART ${Text.ToString}"$, 0)
'		If coverArtUrl.IndexOf(".jpg") > -1 Or coverArtUrl.IndexOf(".png") > -1 Then
'			wait for (processAlbumArt) Complete (result As Boolean)
'			
'			reverseSearch = False
'		Else
'			reverseSearch = True
'		End If
'	End If
'	If reverseSearch = True Then
'		checkAlbumart
'	End If
'End Sub

'Sub processAlbumArt As ResumableSub
'	Dim j As HttpJob
'	Dim bm As Bitmap
'	
'	Starter.clsFunc.showLog($"ALBUMART FOUND IS ${Starter.albumArtSet}"$, 0)
'	If Starter.albumArtSet = True Then
'		Return True
'	End If
'	
'	j.Initialize("",  Me)
'	j.Download(coverArtUrl)
'	j.GetRequest.Timeout = Starter.jobTimeOut
'	
'	Wait For (j) JobDone(j As HttpJob)
'	If j.Success Then
'		bm = j.GetBitmap
'		j.Release
'		Starter.albumArtSet = True
'		'Log($"chartlyric song"$)
'		CallSubDelayed2(Starter, "setAlbumArt", bm)
'	End If
'	j.Release
'	Return True
'End Sub
#End Region


Sub processSong(song As String, reverseFind As Boolean) As String

	song = Starter.clsFunc.GetArtistAndSong(song, reverseFind)
	song = Starter.clsFunc.checkAmpersant(song)
	song = Starter.clsFunc.ReplaceRaros(song)
	song = Starter.clsFunc.removeBetween(song, "(-)")
	Return song
End Sub


Sub checkScrapLyrics(reverseFind As Boolean, useSpot As Boolean) As ResumableSub
	Dim url, song As String
	
	If Starter.chartArtist = "" Or Starter.chartSong = "" Then
		CallSub(Starter, "showNoImage")
		Return False
	End If
	
	'Starter.spotMap.Put("artistname",colartists.Get("name"))
	'Starter.spotMap.Put("artistsong",colitems.Get("name"))
	
'	LogColor($"ARTIST ${Starter.spotMap.Get("artistname")} SONG ${Starter.spotMap.Get("artistsong")}"$, Colors.Blue)
	
	If useSpot = True And reverseFind = True Then
		Dim mArtist As String = Starter.spotMap.Get("artistname")
		If mArtist.IndexOf("&") > -1 Then
			mArtist = mArtist.Replace("&", "")
			
		End If
		
	End If
	
	If useSpot = False Then
		song = processSong(Starter.icy_playing, reverseFind)
	Else If useSpot = True And reverseFind = True Then
		Dim mArtist As String = Starter.spotMap.Get("artistname")
		If mArtist.IndexOf("&") > -1 Then
			mArtist = mArtist.Replace("&", "")
			song = processSong(mArtist &" - " & Starter.spotMap.Get("artistsong"), False)
		End If
	Else
		song = processSong(Starter.spotMap.Get("artistname") &" - " & Starter.spotMap.Get("artistsong"), reverseFind)
	End If
	url = $"http://ice.pdeg.nl/index.php?filename=${Starter.clsFunc.checkAmpersant(song)}&format=json"$
	
'	Log(url)


	Dim j As HttpJob
	
	j.Initialize("", Me)
	j.Download(url)
	j.GetRequest.Timeout = Starter.jobTimeOut
	
	Wait For (j) JobDone(j As HttpJob)
		
	If j.Success Then
		If j.GetString.Length < 10 Then
			j.Release
			Return False
		End If
		clsFunc.parseScrapeData(j.GetString)
		j.Release
		'CallSub2(player, "setSongPlaying",  Starter.icy_playing)
		If Starter.vSongLyric = "nolyric" Then
			Return False
		Else
			Return True
		End If
	Else
		j.Release
		Return False
	End If
	
		
End Sub


public Sub getSongLyrics As ResumableSub
	Dim urlStream, http As String
'	Starter.clsFunc.showLog("getSongLyrics", Colors.Green)

	
	http = "https://lyric-api.herokuapp.com/api/find/"
	
	urlStream	= scrobbler.processLyrics(CallSub(player, "retSongPlaying"), False)
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


Private Sub processUrl(purl As String) As ResumableSub
	Dim j As HttpJob
	
	If purl = "" Or clsFunc.checkUrl(purl) = False Then
		Return False
	End If
	
	j.Initialize("",  Me)
	j.Download(purl)
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


Sub tryLyrics
	If Starter.triedLyrics = True Then Return
	
	Starter.triedLyrics = True
	
'	Log($"TRY LYRICS - $DateTime{DateTime.Now}"$)
	
	If Starter.vSongLyric = "noLyric" Then
		wait for(checkScrapLyrics(False, False)) Complete (result As Boolean)
		If result = False Then
			wait for(checkScrapLyrics(True, False)) Complete (result As Boolean)
			If result = False Then
				wait for(checkScrapLyrics(False, True)) Complete (result As Boolean)
			End If
			If result = False Then
				wait for(checkScrapLyrics(True, True)) Complete (result As Boolean)
			End If
			If result = False Then
'				Log("HEROKU")
				wait for(getSongLyrics) Complete (result As Boolean)
			End If
		End If
	End If
End Sub

