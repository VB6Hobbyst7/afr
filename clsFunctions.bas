B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
#IgnoreWarnings: 9, 1
Sub Class_Globals
	Private mlWifi As MLwifi
	
End Sub

Public Sub Initialize
	
	
End Sub

'***function description here...
Public Sub stringSplit(splitChar As String, stringToSplit As String, startPos As Int, addSplitChar As Boolean, returnIndex As Int, returnCount As Boolean) As String
	Dim retString="", splitString As String
	Dim splitList As List
	Dim i As Int
	
	
	
	If stringToSplit.Length < 3 Then
		Return stringToSplit
	End If
	
	If stringToSplit.IndexOf(splitChar) = -1 Then
		Return stringToSplit
	End If
	
	splitList.Initialize
	splitList =Regex.Split(splitChar, stringToSplit)
	
	Try
	
		If returnCount = True Then
			Return splitList.Size +1
		End If
		
'		Log($"RETURN INDEX ${returnIndex}"$)
		'If returnIndex = Null Then
			'Return 0	
		'End If
		
		If returnIndex > -1 Then
			Return splitList.Get(returnIndex)
		End If
	
		For i = startPos To splitList.Size -1
			If splitString = "" Then
				splitString = splitList.Get(i)
				retString = splitString.Trim
			Else
				splitString = splitList.Get(i)
				If addSplitChar = True Then
					retString = $"${retString} - ${splitString.Trim}"$
				Else
					retString = $"${retString} ${splitString.Trim}"$
				End If
			End If
		
		Next
	
	Catch
		Starter.clsFunc.showLog("CLSFUNCTIONS @ 64 : "&LastException, 0)
	End Try
	Return retString

End Sub

'***Pass message and optional a color e.g. showLog("test message", colors.Red)
Sub showLog(logMessage As String, setColor As Int)
	#if debug
	If setColor <> 0 Then
		LogColor(logMessage, setColor)
	Else
		Log(logMessage)
	End If
	#end if
End Sub

Public Sub BytesToImage(bytes() As Byte) As B4XBitmap
	Dim in As InputStream
	in.InitializeFromBytesArray(bytes, 0, bytes.Length)
#if B4A or B4i
	Dim bmp As Bitmap
	bmp.Initialize2(in)
#else
   Dim bmp As Image
   bmp.Initialize2(In)
#end if
	Return bmp
End Sub

Public Sub ImageToBytes(Image As B4XBitmap) As Byte()
	Dim out As OutputStream
	out.InitializeToBytesArray(0)
	Image.WriteToStream(out, 100, "JPEG")
	out.Close
	Return out.ToBytesArray
End Sub

public Sub CheckConnected As ResumableSub
	Dim p As Phone
	Wait For (p.ShellAsync("ping", Array As String("-c", "1", "8.8.8.8"))) Complete (Success As Boolean, ExitValue As Int, StdOut As String, StdErr As String)
	If StdErr = "" And StdOut.Contains("Destination Host Unreachable")=False Then
		Return True
	Else
		Return False
	End If
End Sub


public Sub IsStreamActive(Stream As Int) As Boolean
	Dim jo As JavaObject
	Return jo.InitializeStatic("android.media.AudioSystem").RunMethod("isStreamActive", Array(Stream, 0))
End Sub

Sub ReplaceRaros(p_strText As String) As String

	If p_strText.Length < 1 Then
		Return ""
	End If

	Dim strTemp As String
	strTemp = p_strText
	
	If strTemp.Length < 3 Then
		Return ""
	End If

	strTemp=strTemp.Replace("Ã¡","á")
	strTemp=strTemp.Replace("Ã©","é")
	strTemp=strTemp.Replace("Ã*","í")
	strTemp=strTemp.Replace("Ã³","ó")
	strTemp=strTemp.Replace("Ãº","ú")
	strTemp=strTemp.Replace("Ã","Á")
	strTemp=strTemp.Replace("Ã‰","É")
	strTemp=strTemp.Replace("Ã","Í")
	strTemp=strTemp.Replace("Ã","Ó")
	strTemp=strTemp.Replace("Ãš","Ú")
	strTemp=strTemp.Replace("Ã±","ñ")
	strTemp=strTemp.Replace("Ã§","ç")
	strTemp=strTemp.Replace("Ã‘","Ñ")
	strTemp=strTemp.Replace("Ã‡","Ç")
	strTemp=strTemp.Replace("Â©","©")
	strTemp=strTemp.Replace("Â®","®")
	strTemp=strTemp.Replace("â„¢","™")
	strTemp=strTemp.Replace("Ã˜","Ø")
	strTemp=strTemp.Replace("Âª","ª")
	strTemp=strTemp.Replace("Ã¤","ä")
	strTemp=strTemp.Replace("Ã«","ë")
	strTemp=strTemp.Replace("Á«","ë")
	strTemp=strTemp.Replace("Á©","é")
	strTemp=strTemp.Replace("HI: ", "")
	
	strTemp=strTemp.Replace("Ã¯","ï")
	strTemp=strTemp.Replace("Ã¶","ö")
	strTemp=strTemp.Replace("Ã¼","ü")
	strTemp=strTemp.Replace("Ã„","Ä")
	strTemp=strTemp.Replace("Ã‹","Ë")
	strTemp=strTemp.Replace("Ã","Ï")
	strTemp=strTemp.Replace("Ã–","Ö")
	strTemp=strTemp.Replace("Ãœ","Ü")
	strTemp=strTemp.Replace("'","")
	strTemp=strTemp.Replace("&#39","")
	strTemp=strTemp.Replace("&#38","")
	strTemp=strTemp.Replace("*","")
	strTemp=strTemp.Replace("?m","'m")
	strTemp	= strTemp.Replace(" ft", "")
	strTemp	= strTemp.Replace(" ft.", "")
	strTemp	= strTemp.Replace("TOPSONG: ", "")
	strTemp	= strTemp.Replace("Nu:Straks:", "")
	strTemp	= strTemp.Replace("Nu:Straks:", "")
	'strTemp	= strTemp.Replace("Straks:", "")
	strTemp	= strTemp.Replace("Now Playing: ", "")
	strTemp	= strTemp.Replace("S.S.", "")
	
	If strTemp.SubString2(0,3) = " - " Then
		strTemp = strTemp.SubString2(3,strTemp.Length)
	End If
	
'	If strTemp.SubString2(strTemp.Length-1, strTemp.Length) = " " Then
''		strTemp.SubString2(0, strTemp.Length-1)
'	End If
	
	Return strTemp
End Sub

Public Sub getConnectionType
	Dim phone As Phone
	Dim phoneInfoText As String = $"${phone.GetNetworkOperatorName} (${phone.GetNetworkType}) ${CheckConnectionStatus}"$
	If mlWifi.isWifiConnected = True Then
		CallSub2(player, "setConnectionIcon", "WIFI connected"  & " (" & mlWifi.WifiIpAddress &", " & mlWifi.WifiLinkSpeed&" Mbps)")', "wifi")
		Starter.vWifiConnected = True
		CallSub3(player, "setWifiPhoneImage", Starter.vWifiConnected, phoneInfoText)
	Else
		Starter.vWifiConnected = False
		If phone.GetNetworkType = "UNKNOWN" Then
			'CallSub2(player, "startOrStopStream", (Starter.vPlayerSelectedPanel))
			CallSub2(player, "showNoConnectionText", "Please check your internet connection")
			Return
		End If
		CallSub3(player, "setWifiPhoneImage", Starter.vWifiConnected, phoneInfoText)
		CallSub2(player, "setConnectionIcon", phoneInfoText)', "mobile")
	End If
	
If Starter.vWifiOnly = True And Starter.vWifiConnected = False Then
		If modGlobal.PlayerStarted = True Then
			modGlobal.PlayerStarted = False
			'CallSub(Starter, "StopPlayer")
			'Starter.clsExoPlayer.stopPlayer
			CallSub(Starter, "stopPlayer")
			CallSub(player, "checkWifiOnly")
		End If
	End If
End Sub

Sub CheckConnectionStatus As String
	Dim InterCon As ServerSocket
	InterCon.Initialize(0, "")
	Return InterCon.GetMyIP
End Sub

Sub IsMusicPlaying As Boolean
	Dim JO As JavaObject
	JO.InitializeContext
	Return JO.RunMethodJO("getSystemService",Array("audio")).RunMethod("isMusicActive",Null)
End Sub

'padText e.g. "9", padChar e.g. "0", padSide 0=left 1=right, padCount e.g. 2
Public Sub padString(padText As String ,padChr As String, padSide As Int, padCount As Int) As String
	Dim padStr As String
	
	For i = 1 To padCount
		padStr = padStr&padChr
	Next
	
	If padStr = 0 Then
		Return padStr&padText
	Else
		Return padText&padStr	
	End If
	
End Sub


Public Sub ConvertMillisecondsToString(t As Long) As String
	Dim hours, minutes, seconds As Int
	hours = t / DateTime.TicksPerHour
	minutes = (t Mod DateTime.TicksPerHour) / DateTime.TicksPerMinute
	seconds = (t Mod DateTime.TicksPerMinute) / DateTime.TicksPerSecond
	Return $"$2.0{seconds}"$
	Return $"$1.0{hours}:$2.0{minutes}:$2.0{seconds}"$
End Sub


Public Sub MobileDataEnabled As Boolean
	Dim r As Reflector
	r.Target = r.GetContext
	r.Target = r.RunMethod2("getSystemService", "connectivity", "java.lang.String")
	Return r.RunMethod("getMobileDataEnabled")
End Sub

Public Sub checkUrl(url As String) As Boolean
	Dim m As Matcher = Regex.Matcher($"(?i)\b((?:https?:(?:/{1,3}|[a-z0-9%])|[a-z0-9.\-]+[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)/)(?:[^\s()<>{}\[\]]+|\([^\s()]*?\([^\s()]+\)[^\s()]*?\)|\([^\s]+?\))+(?:\([^\s()]*?\([^\s()]+\)[^\s()]*?\)|\([^\s]+?\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])|(?:(?<!@)[a-z0-9]+(?:[.\-][a-z0-9]+)*[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)\b/?(?!@)))"$, url)
	If m.Find Then
		Dim s As String = m.Match
		If s.StartsWith("http") = False Then
			Return True
		End If
		Return True
	End If
	Return False
End Sub

Public Sub checkUrlHttp(url As String) As String
	Dim m As Matcher = Regex.Matcher($"(?i)\b((?:https?:(?:/{1,3}|[a-z0-9%])|[a-z0-9.\-]+[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)/)(?:[^\s()<>{}\[\]]+|\([^\s()]*?\([^\s()]+\)[^\s()]*?\)|\([^\s]+?\))+(?:\([^\s()]*?\([^\s()]+\)[^\s()]*?\)|\([^\s]+?\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])|(?:(?<!@)[a-z0-9]+(?:[.\-][a-z0-9]+)*[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)\b/?(?!@)))"$, url)
	If m.Find Then
		Dim s As String = m.Match
		If s.StartsWith("http") = False Then
			Return "http://"&url
		End If
	End If
	Return ""
End Sub

Public Sub shadowLayer(lbl As View, Radius As Float, dx As Float, dy As Float, Color As Int)
	Dim jo = lbl As JavaObject
	jo.RunMethod("setShadowLayer", Array(Radius, dx, dy , Color))

End Sub


Public Sub replacetekens(str As String) As String
	str	= str.Replace(" ", "")
	str	= str.Replace("'", "")
	str	= str.Replace("&", "")
	str	= str.Replace("&_", "")
	str	= str.Replace("(", "")
	str	= str.Replace(")", "")
	str	= str.Replace(".", "")
	str	= str.Replace("-", "")
	str	= str.Replace("|", " ")
	str	= str.Replace(",", "")
	str	= str.Replace("!", "")
	str	= str.Replace("?", "")
	
	Return str
End Sub


Sub TitleCase (s As String) As String
	If Starter.capNowPlaying = False Then
		Return s
	End If
	s = s.ToLowerCase
	Dim m As Matcher = Regex.Matcher("\b(\w)", s)
	Do While m.Find
		Dim i As Int = m.GetStart(1)
		s = s.SubString2(0, i) & s.SubString2(i, i + 1).ToUpperCase & s.SubString(i + 1)
	Loop
	Return s
End Sub



Public Sub FormatFileSize(passedBytes As Float) As String
	Private Unit() As String = Array As String(" Bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB")
   
	If passedBytes = 0 Then
		Return "0 Bytes"
	Else
		Private Po, si As Double
		Private I As Int
       
		passedBytes = Abs(passedBytes)
                            
		I = Floor(Logarithm(passedBytes, 1024))
		Po = Power(1024, I)
		si = passedBytes / Po
       
		Return NumberFormat2(si, 1, 2, 2, False) & Unit(I)
       
	End If
   
End Sub

Public Sub singularPlural(str As String, count As Int) As String
	If count <= 0 Then
		Return $"${str}s"$
	End If
	If count > 1 Then
		Return $"${str}s"$
	End If

	Return $"${str}"$
End Sub

Public Sub parseScrapeData (metadata As String)
	If metadata = "" Then 
	'	CallSubDelayed2(player, "setlblTimeNow", "")
		Return
	End If
	
	Dim parser As JSONParser
	parser.Initialize(metadata)
	Dim root As Map = parser.NextObject
	
	Dim lyric As String = root.Get("lyrics")
	Dim source As String = root.Get("source")
	If lyric = "" Then
		Starter.vSongLyric = "nolyric"
		Return
	End If
	lyric = lyric.Replace("<p class='verse'>", "")
	lyric = lyric.Replace("</p>", "")
	lyric = lyric.Replace($"<script>try{_402_Show();}catch(e){}</script>\n<div class=\"fb-quote\"></div>\n</div>""$, "")
	lyric = lyric.Replace("\n<!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->", "")
	Starter.vSong = lyric
	Starter.vSongLyric = "foundLyric"
	CallSubDelayed2(Starter, "setSongLyric", lyric)
'	Log($"$DateTime{DateTime.Now} : ${source}"$)
	'CallSubDelayed2(player, "setlblTimeNow", source)
	'Log(lyric)
End Sub


Public Sub parseIcy(metaData As String) As String
	If metaData.SubString2(0,1) <> "{" Then
		Return "No song information"
	End If
	Dim parser As JSONParser
	parser.Initialize(metaData)
	
	

Try
		Dim root As Map = parser.NextObject
Catch
		'CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		CallSub(Starter, "showNoImage")
		Return "No song information"
End Try
	
	'Dim root As Map = parser.NextObject
	If root.ContainsKey("error") Then
		'CallSubDelayed2(Starter, "setAlbumArt", LoadBitmap(File.DirAssets, "NoImageAvailable.png"))
		CallSub(Starter, "showNoImage")
		Return "No song information"
	End If
	
	Dim icy_by As String = root.Get("icy-by")
	Dim icy_name As String = root.Get("icy-name")
	Dim icy_playing As String = root.Get("icy-playing")
	Dim icy_genre As String = root.Get("icy-genre")
	Dim icy_br As String = root.Get("icy-br")
	Dim icy_url As String = root.Get("icy-url")
	If icy_genre = "" Then
		icy_genre = "N/A"
	End If
'	Log(icy_playing)
	If ReplaceRaros(icy_playing) <> Starter.lastSong Or Starter.lastSong = "" Then
	
		CallSub2(player, "setGenre", icy_genre)
		CallSub2(player, "getStationLogo", icy_url)
		Starter.vStationName	= icy_name
		If Starter.vStationName = "" Then
			Starter.vStationName = "AdFree Radio"
		End If
	
		If Starter.activeActivity = "searchStation" Then
			CallSub2(searchStation, "setStreamBitRate", "Bitrate : " & icy_br)
		Else
			CallSub2(player,"setStationBitrate", "Station bitrate : "& icy_br)
		End If
		Starter.icy_playing = icy_playing
		'CallSubDelayed2(player, "setSongPlaying", icy_playing)
		Return icy_playing
	Else
		Return Starter.lastSong
	End If
End Sub

Public Sub checkAmpersant(str As String) As String
	Dim ampPos As Int = 0
	Dim txtPreAmp, txtPostAmp, retVal As String

	ampPos = str.IndexOf("&")
	If ampPos = -1 Then
		Return str
	End If
	
	If str.SubString2(ampPos-1, ampPos) = " " And str.SubString2(ampPos + 1, ampPos+2) = " " Then
		retVal = Regex.Replace("&", str, "And")
	Else
		txtPreAmp = str.SubString2(0, ampPos)
		txtPostAmp = str.SubString2(ampPos + 1, str.Length)
		retVal = $"${txtPreAmp} And ${txtPostAmp}"$
	End If
	
	If retVal.IndexOf("&") > -1 Then
		retVal = checkAmpersant(retVal)
	End If

	Return retVal
	
End Sub

'ONLY RETURN ROWS THAT CONTAIN TEXT 
Public Sub GetArtistAndSong(song As String, reverse As Boolean) As String
	Dim lst, cleanList As List
	Dim retVal As String
	
	lst.Initialize
	cleanList.Initialize
	
	lst = Regex.Split("-", song)
	
	For Each str As String In lst
		If str.Length > 2 Then
			cleanList.Add(str.Trim)
		End If
	Next
	
	If reverse = True Then
		retVal = $"${cleanList.Get(1)} - ${cleanList.Get(0)}"$
	Else
		retVal = $"${cleanList.Get(0)} - ${cleanList.Get(1)}"$
	End If
	Starter.icy_playing = retVal
		
	Return retVal
End Sub

Sub removeBetween(str As String, charLst As String) As String
	Dim remLst As List = Regex.Split("-", charLst)
	Dim firstPos, lastPos As Int
	Dim remString, newString As String
	
	If str.IndexOf(remLst.Get(0)) > -1 Then
		firstPos = str.IndexOf(remLst.Get(0))
		lastPos	= str.IndexOf(remLst.Get(1))
		remString = str.SubString2(firstPos, lastPos+1)
		Log(remString)
		newString = str.Replace(remString, "")
		Log(newString)
	End If
	
	If newString.IndexOf(remLst.Get(0)) > -1 Then
		newString = removeBetween(newString, charLst)
	End If
	Return str
End Sub

Sub removeCommaFromArtist(str As String) As String
	
End Sub
