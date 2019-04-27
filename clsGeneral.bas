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
	
	
	url = $"https://api.lyrics.ovh/v1/${Starter.chartArtist.ToLowerCase}/${Starter.chartSong.ToLowerCase}"$
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
	Starter.clsFunc.showLog("processOvhLyrics : " & ovhUrl, 0)
	
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
'			Log("LYRICS FROM OvhLyrics")
			CallSub2(Starter, "setSongLyric", parsedLyric)
			Starter.chartDataFound = True
			Starter.lyricFound = True
			job.Release
			Return True
				
		End If
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
	Else
		CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		Starter.chartDataFound	= False
		Starter.albumArtFound	= False
		End If
	Catch
		Log(LastException)
		CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		Starter.chartDataFound	= False
		Starter.albumArtFound	= False
	End Try
	j.Release
End Sub



Sub getDataFromOndemand As ResumableSub
	If Starter.lyricFound = True Then Return True
	Try
		Dim mJob As HttpJob
		Dim page As String
		Dim url As String

		url= scrobbler.createLyricsOnDemand

		If url = "noUrl" Then
			Return True
		End If
		
		mJob.Initialize("", Me)
		mJob.Download(url)
	
		Wait For (mJob) jobDone(mJob As HttpJob)
			
		If mJob.Success Then
			page= mJob.GetString
			processLyricsOnDemand(page)
		End If
		mJob.Release
	
		Return True
	Catch
		Log(LastException)
	End Try
	Return True
End Sub

Sub processLyricsOnDemand(page As String)
	Dim pattern, pattern1 As String
	Dim matcher As Matcher
	Dim pageError As Boolean
	Dim startPos, endPos As Int
	
	pattern = $"404"$
	pageError	= False
	If page.IndexOf(pattern) > -1 Then
		Starter.chatDataLyric = False
	End If
	matcher	= Regex.Matcher(pattern, page)
	Do While matcher.Find = True
		'SONG NO FOUND, BAIL OUT
		pageError	= True
		Exit
	Loop
		
	If pageError = True Then
		Starter.chatDataLyric = False
	End If
	
	pattern = $"<div class="lcontent" >"$
	
	matcher = Regex.Matcher(pattern, page)
	Do While matcher.Find = True
		startPos	= matcher.GetStart(0)
	Loop
	
	Dim newText As String = page.SubString2(startPos, page.Length)
	Dim pattern1 As String	= "</div>"'"<!--"

	matcher = Regex.Matcher(pattern1, newText)

	Do While matcher.Find = True
		endPos = matcher.GetStart(0)
		Exit
	Loop
	Dim vSong As String = newText.SubString2(pattern.Length, endPos)
	Starter.chatDataLyric	= True
	Starter.lyricFound		= True
	
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
			'Log(LastException) 'This can cause another error
		End Try 'ignore
		
	End If
End Sub