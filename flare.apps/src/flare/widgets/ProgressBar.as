package flare.widgets
{
	import flare.display.TextSprite;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	public class ProgressBar extends Sprite
	{
		private var _backColor:uint;
		private var _fillColor:uint;
		private var _barWidth:Number;
		private var _barHeight:Number;
		private var _msg:TextSprite;
		
		private var _bar:Sprite;
		private var _back:Shape;
		private var _fill:Shape;
		private var _progress:Number = 0;
		
		public function get progress():Number { return _progress; }
		public function set progress(v:Number):void {
			v = isNaN(v) ? 0 : v;
			_progress = v;
			_fill.graphics.clear();
			_fill.graphics.beginFill(_fillColor);
			_fill.graphics.drawRoundRect(0, 0, v*_barWidth,
				_barHeight, _barHeight, _barHeight);
		}
		
		public function get bar():Sprite { return _bar; }
		public function get message():TextSprite { return _msg; }
		
		public function ProgressBar(message:String="LOADING", w:Number=200,
			h:Number=6, fillColor:uint=0xff3333, backColor:uint=0xcccccc)
		{
			_fillColor = fillColor;
			_backColor = backColor;
			_barWidth = w;
			_barHeight = h;
			
			addChild(_bar = new Sprite());
			addChild(_msg = new TextSprite(message));
			
			_bar.addChild(_back = new Shape());
			_bar.addChild(_fill = new Shape());
			
			_back.graphics.beginFill(_backColor);
			_back.graphics.drawRoundRect(0, 0, _barWidth,
				_barHeight, _barHeight, _barHeight);
			
			_msg.font = "Verdana";
			_msg.size = 18;
			_msg.color = _fillColor;
			_msg.letterSpacing = 2;
			_msg.y = 1.5 * _barHeight;
		}
		
		public function loadURL(ldr:URLLoader,
			onComplete:Function=null, onError:Function=null):URLLoader
		{
			var bar:ProgressBar = this;
			ldr.addEventListener(Event.COMPLETE, function(evt:Event):void {
            	this.progress = 1; // set progress bar to complete
            	var timer:Timer = new Timer(1000);
            	timer.addEventListener(TimerEvent.TIMER, function(e:Event):void
            	{
            		timer.stop(); timer = null;
            		try {
	            		if (onComplete!=null) onComplete();
	             	} catch (err:Error) {
	             		error(err); 
	             		return;
	             	}
            		// remove progress bar
            		if (parent) parent.removeChild(bar);
            	});
				timer.start();
            });
            ldr.addEventListener(ProgressEvent.PROGRESS,
            	function(evt:ProgressEvent):void {
            		bar.progress = evt.bytesLoaded / evt.bytesTotal;
            	}
            );
            var error:Function = function(e:Object=null):void {
            	bar.message.text = "FAILED";
            	trace(e.toString());
            	if (onError!=null) onError();
            };
            ldr.addEventListener(IOErrorEvent.IO_ERROR, error);
            ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error);
            return ldr;
		}
		
	} // end of class ProgressBar
}