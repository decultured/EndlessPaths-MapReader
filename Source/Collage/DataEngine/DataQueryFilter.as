package Collage.DataEngine
{
	import Collage.Utilities.Logger.*;
	import mx.collections.ArrayList;
	import flash.utils.*;

	public class DataQueryFilter
	{
		[Savable][Bindable]public var isAnd:Boolean = true;

		[Savable][Bindable]public var columnID:String = null;
		[Savable][Bindable]public var columnType:String = "numeric";

		[Savable][Bindable]public var modifier:String = ">";

		[Savable][Bindable]public var value:String = null;
		
		public function DataQueryFilter():void
		{
		}
		
		public function SaveToObject():Object
		{
			var typeDef:XML = describeType(this);
			var newObject:Object = new Object();
			for each (var metadata:XML in typeDef..metadata) {
				if (metadata["@name"] != "Savable")
					continue;
				if (this.hasOwnProperty(metadata.parent()["@name"])) {
					newObject[metadata.parent()["@name"]] = this[metadata.parent()["@name"]];
				}
			}

			return newObject;
		}

		public function LoadFromObject(dataObject:Object):Boolean
		{
			if (!dataObject) return false;
			for(var obj_k:String in dataObject) {
				try {
					if(this.hasOwnProperty(obj_k)) {
						this[obj_k] = dataObject[obj_k];
					}
				} catch(e:Error) { }
			}
			return true;
		}
	}
}