package Collage.Document
{
	import spark.components.Group;
	import Collage.Utilities.Logger.*;
	import Collage.Clip.*;
	import flash.utils.*;
	import mx.events.PropertyChangeEvent;
	import mx.utils.*;
	import mx.core.*;  
	
	public class Page extends Group
	{
		[Savable]public var UID:String;

		public static var DEFAULT_WIDTH:Number = 1280;
		public static var DEFAULT_HEIGHT:Number = 800;
		
		[Bindable][Savable]public var displayName:String = "UNNAMED";
		[Bindable][Savable]public var backgroundURL:String = null;
		[Bindable][Savable]public var backgroundColor:Number = 0xFFFFFF;
		[Bindable][Savable]public var pageHeight:Number = 1280;
		[Bindable][Savable]public var pageWidth:Number = 800;
		
		private var _Loading:Boolean = false;
		
		private var _Clips:Object = new Object();
		
		public function Page():void
		{
			New();
		}

		public function NewUID():void
		{
			UID = UIDUtil.createUID();
		}

		public function New():void
		{
			NewUID();
			pageWidth = DEFAULT_WIDTH;
			pageHeight = DEFAULT_HEIGHT;
			backgroundURL = null;
			backgroundColor = 0xffffff;
			DeleteAllClips();
			_Clips = new Object();
			Logger.LogDebug("Page Reset", this);
		}

		public function ViewResized():void
		{
			// TODO : Reposition all objects to fit in new size
		}

		public function AddClip(clip:Clip):Clip
		{
			if (clip && !_Clips[clip.UID]) {
				_Clips[clip.UID] = clip;
				addElement(clip.view);
				Logger.LogDebug("Clip Added", clip);
				return clip;
			}
			Logger.LogWarning("Problem Adding Clip", clip);
			return null;
		}

		public function AddClipByType(type:String):Clip
		{
			return AddClip(ClipFactory.CreateByType(type));
		}
		
		public function DeleteClip(clip:Clip):void
		{
			if (clip) {
				Logger.LogDebug("Clip Deleted", clip);
				_Clips[clip.UID] = null;
				removeElement(clip.view);
			}
		}
		
		public function DeleteAllClips():void
		{
			for (var i:int = numElements - 1; i > -1; i--) {
				if (getElementAt(i) is ClipView) {
					var clipView:ClipView = getElementAt(i) as ClipView;
					DeleteClip(clipView.model as Clip);
				}
			}
		}
		
		public function SaveToObject():Object
		{
			Logger.LogDebug("PageSaving : " + UID, this);
			
			var typeDef:XML = describeType(this);
			var newObject:Object = new Object();
			for each (var metadata:XML in typeDef..metadata) {
				if (metadata["@name"] != "Savable") continue;
				if (this.hasOwnProperty(metadata.parent()["@name"]))
					newObject[metadata.parent()["@name"]] = this[metadata.parent()["@name"]];
			}

			newObject["clips"] = new Array();

			for (var i:int = 0; i < numElements; i++) {
				if (getElementAt(i) is ClipView) {
					var clipView:ClipView = getElementAt(i) as ClipView;
					clipView.model.zindex = i;
					newObject["clips"].push(clipView.model.SaveToObject());
				}
			}

			return newObject;
		}

		public function LoadFromObject(dataObject:Object):Boolean
		{
			New();

			Logger.LogDebug("PageLoading : " + UID, this);
			
			if (!dataObject) {
				Logger.LogError("PageLoading - dataObject was NULL", this);
				return false;
			}

			for (var key:String in dataObject)
			{
				if (key == "clips") {
					if (!dataObject[key] is Array)
						continue;
					var clipArray:Array = dataObject[key] as Array;
					for (var i:uint = 0; i < clipArray.length; i++) {
						var clipDataObject:Object = clipArray[i] as Object;
						if (!clipDataObject["type"])
							continue;
						var newClip:Clip = AddClipByType(clipDataObject["type"]);
						if (newClip)
							newClip.LoadFromObject(clipDataObject);
					}
				} else {
					try {
						if(this.hasOwnProperty(key)) {
							this[key] = dataObject[key];
							dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, key, null, this[key]));
						}
					} catch(e:Error) {
						Logger.LogWarning("Key: " + key + " Not found for object: " + this, this); 
					}
				}
			}
			
			Logger.Log("Page Loaded: " + displayName + " Width: " + pageWidth + " Height: " + pageHeight, this);
			return true;
		}
	} 
}