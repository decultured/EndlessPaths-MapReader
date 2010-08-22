package Maps.Application
{
	import flash.system.*;
	import flash.ui.*;
	import mx.events.*;
	import mx.controls.Alert;
	import mx.controls.FlexNativeMenu;
	import Collage.Utilities.Logger.*;
	
	public class MapsMenu extends FlexNativeMenu
	{
		public var menuData:XML = <root>
	            <menuitem label="MapReader">
	                <menuitem label="About" command="about" enabled="false"/>
					<menuitem type="separator"/>
					<menuitem label="Logout" command="logout" />
	                <menuitem label="Quit" command="quit" key="q"/>
	            </menuitem>
	            <menuitem label="File">
	                <menuitem label="New" command="new" key="n"/>
	                <menuitem label="Open SHP File..." command="openshp" key="1" />
	                <menuitem label="Open DBF File..." command="opendbf" key="2" />
	                <menuitem label="Run Importer" command="run" key="3" />
	                <menuitem type="separator"/>
	                <menuitem label="Save Collage Output File..." command="save" />
	                <menuitem type="separator"/>
	                <menuitem label="Save Debug Log File..." command="savelog" key="l" />
					<menuitem type="separator"/>
	            </menuitem>
	        </root>;

		public var mapsApp:AppMain = null;
		
		public function MapsMenu():void
		{
			dataProvider = menuData;
			keyEquivalentModifiersFunction = StandardOSModifier;
			addEventListener(FlexNativeMenuEvent.ITEM_CLICK, menuItemClicked);
			addEventListener(FlexNativeMenuEvent.MENU_SHOW, menuShow);
		}
		
		private function menuShow(menuEvent:FlexNativeMenuEvent):void
		{
		}

		private function StandardOSModifier(item:Object):Array{
			var modifiers:Array = new Array();
			if((Capabilities.os.indexOf("Windows") >= 0)){
				modifiers.push(Keyboard.CONTROL);
			} else if (Capabilities.os.indexOf("Mac OS") >= 0){
				modifiers.push(Keyboard.COMMAND);
			}
			return modifiers;
		}


		private function menuItemClicked(menuEvent:FlexNativeMenuEvent):void
		{
			if (!mapsApp) {
				return;
			}

			var command:String = menuEvent.item.@command;
			switch(command){
				case "quit":		mapsApp.Quit(); break;
				case "about":		break;
				case "openshp":		mapsApp.OpenSHPFile();	break;
				case "opendbf":		mapsApp.OpenDBFFile();	break;
				case "run":			mapsApp.RunImporter();	break;
				case "new": 		mapsApp.mapClip.New(); mapsApp.shapeReader.Reset(); break;
				case "save":		mapsApp.SaveFile();	break;
				case "savelog":		mapsApp.SaveLogFile();	break;
				default:
					Logger.LogWarning("Unrecognized Menu Command: " + command + "  " + menuEvent.item.@label);
			}
		}		
	}
}