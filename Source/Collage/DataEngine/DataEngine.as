package Collage.DataEngine
{
	import flash.net.*;
	import flash.events.*;
	import com.adobe.serialization.json.JSON;
	import mx.collections.*;
	import Collage.Utilities.Logger.*;
	
	public class DataEngine extends EventDispatcher
	{
		//public static var baseUrl:String = "http://dataengine.local/";
		public static var baseUrl:String = "http://dataengine.endlesspaths.com/";

		[Bindable]public static var modifierSelections:ArrayList = new ArrayList(
				[ {label:"Min", data:"min"},
				{label:"Max", data:"max"},
				{label:"Average", data:"avg"},
				{label:"Sum", data:"sum"},
				{label:"Count", data:"count"},
				{label:"Mode", data:"mode"}
				]);

		[Bindable]public static var datetimeGrouping:ArrayList = new ArrayList(
				[ {label:"None", data:"val"},
				{label:"Date", data:"date"},
				{label:"Year", data:"year"},
				{label:"Month", data:"month"},
				{label:"Day of Month", data:"day"},
				{label:"Hour", data:"hour"},
				]);

		[Bindable]public static var filterTypeSelections:ArrayList = new ArrayList(
				[ {label:"Equal To", data:"="},
				{label:"Not Equal To", data:"!="},
				{label:"Greater Than", data:">"},
				{label:"Greater or Equal To", data:">="},
				{label:"Less Than", data:"<"},
				{label:"Less or Equal To", data:"<="}
				]);

		[Bindable]public static var sortingSelections:ArrayList = new ArrayList(
				[ {label:"None", data:null},
				{label:"Descending", data:"desc"},
				{label:"Ascending", data:"asc"},
				]);

		public static var COMPLETE:String = "complete";
		
		[Bindable]public static var datasets:ArrayList = new ArrayList();
		public static var numDataSets:Number = 0;
		
		public static var events:EventDispatcher = new EventDispatcher();

		[Bindable]public static var loaded:Boolean = false;
		[Bindable]public static var loading:Boolean = false;

		public function DataEngine():void
		{
			
		}
		
		public static function getUrl(urlStr:String):String {
			if(urlStr.charAt(0) == '/') {
				urlStr = urlStr.substr(1, urlStr.length);
			}
			
			return baseUrl + urlStr;
		}
		
		public static function GetDataSetIndexByID(id:String):int
		{
			var foundDataSetIndex:int = -1;
			for (var dataSetIndex:uint = 0; dataSetIndex < datasets.length; dataSetIndex++) {
				var dataSet:DataSet = datasets.getItemAt(dataSetIndex) as DataSet;
				if (dataSet.id == id) {
					foundDataSetIndex = dataSetIndex;
					break;
				}
			}
			return foundDataSetIndex;
		}

		public static function GetDataSetByID(id:String):DataSet
		{
			var dataSetIndex:int = GetDataSetIndexByID(id);
			if (dataSetIndex > -1) {
				return datasets.getItemAt(dataSetIndex) as DataSet
			}
			
			Logger.LogWarning("Data Set ID Not Found: " + id);
			return null;
		}
		
		public static function get DataSetsLoaded():Boolean
		{
			for each (var dataSet:DataSet in datasets)
			{
				if (!dataSet.loaded)
					return false;
			}
			return true;
		}
		
		public static function LoadAllDataSets():void
		{
			// http://dataengine.local/api/v1/dataset/list
			
			loading = true;
			
			//Logger.Log("Loading All Available Datasets");

			var request:URLRequest = new URLRequest(DataEngine.getUrl("/api/v1/dataset/list"));
			var loader:URLLoader = new URLLoader();
			var params:URLVariables = new URLVariables();
			params.aT = Session.AuthToken;
			request.data = params;
			request.method = URLRequestMethod.GET;
			loader.addEventListener(Event.COMPLETE, CompleteHandler);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorHandler);
            loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, HttpStatusHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			
			loader.load(request);
		}
		
		private static function HttpStatusHandler(event:HTTPStatusEvent):void
		{
            event.target.removeEventListener(HTTPStatusEvent.HTTP_STATUS, HttpStatusHandler);
			//Logger.LogDebug("Data Engine HTTP Status: " + event);
		}
		
		private static function IOErrorHandler(event:IOErrorEvent):void
		{
            event.target.removeEventListener(IOErrorEvent.IO_ERROR, IOErrorHandler);
			Logger.LogError("Data Engine IO Error: " + event);
		}
		
        private static function SecurityErrorHandler(event:SecurityErrorEvent):void
		{
            event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, SecurityErrorHandler);
			Logger.LogError("Data Engine Security Error: " + event);
        }

		private static function CompleteHandler(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, CompleteHandler);
			var results:Object = JSON.decode(event.target.data);

			for (var key:String in results)
			{
				if (!results[key]["id"])
					continue;
				
				var dataSetIndex:int = GetDataSetIndexByID(results[key]["id"]);
				var newDataSet:DataSet;
				
				if (dataSetIndex < 0) {
					newDataSet = new DataSet();
					datasets.addItem(newDataSet);
					numDataSets++;
				} else {
					newDataSet = datasets.getItemAt(dataSetIndex) as DataSet;
				}

				for (var dataSetKey:String in results[key]) {
					if (dataSetKey == "uploaded" || dataSetKey == "processed") {
						(results[key][dataSetKey] == "true") ? newDataSet[dataSetKey] = true : newDataSet[dataSetKey] = false;
					} else if (newDataSet.hasOwnProperty(dataSetKey)) {
						newDataSet[dataSetKey] = results[key][dataSetKey];
					}
				}
				
				newDataSet.addEventListener(DataSet.COMPLETE, DataSetFinishedLoading);
				newDataSet.LoadColumns();
				//Logger.LogDebug("Data Set Loading: " + results[key]["id"]);
			}
			Logger.LogDebug("Data Engine Load Complete");
		}
		
		public static function DataSetFinishedLoading(event:Event):void
		{
			if (DataSetsLoaded) {
				events.dispatchEvent(new Event(COMPLETE));
				loading = false;
				loaded = true;
			}
		}
	}
}