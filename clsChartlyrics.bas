B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9
@EndOfDesignText@
Sub Class_Globals
	Dim url, coverArtUrl As String
	Dim parser As SaxParser
	Dim reverseSearch As Boolean = False
	Dim reverseCount As Int = 0
	Dim clsFunc As clsFunctions
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
End Sub


Public Sub checkAlbumart As ResumableSub
	If Starter.chartLyricsDown = True Then
		
		Return False
	End If
'	Log("CHARTLYRICS")
	If reverseCount = 1 Then
		reverseCount = 0
		reverseSearch = False
		Return False
	End If
	
	scrobbler.processPlaying(Starter.vSong)
	If reverseSearch = False Then
		url = $"http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=${Starter.chartSong}&song=${Starter.chartArtist}"$
	Else
		reverseCount = reverseCount+1
		url = $"http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=${Starter.chartArtist}&song=${Starter.chartSong}"$
	End If
	wait for (processUrl) Complete (result As Boolean)
	Return result
	
End Sub


Private Sub processUrl As ResumableSub
	reverseSearch = False
	Dim j As HttpJob
	
	If url = "" Or Starter.clsFunc.checkUrl(url) = False Or url = "http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect?artist=&song=" Then
		Return False
	End If
	
	j.Initialize("",  Me)
	j.Download(url)
	j.GetRequest.Timeout = Starter.jobTimeOut
	Wait For (j) JobDone(j As HttpJob)
	
	If j.Success Then
		File.WriteString(Starter.irp_dbFolder,"file.xml", j.GetString)
		j.Release
		processXml
		Return True
	Else
		Starter.chartLyricsDown = True	
	End If
	j.Release
	Return False
End Sub


Private Sub processXml()
	Dim in As InputStream
	in = File.OpenInput(Starter.irp_dbFolder,"file.xml")
	
	parser.Initialize
	parser.Parse(in,"parser")
	
	
End Sub

Sub Parser_EndElement (Uri As String, Name As String, Text As StringBuilder)
	'Log(Name)
	If Name = "Lyric" Then
		Starter.vSongLyric = Text.ToString
		CallSubDelayed2(Starter, "setSongLyric", Text.ToString)
		'Log(Text.ToString)
	End If
	If Name = "LyricCovertArtUrl" Then
		coverArtUrl = Text.ToString
	'	Starter.clsFunc.showLog($"ALBUMART ${Text.ToString}"$, 0)
		If coverArtUrl.IndexOf(".jpg") > -1 Or coverArtUrl.IndexOf(".png") > -1 Then
			wait for (processAlbumArt) Complete (result As Boolean)
			
			reverseSearch = False
		Else
			reverseSearch = True
		End If
	End If
	If reverseSearch = True Then
		checkAlbumart
	End If
End Sub

Sub processAlbumArt As ResumableSub
	Dim j As HttpJob
	Dim bm As Bitmap
	
	Starter.clsFunc.showLog($"ALBUMART FOUND IS ${Starter.albumArtSet}"$, 0)
	If Starter.albumArtSet = True Then
		Return True
	End If
	
	j.Initialize("",  Me)
	j.Download(coverArtUrl)
	j.GetRequest.Timeout = Starter.jobTimeOut
	
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
		bm = j.GetBitmap
		j.Release
		Starter.albumArtSet = True
		'Log($"chartlyric song"$)
		CallSubDelayed2(Starter, "setAlbumArt", bm)
	End If
	j.Release
	Return True
End Sub



Sub checkScrapLyrics(artist As String, song As String) As ResumableSub 
	Dim nowPlaying As String = CallSub(player, "getNowPlaying")
	
'	Log(nowPlaying)
	
	
	If artist = "" Or song = "" Then
		Return False
	End If
	
	Try
	
	Dim url As String
	url = $"http://ice.pdeg.nl/index.php?filename=${nowPlaying}&format=json"$
	
	'Log($"http://ice.pdeg.nl/index.php?filename=${artist} - ${song}&format=json"$)
		Dim j As HttpJob
	
	j.Initialize("", Me)
	j.Download(url)
	'j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
	
	j.GetRequest.Timeout = Starter.jobTimeOut
	
	
	Wait For (j) JobDone(j As HttpJob)
		
	If j.Success Then
		If j.GetString.Length < 10 Then
			
			j.Release
			Return False
		End If
		clsFunc.parseScrapeData(j.GetString)
		j.Release
		Return True
	Else 
		j.Release
		Return False	
	End If
		
	Catch
		Return False
	End Try
End Sub