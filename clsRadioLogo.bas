B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.8
@EndOfDesignText@
#Event: RequestFinished
#IgnoreWarnings: 9, 1
Sub Class_Globals
	Private cbObj As Object
	Private cbEN As String
'	Private stationId As String
	Private imgFile As String
'	Private imgUrl As String
'	Private pageids As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(callbackModule As Object, callbackEventName As String)
	cbObj = callbackModule
	cbEN = callbackEventName
End Sub


Sub getImgUrl
	Dim url As String
	Dim imgJson As String
	
	If imgFile.IndexOf("file") = -1 Then
		Return
	End If
	
	'https://en.wikipedia.org/w/api.php?action=query&titles=File:NPO%20Radio%202%20logo.png&prop=imageinfo&iilimit=50&iiend=2007-12-31T23:59:59Z&iiprop=timestamp%7Cuser%7Curl
	url= "https://en.wikipedia.org/w/api.php?action=query&titles="&imgFile&"&prop=imageinfo&iilimit=50&iiend=2007-12-31T23%3A59%3A59Z&iiprop=timestamp%7Cuser%7Curl&format=json"
	Dim j3 As HttpJob
	j3.Initialize("", Me)
	j3.Download(url)
	
	Wait For (j3) JobDone(j3 As HttpJob)
	If j3.Success Then
		imgJson = j3.GetString
		j3.Release
	
		
		
'		Dim replaceId As String = scrobbler.processImgUrlJson(imgJson)
Dim replaceId As String = ""
		If replaceId = "" Then
			Return
		End If
		
		imgJson	= imgJson.Replace(replaceId, "helloworld")

		Dim parser As JSONParser
		parser.Initialize(imgJson)
		Dim root As Map = parser.NextObject
		
'		Dim batchcomplete As String = root.Get("batchcomplete")
		Dim query As Map = root.Get("query")
		Dim pages As Map = query.Get("pages")
		Dim helloworld As Map = pages.Get("helloworld")
'		Dim known As String = helloworld.Get("known")
'		Dim ns As Int = helloworld.Get("ns")
'		Dim missing As String = helloworld.Get("missing")
'		Dim imagerepository As String = helloworld.Get("imagerepository")
		Dim imageinfo As List = helloworld.Get("imageinfo")
		For Each colimageinfo As Map In imageinfo
'			Dim descriptionurl As String = colimageinfo.Get("descriptionurl")
'			Dim descriptionshorturl As String = colimageinfo.Get("descriptionshorturl")
'			Dim user As String = colimageinfo.Get("user")
			Dim url As String = colimageinfo.Get("url")
'			Dim timestamp As String = colimageinfo.Get("timestamp")
		Next
'		Dim title As String = helloworld.Get("title")
	End If
	'CALL SUB TO GET IMAGE
End Sub