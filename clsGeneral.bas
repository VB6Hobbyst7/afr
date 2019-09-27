B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
#IgnoreWarnings: 9, 1, 11
Sub Class_Globals
	Private xmlparser As SaxParser
	Private url As String

	Public chartDataFound As Boolean = False
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
	
End Sub

public Sub setChartDataFound(value As Boolean)
	chartDataFound = value
End Sub


Public Sub getLyricFromOvh As ResumableSub '(Starter.chartArtist, Starter.chartSong)As ResumableSub
	
	wait for (getLyrics) Complete (result As Boolean)
	Return result
	
End Sub


Private Sub getLyrics As ResumableSub
	Dim url, artist, song As String
	
	artist = Starter.spotMap.Get("artistname")
	song = Starter.spotMap.Get("artistsong")
	
	artist = Starter.clsFunc.replacetekens(artist)
	song = Starter.clsFunc.replacetekens(song)
	
	url = $"https://api.lyrics.ovh/v1/${artist}/${song}"$
	Wait For (processOvhLyrics(url)) Complete (result As Boolean)
	If result = True Then
		Return result
	End If

	'****TRY REVERSE
	url = $"https://api.lyrics.ovh/v1/${Starter.chartSong.ToLowerCase}/${Starter.chartArtist.ToLowerCase}"$
	Wait For (processOvhLyrics(url)) Complete (result As Boolean)	
	Return result
	
End Sub


Private Sub processOvhLyrics(ovhUrl As String) As ResumableSub
	Dim job As HttpJob
	
	job.Initialize("", Me)
	job.Download(ovhUrl)
	job.GetRequest.Timeout = 5*1000
	
	
	Wait For (job) JobDone(job As HttpJob)
	
	If job.Success Then
		Dim x As String = job.GetString
		Dim parser As JSONParser
		Dim parsedLyric As String
		
		parser.Initialize(x)
		Dim root As Map = parser.NextObject
		Dim lyrics As String = root.Get("lyrics")
		If lyrics <> "No lyrics found" Then
			parsedLyric	= lyrics.Replace(" \n", "<br>")
			parsedLyric	= lyrics.Replace(" \r", "<br>")
			Starter.chatDataLyric 	= True
			Starter.lyricFound		= True
			CallSub2(Starter, "setSongLyric", parsedLyric)
			Starter.chartDataFound = True
			Starter.lyricFound = True
			job.Release
			Return True
				
		End If
	Else 
		job.Release	
	End If
	
	Return False
	
End Sub


Sub Parser_EndElement (Uri As String, Name As String, Text As StringBuilder)
	Dim lyric As String
	
	If xmlparser.Parents.IndexOf("GetLyricResult") > -1 Then
		If Name = "LyricCovertArtUrl" Then
			If Text.ToString = "" Then
				chartDataFound 			= False
				Starter.albumArtFound	= False
				Return
			End If
			DownloadImage(Text.ToString)
		End If
		If Name = "Lyric" Then
			lyric = Text.ToString.Replace(CRLF, "<br>")
			If lyric.Length > 20 Then
				Starter.chatDataLyric 	= True
				Starter.lyricFound		= True
				CallSub2(Starter, "setSongLyric", lyric)
				Starter.chartDataFound = True
			Else
				chartDataFound 		= False
				Starter.lyricFound	= False
				CallSub2(Starter, "setSongLyric", "noLyric")
			End If
		End If
	End If
End Sub


Sub DownloadImage(Link As String)
	Try
	
	Dim bm As Bitmap
	Dim j As HttpJob
	
	j.Initialize("", Me)
	j.Download(Link)
	Wait For (j) JobDone(j As HttpJob)
	If j.Success Then
	
		bm = j.GetBitmap
		
		If bm.Width > 0 Then
			CallSubDelayed2(Starter, "setAlbumArt", j.GetBitmap)
			Starter.chartDataFound	= True
			Starter.albumArtFound	= True
		Else
			CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
			Starter.chartDataFound	= False
			Starter.albumArtFound	= False
		End If
		j.Release
	Else
		j.Release
		CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		Starter.chartDataFound	= False
		Starter.albumArtFound	= False
		End If
	Catch
'		Log("CLSGENERAL @ 145 : "&LastException)
		CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		Starter.chartDataFound	= False
		Starter.albumArtFound	= False
	End Try
	j.Release
End Sub


Public Sub pullDataFromFandom(reverse As Boolean) As ResumableSub
	Dim url, artist, song As String
	Dim j As HttpJob
	
	artist = Starter.spotMap.Get("artistname")
	song = Starter.spotMap.Get("artistsong")
	
	artist = Starter.clsFunc.replacetekens(artist)
	song = Starter.clsFunc.replacetekens(song)
	
	
	If reverse = False Then
		url = $"https://lyrics.fandom.com/wiki/${Starter.clsFunc.replacetekens(Starter.chartArtist)}:${Starter.clsFunc.replacetekens(Starter.chartSong)}"$
	Else
		url = $"https://lyrics.fandom.com/wiki/${Starter.clsFunc.replacetekens(Starter.chartSong)}:${Starter.clsFunc.replacetekens(Starter.chartArtist)}"$
	End If
	Starter.clsFunc.showLog(url, Colors.Red)
	
	j.Initialize("", Me)
	j.Download(url)
	j.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)")
	j.GetRequest.Timeout = 4000
	
	Wait For (j) jobDone(j As HttpJob)
		
	If j.Success Then
		processFandom(j.GetString And j.Response.StatusCode <> "404")
		'Starter.clsFunc.showLog($"FANDOM STATUS ${j.Response.StatusCode}"$, Colors.Red)
		j.Release
	Else
		j.Release
		If reverse = False Then
			pullDataFromFandom(True)
		End If
		'Starter.clsFunc.showLog($"FANDOM STATUS ${j.Response.StatusCode}"$, Colors.Red)
		'Starter.clsFunc.showLog("FANDOM " & j.ErrorMessage, Colors.Magenta)
	End If
	j.Release
	Return True
End Sub


Sub processFandom(page As String)
	
	Dim pattern, pattern1 As String
	Dim matcher As Matcher
	Dim startPos=0, endPos=0 As Int

	pattern = $"class='lyricbox'"$
	
	matcher = Regex.Matcher(pattern, page)
	Do While matcher.Find = True
		startPos	= matcher.GetStart(0)
		Exit
	Loop
	If startPos = 0 Then
		Return
	End If
	
	Dim newText As String = page.SubString2(startPos, page.Length)
	Dim pattern1 As String	= $"div class='lyricsbreak'"$

	matcher = Regex.Matcher(pattern1, newText)

	Do While matcher.Find = True
		endPos = matcher.GetStart(0)
		Exit
	Loop
	Dim vSong As String = newText.SubString2(pattern.Length+1, endPos)
	Starter.chatDataLyric	= True
	Starter.lyricFound		= True
	Starter.vSong = vSong
	CallSub2(Starter, "setSongLyric", vSong)
'	CallSub2(player, "showLyricProviderImage", LoadBitmap(File.DirAssets, "lod.png"))
	Starter.chartDataFound = True
End Sub


public Sub pullDataFromOndemand(reverse As Boolean) As ResumableSub
	'If Starter.lyricFound = True Then Return True
	
	Dim mJob As HttpJob
	Dim page As String
	Dim url As String

	
	

	url= scrobbler.createLyricsOnDemand(reverse)
	Starter.clsFunc.showLog(url, Colors.Blue)
	If url = "noUrl" Then
		Return True
	End If
		
	
	'Log(url)
	mJob.Initialize("", Me)
	mJob.Download(url)
	mJob.GetRequest.Timeout = 5*1000
	mJob.GetRequest.SetHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0")
	
	Try
		Wait For (mJob) jobDone(mJob As HttpJob)
	Catch
		LogColor("HTTP ERROR "&mJob.ErrorMessage, Colors.Red)	
	End Try
	If mJob.Success = False Then
		If reverse = False Then
			pullDataFromOndemand(True)
		End If
		Starter.clsFunc.showLog($"DEMAND STATUS ${mJob.Response.StatusCode}"$, Colors.Red)
		mJob.Release
	Else
		Starter.clsFunc.showLog($"DEMAND STATUS ${mJob.Response.StatusCode}"$, Colors.Red)
		page = mJob.GetString
		processLyricsOnDemand(page)
		mJob.Release
	End If
	mJob.Release
	
	Return True
	
End Sub

Sub processLyricsOnDemand(page As String)
	Dim pattern, pattern1 As String
	Dim matcher As Matcher
	Dim startPos=0, endPos=0 As Int
	
	
	
	pattern = $"<div class="lcontent" >"$
	
	matcher = Regex.Matcher(pattern, page)
	Do While matcher.Find
		startPos	= matcher.GetStart(0)
		Exit
	Loop
	If startPos = 0 Then
		Return
	End If
	
	Dim newText As String = page.SubString2(startPos, page.Length)
	Dim pattern1 As String	= "/div"'"<!--"

	matcher = Regex.Matcher(pattern1, newText)

	Do While matcher.Find = True
		endPos = matcher.GetStart(0)
		Exit
	Loop
	If endPos = 0 Then
		Return
	End If
	Dim vSong As String = newText.SubString2(pattern.Length, endPos)
	Starter.chatDataLyric	= True
	Starter.clsFunc.showLog($"ONDEMAND LYRIC FOUND ${Starter.chatDataLyric}"$, Colors.Red)
	Starter.lyricFound		= True
	Starter.vSong 			= vSong
	CallSub2(Starter, "setSongLyric", vSong)
	Starter.chartDataFound = True
End Sub


public Sub CheckConnected As ResumableSub
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


Sub Activity_WindowFocusChanged(HasFocus As Boolean, act As Activity)
	If HasFocus Then
		Try
			Dim jo As JavaObject = act
			Sleep(300)
			jo.RunMethod("setSystemUiVisibility", Array As Object(5894)) '3846 - non-sticky
		Catch
			Log(LastException) 'This can cause another error
		End Try 'ignore
		
	End If
End Sub

Public Sub userCountry As ResumableSub
	Dim j As HttpJob
	
	j.Initialize("", Me)
	
	j.Download("http://ip-api.com/json/")
	
	Wait For (j) JobDone (j As HttpJob)
	
	If j.Success Then
		Dim parser As JSONParser
		parser.Initialize(j.GetString)
  
		Dim mparse As Map = parser.NextObject
  
		Dim country As String = mparse.Get("country")
		Starter.countryCode = mparse.Get("countryCode")
		j.Release
	Else 
		j.Release	
	End If
	
	Return True
	
End Sub


