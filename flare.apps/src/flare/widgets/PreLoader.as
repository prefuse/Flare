package flare.widgets
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	public class PreLoader extends MovieClip
	{
		private var _bar:ProgressBar;
		
		public function PreLoader()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// create progress bar
			addChild(_bar = new ProgressBar());
			_bar.bar.filters = [new DropShadowFilter(1)];
			_bar.x = (stage.stageWidth - _bar.width) / 2;
			_bar.y = (stage.stageHeight - _bar.height) / 2;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
            _bar.progress = percent;
            
            if (framesLoaded == totalFrames) {	
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                nextFrame();
                init();
            }
        }
        
        private function init():void
        {
        	var name:String = root.loaderInfo.parameters.appClass;
            if (name != null) {
            	var type:Class = Class(getDefinitionByName(name));
	            if (type) {
	                var app:App = new type() as App;
	                removeChild(_bar);
	                addChild(app);
	                return;
	            }
			}
			_bar.message.text = "FAILED";
        }
		
	} // end of class PreLoader
}