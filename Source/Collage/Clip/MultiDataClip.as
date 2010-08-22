package Collage.Clip
{
	import mx.events.PropertyChangeEvent;
	import Collage.DataEngine.*;
	import Collage.Application.*;
	import flash.utils.*;
	import Collage.Clip.Skins.*;
	import Collage.Clip.DataClipWizard.*;
	import Collage.Utilities.Logger.*;
	
	public class MultiDataClip extends Clip
	{
		[Bindable]public var queryDefinitions:ArrayList() = new ArrayList();
		[Bindable]public var queries:ArrayList() = new ArrayList();
		
		public function MultiDataClip(_clipViewSkin:Class, _clipEditorSkin:Class, _smallClipEditorSkin:Class = null):void
		{
			super(_clipViewSkin, _clipEditorSkin, _smallClipEditorSkin);
		}
		
		protected override function ModelChanged(event:PropertyChangeEvent):void
		{
			switch( event.property )
			{
				case "":
					return;
			}

			super.ModelChanged(event);
		}
	}
}
