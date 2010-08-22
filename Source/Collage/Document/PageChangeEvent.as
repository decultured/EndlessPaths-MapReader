package Collage.Document
{
	import flash.events.Event;

	public class PageChangeEvent extends Event
	{
		public static const PAGE_INDEX_CHANGED:String = "removedFromSelection";
		
		public var oldIndex:uint = 0;
		public var newIndex:uint = 0;
		
		public function PageChangeEvent(type:String, _oldIndex:uint, _newIndex:uint, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			oldIndex = _oldIndex;
			newIndex = _newIndex;

			super(type, bubbles, cancelable);
		}
	}
}