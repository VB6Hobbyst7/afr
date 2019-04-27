B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9
@EndOfDesignText@
#Extends: android.support.v7.app.AppCompatActivity
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private toolbar As ACToolBarDark
	Private ScrollView1 As ScrollView
	Private ACSwitch1 As ACSwitch
	Private ACActionMenu1 As ACActionMenu
	Private ACSubmenu1 As ACSubMenu
	Private ACButton3 As ACButton
	Private Panel6 As Panel
	Private ACSpinner1 As ACSpinner
	Private ACSpinner2 As ACSpinner

	Private sv As ACSearchView
	Private si As ACMenuItem
End Sub

'Inline Java code to initialize the Menu
#If Java
	public boolean _onCreateOptionsMenu(android.view.Menu menu) {
		if (processBA.subExists("activity_createmenu")) {
			processBA.raiseEvent2(null, true, "activity_createmenu", false, new de.amberhome.objects.appcompat.ACMenuWrapper(menu));
			return true;
		}
		else
			return false;
	}
#End If


Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	Activity.LoadLayout("test")
	ACSpinner1.AddAll(Array As String ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))
	ACSpinner2.AddAll(Array As String ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))

	'Ad some Action Menu items
	ACActionMenu1.Menu.Add(1, 1, "Menu1", Null)
	ACSubmenu1 = ACActionMenu1.Menu.AddSubMenu(1, 2, 2, "Submenu")
	ACSubmenu1.Add(101, 1, "Submenu Item 1", Null)
	ACSubmenu1.Add(102, 2, "Submenu Item 2", Null)
	ACActionMenu1.Menu.Add(3, 3, "MenuItem 2", Null)

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


'This is the Sub called by the inline Java code to initialize the Menu
Sub Activity_CreateMenu(Menu As ACMenu)
	sv.Initialize2("Search", sv.THEME_DARK)
	sv.IconifiedByDefault = True

	'Clear the menu
	Menu.Clear
	
	'Add a menu item and assign the SearchView to it
	si = Menu.Add2(1, 1, "Search", Null)
	si.SearchView = sv
End Sub