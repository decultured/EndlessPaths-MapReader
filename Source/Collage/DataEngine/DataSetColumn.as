package Collage.DataEngine
{
	public class DataSetColumn
	{
		//[{"label": "My Field", "internal": "field_0", "type": "string"}]
		
		public var label:String;
		public var internalLabel:String;
		public var index:String;

		// The "type" paramter can be: string, numeric, datetime, boolean, or url
		public var datatype:String;
		
		public function DataSetColumn():void
		{
		}
	}
}