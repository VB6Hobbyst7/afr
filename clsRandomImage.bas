B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9
@EndOfDesignText@
Sub Class_Globals
	Dim url As String = "https://picsum.photos/150/150?random=2"
End Sub

'Initializes the object. You can add parameters to this method if needed.
'https://picsum.photos/200/300?random=2
Public Sub Initialize
	
End Sub

public Sub newRandomImage
	Dim j As HttpJob
	
	j.Initialize("",  Me)
	j.Download(url)
	j.GetRequest.Timeout = Starter.jobTimeOut
	Wait For (j) JobDone(j As HttpJob)
	
	If j.Success Then
		CallSubDelayed2(Starter, "setAlbumArt", j.GetBitmap)
	End If
	j.Release
End Sub