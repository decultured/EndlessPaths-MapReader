package Collage.DataEngine
{
	import mx.collections.ArrayList;
	import flash.net.*;
	import flash.events.*;
	import Collage.Utilities.Logger.*;
	import com.adobe.serialization.json.JSON;

	public class DataSet extends EventDispatcher
	{
		public static var COMPLETE:String = "complete";

		[Bindable] public var loaded:Boolean = false;
		[Bindable] public var loading:Boolean = false;

		[Bindable] public var id:String = "";
		[Bindable] public var title:String = "";

		[Bindable] public var totalRows:Number = 0;

		[Bindable] public var uploaded:Boolean = false;
		[Bindable] public var processed:Boolean = false;

		[Bindable] public var created:String = "";
		[Bindable] public var changed:String = "";
		[Bindable] public var accessed:String = "";
		
		[Bindable] public var columns:ArrayList = new ArrayList();

		public function DataSet():void
		{
			
		}

		public function GetColumnByID(id:String):DataSetColumn
		{
			for (var i:int = 0; i < columns.length; i++)
			{
				if (columns.getItemAt(i) && columns.getItemAt(i).internalLabel == id)
					return columns.getItemAt(i) as DataSetColumn;
			}
			return null;
		}

		public function GetColumnByLabel(label:String):DataSetColumn
		{
			for (var i:int = 0; i < columns.length; i++)
			{
				if (columns.getItemAt(i) && columns.getItemAt(i).label == label)
					return columns.getItemAt(i) as DataSetColumn;
			}
			return null;
		}

		public function GetNumColumnsOfType(allowedTypes:Array = null):uint
		{
			var columnsFound:uint = 0;
			for (var i:int = 0; i < columns.length; i++) {
				if (allowedTypes) {
					var typeFound:Boolean = false;
					for each (var type:String in allowedTypes) {
						if (type == columns.getItemAt(i).datatype) {
							typeFound = true;
							break;
						}
					}
					if (!typeFound)
						continue;
				} 
				columnsFound++;
			}
			return columnsFound;
		}

		public function LoadColumns():void
		{
			loading = true;

			if (!id || id.length < 5)
				return;
			
			var request:URLRequest = new URLRequest(DataEngine.getUrl("/api/v1/dataset/" + id + "/metadata"));
			var loader:URLLoader = new URLLoader();
			var params:URLVariables = new URLVariables();
			params.aT = Session.AuthToken;
			request.data = params;
			request.method = URLRequestMethod.GET;
			loader.addEventListener(Event.COMPLETE, CompleteHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			
			loader.load(request);
		}
		
		private function IOErrorHandler(event:IOErrorEvent):void
		{
            event.target.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			Logger.LogError("ioErrorHandler: " + event);
		}
		
        private function SecurityErrorHandler(event:SecurityErrorEvent):void
		{
            event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorHandler);
            Logger.LogError("securityErrorHandler: " + event);
        }

		private function CompleteHandler(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, CompleteHandler);
			var results:Object = JSON.decode(event.target.data);
			
			for (var key:String in results)
			{
				if (key == "total_rows") {
					totalRows = parseInt(results[key]);
				} else if (key == "columns") {
					for (var columnKey:String in results[key]) {
						if (!results[key][columnKey]["internal"])
							continue;
						var newColumn:DataSetColumn = GetColumnByID(results[key][columnKey]["internal"]);
						if (!newColumn) {
							newColumn = new DataSetColumn();
							columns.addItem(newColumn);
						}

						for (var columnDataKey:String in results[key][columnKey])
						{
							if (columnDataKey == "internal")
								newColumn.internalLabel = results[key][columnKey][columnDataKey];
							else if (columnDataKey == "label")
								newColumn.label = results[key][columnKey][columnDataKey];
							else if (columnDataKey == "index")
								newColumn.index = results[key][columnKey][columnDataKey];
							else if (columnDataKey == "datatype")
								newColumn.datatype = results[key][columnKey][columnDataKey];
						}
					}
				}
			}
			
			loading = false;
			loaded = true;
			//Logger.LogDebug("Data Set Loaded: " + id + " Rows: " + totalRows + " " + title, this);
			dispatchEvent(new Event(COMPLETE));
		}

	}
}