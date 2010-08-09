package Maps.Map
{
	import Collage.Utilities.Logger.*;

	import spark.components.SkinnableContainer;
	import mx.collections.ArrayList;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;

	public class MapObject extends SkinnableContainer
	{
		public var path:String;
		public var names:Object = new Object();

		public var value:Number = 0;
		
		public function MapObject(pathString:String, namesArray:Array):void
		{
			path = pathString;
			names = namesArray;
		}
	}
}