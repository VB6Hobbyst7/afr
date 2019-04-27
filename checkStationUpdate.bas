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
	dim dlCount as Int = 0
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
	Private pbDownload As ProgressBar
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("checkStationUpdate")
	pbDownload.Visible = False
	
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
				Log(fName & ", " & sizeText & ", " & Files(i).Timestamp)
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

Sub pnlUpdateFile_Click
	Dim index As Int
	Dim pnl As Panel
	Dim subTitle As String = toolbar.SubTitle
	
	Starter.getUpdate = True
	index = clv_updates.GetItemFromView(Sender)
	pnl = clv_updates.GetPanel(index)
	dlCount = 0
	pbDownload.Visible = True
	wait for (downloadUpdate(pnl.Tag)) Complete (result As Boolean)
	pbDownload.Visible = False
	toolbar.SubTitle = subTitle
End Sub


Sub downloadUpdate(fileName As String)As ResumableSub
	FTP.PassiveMode = True
	FTP.Initialize("FTP", "ftp.pdeg.nl", 21, Starter.doy, Starter.moy)
	Dim sf As Object = FTP.DownloadFile(fileName, False, Starter.irp_dbFolder, "rdolist_main.csv")
	Wait For (sf) ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
	FTP.Close
	importStations("stUpdate")
	
	Return True
End Sub

Sub FTP_DownloadProgress (ServerPath As String, TotalDownloaded As Long, Total As Long)
	Return
	dlCount = dlCount +1
	If dlCount Mod 5 = 0 Then
		Dim s As String
		s = "Downloaded " & Round(TotalDownloaded / 1000) & "KB"
		If Total > 0 Then s = s & " out of " & Round(Total / 1000) & "KB"
		toolbar.SubTitle = "Downloading station list " & Round(TotalDownloaded / 1000) & "KB"
		Sleep(0)
	End If
End Sub

Public Sub importStations(table As String) As ResumableSub
	Dim su As StringUtils
	Dim csv As List
	Dim items() As String
	Dim modValue As Int = 50
	Dim sql As String
	Dim vSql As SQL
	Dim vDbName As String = "rdodb.db"
	
	Dim db_path As String = CallSub(Starter, "getDbPath")
	Try
		If vSql.IsInitialized = False Then
			vSql.Initialize(db_path, vDbName, False)
		End If
	Catch
		Log(LastException)
	End Try
	
	sql = $"insert
	into
		${table} (stname,
		description,
		genre,
		country,
		language,
		stream1,
		stream2,
		stream3,
		stream4,
		stream5,
		stream6)
	VALUES (?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?,
	?)"$
	
	genDb.truncateTable(table)
	csv = su.LoadCSV(Starter.irp_dbFolder, "rdolist_main.csv", "|")
	
	
	vSql.BeginTransaction
	For i = 2 To csv.Size - 1
		items = csv.Get(i)
		
		vSql.ExecNonQuery2(sql, Array As String(items(1), items(2), items(3), items(4), items(5),items(6), items(7), items(8), items(9), items(10), items(11)))
		
	Next
	toolbar.SubTitle = $"Importing stations ${NumberFormat2(i-2, 1, 0, 0, False)} of ${NumberFormat2(csv.Size - 2, 1, 0, 0, False)}"$
	vSql.TransactionSuccessful
	vSql.EndTransaction
	
	
	
	File.Delete(Starter.irp_dbFolder, "rdolist_main.csv")
	Return False
End Sub
