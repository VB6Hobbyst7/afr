B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=8
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	
End Sub

Sub Globals
	Private lbl_date As Label
	Private lbl_station As Label
	Private lbl_artist As Label
	Private lbl_delete As Label
	Private btn_clear_list As Button
	Private clvStoredSongs As irp_CustomListView
	Private toolbar As ACToolBarDark
	Private pnl_song As Panel
	
	Dim sb As StringBuilder
	Dim xml As XmlLayoutBuilder
	Private iv_logo As ImageView
	
	Private iv_album As ImageView
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("stored_songs")
	toolbar.Title = "Adfree Radio - Stored songs"
End Sub

Sub Activity_Resume
	getStations
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	
	Activity.Finish
End Sub

Sub btn_clear_list_Click
	Dim result As Int
	
	result = Msgbox2("Clear list?", Starter.vAppname, "Yes", "",  "No", Null)
	If result = DialogResponse.POSITIVE Then
		clearList
	End If
End Sub

Sub clearList
	Dim kvsSql As SQL
	Dim sql As String
	
	kvsSql.Initialize(Starter.irp_dbFolder, "settings", False)
	sql = "DELETE FROM main WHERE key LIKE ?"
	
	kvsSql.ExecNonQuery2(sql,  Array As Object("store_song_%"))
	Msgbox("List cleared", Starter.vAppname)

	kvsSql.Close
	genDb.clearTable("stored_songs")
	CallSubDelayed(player, "showHideStoredSongs")
	
	Activity.Finish
End Sub

Sub getStations
	Dim curs As Cursor = genDb.getStoredSongsFromDb
	Dim store As List
	Dim artist, station, key As String
	Dim date As String
	
	DateTime.DateFormat =  DateTime.DeviceDefaultDateFormat
	
	clvStoredSongs.Clear
	
	For i = 0 To curs.RowCount-1
		curs.Position = i
		store.Initialize
		
		artist	= curs.GetString("artist")
		station	= curs.GetString("station")
		date	= $"$DateTime{curs.GetDouble("stored_date")}"$
		key		= curs.GetString("song_id")
		
		Dim logo As Bitmap = Starter.clsFunc.BytesToImage(curs.GetBlob("station_logo"))
		Dim album As Bitmap = Starter.clsFunc.BytesToImage(curs.GetBlob("album_art"))
		
		clvStoredSongs.Add(createPanels(artist.Trim, station.Trim, date, key, logo, album), "")
	Next
	
	
	
End Sub


Sub createPanels (artist As String, station As String, date As String, key As String, logopath As Bitmap, album As Bitmap) As Panel
	Dim p As Panel
	p.Initialize("")
	
	p.SetLayout(0,0, clvStoredSongs.AsView.Width, 225dip)
	p.LoadLayout("stores_song_detail")
	sb.Initialize
	
	lbl_artist.Text		= sb.Append("Artist : ").Append(TAB).Append(artist)
	sb.Initialize
	lbl_station.Text	= sb.Append("Station : ").Append(TAB).Append(station)
	sb.Initialize
	lbl_date.Text	= sb.Append("Date : ").Append(TAB).Append(date)
	lbl_delete.Background = xml.GetDrawable("ic_delete_forever_black_24dp")
	lbl_delete.Tag	= key

	imgRoundedCorners(logopath, iv_logo)
	imgRoundedCorners(album, iv_album)
	Return p
End Sub

Sub lbl_delete_Click
	Dim lbl As Label = Sender
	Dim index As String
	
	Dim result As Int
	
	result = Msgbox2("Delete selected song", Starter.vAppname, "Yes", "", "No", Null)
	If result = DialogResponse.POSITIVE Then
		index	= clvStoredSongs.GetItemFromView(lbl) 
		deleteSelectedSong(lbl.Tag)
		genDb.deleteStoredSong(lbl.Tag)
		clvStoredSongs.RemoveAt(index)
		If clvStoredSongs.Size >0 Then
			clvStoredSongs.ScrollToItem(0)
		End If
		CallSub(player, "showHideStoredSongs")
	End If
	
End Sub

Sub deleteSelectedSong(key As String)
	Dim kvsSql As SQL
	Dim sql As String
	
	sql = "DELETE FROM main WHERE key = ?"
	kvsSql.Initialize(Starter.irp_dbFolder, "settings", False)
	kvsSql.ExecNonQuery2(sql,  Array As String(key))
End Sub


Sub imgRoundedCorners(bm As Bitmap, view As ImageView)
	Dim rsie As RSImageEffects
	Dim rsip As RSImageProcessing
	Dim bmScale As Bitmap
		
	rsip.Initialize
	
	bmScale = rsip.createScaledBitmap(bm, bm.width, bm.height, False)
	view.Bitmap = rsie.RoundCorner(bmScale, 16)
	
End Sub


Sub iv_logo_Click
	
End Sub