package Maps.Application
{
	import spark.components.Group;
	import spark.components.TitleWindow;
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
	import Maps.MapImporter.*;
	import Collage.Clips.Map.*;
	import Collage.Application.*;
	import Collage.Utilities.Logger.*;
	import Collage.Utilities.json.*;

	
	public class AppMain extends CollageBaseApp
	{
		public var window:DisplayObject;
		public var shapeReader:ShapeReader = new ShapeReader();
		
		[Bindable]public static var instance:AppMain = null;

		[Bindable]public var mapClip:MapClip = new MapClip();
		
		protected var _PopupWindows:Object = new Object();
		protected var _PopupWindowContents:Object = new Object();

		[SkinPart(required="true")]
		public var toolbar:Group;

		public function AppMain():void
		{
			instance = this;
			addElement(mapClip.view);
		}
		
		public function SetToolbar():void {	
			toolbar.addElement(mapClip.CreateEditor());
		}
		
		public function RunImporter():void
		{

			shapeReader.mapClip = mapClip;
			shapeReader.RunImporter();
		}
		
        public override function OpenPopup(contents:UIComponent, name:String, modal:Boolean = true, size:Point = null):void {
 			var newWindow:CollagePopupWindow = null;

			if (!size)
				size = new Point(500, 350);
				
			if (_PopupWindows[name] && _PopupWindows[name] is CollagePopupWindow) {
				newWindow = _PopupWindows[name] as CollagePopupWindow;
				newWindow.removeAllElements();
				newWindow.addElement(contents);
			} 
			else if (_PopupWindows[name] && _PopupWindows[name] is TitleWindow) {
				super.OpenPopup(contents, name, modal);
				return;
			} else {
				newWindow = new CollagePopupWindow();
				newWindow.systemChrome = "none";
				newWindow.type = NativeWindowType.NORMAL;
				newWindow.resizable = false;
				newWindow.width = size.x;
	            newWindow.height = size.y;
				newWindow.transparent = true;
				newWindow.removeAllElements();
				newWindow.setStyle("skinClass", CollagePopupWindowSkin);
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
		
        public override function ClosePopup(name:String):void {
 			var newWindow:CollagePopupWindow = null;
			if (_PopupWindows[name] && _PopupWindows[name] is CollagePopupWindow) {
				newWindow = _PopupWindows[name] as CollagePopupWindow;
				newWindow.close();
				Logger.LogDebug("Closed Popup Window: " + name, this);
			} 
			else if (_PopupWindows[name] && _PopupWindows[name] is TitleWindow) {
				super.ClosePopup(name);
				return;
			}
        }
		
		public override function Quit():void
		{
			NativeApplication.nativeApplication.exit();	
		}
		
		public override function SaveFile():void
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
