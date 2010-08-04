package flare.vis.controls
{
	import flare.vis.events.SelectionEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	[Event(name="select",   type="flare.vis.events.SelectionEvent")]
	[Event(name="deselect", type="flare.vis.events.SelectionEvent")]
	
	/**
	 * Interactive control for selecting a group of objects by "rubber-banding"
	 * them with a rectangular section region.
	 */
	public class SelectionControl extends Control
	{
		private var _r:Rectangle = new Rectangle();
		private var _drag:Boolean = false;
		private var _shape:Shape = new Shape();
		private var _hit:InteractiveObject;
		private var _stage:Stage;
		private var _sel:Dictionary = new Dictionary();
		
		private var _add0:DisplayObject = null;
		private var _rem0:DisplayObject = null;
		private var _add:Array = null;
		private var _rem:Array = null;
		
		/** The active hit area over which selection
		 *  interactions can be performed. */
		public function get hitArea():InteractiveObject { return _hit; }
		public function set hitArea(hitArea:InteractiveObject):void {
			if (_hit != null) onRemove();
			_hit = hitArea;
			if (_object && _object.stage != null) onAdd();
		}
		
		/** Indicates if a selection events should be fired immediately upon a
		 *  chane of selection status (true) or after the mouse is released
		 * (false). The default is true. Set this to false if immediate
		 * selections are causing any performance issues. */
		public var fireImmediately:Boolean = true;
		
		/** Line color of the selection region border. */
		public var lineColor:uint = 0x8888FF;
		/** Line alpha of the selection region border. */
		public var lineAlpha:Number = 0.4;
		/** Line width of the selection region border. */
		public var lineWidth:Number = 2;
		/** Fill color of the selection region. */
		public var fillColor:uint = 0x8888FF;
		/** Fill alpha of the selection region. */
		public var fillAlpha:Number = 0.2;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SelectionControl.
		 * @param filter an optional Boolean-valued filter determining which
		 *  items are eligible for selection.
		 * @param hitArea a display object to use as the hit area for mouse
		 *  events. For example, this could be a background region over which
		 *  the selection can done. If this argument is null,
		 *  the stage will be used.
		 * @param select an optional SelectionEvent listener for selections
		 * @param deselect an optional SelectionEvent listener for deselections
		 */
		public function SelectionControl(filter:*=null,
			select:Function=null, deselect:Function=null,
			hitArea:InteractiveObject=null)
		{
			_hit = hitArea;
			this.filter = filter;
			if (select != null)
				addEventListener(SelectionEvent.SELECT, select);
			if (deselect != null)
				addEventListener(SelectionEvent.DESELECT, deselect);
		}
		
		/**
		 * Indicates is a display object has been selected. 
		 * @param d the display object
		 * @return true if selected, false if not
		 */
		public function isSelected(d:DisplayObject):Boolean
		{
			return _sel[d] != undefined;
		}
		
		// -----------------------------------------------------
		
		/** @inheritDoc */
		public override function attach(obj:InteractiveObject):void
		{
			if (obj==null) { detach(); return; }
			if (!(obj is DisplayObjectContainer)) {
				throw new Error("Attached object must be a DisplayObjectContainer");
			}
			super.attach(obj);
			if (obj != null) {
				obj.addEventListener(Event.ADDED_TO_STAGE, onAdd);
				obj.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
				if (obj.stage != null) onAdd();
			}
		}
		
		/** @inheritDoc */
		public override function detach():InteractiveObject
		{
			onRemove();
			if (_object != null) {
				_object.removeEventListener(Event.ADDED_TO_STAGE, onAdd);
				_object.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			}
			_hit = null;
			return super.detach();
		}
		
		private function onAdd(evt:Event=null):void
		{
			_stage = _object.stage;
			if (_hit == null) _hit = _stage;
			_hit.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		private function onRemove(evt:Event=null):void
		{
			if (_hit)
				_hit.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}
		
		// -----------------------------------------------------
				
		private function mouseDown(evt:MouseEvent):void
		{
			if (_stage == null) return;
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
			_r.x = _object.mouseX;
			_r.y = _object.mouseY;
			_r.width = 0;
			_r.height = 1;
			_drag = true;
			
			DisplayObjectContainer(_object).addChild(_shape);
			renderShape(_shape.graphics);
			if (fireImmediately) {
				selectionTest(evt);
			}
		}
		
		private function mouseMove(evt:MouseEvent):void
		{
			if (!_drag) return;
			_r.width = _object.mouseX - _r.x;
			_r.height = _object.mouseY - _r.y;
			
			renderShape(_shape.graphics);
			if (fireImmediately) {
				selectionTest(evt);
			}
		}
		
		private function mouseUp(evt:MouseEvent):void
		{
			if (!fireImmediately)
				selectionTest(evt);
			_drag = false;
			DisplayObjectContainer(_object).removeChild(_shape);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		}
		
		private function renderShape(g:Graphics):void {
			g.clear();
			g.beginFill(fillColor, fillAlpha);
			g.lineStyle(lineWidth, lineColor, lineAlpha, true, "none");
			g.drawRect(_r.x, _r.y, _r.width, _r.height);
			g.endFill();
		}
		
		private function selectionTest(evt:MouseEvent):void {			
			var con:DisplayObjectContainer = DisplayObjectContainer(_object);
			for (var i:uint=0; i<con.numChildren; ++i) {
				walkTree(con.getChildAt(i), test);
			}
			
			// process selection events
			if (_rem0 && hasEventListener(SelectionEvent.DESELECT)) {
				dispatchEvent(new SelectionEvent(SelectionEvent.DESELECT,
					_rem ? _rem : _rem0, evt));
			}
			if (_add0 && hasEventListener(SelectionEvent.SELECT)) {
				dispatchEvent(new SelectionEvent(SelectionEvent.SELECT,
					_add ? _add : _add0, evt));
			}
			_rem = _add = null;
			_rem0 = _add0 = null;
		}
		
		private static function walkTree(obj:DisplayObject, func:Function):void
		{
			func(obj);
			if (obj is DisplayObjectContainer) {
				var con:DisplayObjectContainer = obj as DisplayObjectContainer;
				for (var i:int=0; i<con.numChildren; ++i) {
					walkTree(con.getChildAt(i), func);
				}
			}
		}
		
		private function test(d:DisplayObject):void
		{
			if (_filter!=null && !_filter(d)) return;
			var a:Boolean = _sel[d] != undefined;
			var b:Boolean = d.hitTestObject(_shape);
			
			if (!a && b && hasEventListener(SelectionEvent.SELECT)) {
				select(d);
			} else if (a && !b && hasEventListener(SelectionEvent.DESELECT)) {
				deselect(d);
			}
		}
		
		private function select(d:DisplayObject):void {
			_sel[d] = d;
			if (_add == null)
				if (_add0 == null) {
					_add0 = d;
				} else {
					_add = [_add0, d];
				}
			else
				_add.push(d);
		}
		
		private function deselect(d:DisplayObject):void {
			delete _sel[d];
			if (_rem == null)
				if (_rem0 == null) {
					_rem0 = d;
				} else {
					_rem = [_rem0, d];
				}
			else
				_rem.push(d);
		}
		
	} // end of class SelectionControl
}