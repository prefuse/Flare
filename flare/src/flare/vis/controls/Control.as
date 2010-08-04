package flare.vis.controls
{
	import flare.util.Filter;
	
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;

	/**
	 * Base class for interactive controls.
	 */
	public class Control extends EventDispatcher implements IControl
	{
		/** @private */
		protected var _object:InteractiveObject;
		/** @private */
		protected var _filter:Function;
		
		/** Boolean function indicating the items considered by the control.
		 *  @see flare.util.Filter */
		public function get filter():Function { return _filter; }
		public function set filter(f:*):void { _filter = Filter.$(f); }
		
		/**
		 * Creates a new Control
		 */
		public function Control() {
			// do nothing
		}
		
		/** @inheritDoc */
		public function get object():InteractiveObject
		{
			return _object;
		}
		
		/** @inheritDoc */
		public function attach(obj:InteractiveObject):void
		{
			if (_object) detach();
			_object = obj;
		}
		
		/** @inheritDoc */
		public function detach():InteractiveObject
		{
			var obj:InteractiveObject = _object;
			_object = null;	
			return obj;
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Object, id:String):void
		{
			// do nothing
		}
		
	} // end of class Control
}