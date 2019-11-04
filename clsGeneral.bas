B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
#IgnoreWarnings: 9, 1, 11
Sub Class_Globals
	'Private xmlparser As SaxParser
	'Private url As String

	Public chartDataFound As Boolean = False
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
	
End Sub

public Sub setChartDataFound(value As Boolean)
	chartDataFound = value
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
	j.GetRequest.Timeout = Starter.jobTimeOut
	
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


