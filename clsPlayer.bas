B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.01
@EndOfDesignText@
Sub Class_Globals
	Public kvs As KeyValueStore
	Public currAct As Activity
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Activity As Activity)
	currAct = Activity
	kvs.Initialize(Starter.irp_dbFolder, "settings", True)
	PullViews
End Sub

Public Sub resetKvsPnlButtons
	kvs.PutSimple("app_started", 0)
	kvs.PutSimple("pnl_stop_button",  0)
	kvs.PutSimple("pnl_lyric_button",  0)
	kvs.PutSimple("pnl_store_song_button", 0)
	kvs.PutSimple("pnl_album_info_button", 0)
	kvs.PutSimple("lbl_time_now", "")
	kvs.PutSimple("lblNowPlayingDataRate", "")
	kvs.Remove("player_station_logo")
End Sub

Sub getSetSettings
'	'get wifi only setting
'	If kvs.GetSimple("wifionly") = 1 Then
	'	currAct.Switch.Checked		= True
'		Starter.vWifiOnly	= True
'	Else
'		Switch.Checked		= False
'		Starter.vWifiOnly	= False
'	End If
'	
'	If kvs.GetSimple("updatelogo") = 1 Then
'		SwitchUpdateLogo.Checked = True
'		Starter.vUpdateLogo = True
'	Else
'		SwitchUpdateLogo.Checked = False
'		Starter.vUpdateLogo = False
'	End If

End Sub


Sub PullViews
	
	For Each v As B4XView In currAct.GetAllViewsRecursive
		Log(v.Height)
	Next
End Sub