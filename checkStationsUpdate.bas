B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Dim ftp As FTP
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub checkUpdate As ResumableSub
	If ftp.IsInitialized = False Then
		ftp.Initialize("FTP", "ftp.pdeg.nl", 21, Starter.doy, Starter.moy)
	End If
	ftp.List("/")
	wait for FTP_ListCompleted(ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)
	If Success = False Then
		Log(LastException)
		ftp.Close
	Else
		For i = 0 To Files.Length - 1
			dbTimestamp = Files(i).Timestamp
		Next
		ftp.Close
	End If
	Return True
End Sub
