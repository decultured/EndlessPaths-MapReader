package Collage.Document
{
	import spark.components.SkinnableContainer;
	
	public class EditPageToolbar extends SkinnableContainer
	{
		[Bindable]public var model:Object;
		
		public function EditPageToolbar(_model:EditPage, _editPageToolbarSkin:Class)
		{
			super();
			model = _model;
			setStyle("skinClass", _editPageToolbarSkin);
		}
	}
}