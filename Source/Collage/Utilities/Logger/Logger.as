package Collage.Utilities.Logger
{
	import mx.collections.ArrayCollection;
	import flash.utils.*;
	import flash.events.*;
	import mx.controls.Alert;
	
	public class Logger
	{
		public static var NEW_LOG_EVENT:String = "new log event";
		public static var events:EventDispatcher = new EventDispatcher();
		
		public static var logEntries:Array = new Array(); 
		public static var userID:String = "";
		public static var alerts:Boolean = false;
		public static var alertLevel:Number = LogEntry.ERROR;
		
		public static function Log(text:String, owner:Object = null, level:int = 100):LogEntry
		{
			var newLog:LogEntry = new LogEntry(text, level, getQualifiedClassName(owner), userID);
			logEntries.push(newLog);

			if (alerts && level >= alertLevel)
				Alert.show(newLog.toString());

			events.dispatchEvent(new Event(NEW_LOG_EVENT));
			return newLog;
		}

		public static function LogDebug(text:String, owner:Object = null):LogEntry
		{
			return Log(text, owner, LogEntry.DEBUG);
		}
		
		public static function LogWarning(text:String, owner:Object = null):LogEntry
		{
			return Log(text, owner, LogEntry.WARNING);
		}
		
		public static function LogError(text:String, owner:Object = null):LogEntry
		{
			return Log(text, owner, LogEntry.ERROR);
		}
		
		public static function LogCritical(text:String, owner:Object = null):LogEntry
		{
			return Log(text, owner, LogEntry.CRITICAL);
		}
		
		public static function LastLog():LogEntry
		{
			if (logEntries.length)
				return logEntries[logEntries.length - 1];
			else
				return null;
		}
		
		public static function toString():String
		{
			var output:String = "";
			for each (var entry:LogEntry in logEntries)
			{
				output += entry.toString() + "\n";
			}
			return output;
		}
	}
}