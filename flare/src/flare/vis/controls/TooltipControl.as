package flare.vis.controls
{
	import flare.animate.Tween;
	import flare.display.TextSprite;
	import flare.vis.Visualization;
	import flare.vis.events.TooltipEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	[Event(name="show", type="flare.vis.events.TooltipEvent")]
	[Event(name="hide", type="flare.vis.events.TooltipEvent")]
	[Event(name="update", type="flare.vis.events.TooltipEvent")]

	/**
	 * Interactive control for displaying a tooltip in response to mouse
	 * hovers exceeding a minimum time interval. By default, a 
	 * <code>flare.display.TextSprite</code> instance is used to show a
	 * tooltip. To change the tooltip text, clients can set either the
	 * <code>text</code> or <code>htmlText</code> properties of this
	 * <code>TextSprite</code>. For example:
	 * 
	 * <pre>
	 * // create a new tooltip control and set the text
	 * var ttc:TooltipControl = new TooltipControl();
	 * TextSprite(ttc.tooltip).text = "The tooltip text";
	 * </pre>
	 * 
	 * <p>Furthermore, this control fires events corresponding to tooltip show,
	 * update (move), and hide events. Listeners can be added to dynamically
	 * change the tooltip text when these events occur. Additionally, the
	 * default text tooltip can be replaced with an arbitrary
	 * <code>DisplyObject</code> to provide completely customized tooltips.</p>
	 * 
	 * @see flare.vis.events.TooltipEvent
	 * @see flare.display.TextSprite
	 */
	public class TooltipControl extends Control
	{		
		// ********************************************************************
		// Public Properties
		// ********************************************************************
		
		/** The tooltip delay, in milliseconds. */
		public function get showDelay():Number { return _showTimer.delay; }
		public function set showDelay(d:Number):void { _showTimer.delay = d; }
		
		/** The delay before hiding a tooltip, in milliseconds. */
		public function get hideDelay():Number { return _hideTimer.delay; }
		public function set hideDelay(d:Number):void { _hideTimer.delay = d; }
		
		/** The legal bounds for the tooltip in stage coordinates.
		 *  If null (the default), the full stage bounds are used. */
		public var tipBounds:Rectangle = null;
		
		/** The x-offset from the mouse at which to place the tooltip. */
		public var xOffset:Number = 0;
		/** The y-offset from the mouse at which to place the tooltip. */
		public var yOffset:Number = 25;
		
		/** The display object presented as a tooltip. */
		public var tooltip:DisplayObject = null;
		
		/** Duration of fade animations (in seconds) for tooltip show and hide.
		 *  If less than or equal to zero, no fade will be performed. */
		public var fadeDuration:Number = 0.3;
		
		/** Indicates if the tooltip should follow the mouse pointer. */
		public var followMouse:Boolean = true;
		
		/**
		 * After the hide, should the toolTip be removed from its parent? 
		 */		
		public var remove : Boolean = true;
		
		// ********************************************************************
		// Public Methods
		// ********************************************************************
		
		
		/**
		 * Constructor creates a new TooltipControl.
		 * 
		 * @param filter a Boolean-valued filter function indicating which visualization elements/items should receive tooltip handling
		 * @param tooltip DisplayObject that will render the tooltip GUI
		 *  
		 */
		public function TooltipControl(filter:*=null,
			tooltip:DisplayObject=null, show:Function=null,
			update:Function=null, hide:Function=null, delay:Number=500)
		{
			this.filter = filter;
			this.tooltip = tooltip ? tooltip : createDefaultTooltip();
			
			_showTimer = new Timer(delay);
			_hideTimer = new Timer(100);
			
			_showTimer.addEventListener(TimerEvent.TIMER, onShow);
			_hideTimer.addEventListener(TimerEvent.TIMER, onHide);

			if (show != null) 	addEventListener(TooltipEvent.SHOW, 	show);
			if (update != null) addEventListener(TooltipEvent.UPDATE, 	update);
			if (hide != null) 	addEventListener(TooltipEvent.HIDE, 	hide);
		}
		
		/**
		 * Generates a default TextSprite tooltip 
		 * @return a new default tooltip object
		 */
		public static function createDefaultTooltip():TextSprite
		{
			var fmt:TextFormat = new TextFormat("Arial", 14);
			
				fmt.leftMargin  = 2;
				fmt.rightMargin = 2;
			
			var tip:TextSprite  = new TextSprite("", fmt);
			
				tip.textField.border      	  = true;
				tip.textField.borderColor 	  = 0;
				tip.textField.background 	  = true;
				tip.textField.backgroundColor = 0xf5f5cc;
				tip.textField.multiline 	  = true;
				tip.filters 				  = [new DropShadowFilter(4,45,0,0.5)];
				
			return tip;
		}
		

		// ********************************************************************
		// Public Control setup methods
		// ********************************************************************
		
		/** @inheritDoc */
		public override function attach(viz:InteractiveObject):void
		{
			if (!(viz is DisplayObjectContainer)) {
				throw new Error("TooltipControls can only be " +
					"attached to DisplayObjectContainers.");
			}
			super.attach(viz);
			if (viz != null) {
				viz.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				viz.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			if (viz != null) {
				viz.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				viz.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			}
			return super.detach();
		}
		// ********************************************************************
		// Protecte Methods
		// ********************************************************************

		/**
		 * Calculates the tooltip layout.
		 * Note: this method assumes that the tooltip is a child of Stage
		 * 
		 * @param tip the tooltip object
		 * @param obj the currently moused-over object
		 */
		protected function layout(tip:DisplayObject, obj:DisplayObject):void
		{	
			validateTipParent();
			
			var s  : Stage 		= obj.stage;
			var b  : Rectangle 	= tipBounds ? tipBounds : getStageBounds(s);
			var tl : Point		= new Point(s.mouseX + xOffset,s.mouseY + yOffset);
			
				tip.x = tl.x;
				tip.y = tl.y;
				
			var r:Rectangle = tip.getBounds(s);
			
			if (r.width > b.width) 				tip.x = b.left;
			else if (r.left < b.left + 5) 		tip.x = s.mouseX + xOffset;
			else if (r.right > b.right - 5) 	tip.x = s.mouseX - 2 - r.width;
			
			
			if (r.height > b.height) 			tip.y = b.top;
			else if (r.top < b.top + 5) 		tip.y = s.mouseY - yOffset;
			else if (r.bottom > b.bottom - 5) 	tip.y = s.mouseY - 7 - r.height;
		}
		
		/** @private */
		protected function fireEvent(type:String):void
		{
			if (hasEventListener(type)) {
				dispatchEvent(new TooltipEvent(type, _cur, tooltip));
			}
		}
		
		/**
		 * If the "remove" flag is true, then clear any parent from toolTip
		 * If the toolTip does not have a parent, add it as a Stage child
		 */
		protected function validateTipParent():void {
			if (tooltip.parent && remove) tooltip.parent.removeChild(tooltip);
			
			if (tooltip.parent == null) viz.stage.addChild(tooltip);
		}
		
		
		// ********************************************************************
		// Protected Mouse EventHandlers
		// ********************************************************************
		
		protected function onMouseOver(evt:MouseEvent):void
		{
			var n:DisplayObject = evt.target as DisplayObject;
			if (n==null || (_filter!=null && !_filter(n))) return;
			
			_cur = n;
			if (_show) {
				_hideTimer.stop();
				onShow();
			} else {
				_showTimer.start();
			}
		}
		
		protected function onMouseMove(evt:MouseEvent):void
		{
			if (!followMouse) {
				viz.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				return;
			}
			fireEvent(TooltipEvent.UPDATE);
			layout(tooltip, _cur);
		}
		
		
		protected function onMouseOut(evt:MouseEvent):void
		{
			_showTimer.stop();
			if (_cur == null) return;
			viz.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			if (_show) _hideTimer.start();
		}
		

		// ********************************************************************
		// Protected Visibility Methods
		// ********************************************************************
		
		protected function onShow(evt:TimerEvent=null):void
		{
			if (_t && _t.running) _t.stop();
			if (!_cur || !_cur.stage) return;
			
			_showTimer.stop();
			_show = true;
			
			fireEvent(TooltipEvent.SHOW);
			
			if (_show == true) {
				layout(tooltip, _cur);
				
				if (fadeDuration <= 0) {
					immediateShow();
				} else {
					_t = new Tween(tooltip, fadeDuration, {alpha:1, visible:true});
					_t.play();
				}
				if (followMouse)
					viz.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		protected function onHide(evt:TimerEvent=null):void
		{
			_hideTimer.stop();
			fireEvent(TooltipEvent.HIDE);
			
			if (fadeDuration <= 0) {
				immediateHide();
			} else {
				_t = new Tween(tooltip, fadeDuration,
					{alpha: 0, visible: false}, remove);
				_t.play();
			}
			
			_show = false;
			_cur = null;
		}
		
		
		protected function immediateHide():void {
			tooltip.alpha = 0;
			tooltip.visible = false;
			
			if (tooltip.parent && remove)
				tooltip.parent.removeChild(tooltip);
		}
		
		protected function immediateShow():void {
			tooltip.alpha = 1;
			tooltip.visible = true;
			
			validateTipParent();
		}
		
		// ********************************************************************
		// Private Methods and Attributes
		// ********************************************************************
		
		protected function get viz():Visualization {
			return _object as Visualization;
		}
		
		protected var _show:Boolean = false;
		
		private var _cur:DisplayObject;
		
		private var _showTimer:Timer;
		private var _hideTimer:Timer;
		private var _t:Tween;
		
		
		protected static function getStageBounds(stage:Stage):Rectangle 
		{
			return new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		}
		
	} // end of class TooltipControl
}