package Collage.DataEngine
{
	import Collage.Clip.*;
	import mx.collections.ArrayList;

	public class QueryDefinition
	{
		[Bindable]public var queryTitle:String = "";
		[Bindable]public var queryDescription:String = "";
		[Bindable]public var filtersAllowed:Boolean = true;
		[Bindable]public var minRowsReturned:Number = 1;
		[Bindable]public var maxRowsReturned:Number = 1000;
		[Bindable]public var sortable:Boolean = true;
		[Bindable]public var finalSortOnField:String = null;
		
		[Bindable]public var fieldDefinitions:ArrayList = new ArrayList();

		public function QueryDefinition():void
		{
		}
		
		public function AddFieldDefinition(_fieldDefinition:QueryFieldDefinition):void
		{
			fieldDefinitions.addItem(_fieldDefinition);
		}
	}
}