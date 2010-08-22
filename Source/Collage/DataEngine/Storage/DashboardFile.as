package Collage.DataEngine.Storage
{
	import mx.controls.Alert;
	import flash.net.*;
	import flash.events.*;
	import com.adobe.serialization.json.JSON;
	import Collage.DataEngine.*;
	import Collage.Utilities.Logger.*;

	public class DashboardFile extends CloudFile
	{
		public var ID:String;
		public var Title:String;
		
		public var Attachments:Array;
		
		public function DashboardFile():void {
			this.Attachments = new Array();
			
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
			return DataEngine.getUrl("/api/v1/storage/dashboard/read");
		}

		override protected function GetSaveUrl():String {
			return DataEngine.getUrl("/api/v1/storage/dashboard/write");
		}

		override protected function GenerateEnvelope():Object {
			var attachmentIDs:Array = new Array();
			
			if(this.Attachments != null && this.Attachments.length > 0) {
				for each(var attach:DashboardImage in this.Attachments) {
					attachmentIDs.push( attach.ID );
				}
			}
			
			return {
				'file_id': this.ID,
				'title': this.Title
			}
		}

		public function Open(fileId:String = null):void {
			if(fileId != null)
				this.ID = fileId;
				
			Logger.LogDebug("ID: " + this.ID, this);

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

				if(lastResult.hasOwnProperty('title')) {
					this.Title = lastResult['title'];
				}
			}
		}

		public function Save_Success(event:Event):void {
			Logger.Log("DashboardFile::Save_Success: " + event, this);

			if(lastResult != null) {
				if(lastResult.hasOwnProperty('id')) {
					this.ID = lastResult['id'];
				}
			}
		}

		public function Save_Failure(event:Event):void {
			this.ID = null;
			Logger.LogError("DashboardFile::Save_Failure: " + event, this);
		}
	}
}