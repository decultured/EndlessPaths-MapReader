package Collage.Clip
{
	import spark.components.SkinnableContainer;
	
	public class ClipEditor extends SkinnableContainer
	{
		[Bindable]public var model:Object;
		
		public function ClipEditor(_model:Clip, _clipEditorSkin:Class)
		{
			super();
			model = _model;
			setStyle("skinClass", _clipEditorSkin);
		}
	}
}