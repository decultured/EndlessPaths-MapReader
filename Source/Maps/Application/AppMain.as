package Maps.Application
{
	import spark.components.SkinnableContainer;
	import mx.events.AIREvent;
	import mx.graphics.*;
	import mx.core.*;
	import flash.filesystem.*;
	import flash.display.*;
	import flash.desktop.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.net.*;

	import Maps.Map.*;
	import Maps.Map.Skins.*;
	import Collage.Utilities.Logger.*;
	import Collage.Utilities.json.*;

	import Maps.MapImporter.*;
	
	public class AppMain extends SkinnableContainer
	{
		public var window:DisplayObject;
		public var shapeReader:ShapeReader = new ShapeReader();

		[SkinPart(required="true")]
		[Bindable]public var mapView:MapView;
		
		protected var _PopupWindows:Object = new Object();
		protected var _PopupWindowContents:Object = new Object();

		public function AppMain():void
		{
		}
		
		public function RunImporter():void
		{
			shapeReader.mapView = mapView;
			shapeReader.RunImporter();
		}
		
		public function OpenPopup(contents:UIComponent, name:String, modal:Boolean = true, size:Point = null):void {
 			var newWindow:MapsPopupWindow = null;

			if (!size)
				size = new Point(500, 350);
				
			if (_PopupWindows[name] && _PopupWindows[name] is MapsPopupWindow) {
				newWindow = _PopupWindows[name] as MapsPopupWindow;
				newWindow.removeAllElements();
				newWindow.addElement(contents);
			} else {
				newWindow = new MapsPopupWindow();
				newWindow.systemChrome = "none";
				newWindow.type = NativeWindowType.NORMAL;
				newWindow.resizable = false;
				newWindow.width = size.x;
	            newWindow.height = size.y;
				newWindow.transparent = true;
				newWindow.removeAllElements();
				newWindow.setStyle("skinClass", MapsPopupWindowSkin);
				newWindow.addElement(contents);
				newWindow.addEventListener(Event.CLOSE, HandlePopUpClose);
				_PopupWindows[name] = newWindow;
				Logger.LogDebug("Added Popup Window: " + name, this);
			}

            try {
                newWindow.open(true);
            } catch (err:Error) {
                Logger.LogError("Problem Opening Popup Window: " + err, this);
            }
        }
        
		public function HandlePopUpClose(event:Event):void
		{
			for (var key:String in _PopupWindows) {
				if (_PopupWindows[key] == event.target)
					_PopupWindows[key] = null;
			}
		}
		
        public function ClosePopup(name:String):void {
 			var newWindow:MapsPopupWindow = null;
			if (_PopupWindows[name] && _PopupWindows[name] is MapsPopupWindow) {
				newWindow = _PopupWindows[name] as MapsPopupWindow;
				newWindow.close();
				Logger.LogDebug("Closed Popup Window: " + name, this);
			} 
        }
		
		public function Quit():void
		{
			NativeApplication.nativeApplication.exit();	
		}
		
		public function SaveFile():void
		{
			var file:File = File.desktopDirectory.resolvePath("file.clg");
			file.addEventListener(Event.SELECT, SaveFileEvent);
			file.browseForSave("Save As");
		}

		protected function SaveFileEvent(event:Event):void
		{
//			var jsonFile:String = JSON.encode(SaveToObject());
			var newFile:File = event.target as File;
			var fs:FileStream = new FileStream();
			try{
				fs.open(newFile,FileMode.WRITE);
//				jsonFile = jsonFile.replace(/\n/g, File.lineEnding);
//				fs.writeUTFBytes(jsonFile);
				fs.close();
				Logger.Log("File Saved: " + newFile.url, this);
			} catch(e:Error){
				Logger.Log(e.message, this);
			}
		}
		
		public function SaveLogFile():void
		{
			var file:File = File.desktopDirectory.resolvePath("file.txt");
			file.addEventListener(Event.SELECT, SaveLogFileEvent);
			file.browseForSave("Save Log As");
		}

		protected function SaveLogFileEvent(event:Event):void
		{
			var newFile:File = event.target as File;
			var fs:FileStream = new FileStream();
			try{
				fs.open(newFile,FileMode.WRITE);
				fs.writeUTFBytes(Logger.toString());
				fs.close();
				Logger.Log("File Saved: " + newFile.url, this);
			} catch(e:Error){
				Logger.Log(e.message, this);
			}
		}
		
		public function OpenSHPFile():void
		{
			var file:File = File.desktopDirectory;
			file.addEventListener(Event.SELECT, OpenSHPFileEvent);
			
			var filters:Array = new Array();
			filters.push( new FileFilter( "SHP Files", "*.shp" ) );
			file.browseForOpen("Open", filters);
		}

		protected function OpenSHPFileEvent(event:Event):void
		{
			OpenSHPFileObject(event.target as File);
		}

		public function OpenSHPFileObject(file:File):void
		{
			if (!file)
				return;

			var outBytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			try{
			    stream.open(file, FileMode.READ);
				stream.readBytes(outBytes, 0, stream.bytesAvailable);
				shapeReader.LoadSHPBytes(outBytes);
				Logger.Log("File Opened: " + file.url, this);
			} catch(e:Error){
				Logger.LogError("File Open Error: " + file.url, this);
			}
		}

		public function OpenDBFFile():void
		{
			var file:File = File.desktopDirectory;
			file.addEventListener(Event.SELECT, OpenDBFFileEvent);
			
			var filters:Array = new Array();
			filters.push( new FileFilter( "DBF Files", "*.dbf" ) );
			file.browseForOpen("Open", filters);
		}

		protected function OpenDBFFileEvent(event:Event):void
		{
			OpenDBFFileObject(event.target as File);
		}

		public function OpenDBFFileObject(file:File):void
		{
			if (!file)
				return;

			var outBytes:ByteArray = new ByteArray();
			var stream:FileStream = new FileStream();
			try{
			    stream.open(file, FileMode.READ);
				stream.readBytes(outBytes, 0, stream.bytesAvailable);
				shapeReader.LoadDBFBytes(outBytes);
				Logger.Log("File Opened: " + file.url, this);
			} catch(e:Error){
				Logger.LogError("File Open Error: " + file.url, this);
			}
		}

	}	
}
