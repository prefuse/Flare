package flare.vis.controls
{
	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="select",   type="flare.vis.events.SelectionEvent")]
	[Event(name="deselect", type="flare.vis.events.SelectionEvent")]
	
	/**
	 * Interactive control for responding to mouse clicks events. Select event
	 * listeners can be added to respond to the mouse clicks. This control
	 * also allows the number of mouse-clicks (single, double, triple, etc) and
	 * maximum delay time between clicks to be configured.
	 * @see flare.vis.events.SelectionEvent
	 */
	public class ClickControl extends Control
	{
		private var _timer:Timer;
		private var _cur:DisplayObject;
		private var _clicks:uint = 0;
		private var _clear:Boolean = false;
		private var _evt:MouseEvent = null;
		
		/** The number of clicks needed to trigger a click event. Setting this
		 *  value to zero effectively disables the click control. */
		public var numClicks:uint;
		
		/** The maximum allowed delay (in milliseconds) between clicks. 
		 *  The delay determines the maximum time interval between a
		 *  mouse up event and a subsequent mouse down event. */
		public function get clickDelay():Number { return _timer.delay; }
		public function set clickDelay(d:Number):void { _timer.delay = d; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ClickControl.
		 * @param filter a Boolean-valued filter function indicating which
		 *  items should trigger hover processing
		 * @param numClicks the number of clicks
		 * @param onClick an optional SelectionEvent listener for click events
		 */
		public function ClickControl(filter:*=null, numClicks:uint=1,
			onClick:Function=null, onClear:Function=null)
		{
			this.filter = filter;
			this.numClicks = numClicks;
			_timer = new Timer(150);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			if (onClick != null)
				addEventListener(SelectionEvent.SELECT, onClick);
			if (onClear != null)
				addEventListener(SelectionEvent.DESELECT, onClear);
		}
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj==null) { detach(); return; }
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(MouseEvent.CLICK, onClick);
				obj.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (_object != null) {
				_object.removeEventListener(MouseEvent.CLICK, onClick);
				_object.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}
			return super.detach();
		}
		
		// -----------------------------------------------------
		
		private function onDown(evt:MouseEvent):void
		{
			_timer.stop();
		}
		
		private function onClick(evt:MouseEvent):void
		{
			var n:DisplayObject = evt.target as DisplayObject;
			if (n==null || (_filter!=null && !_filter(n))) {
				_clicks++;
				_clear = true;
			} else if (_cur != n) {
				_clear = false;
				_clicks = 1;
				_cur = n;
			} else {
				_clicks++;
			}
			_evt = evt;
			_timer.start();
		}
		
		private function onTimer(evt:Event=null):void
		{
			if (_clicks == numClicks && _cur) {
				var type:String = _clear ? SelectionEvent.DESELECT 
				                         : SelectionEvent.SELECT;
				if (hasEventListener(type))
					dispatchEvent(new SelectionEvent(type, _cur, _evt));
				if (_clear) _cur = null;
			}
			_timer.stop();
			_clicks = 0;
			_evt = null;
			_clear = false;
		}
		
	} // end of class ClickControl
}