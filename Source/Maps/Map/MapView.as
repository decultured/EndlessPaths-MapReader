package Maps.Map
{
	import Collage.Utilities.Logger.*;
	import Maps.Map.Skins.*;

	import spark.components.SkinnableContainer;
	import mx.events.PropertyChangeEvent;
	import mx.collections.ArrayList;
	import mx.graphics.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;

	public class MapView extends SkinnableContainer
	{
		[Bindable]public var objects:ArrayList = new ArrayList();

		[Bindable]public var backgroundColor:Number = 0x0072bc;
		[Bindable]public var backgroundAlpha:Number = 1.0;

		[Bindable]public var borderColor:Number = 0x534741;
		[Bindable]public var borderWeight:uint = 1;
		[Bindable]public var borderAlpha:Number = 1;

		[Bindable]public var fillColor:Number = 0xc69c6d;
		[Bindable]public var fillAlpha:Number = 1;
		
		[Bindable]public var aspectRatio:Number = 2;
		[Bindable]public var viewWidth:Number = 100;
		[Bindable]public var viewHeight:Number = 100;
		[Bindable]public var scaleAmount:Number = 0.5;
		
		[SkinPart(required="true")]
		[Bindable]public var polyBorderStroke:IStroke;

		public function MapView():void
		{
		}
	
		public function New():void
		{
			objects.removeAll();
			removeAllElements();
		}
		
		public function Resize():void
		{
			viewWidth = width;
			if (!aspectRatio)
				aspectRatio = 1;
			viewHeight = viewWidth / aspectRatio;
			
			if (width > 0)
				scaleAmount = width / 10000;
			else
				scaleAmount = 0.1;

			height = viewHeight;
			contentGroup.scaleX = scaleAmount;
			contentGroup.scaleY = scaleAmount;
			
			Logger.Log("Scale Changed! " + scaleAmount, this);
		}
		
		public function Process():void
		{
			
		}

		public function addObjectPath(pathString:String, displayName:String, namesArray:Array):void
		{
			var newObject:MapPolygon = new MapPolygon();

			newObject.polyBorderStroke = polyBorderStroke;
			newObject.pathData = pathString;
			newObject.percentWidth = 100;
			newObject.percentHeight = 100;
			
			if (displayName)
				displayName = displayName.replace(/^\s+|\s+$/g, '');
			else
				displayName = "Unknown";
			
			newObject.displayName = displayName;
			addElement(newObject);
		}
	}
}