B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
Sub Class_Globals
	Private chartDataFound As Boolean = False
	Private tryReversed As Boolean = False
	Private url As String
	Private matchPercArtist, matchPercSong As Float
	Private sim As ABSimMetrics
	Private xmlparser As SaxParser
	Private xmldata As Map
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub


public Sub getDataFromChartLyrics As ResumableSub
	Dim inputXml As String
	Dim TextReader As TextReader
	
	chartDataFound	= False
	
	If Starter.chartArtist.Length < 1 Then
		Return chartDataFound
	End If
	
	genUrl
	Dim job As HttpJob
	job.Initialize("", Me)
	job.Download(url)
	job.GetRequest.Timeout = 5*1000
	Wait For (job) JobDone(job As HttpJob)
	
	If job.Success Then
		Dim jString As String = job.GetString()
		job.Release
		
		File.WriteString(File.DirInternal,"test.xml", jString)
		TextReader.Initialize(File.OpenInput(File.DirInternal, "test.xml"))
		
		inputXml = TextReader.ReadAll
		File.WriteString(File.DirInternal, "ff.json",xmltojson(inputXml))
		modifyJSON(File.ReadString(File.DirInternal, "ff.json"), Starter.chartArtist, Starter.chartSong)
		
		If chartDataFound = False And tryReversed = False Then
			tryReversed = True
			'genUrl
			getDataFromChartLyrics
		End If
		
		Return chartDataFound
	End If
	Return chartDataFound
End Sub


Sub genUrl
	If tryReversed = False Then
		url= $"http://api.chartlyrics.com/apiv1.asmx/SearchLyric?artist=${Starter.chartArtist}&song=${Starter.chartSong}"$
	Else
		url= $"http://api.chartlyrics.com/apiv1.asmx/SearchLyric?artist=${Starter.chartSong}&song=${Starter.chartArtist}"$
	End If
	
End Sub

Sub xmltojson(xml As String) As String
	'nothing to do in this sub it just works
	Dim jo As JavaObject
	Dim JSON As JSONParser
	Dim jg1 As JSONGenerator
 
	jo.InitializeNewInstance("org.json.XML", Null)
	Dim jml As String = jo.RunMethod("toJSONObject", Array(xml))
 
	Dim Map1 As Map
	JSON.Initialize(jml)
	Map1 = JSON.NextObject
 
	jg1.Initialize(Map1)
	Return jg1.ToPrettyString(4)
End Sub


Sub modifyJSON(json As String, vartist As String, vsong As String)
	Dim jsFirstPos, jsLastPos As Int
	Dim rp As RuntimePermissions
	Dim dataFound As Boolean = False
	
'	Log($"MODIFY JSON : ARTIEST ${vartist} SONG ${vsong}"$)
	
	jsFirstPos = json.IndexOf("[")
	jsLastPos	= json.LastIndexOf("]")
	
'	Log($"FIRST POS ${jsFirstPos}"$)
	If jsFirstPos = -1 Then
		chartDataFound	= False
		Return
	End If
	
	File.WriteString(rp.GetSafeDirDefaultExternal("files"), "pdeg.json", json.SubString2(jsFirstPos, jsLastPos+1))
	
	Dim parser As JSONParser
	
	parser.Initialize(File.ReadString(rp.GetSafeDirDefaultExternal("files"), "pdeg.json"))
	Dim root As List = parser.NextArray
	
	For Each colroot As Map In root
		If colroot.ContainsKey("Artist") Then
			Dim Artist As String = colroot.Get("Artist")
			Dim LyricId As Int = colroot.Get("LyricId")
			Dim LyricChecksum As String = colroot.Get("LyricChecksum")
			Dim Song As String = colroot.Get("Song")
			'	Dim SongUrl As String = colroot.Get("SongUrl")
			'	Dim ArtistUrl As String = colroot.Get("ArtistUrl")
			'	Dim SongRank As Int = colroot.Get("SongRank")
			'	Dim TrackId As Int = colroot.Get("TrackId")
			'	Log($"ARTIST ${Artist} - ${Starter.chartArtist} SONG ${Song} - ${Starter.chartSong}"$)
			matchPercArtist = sim.ABGetSimilarity(Artist.ToLowerCase, vartist.ToLowerCase, sim.LEVENSHTEIN_DISTANCE)
			matchPercSong	= sim.ABGetSimilarity(Song.ToLowerCase, vsong.ToLowerCase, sim.LEVENSHTEIN_DISTANCE)
			'	LogColor($"matchPercArtist : ${matchPercArtist}, matchPercSong ${matchPercSong}"$, Colors.Red)
			If matchPercArtist*100 > 60.0  And matchPercSong*100 > 60.0 And LyricId > 0 Then
				dataFound	= True
				getLyricAlbum(LyricId, LyricChecksum)
				
				Exit
			End If
		End If
	Next
	chartDataFound	= dataFound
End Sub


Sub getLyricAlbum(lyricId As String, lyricChecksum As String)
	Dim url As String
	Dim rp As RuntimePermissions
	
	url	= $"http://api.chartlyrics.com/apiv1.asmx/GetLyric?lyricId=${lyricId}&lyricCheckSum=${lyricChecksum}"$
	Dim j1 As HttpJob
	j1.Initialize("", Me)
	j1.Download(url)
  
	Wait For (j1) JobDone(j1 As HttpJob)
	If j1.Success Then
		Dim j1String As String = j1.GetString()
		j1.Release
		Dim clsFunc As clsFunctions
		clsFunc.Initialize
		clsFunc.showLog(j1String,0)
		File.WriteString(rp.GetSafeDirDefaultExternal("files"), "ff.xml", j1String)
		xmlparser.Initialize
		xmldata.Initialize
		Dim result As InputStream = File.Openinput(rp.GetSafeDirDefaultExternal("files"), "ff.xml")
		xmlparser.Parse(result, "parser")
		chartDataFound		= True
		Starter.lyricFound	= True
		Starter.albumArtFound = True
	Else
		clsFunc.showLog("NO CHARTDATA",0)
		chartDataFound		= False
		Starter.lyricFound	= False
	End If
End Sub