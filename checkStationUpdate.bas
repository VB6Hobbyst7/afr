B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.01
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	Dim FTP As FTP
	
End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private toolbar As ACToolBarDark
	Private clv_updates As irp_CustomListView
	Private lblUpdateName As Label
	Private lblUpdateDate As Label
	Private lblUpdateSize As Label
	Private Label1 As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("checkStationUpdate")

	If FTP.IsInitialized = False Then
		FTP.Initialize("FTP", "ftp.pdeg.nl", 21, Starter.doy, Starter.moy)
	End If
	
	

	
End Sub

Sub Activity_Resume
	FTP.List("/")

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub



Sub FTP_ListCompleted (ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)
	Dim fName, sizeText As String
	Dim size As Float
	Log(ServerPath)
	clv_updates.Clear
	If Success = False Then
		Log(LastException)
		FTP.Close
	Else
'		For i = 0 To Folders.Length - 1
'			Log(Folders(i).Name)
'		Next
		
		For i = 0 To Files.Length - 1
			fName = Files(i).Name
			size	= Files(i).Size
			sizeText = Starter.clsFunc.FormatFileSize(size)
			If fName.IndexOf("upd") > -1 Then
'				Log(fName & ", " & sizeText & ", " & DateTime.Date(Files(i).Timestamp))
				clv_updates.Add(createPanels(fName, sizeText), "")
			End If
		Next
		FTP.Close
	End If
End Sub


Sub createPanels (fName As String, size As String) As Panel
	Dim p As Panel
	Dim fileName, newStations As String
	Dim parseList As List
	
	fileName = fName.Replace(".csv", "")
	parseList.Initialize
	parseList = Regex.Split("_", fileName)
	newStations = parseList.Get(4)
	p.Initialize("")
	
	p.SetLayout(0,0, clv_updates.AsView.Width, 125dip)
	p.LoadLayout("plnUpdateList")
	
	p.Tag = fName
	lblUpdateName.Text	= "Update "& parseList.Get(1)&"-"&parseList.Get(2)&"-"&parseList.Get(3)  'fName.Replace(".csv", "")
	lblUpdateSize.Text	= size
	lblUpdateDate.Text	= newStations & " new stations"'date
	
	Return p
End Sub

Sub Label1_Click
	StartActivity("addNewStations")
End Sub