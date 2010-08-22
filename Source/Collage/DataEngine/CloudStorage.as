package Collage.DataEngine
{
	import flash.net.*;
	import flash.events.*;
	import flash.utils.ByteArray;
	import mx.controls.Alert;
	import com.adobe.serialization.json.JSON;
	import com.adobe.crypto.*;
	import Collage.DataEngine.*;

	public class CloudStorage extends EventDispatcher
	{
		public static const DASHBOARD_OPEN_SUCCESS:String = "DashboardOpenSuccessful";
		public static const DASHBOARD_OPEN_FAILURE:String = "DashboardOpenFailure";

		public static const DASHBOARD_SAVE_SUCCESS:String = "DashboardSaveSuccessful";
		public static const DASHBOARD_SAVE_FAILURE:String = "DashboardSaveFailure";

		public static const DASHBOARD_ATTACHMENT_OPEN_SUCCESS:String = "DashboardImageOpenSuccessful";
		public static const DASHBOARD_ATTACHMENT_OPEN_FAILURE:String = "DashboardImageOpenFailure";

		public static const DASHBOARD_ATTACHMENT_SAVE_SUCCESS:String = "DashboardImageSaveSuccessful";
		public static const DASHBOARD_ATTACHMENT_SAVE_FAILURE:String = "DashboardImageSaveFailure";

		public static var events:EventDispatcher = new EventDispatcher();

		public static var dashboardsList:Array = null;

		public function CloudStorage():void
		{

		}

		public static function GetDashboardList():void {
			var request:URLRequest = new URLRequest(DataEngine.getUrl("/api/v1/storage/dashboard/list"));
			var loader:URLLoader = new URLLoader();

			var params:URLVariables = new URLVariables();
			params.aT = Session.AuthToken;

			request.data = params;
            request.requestHeaders.push(new URLRequestHeader("X-Requested-With", "XMLHttpRequest"));
			request.method = URLRequestMethod.POST;
			loader.addEventListener(Event.COMPLETE, GetDashboardList_CompleteHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, GetDashboardList_ErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, GetDashboardList_ErrorHandler);

			loader.load(request);
		}

		private static function GetDashboardList_CompleteHandler(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, GetDashboardList_CompleteHandler);
			var results:Object = JSON.decode(event.target.data);

			if(results.hasOwnProperty('success') && results['success'] == true) {
				dashboardsList = null;
				dashboardsList = results["dashboards"];
				events.dispatchEvent(new Event(DASHBOARD_SAVE_SUCCESS));
			} else {
				events.dispatchEvent(new Event(DASHBOARD_SAVE_FAILURE));
			}
		}

		private static function GetDashboardList_ErrorHandler(event:Event):void {
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, GetDashboardList_ErrorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, GetDashboardList_ErrorHandler);

			dashboardsList = null;

			events.dispatchEvent(new Event(DASHBOARD_SAVE_FAILURE));
		}
	}
}