B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.5
@EndOfDesignText@
Sub Class_Globals
	Private pnlMain As Panel
	Private pnlSlider As Panel
	Private pnlVolImage As Panel
	Private sb As SeekBar
	Private volLabel As Label
	Private ph As Phone
	Private volImage As ImageView
	Public pnlWidth As Int = 40
End Sub

Public Sub Initialize
	
	
End Sub

Public Sub setupMainVolumePanel As Panel
	pnlMain.Initialize("")
	pnlMain.Background = panelBorderTransparent
	
	pnlMain.Width		= 40dip
	pnlMain.Height		= 400dip
	pnlMain.Elevation	= 8dip
	
	pnlMain.AddView(createPanel, 0dip, 0dip, pnlSlider.Width, pnlSlider.Height)
	pnlMain.AddView(createVolImgPanel, 0dip, 352dip, 40dip, 40dip)
	Return pnlMain
End Sub

Public Sub createPanel As Panel
	
	pnlSlider.Initialize("")
	pnlSlider.Elevation = 4dip
	pnlSlider.Left 		= 20dip
	pnlSlider.Top 		= 30dip
	pnlSlider.Width 	= 40dip
	pnlSlider.Height	= 350dip
	
	pnlSlider.Background = panelBorder
	
	pnlSlider.AddView(createSeekbar, 0, pnlSlider.Height-30dip, pnlSlider.Height - 25dip, pnlWidth)
	pnlSlider.AddView(createVolLabel, 0, 0, pnlSlider.Width, 30dip)
	
	For Each v As B4XView In pnlSlider.GetAllViewsRecursive
		Starter.clsFunc.showLog(v.Tag, 0)
	Next
	pnlSlider.Visible = False
	Return pnlSlider
End Sub

Private Sub createSeekbar As SeekBar
	sb.Initialize("sb")
	sb.Tag		= "seekbar"
	sb.Width 	= 40dip'pnl.Height-10dip
	sb.Height	= 10dip'pnl.Width
	sb.Left		= 10dip'pnl.Left
	sb.Top		= 10dip'pnl.Height-sb.Width
	
	Dim xView As B4XView = sb
	xView.Rotation = -90
	
	sb.Max = getMaxMusicVolume
	sb.Value = getMusicVolume

	Return sb
End Sub

Private Sub sb_ValueChanged(value As Int, userchanged As Boolean)
	volLabel.Text	= value
	ph.SetVolume(ph.VOLUME_MUSIC, value, False)
End Sub

Private Sub createVolLabel As Label
	Dim dip As Int = 0
	volLabel.Initialize("")
	
	volLabel.Top	= dip
	volLabel.Left	= dip
	volLabel.Width	= dip
	
	volLabel.Gravity	= Gravity.CENTER_HORIZONTAL
	volLabel.Typeface	= Typeface.DEFAULT
	volLabel.TextSize	= 16
	volLabel.Tag		= "vollabel"
	volLabel.TextColor	= Colors.Black
	Return volLabel
End Sub

Public Sub createVolImgPanel As Panel
	pnlVolImage.Initialize("pnlVol")
	
	pnlVolImage.Background	= panelBorder
	pnlVolImage.Elevation	= 4dip
	pnlVolImage.AddView(createVolPanelImage, 5dip, 5dip, 30dip, 30dip)
	
	Return pnlVolImage
End Sub

Private Sub pnlVol_Click
	If pnlSlider.Visible = False Then
		pnlSlider.SetVisibleAnimated(0, True)
	Else
		pnlSlider.SetVisibleAnimated(0, False)
	End If
	
End Sub

Private Sub getMusicVolume As Int
	Return ph.GetVolume(ph.VOLUME_MUSIC)
End Sub

Private Sub getMaxMusicVolume As Int
	Return ph.GetMaxVolume(ph.VOLUME_MUSIC)
End Sub

Private Sub panelBorder As ColorDrawable
	Dim c As ColorDrawable
	c.Initialize2(Colors.White,4dip,1dip,0xFFEFECEC)
	
	Return c
End Sub

Private Sub panelBorderTransparent As ColorDrawable
	Dim c As ColorDrawable
	c.Initialize2(0x00FFFFFF,4dip,1dip,0x00FFFFFF)
	
	Return c
End Sub


Private Sub createVolPanelImage As ImageView
	volImage.Initialize("")
	
	volImage.Width	= 30dip
	volImage.Height	= 30dip
	setSvg(volImage, "show_volume.svg")
	
	Return volImage
End Sub

Private Sub setSvg(view As ImageView, svg As String)
	Dim tCanvas As Canvas
	tCanvas.Initialize(view)

	Dim svgGen As ioxSVG
	svgGen.Initialize(svg)
	svgGen.DocumentWidth = view.Width
	svgGen.DocumentHeight = view.Height
	svgGen.RenderToCanvas(tCanvas)
End Sub


