package Collage.Clip
{
	import spark.components.BorderContainer;
	import spark.components.SkinnableContainer;
	
	public class ClipBackground extends SkinnableContainer
	{
		[Bindable]public var model:Object;
		[Bindable]public var editing:Boolean = false;

		public function ClipBackground()
		{
			super();
		}
	}
}