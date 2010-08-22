package Collage.Clip
{
	import mx.events.PropertyChangeEvent;
	import Collage.DataEngine.*;
	import Collage.Application.*;
	import flash.utils.*;
	import Collage.Clip.Skins.*;
	import Collage.Clip.DataClipWizard.*;
	import Collage.Utilities.Logger.*;
	
	public class DataClip extends Clip
	{
		protected var _QueryDefinition:QueryDefinition;
		[Bindable]public var query:DataQuery = new DataQuery();

        [Bindable][Savable]public var datasetID:String = null;
		[Bindable][Savable]public var datasetFields:Object = new Object();

 		public function DataClip(_clipViewSkin:Class, _clipEditorSkin:Class, _smallClipEditorSkin:Class = null):void
		{
			super(_clipViewSkin, _clipEditorSkin, _smallClipEditorSkin);
			_QueryDefinition = new QueryDefinition();
			query.addEventListener(DataQuery.FIELDS_CHANGED, QueryFieldsChangedHandler, false, 0, true);
			query.addEventListener(DataQuery.COMPLETE, QueryCompleteHandler, false, 0, true);
		}

		public function ClearFields():void
		{
			datasetFields = new Object;
		}
		
		public function SetField(internalName:String, fieldName:String):void
		{
			datasetFields[internalName] = fieldName;
		}

		protected function QueryCompleteHandler(event:Event):void
		{
			return;
		}
		
		protected function QueryFieldsChangedHandler(event:Event):void
		{
			for (var i:int = 0; i < query.fields.length; i++)
			{
				var field:DataQueryField = query.fields.getItemAt(i) as DataQueryField;
								
				if (!field || !field.internalName || !this.hasOwnProperty(field.internalName))
					continue;

				var oldVal:String = this[field.internalName];
				this[field.internalName] = field.resultName;
				dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, field.internalName, oldVal, this[field.internalName]));
			}
		}
		
		public override function Refresh():void {
			query.LoadQueryResults();
			Logger.LogDebug("Refresh, it works!", this);
		}

		protected override function ModelChanged(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "":
					return;
			}

			super.ModelChanged(event);
		}
		
		public function OpenDataWizard():void {
			var dataWizard:DataClipWizard = new DataClipWizard();
			dataWizard.clip = this;
			dataWizard.query = query;
			dataWizard.queryDefinition = _QueryDefinition;
			dataWizard.Reset();
			dataWizard.setStyle("top", "0");
			dataWizard.setStyle("bottom", "0");
			dataWizard.setStyle("left", "0");
			dataWizard.setStyle("right", "0");

			CollageApp.instance.OpenPopup(dataWizard, "datawizard");
		}
		
		public override function SaveToObject(onlyTheme:Boolean = false):Object
		{
			var typeDef:XML = describeType(this);
			var newObject:Object = new Object();
			for each (var metadata:XML in typeDef..metadata) {
				if (metadata["@name"] != "Savable")
					continue;
				if (onlyTheme) {
					var isTheme:Boolean = false;
					for each (var args:XML in metadata..arg) {
						if (args["@key"] == "theme" && args["@value"] == "true") {
							isTheme = true;
							break;
						}
					}
					if (!isTheme)
						continue;
				}
				if (this.hasOwnProperty(metadata.parent()["@name"])) {
					newObject[metadata.parent()["@name"]] = this[metadata.parent()["@name"]];
				}
			}
			newObject["query"] = query.SaveToObject();
			return newObject;
		}

		public override function LoadFromObject(dataObject:Object):Boolean
		{
			if (!dataObject) return false;

			for(var obj_k:String in dataObject) {
				try {
					if (obj_k == "query")
						query.LoadFromObject(dataObject[obj_k]);
					else if(this.hasOwnProperty(obj_k))
						this[obj_k] = dataObject[obj_k];
				} catch(e:Error) { }
			}
			
			Refresh();
			return true;
		}
	}
}
