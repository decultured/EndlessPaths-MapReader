package Collage.Application
{
	import flash.display.*;
	import mx.events.PropertyChangeEvent;
	import spark.primitives.supportClasses.*;
	
	public class Grid extends StrokedElement
	{
		[Bindable]public var xDensity:uint = 16;
		[Bindable]public var yDensity:uint = 16;
		[Bindable]public var xOffset:uint = 0;
		[Bindable]public var yOffset:uint = 0;
		[Bindable]public var gridColor:Number = 0x000000;
		[Bindable]public var gridAlpha:Number = 0.1;
		[Bindable]public var gridWeight:uint = 1;
		[Bindable]public var snap:Boolean = false;
		
		[Bindable]
		public function set density(_density:uint):void {xDensity = yDensity = _density;}
		public function get density():uint {return xDensity;}
		
		public function Grid():void
		{
			super();
			addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, ModelChange);
		}
	
		protected function ModelChange(event:PropertyChangeEvent):void
		{
			invalidateDisplayList();
		}
		
		protected override function draw(g:Graphics):void
		{
			if (!xDensity || !yDensity) {
				g.clear();
				return;
			}
			
			g.clear();
			g.lineStyle(gridWeight, gridColor, gridAlpha);
			
			for (var xPos:Number = xDensity; xPos < width; xPos += xDensity) {
		    	g.moveTo(xPos, 0); 
		    	g.lineTo(xPos, height); 
			}

			for (var yPos:Number = yDensity; yPos < height; yPos += yDensity) {
		    	g.moveTo(0, yPos); 
		    	g.lineTo(width, yPos); 
			}
		} 
		
	}	
}
