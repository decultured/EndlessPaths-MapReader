package Collage.DataEngine.Storage
{
	import mx.controls.Alert;
	import flash.net.*;
	import flash.events.*;
	import com.adobe.serialization.json.JSON;
	import Collage.DataEngine.*;
	import Collage.Utilities.Logger.*;

	public class DashboardImage extends CloudFile
	{
		[Bindable]
		public var ID:String;
		public var URL:String;
		
		public function DashboardImage():void {
			this.addEventListener(OPEN_SUCCESS, Open_Success);
			this.addEventListener(SAVE_SUCCESS, Save_Success);
		}

		public function get Content():String {
			return this._Content;
		}

		public function set Content(content:String):void {
			if(typeof content == "object") {
				content = JSON.encode(content);
			}

			this._Content = content;
		}

		override protected function GetOpenUrl():String {
			return DataEngine.getUrl("/api/v1/storage/attachment/read");
		}

		override protected function GetSaveUrl():String {
			return DataEngine.getUrl("/api/v1/storage/attachment/write");
		}

		override protected function GenerateEnvelope():Object {
			return {
				'file_id': this.ID
			}
		}

		public function Open(fileId:String = null):void {
			if(fileId != null)
				this.ID = fileId;

			OpenFile();
		}

		public function Save(fileId:String = null):void {
			if(fileId != null)
				this.ID = fileId;

			SaveFile();
		}

		public function Open_Success(event:Event):void {
			Logger.Log("DashboardFile::Open_Success: " + event, this);

			if(lastResult != null) {
				if(lastResult.hasOwnProperty('id')) {
					this.ID = lastResult['id'];
				}
			}
		}

		public function Save_Success(event:Event):void {
			Logger.Log("DashboardFile::Save_Success: " + event, this);

			if(lastResult != null) {
				if(lastResult.hasOwnProperty('id')) {
					this.ID = lastResult['id'];
					this.URL = DataEngine.getUrl("/api/v1/storage/attachment/"+ this.ID +".png");
				}
			}
		}

		public function Save_Failure(event:Event):void {
			Logger.LogError("DashboardFile::Save_Failure: " + event, this);
		}
	}
}