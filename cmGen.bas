B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.8
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	
End Sub


Sub stripUrl(url As String)
	Dim countSlash, slashIndex As Int
	Dim newUrl As String
	
	countSlash = CountChar(url, "/")
	
	If countSlash > 2 Then
		slashIndex	= getFirstSlash(url,"/")
		newUrl		= url.SubString2(0, slashIndex)
	End If
	
	If newUrl.Length > 0 Then
		CallSub2(player,"getStationLogo", newUrl)
	End If
	
End Sub

' Counts the number of times a char appears in a string.
' Param - searchMe, the string to be searched
' Param - findMe, the single char to search for
Sub CountChar(searchMe As String, findMe As Char) As Int
	If Not(searchMe.Contains(findMe)) Then Return 0

	Dim CountMe As Int = 0

	For x = 0 To searchMe.Length - 1
		If searchMe.CharAt(x) = findMe Then
			CountMe = CountMe + 1
		End If
	Next

	Return CountMe

End Sub


Sub getFirstSlash(searchMe As String, findMe As Char) As Int

	If Not(searchMe.Contains(findMe)) Then Return 0

	Dim CountMe As Int = 0

	For x = 0 To searchMe.Length - 1
		If searchMe.CharAt(x) = findMe Then
			CountMe = CountMe + 1
			If CountMe = 3 Then
				Return x
			End If
		End If
	Next

	Return CountMe

End Sub


Sub setStationUrlToRecord(url As String, stationId As String)
	genDb.setStationUrl(url, stationId)
End Sub


'Sub openStationUrl(stationName As String)
'	Dim ph As PhoneIntents
'	Dim url As String = genDb.getStationUrl(stationName)
'	
'	If url = "nourl" Or url = Null Then
'		ToastMessageShow("Invalid Url", True)
'		Return
'	End If
'	url = Starter.clsFunc.checkUrlHttp(url)
'	Try
'		If Not(Starter.clsFunc.checkUrl(url)) Then
'			Return
'		End If
'		StartActivity(ph.OpenBrowser(url))
'	Catch
'		ToastMessageShow("Station url seems to be invalid", True)
''		Log("CMGEN @ 85 : "&LastException)
'	End Try
'End Sub


Sub getStationRecord(stationName As String, column As String) As String
	Return genDb.getStationRecord(stationName, column)
End Sub


'Sub FormatFileSize(passedBytes As Float) As String
'	Private Unit() As String = Array As String(" Bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB")
'   
'	If passedBytes = 0 Then
'		Return "0 Bytes"
'	Else
'		Private Po, Si As Double
'		Private I As Int
'       
'		passedBytes = Abs(passedBytes)
'                            
'		I = Floor(Logarithm(passedBytes, 1024))
'		Po = Power(1024, I)
'		Si = passedBytes / Po
'       
'		Return NumberFormat2(Si, 1, 2, 2, False) & Unit(I)
'       
'	End If
'   
'End Sub



Public Sub logShowDateTime
	Starter.clsFunc.showLog($"Current time is $DateTime{DateTime.Now}"$, Colors.Red)
	
End Sub

Sub RegexReplace(Pattern As String, Text As String, Replacement As String) As String
	Dim m As Matcher
	m = Regex.Matcher(Pattern, Text)
	Dim r As Reflector
	r.Target = m
	Return r.RunMethod2("replaceAll", Replacement, "java.lang.String")
End Sub




