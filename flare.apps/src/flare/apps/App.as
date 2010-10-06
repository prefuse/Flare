package flare.apps
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class App extends Sprite
	{
		protected var _appBounds:Rectangle;
		
		public function App()
		{
			addEventListener(Event.ADDED_TO_STAGE, onStageAdd);
		}
		
		private function onStageAdd(evt:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onStageAdd);
			initStage();
			init();
			onResize();
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function onResize(evt:Event=null):void
		{
			_appBounds = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			resize(_appBounds.clone());
		}
		
		protected function initStage():void
		{
			if (!stage) {
				throw new Error(
					"Can't initialize Stage -- not yet added to stage");
			}
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		protected function init():void
		{
			
		}
		
		public function resize(bounds:Rectangle):void
		{
			
		}
		
	} // end of class App
}