package Collage.DataEngine
{
	import Collage.Utilities.json.*;
	import mx.graphics.ImageSnapshot;
	import Collage.Application.*;
	import Collage.DataEngine.*;
	import Collage.DataEngine.Storage.*;
	import Collage.Utilities.Logger.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class CloudDocument
	{
		public static var SAVE_TO_CLOUD_WINDOW:String = "saveToCloud";
		public static var OPEN_FROM_CLOUD_WINDOW:String = "openFromCloud";
		
		private var _SaveWindow:DashboardSaveUI;
		private var _OpenWindow:DashboardListUI;

		// cloud dashboard file
		private var _Dashboard:DashboardFile;
		private var _DashboardImages:Array;

		private var _AppClass:CollageBaseApp;

		public function CloudDocument(appClass:CollageBaseApp)
		{
			_AppClass = appClass;
		}

		public function Save():void {
			_SaveWindow = new DashboardSaveUI();
			_AppClass.OpenPopup(_SaveWindow, SAVE_TO_CLOUD_WINDOW, true, new Point(300, 150));
			_SaveWindow.addEventListener(DashboardSaveUI.CLOSED, SaveWindowClosed);
			_SaveWindow.addEventListener(DashboardSaveUI.COMPLETE, SaveWindowComplete);
	
			if(_Dashboard != null) {
				if(_Dashboard.Title != null) {
					_SaveWindow.Title = _Dashboard.Title;
				}
				if(_Dashboard.ID != null) {
					_SaveWindow.dispatchEvent(new Event(DashboardSaveUI.COMPLETE));
					_SaveWindow.dispatchEvent(new Event(DashboardSaveUI.CLOSED));
				}
			}
		}

		public function SaveWindowClosed(e:Event):void {
			_AppClass.ClosePopup(SAVE_TO_CLOUD_WINDOW);
		}

		public function SaveWindowComplete(e:Event):void
		{
			var jsonFile:String = JSON.encode(_AppClass.SaveToObject());

			if(_Dashboard == null) {
				_Dashboard = new DashboardFile();
				_Dashboard.addEventListener(CloudFile.SAVE_SUCCESS, HandleSaveSuccess)
				_Dashboard.addEventListener(CloudFile.SAVE_FAILURE, HandleSaveFailure)
			}

			_Dashboard.Title = _SaveWindow.Title;
			_Dashboard.Content = jsonFile;
			_Dashboard.Attachments = _DashboardImages;

			if (_AppClass is CollageApp) {
				var snapshot:ImageSnapshot = ImageSnapshot.captureImage((_AppClass as CollageApp).editPageContainer);
				_Dashboard.Filedata = snapshot.data;
			}

			try{
				Logger.Log("Saving to cloud", this);
				_Dashboard.Save();
			} catch(e:Error){
				Logger.LogError(e.message, this);
			}
			
			_AppClass.ClosePopup(SAVE_TO_CLOUD_WINDOW);
		}

		public function HandleSaveSuccess(event:Event):void {
			Logger.Log("Saved to cloud", this);
		}

		public function HandleSaveFailure(event:Event):void {
			Logger.LogError("Failure saving to cloud", this);
			if (_Dashboard)
				_Dashboard.ID = null;
		}
		
		public function Open():void {
			_OpenWindow = new DashboardListUI();
			_AppClass.OpenPopup(_OpenWindow, OPEN_FROM_CLOUD_WINDOW, true, new Point(450, 350));
			_OpenWindow.addEventListener(DashboardSaveUI.CLOSED, OpenWindowClosed);
			_OpenWindow.addEventListener(DashboardSaveUI.COMPLETE, OpenWindowComplete);
		}

		public function OpenWindowClosed(e:Event):void {
			_AppClass.ClosePopup( OPEN_FROM_CLOUD_WINDOW );
			_OpenWindow = null;
		}

		public function OpenWindowComplete(e:Event):void
		{
			_Dashboard = null;
			_Dashboard = new DashboardFile();
			_Dashboard.addEventListener(CloudFile.OPEN_SUCCESS, HandleOpenSuccess)
			_Dashboard.addEventListener(CloudFile.OPEN_FAILURE, HandleOpenFailure)

			try{
				Logger.Log("Opening from cloud - id: " + _OpenWindow.DashboardID, this);
				_Dashboard.Open( _OpenWindow.DashboardID );
			} catch(e:Error){
				Logger.LogError(e.message, this);
			}
		}

		public function OpenDashboardByID(id:String):void
		{
			_Dashboard = null;
			_Dashboard = new DashboardFile();
			_Dashboard.addEventListener(CloudFile.OPEN_SUCCESS, HandleOpenSuccess)
			_Dashboard.addEventListener(CloudFile.OPEN_FAILURE, HandleOpenFailure)

			try{
				Logger.Log("Opening from cloud - id: " + id, this);
				_Dashboard.Open(id);
			} catch(e:Error){
				Logger.LogError(e.message, this);
			}
		}

		public function HandleOpenSuccess(event:Event):void {
			Logger.Log("Opened from cloud", this);

			var fileData:Object = JSON.decode( _Dashboard.Content );
		    _AppClass.LoadFromObject(fileData);
		}

		public function HandleOpenFailure(event:Event):void {
			Logger.LogError("Failure opening from cloud", this);
			if (_Dashboard)
				_Dashboard.ID = null;
		}
		
	}
}