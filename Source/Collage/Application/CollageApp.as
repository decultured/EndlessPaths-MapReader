package Collage.Application
{
	import spark.components.SkinnableContainer;
	import spark.components.BorderContainer;
	import mx.events.PropertyChangeEvent;
	import spark.components.Group;
	import mx.events.FlexEvent;
	import mx.controls.Alert;
	import Collage.DataEngine.*;
	import Collage.Document.*;
	import Collage.Clip.*;
	import Collage.Clips.*;
	import flash.geom.*;
	import mx.core.*;
	import mx.graphics.*;
	import flash.events.*;
	import flash.desktop.*;
	import flash.display.*;
	import flash.utils.*;
	import Collage.Utilities.KeyCodes;
	import Collage.Utilities.Logger.*;
	import mx.events.ResizeEvent;
	import flash.events.KeyboardEvent;
	
	public class CollageApp extends CollageBaseApp
	{
		[Savable]public var FileFormatVersion:String="1.0";

		[Bindable]public static var instance:CollageApp = null;

		[SkinPart(required="true")]
		public var toolbar:Group;

		[SkinPart(required="true")]
		[Bindable]public var appGrid:Grid;

		[SkinPart(required="true")]
		public var appStatusBar:CollageStatusBar;

		[SkinPart(required="true")]
		public var popupOverlay:SkinnableContainer;

		[SkinPart(required="true")]
		public var welcomeScreen:SkinnableContainer;

		[SkinPart(required="true")]
		[Bindable]public var docContainer:BorderContainer;

		[SkinPart(required="true")]
		[Bindable]public var editPage:EditPage;

		[SkinPart(required="true")]
		[Bindable]public var editPageContainer:BorderContainer;
		
		[Bindable]public var zoom:Number = 1.0;
		[Bindable]public var fitToScreen:Boolean = false;

		[Bindable]public var pageManager:PageManager = new PageManager();

		[Bindable]public var statusBarVisible:Boolean = false;

		private var _CloudDocument:CloudDocument;

		protected var _PopupWindows:Object = new Object();
		protected var _PopupWindowContents:Object = new Object();

		public var clgClipboard:CollageClipboard;

		public function CollageApp():void
		{
			instance = this;
			Logger.LogDebug("App Created", this);
			clgClipboard = new CollageClipboard(this);
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, PropertyChangeHandler);
			pageManager.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, PageManagerChanged);
//			addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown, false, 0, true);
		}
		
		protected function OnKeyDown(event:KeyboardEvent):void {
			/*if(event.keyCode == KeyCodes.BACKSPACE || event.keyCode == KeyCodes.DELETE) {
				if(editPage.IsSelectedDeletable() == true) {
					editPage.DeleteSelected();
				}
			}*/
		}
		
		protected function PropertyChangeHandler(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "editPage":
					Logger.Log("Edit Page Added");
					editPage.LoadFromObject(pageManager.currentPage);
					return;
				case "docContainer":
					docContainer.removeEventListener(ResizeEvent.RESIZE, DocContainerResized);
					docContainer.addEventListener(ResizeEvent.RESIZE, DocContainerResized);
					return;
				case "fitToScreen":
					if (fitToScreen && docContainer)
						ZoomToSize(docContainer.width, docContainer.height);
					return;
			}
		}

		protected function PageManagerChanged(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "currentPageIndex":
					Logger.Log("Page Index Changed");
					SaveCurrentPage();
					editPage.LoadFromObject(pageManager.currentPage);
					return;
			}
		}

		protected function DocContainerResized(event:ResizeEvent):void
		{
			if (!fitToScreen)
				return;
				
			ZoomToSize(docContainer.width, docContainer.height);
		}

		public override function SaveCurrentPage():void
		{
			pageManager.SetPageByUID(editPage.SaveToObject(), editPage.UID);
		}

		public override function New():void
		{
			pageManager.New(true);
			editPage.LoadFromObject(pageManager.currentPage);
//			_CloudDocument.ID = null;
		}
		
		public override function Quit():void { }

		public override function Fullscreen():void
		{
		}

		public function Copy(event:Event):void
		{
		}

		public function Cut(event:Event):void
		{
		}

		public function Paste(event:Event):void
		{
		}
/*
		private function PopUp_Create(parent:DisplayObject, className:Class, modal:Boolean = false):IFlexDisplayObject {
			popupOverlay.visible = true;
			var popUp:IFlexDisplayObject = PopUpManager.createPopUp(parent, className, modal);
			popUp.visible = false;
			setTimeout(function():void {
				PopUp_Center(popUp);
				popUp.visible = true;
			}, 100);
			
			return popUp;
		}
		
		private function PopUp_Center(popUp:IFlexDisplayObject):void {
			return PopUpManager.centerPopUp(popUp);
		}
		
		private function PopUp_Destroy(popUp:IFlexDisplayObject):void {
			popupOverlay.visible = false;
			return PopUpManager.removePopUp(popUp);
		}
*/

		public function OpenViewer():void {
			
		}

		public override function OpenPopup(contents:UIComponent, name:String, modal:Boolean = true, size:Point = null):void
		{
			if (!size)
				size = new Point(500, 350);

			if (_PopupWindows['name']) {
				
			} else {
				
			}
		}

        public override function ClosePopup(name:String):void {
	
		}

		public override function ZoomOut():void
		{
			if (zoom > 0.1)
				zoom = zoom / 2.0;
			fitToScreen = false;
		}

		public override function ZoomIn():void
		{
			if (zoom < 4.0)
				zoom = zoom * 2.0;
			fitToScreen = false;
		}

		public override function ZoomToSize(newWidth:Number, newHeight:Number):void
		{
			if (!editPage || !editPage.height || !newHeight)
				return;
			
			var docAspectRatio:Number = editPage.width/editPage.height;
			var containerAspectRatio:Number = newWidth/newHeight;
			
			if (containerAspectRatio >= docAspectRatio) {
				// zoom by height
				zoom = newHeight / editPage.height;
			} else {
				// zoom by width
				zoom = newWidth / editPage.width;
			}
		}

		public override function Zoom(amount:Number):void
		{
			zoom = amount;
			fitToScreen = false;
		}

		public override function ResetZoom():void
		{
		}

		public override function SaveImage():void
		{
		}

		public override function SavePDF():void
		{
		}
		
		public override function SaveToCloud():void
		{
			if (!_CloudDocument)
				_CloudDocument = new CloudDocument(this);
			_CloudDocument.Save();
		}
		
		public override function OpenFromCloud(id:String = null):void
		{
			if (!_CloudDocument)
				_CloudDocument = new CloudDocument(this);
				
			if (id)
				_CloudDocument.OpenDashboardByID(id);
			else
				_CloudDocument.Open();
		}

		public override function SaveToObject():Object
		{
			// Load App Stuff
			var typeDef:XML = describeType(this);
			var newObject:Object = new Object();
			for each (var metadata:XML in typeDef..metadata) {
				if (metadata["@name"] != "Savable") continue;
				if (this.hasOwnProperty(metadata.parent()["@name"]))
					newObject[metadata.parent()["@name"]] = this[metadata.parent()["@name"]];
			}

			pageManager.currentPage = editPage.SaveToObject();

			// Load Pages
			newObject["pages"] = pageManager.pages.toArray();

			return newObject;
		}


		public override function LoadFromObject(dataObject:Object):Boolean
		{
			if (!dataObject) return false;

			New();
			
			Logger.Log("Document Loading", this);
			
			for (var key:String in dataObject)
			{
				if (key == "document") {
					for(var obj_k:String in dataObject[key]) {
						try {
							if(this.hasOwnProperty(obj_k))
								this[obj_k] = dataObject[obj_k];
						} catch(e:Error) { }
					}
				} else if (key == "pages") {
					if (!dataObject[key] is Array)
						continue;

					pageManager.LoadFromArray(dataObject[key]);
				}
			}
			
			editPage.LoadFromObject(pageManager.currentPage);
			dispatchEvent(new Event(PAGE_LOAD_COMPLETE));
			
			return true;
		}

		public override function OpenFile():void
		{
		}
		
		public override function SaveFile():void
		{
		}
		
		public override function UploadDataFile():void
		{
		}
	}	
}
