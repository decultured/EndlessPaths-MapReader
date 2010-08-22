package Collage.Clip.DataClipWizard
{
	import spark.components.Group;
	import mx.events.PropertyChangeEvent;
	import Collage.DataEngine.*;
	import Collage.Clip.*;
	import flash.utils.*;
	
	public class DataClipWizardPage extends Group
	{
		public static var MOVE_ON_EVENT:String = "data_clip_wizard_completed_event";
		
		[Bindable]public var title:String = "Data Query Wizard";

		[Bindable]public var clip:Clip;
		[Bindable]public var query:DataQuery;
		[Bindable]public var queryDefinition:QueryDefinition;

		[Bindable]public var columnIndex:uint = 0;
		[Bindable]public var pageNumber:uint = 0;

		[Bindable]public var complete:Boolean = false;
		[Bindable]public var canSubmit:Boolean = false;
		
		public function DataClipWizardPage():void {
			
		}
		
		public function Reset():void {
			complete = false;
		}
		
		public function Save():void {
			
		}
		
		protected function FinishAndProceed():void {
			if (complete) {
				Save();
				dispatchEvent(new Event(MOVE_ON_EVENT));
			}
		}
	}
}
