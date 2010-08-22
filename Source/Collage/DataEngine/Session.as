package Collage.DataEngine
{
	import flash.net.*;
	import flash.events.*;
//	import flash.data.*;
	import flash.utils.ByteArray;
	import Collage.Utilities.Logger.*;
	import com.adobe.serialization.json.JSON;
	import com.adobe.crypto.*;
	
	public class Session extends EventDispatcher
	{
		public static var TOKEN_EXPIRED:String = "TokenExpired";
		public static var TOKEN_VALID:String = "TokenValid";
		
		public static var LOGIN_SUCCESS:String = "LoginSuccessful";
		public static var LOGIN_FAILURE:String = "LoginFailure";
		
		public static var COMPLETE:String = "complete";
		
		[Bindable] public static var AuthToken:String = null;

		public static var events:EventDispatcher = new EventDispatcher();
		
		public function Session():void
		{
			
		}
		
		public static function CheckToken():void {
			try {
				if(AuthToken == null) {
					events.dispatchEvent(new Event(TOKEN_EXPIRED));
					return;
				}
			
				var request:URLRequest = new URLRequest(DataEngine.getUrl("/api/v1/auth/check-token"));
				var loader:URLLoader = new URLLoader();
			
				var params:URLVariables = new URLVariables();
				params.aT = Session.AuthToken;
			
				request.data = params;
	            request.requestHeaders.push(new URLRequestHeader("X-Requested-With", "XMLHttpRequest"));
				request.method = URLRequestMethod.POST;
				loader.addEventListener(Event.COMPLETE, CheckToken_CompleteHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, CheckToken_ErrorHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, CheckToken_ErrorHandler);
			
				loader.load(request);
			} catch(error:Error) {
				Logger.LogError("Session Token Exception: "+ error);
			}
		}
		
		private static function CheckToken_CompleteHandler(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, CheckToken_CompleteHandler);
			var results:Object = JSON.decode(event.target.data);
			
			if(results.hasOwnProperty('valid')) {
				events.dispatchEvent(new Event(LOGIN_SUCCESS));
			} else {
				events.dispatchEvent(new Event(TOKEN_EXPIRED));
			}
		}
		
		private static function CheckToken_ErrorHandler(event:Event):void {
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, CheckToken_ErrorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, CheckToken_ErrorHandler);
			
			events.dispatchEvent(new Event(TOKEN_EXPIRED));
		}
		
		public static function Login(email_address:String, password:String):void {
			try {
				var request:URLRequest = new URLRequest(DataEngine.getUrl("/api/v1/auth/login"));
				var loader:URLLoader = new URLLoader();
			
				var params:URLVariables = new URLVariables();
				params.email_address = email_address;
				params.password = MD5.hash(password);
			
				request.data = params;
	            request.requestHeaders.push(new URLRequestHeader("X-Requested-With", "XMLHttpRequest"));
				request.method = URLRequestMethod.POST;
				loader.addEventListener(Event.COMPLETE, Login_CompleteHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Login_ErrorHandler);
				loader.addEventListener(IOErrorEvent.IO_ERROR, Login_ErrorHandler);
			
				loader.load(request);
			} catch(error:Error) {
				Logger.LogError("Login Exception: " + error);
			}
		}
		
		private static function Login_CompleteHandler(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, Login_CompleteHandler);
			var results:Object = JSON.decode(event.target.data);
			
			if(results.hasOwnProperty('aT')) {
				Session.AuthToken = results['aT'];
			}
			
			if(Session.AuthToken != null) {
				events.dispatchEvent(new Event(LOGIN_SUCCESS));
				Logger.LogDebug("Session Login Success: " + Session.AuthToken);
			} else {
				events.dispatchEvent(new Event(LOGIN_FAILURE));
				Logger.LogWarning("Session Login Failure");
			}
		}
		
		private static function Login_ErrorHandler(event:Event):void
		{
			Logger.LogError("Session Login Error: " + event);

			event.target.removeEventListener(IOErrorEvent.IO_ERROR, Login_ErrorHandler);
			event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, Login_ErrorHandler);
			
			events.dispatchEvent(new Event(TOKEN_EXPIRED));
			events.dispatchEvent(new Event(LOGIN_FAILURE));
		}
		
		public static function Logout():void {
			Logger.Log("Session Logout");
			AuthToken = null;
			events.dispatchEvent(new Event(TOKEN_EXPIRED));
		}
	}
}