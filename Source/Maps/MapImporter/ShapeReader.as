package Maps.MapImporter
{
	import Collage.Utilities.Logger.*;
	import Maps.Map.*;

	import mx.collections.ArrayList;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;

	import org.vanrijkom.dbf.*;
	import org.vanrijkom.shp.*;
	
	public class ShapeReader
	{
		public var dbfFileName:String;
		public var dbfHead:DbfHeader;
		public var dbfBytes:ByteArray;
		
		public var shpFileName:String;
		public var shpHead:ShpHeader;
		public var shpRecords:Array;   
		
		public var minX:Number = Number.POSITIVE_INFINITY;
		public var maxX:Number = Number.NEGATIVE_INFINITY;
		public var minY:Number = Number.POSITIVE_INFINITY;
		public var maxY:Number = Number.NEGATIVE_INFINITY;
		public var rangeX:Number = 1;
		public var rangeY:Number = 1;
		public var aspectRatio:Number = 1;
		
		public var mapView:MapView;
		
		public function ShapeReader():void
		{
		}
		
		public function LoadSHPBytes(byteArray:ByteArray):void
		{
			// we must create a shape header first!
			shpHead = new ShpHeader(byteArray);
			// Logger.Log(ShpTools.readRecords(byteArray));	
			shpRecords = ShpTools.readRecords(byteArray);
		}
		
		public function LoadDBFBytes(byteArray:ByteArray):void
		{
			dbfHead = new DbfHeader(byteArray);
			dbfBytes = byteArray;
		}
		
		public function Reset():void
		{
			minX = Number.POSITIVE_INFINITY;
			maxX = Number.NEGATIVE_INFINITY;
			minY = Number.POSITIVE_INFINITY;
			maxY = Number.NEGATIVE_INFINITY;
		}
		
		public function RunImporter():void
		{
			if (!mapView)
				return;
			
			FindBounds();
			BuildMapView();
			mapView.Resize();
		}
		
		protected function BuildMapView():void
		{
			for each (var rec:ShpRecord in shpRecords) {
				if (rec.shapeType == ShpType.SHAPE_POLYGON) {
					var poly:ShpPolygon = rec.shape as ShpPolygon;

					// accessing dbf information using the record index, decreased by one
					var dbfRec:DbfRecord = DbfTools.getRecord(dbfBytes, dbfHead, rec.number-1);
					var meta:Dictionary = dbfRec.values;

					var namesArray:Array = [meta.ISO_3_CODE, meta.ISO_2_CODE, meta.NAME];
					var pathString:String = "";

					for (var ring:uint = 0; ring < poly.rings.length; ring++) {
						for (var coord:uint = 0; coord < poly.rings[ring].length; coord ++) {
							var xCoord:Number = ((poly.rings[ring][coord].x - minX) / rangeX) * 10000;
							var yCoord:Number = (1 - ((poly.rings[ring][coord].y - minY) / rangeY)) * (10000 / aspectRatio);

							if (coord == 0) {
								pathString += "M " + xCoord + " " + yCoord + " "; 
							} else {
								pathString += "L " + xCoord + " " + yCoord + " "; 
							}
						}
						pathString += "Z ";
					}
					mapView.addObjectPath(pathString, meta.NAME, null);
				}
			}
		} 
		
		protected function FindBounds():void
		{
			var ring:uint = 0;
			var coord:uint = 0;

			for each (var rec:ShpRecord in shpRecords) {
				if (rec.shapeType == ShpType.SHAPE_POLYGON) {
					var poly:ShpPolygon = rec.shape as ShpPolygon;
					for (ring = 0; ring < poly.rings.length; ring++) {
						for (coord = 0; coord < poly.rings[ring].length; coord ++) {
							minX = Math.min(minX, poly.rings[ring][coord].x);
			                maxX = Math.max(maxX, poly.rings[ring][coord].x);
			                minY = Math.min(minY, poly.rings[ring][coord].y);
			                maxY = Math.max(maxY, poly.rings[ring][coord].y);
						}
					}
				}
			}

			rangeX = maxX - minX;
			rangeY = maxY - minY;
			if (!rangeX) rangeX = 1;
			if (!rangeY) rangeY = 1;
			aspectRatio = rangeX / rangeY;
			mapView.aspectRatio = aspectRatio;
		}
	}
}