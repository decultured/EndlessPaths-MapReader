package Collage.Utilities.Logger
{
	public class LogEntry
	{
		public static var DEBUG:int = 0;
		public static var INFO:int = 100;
		public static var WARNING:int = 200;
		public static var ERROR:int = 300;
		public static var CRITICAL:int = 400;

		public var text:String = "";
		public var className:String = "unknown";
		public var time:Date;
		// Levels : normal, error, warning, status
		public var level:int = 0;
		public var userID:String = "unknown";
		
		public function LogEntry(text:String, level:int=0, className:String = "unknown", userID:String = "unknown")
		{
			this.text = text;
			this.className = className;
			this.time = new Date();
			this.level = level;
			this.userID = userID;
		}
		
		public function toString():String
		{
			var levelString:String = "";
			switch (level)
			{
				case DEBUG: levelString = 		"DEBUG   "; break;
				case INFO: levelString = 		"INFO    "; break;
				case WARNING: levelString = 	"WARNING "; break;
				case ERROR: levelString = 		"ERROR   "; break;
				case CRITICAL: levelString = 	"CRITICAL"; break;
			}		
			
			var outString:String = userID + ":" + time.toLocaleString() + " # " + levelString + " # " + text;
			
			if (className != "null")
				outString += " at: " + className;
				
			return outString;
			
		}
	}
}