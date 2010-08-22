package Collage.Clip
{
	import flash.events.Event;

	public class ClipEvent extends Event
	{
		public static const REMOVED_FROM_SELECTION:String = "removedFromSelection";
		
		public var targets:Array = [];
		
		public function SelectionEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}