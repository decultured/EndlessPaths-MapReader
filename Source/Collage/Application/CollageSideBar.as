package Collage.Application
{
	import flash.events.*;
	import Collage.Utilities.Logger.*;
	import spark.components.SkinnableContainer;
	
	public class CollageSideBar extends SkinnableContainer
	{
		[SkinState("hidden")]
		[SkinState("extended")]

		[Bindable]public var appClass:CollageApp = null;

		[Bindable]private var _IsOpen:Boolean = false;
		public function get IsOpen():Boolean {return _IsOpen; }
		
		public function CollageSideBar()
		{
			super();
		}

		public function open():void {
			_IsOpen = true;
			invalidateSkinState();
		}
	
		public function close():void {
			_IsOpen = false;
			invalidateSkinState();
		}

		override protected function getCurrentSkinState():String {
			return (_IsOpen == true ? "extended" : "hidden");
		}
	}
}