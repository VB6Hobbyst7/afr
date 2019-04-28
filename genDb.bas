B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.3
@EndOfDesignText@
#IgnoreWarnings: 9, 1, 10
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

	'Public CallSub(Starter, "getDbPath") As String =  'File.DirDefaultExternal
	Public vDbName As String = "rdodb.db"
	
	Private vSql As SQL
	Private vCurs As Cursor
	Public myPanelIndex As Int
End Sub


Private Sub initDB
	Dim db_path As String = CallSub(Starter, "getDbPath")
	Try
		If vSql.IsInitialized = False Then
		vSql.Initialize(db_path, vDbName, False)
	End If
	Catch
		Log(LastException)
	End Try
	
End Sub



Public Sub getStationCount As Int
	Dim vQuery As String
	
	initDB
	vQuery	= "SELECT * FROM rdolist"
	vCurs	= vSql.ExecQuery(vQuery)
	
	Return vCurs.RowCount
End Sub


Public Sub getSubscribedStations As Cursor
	Dim vQry	As String
	Dim vCurs	As Cursor
	initDB
	vQry	= "SELECT * FROM preflist ORDER BY stname ASC"
	vCurs	=  vSql.ExecQuery(vQry)
	Return vCurs
End Sub

Public Sub vacuumDB
	initDB
	vSql.ExecNonQuery("VACUUM")
End Sub


Public Sub clearTable(table As String)
	Dim vQry As String
	initDB
	
	vQry = $"delete from ${table}"$
	vSql.ExecNonQuery(vQry)
End Sub


Public Sub deleteStoredSong(key As String)
	Dim vQry As String
	
	initDB
	
	vQry = "DELETE FROM stored_songs WHERE song_id = ?"
	vSql.ExecNonQuery2(vQry, Array As String(key))
End Sub

Public Sub addSongToStoredSongs (vArtist As String, vSong As String, vStation As String, vDate As Long, vStationLogo As Bitmap, vAlbumArt As Bitmap)
	Dim vQry As String
	initDB
	
	vQry	= "INSERT INTO stored_songs (artist, song, station, stored_date, station_logo, album_art) VALUES (?, ?, ?, ?, ?, ?)"
	
	vSql.ExecNonQuery2(vQry, Array As Object(vArtist, vSong, vStation, vDate, Starter.clsFunc.ImageToBytes(vStationLogo), Starter.clsFunc.ImageToBytes(vAlbumArt)))
End Sub

Public Sub getStoredSongsFromDb As Cursor
	Dim vQry As String
	Dim curs As Cursor
	
	initDB
	
	vQry = "SELECT * FROM stored_songs"
	curs = vSql.ExecQuery(vQry)
	
	Return curs
End Sub

Public Sub countStoredSong As Int
	Dim vQry As String
	Dim count As Int
	initDB
	
	vQry = "select count(*) as tel from stored_songs"
	Dim curs As Cursor	= vSql.ExecQuery(vQry)
	curs.Position = 0
	count = curs.GetInt("tel")
	curs.Close
	Return count
End Sub

Public Sub genUpdateTable
	Dim qry As String
	initDB
	qry = $"CREATE TABLE IF NOT EXISTS stUpdate 
		(stupdate_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		stname TEXT,
		description TEXT,
		genre TEXT,
		country TEXT,
		language TEXT,
		stream1 TEXT,
		stream2 TEXT,
		stream3 TEXT,
		stream4 TEXT,
		stream5 TEXT,
		stream6 TEXT)"$
	vSql.ExecNonQuery(qry)
	
	vacuumDB
End Sub

Public Sub genStoredSongTable
	Dim vQry As String
	initDB
	
	vQry = $"CREATE TABLE IF NOT EXISTS stored_songs (song_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
													  artist TEXT, 
													  song TEXT, 
													  station TEXT, 
													  stored_date REAL, 
													  station_logo BLOB, 
													  album_art BLOB)"$
													  
	
	vSql.ExecNonQuery(vQry)
	vQry = "select count(*) as tel from stored_songs"
	Dim curs As Cursor	= vSql.ExecQuery(vQry)
	curs.Position = 0
	curs.Close
End Sub

Sub getCountryBookmark As String
	Dim vQry As String
	Dim vCurs As Cursor
		
	initDB
	
	vQry	= "SELECT * FROM params WHERE param_name=?"
	vCurs	= vSql.ExecQuery2(vQry, Array As String("bookmark_country"))
	If vCurs.RowCount <> 0 Then
		vCurs.Position = 0
		Return vCurs.GetString("param_value")
	Else
		Return ""
	End If
End Sub

Sub setBookmark(vParamname As String, vParamvalue As String)
	Dim vQry As String
	Dim vBookmark As String
	
	vBookmark	= getCountryBookmark
		
	initDB
	If vBookmark <> "" Then
		vQry	= "UPDATE params SET param_name = ? WHERE param_value = ?"
	Else
		vQry	= "INSERT INTO params (param_name, param_value) VALUES (?, ?)"
	End If
	
	vSql.ExecNonQuery2(vQry, Array As String(vParamname, vParamvalue))
	
	vSql.Close	
End Sub


Sub deleteDefCountry
	Dim vQry As String
	
	initDB
	vQry	= "DELETE FROM params WHERE param_name=?"
	vSql.ExecNonQuery2(vQry, Array As String("bookmark_country"))
	
	
End Sub

'Sub deleteCountryList
'	Dim vQry As String
'	
'	initDB
'	vQry	= "DELETE FROM country"
'	vSql.ExecNonQuery(vQry)
'	
'	
'End Sub

Sub getStationIdByName(vStation As String) As String
	Dim vQry As String
	Dim vCurs As Cursor
	
	initDB
	vQry	= "SELECT pref_id FROM preflist WHERE stname = ?"
	
	vCurs	= vSql.ExecQuery2(vQry, Array As String(vStation))
	If vCurs.RowCount > 0 Then
		vCurs.Position	= 0
		Return vCurs.GetString("pref_id")
	Else
		Return "null"
	End If
End Sub


Sub getSearchStation(vStation As String, vUseCountry As String, genre As String) As Cursor
	Dim vQry As String
	Dim vCurs As Cursor
	If genre = "" Then
		genre = "%"
	Else 
		genre = $"%${genre}%"$	
	End If
	initDB
	
	
	vQry	= "SELECT * FROM rdolist WHERE stname LIKE ? AND country = ? and genre like ? COLLATE NOCASE ORDER BY stname ASC"
	
	vCurs	= vSql.ExecQuery2(vQry, Array As String(vStation, vUseCountry, genre))
	
	Return vCurs
End Sub

Sub checkStationInPresets (vStationId As String, vStreamUrl As String) As Boolean
	Dim vQry As String
	Dim vCurs As Cursor
	
	initDB
	vQry	= "SELECT * FROM preflist WHERE rdo_id = ? AND stream1 = ?"
	
	vCurs	= vSql.ExecQuery2(vQry, Array As String(vStationId, vStreamUrl))
	If vCurs.RowCount > 0 Then
		Return False
	End If
	
	Return True
End Sub


Sub checkStationInPresetsNew (vStationId As String) As Boolean
	Dim vQry As String
	Dim vCurs As Cursor
	
	initDB
	vQry	= "SELECT * FROM preflist WHERE rdo_id = ?"
	
	vCurs	= vSql.ExecQuery2(vQry, Array As String(vStationId))
	If vCurs.RowCount > 0 Then
		Return False
	End If
	
	Return True
End Sub

Sub getPresetStations As Cursor
	Dim vQry As String
	Dim vCurs As Cursor
		
	initDB
	vQry	= "SELECT * FROM preflist ORDER BY stname ASC"
	Try
		vCurs	=  vSql.ExecQuery(vQry)
	Catch
		Log(LastException.Message)
	End Try
	Return vCurs
End Sub

Sub removePreset(vId As String)
	Dim vQry As String
	Dim vCurs As Cursor
		
	initDB
	vQry	= "DELETE FROM preflist WHERE pref_id=?"
	vSql.ExecNonQuery2(vQry, Array As String(vId))
	vSql.Close
End Sub

Sub getStationNameFromPreflist(vId As String) As String
	Dim vQry As String
	Dim vCurs As Cursor
		
	initDB
	vQry	= "SELECT stname FROM preflist WHERE pref_id=?"
	vCurs	= vSql.ExecQuery2(vQry, Array As String(vId))
	
	vCurs.Position = 0
	Return vCurs.GetString("stname")
End Sub


public Sub addStationToPreset(setStname As String, setDescription As String, setGenre As String, setCountry As String, setLanguage As String, setUrl As String, stationId As String)' As String
	Dim vQry, vQryAdd As String
	Dim vCurs As Cursor
		
	initDB
	
	vQryAdd	= "INSERT INTO preflist (stname, description, genre, country, language, stream1, rdo_id) VALUES (?,?,?,?,?,?,?)"
	vSql.ExecNonQuery2(vQryAdd, Array As String(setStname, setDescription,setGenre, setCountry, setLanguage, setUrl, stationId))
	
	vQry	= "SELECT pref_id FROM preflist ORDER BY pref_id DESC LIMIT 1"
	vCurs	= vSql.ExecQuery(vQry)
	vCurs.Position = 0
	'Return vCurs.GetString("pref_id")
End Sub


Sub writeStationImgPath(id As String, path As String)
	Dim vQry As String
			
	initDB
	vQry = "UPDATE preflist SET img_path = ? where pref_id=?"
	vSql.ExecNonQuery2(vQry, Array As String(id, path))
	
End Sub


Sub checkStationLogo(vId As String) As Boolean
	Dim vQry As String
	Dim vCurs As Cursor
	Dim hasImg As Int
		
	initDB
	vQry	= "SELECT COUNT(pref_id) as hasimg FROM preflist WHERE pref_id=? AND img_path IS NOT NULL;"
	vCurs	= vSql.ExecQuery2(vQry, Array As String(vId))
	vCurs.Position	= 0
	
	hasImg	= vCurs.GetInt("hasimg")
	
	
	If hasImg > 0 Then
		Return False
	Else
		Return True	
	End If
	
End Sub


Sub getStationRecord(stationName As String, column As String) As String
	Dim vQry As String
	Dim curs As Cursor
	
	initDB
	vQry	= "SELECT * FROM preflist WHERE stname=?"
	curs	= vSql.ExecQuery2(vQry, Array As String(stationName))
	
	curs.Position = 0
	If curs.RowCount < 1 Then
		Return ""
	Else
		Return curs.GetString(column)
	End If
	
End Sub

Sub getStationUrl(stationName As String) As String
	Dim vQry, stationUrl As String
	Dim curs As Cursor
	
	initDB
	vQry	= "SELECT station_url FROM preflist WHERE stname=?"
	curs	= vSql.ExecQuery2(vQry, Array As String(stationName))
	
	If curs.RowCount >= 0 Then
		curs.Position = 0
		Return curs.GetString("station_url")
	Else
		Return "nourl"	
	End If
	
End Sub

Sub setStationUrl(url As String, id As String)
	Dim vQry As String
			
	initDB
	vQry = "UPDATE preflist SET station_url = ? where pref_id=?"
	vSql.ExecNonQuery2(vQry, Array As String(url, id))
End Sub

Sub updateStationGenre
	Dim vQry As String
	initDB
	vQry = "UPDATE preflist SET genre = ? WHERE pref_id = ?"
	vSql.ExecNonQuery2(vQry, Array As String(Starter.currStationGerne, Starter.currStationId))
	
End Sub

Sub getStationLogoPathOnId(id As String) As String
	Dim vQry As String
	Dim curs As Cursor
	
	initDB
	vQry	= "SELECT img_path FROM preflist WHERE pref_id=?"
	curs	= vSql.ExecQuery2(vQry, Array As String(id))
	curs.Position = 0
	Return curs.GetString("img_path")
End Sub


Public Sub getStoredSongCount As Int
	Dim kvsSql As SQL
	Dim curs As Cursor
	Dim sql As String
	Dim count As String
	
	sql = "SELECT count(key) as count FROM main WHERE key LIKE ?"
	kvsSql.Initialize(Starter.irp_dbFolder, "settings", False)
	curs = kvsSql.ExecQuery2(sql,  Array As String("store_song_%"))
	
	curs.Position = 0
	count	= curs.GetInt("count")
	kvsSql.Close
	
	Return count
End Sub



Public Sub countryTableExists As Boolean
	initDB
	Dim table As String = "country"
	Dim cur As Cursor
	cur = vSql.ExecQuery("SELECT name FROM sqlite_master WHERE type='table' AND name = '" & table & "'")
	
	If cur.RowCount = 1 Then
		Return False
	End If
	
	Dim sql As String = $"CREATE TABLE IF NOT EXISTS country (country_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
													  country TEXT,
													  station_count INTEGER)"$
													  
	Dim sqlIndex As String = $"CREATE INDEX 'idx_country' ON 'country' ('country');"$
	
	vSql.ExecNonQuery(sql)
	vSql.ExecNonQuery(sqlIndex)
	Return True
	
End Sub

Public Sub tableExists(table As String) As Boolean
	initDB
	
	Dim cur As Cursor
	cur = vSql.ExecQuery("SELECT name FROM sqlite_master WHERE type='table' AND name = '" & table & "'")
	
	If cur.RowCount = 1 Then
		Return True
	End If
	
	Return False
	
End Sub


Public Sub getCountyByLetter(param As List) As Cursor
	initDB
		
	Dim cur As Cursor
	Dim qry As String = "SELECT country, station_count FROM rdolist WHERE (SUBSTR(country,1,1) = ? OR SUBSTR(country,1,1) = ?) ORDER BY country"
	qry = $"SELECT country AS country, count(*) AS total_stations FROM rdolist where country <> '-' AND (SUBSTR(country,1,1) = ? OR SUBSTR(country,1,1) = ?) GROUP BY country"$
	cur = vSql.ExecQuery2(qry, Array As String(param.Get(0),param.Get(1)))
	
	
	Return cur
End Sub

Public Sub dropTable(tableName As String)
	initDB
	Dim sql As String = $"DROP TABLE IF EXISTS ${tableName}"$
	
	vSql.ExecNonQuery(sql)
	vacuumDB
	vSql.Close
End Sub


Public Sub countRecords(tableName As String) As Int
	initDB
	Dim sql As String = $"select ifnull(count(*),0) as rec_count from ${tableName}"$
	
	Dim curs As Cursor = vSql.ExecQuery(sql)
	curs.Position = 0
	Return curs.GetInt("rec_count")	
End Sub


Public Sub truncateTable(tableName As String)
	initDB
	
	Dim sql As String = $"DELETE FROM ${tableName}"$
	vSql.ExecNonQuery(sql)
	vacuumDB
	Sleep(300)
End Sub

Public Sub getStationStream(stationId As String) As Cursor
	initDB
	Dim sql As String ="SELECT * FROM rdolist WHERE rdo_id = ?"
	
	Return vSql.ExecQuery2(sql, Array As String(stationId))
End Sub

Public Sub getStationForPreset(stationId As String) As Cursor
	initDB
	
	Dim sql As String = "SELECT stname, description, genre, country, language, rdo_id FROM rdolist WHERE rdo_id=?"
	
	Return vSql.ExecQuery2(sql, Array As String(stationId))
End Sub

Public Sub genrneCountry(country As String) As Cursor
	initDB
	Dim sql As String = $"select distinct genre from rdolist where
country = ? 
and genre <> '-' 
and genre <> '' 
and genre is NOT NULL 
order by genre"$
	
	Return vSql.ExecQuery2(sql, Array As String(country))
	
End Sub




