package flare.vis.events
{
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * Event fired in response to tooltip show, hide, or update events.
	 * @see flare.vis.controls.TooltipControl
	 */
	public class TooltipEvent extends Event
	{
		/** A tooltip show event. */
		public static const SHOW:String = "show";
		/** A tooltip hide event. */
		public static const HIDE:String = "hide";
		/** A tooltip update event. */
		public static const UPDATE:String = "update";
		
		private var _object:DisplayObject;
		private var _tooltip:DisplayObject;
		
		/** The displayed tooltip object. */
		public function get tooltip():DisplayObject { return _tooltip; }
		
		/** The moused-over interface object. */
		public function get object():DisplayObject { return _object; }
		/** The moused-over interface object, cast to a NodeSprite. */
		public function get node():NodeSprite { return _object as NodeSprite; }
		/** The moused-over interface object, cast to an EdgeSprite. */
		public function get edge():EdgeSprite { return _object as EdgeSprite; }
		
		/**
		 * Creates a new TooltipEvent.
		 * @param type the event type (SHOW,HIDE, or UPDATE)
		 * @param item the DisplayObject that was moused over
		 * @param tip the tooltip DisplayObject
		 */
		public function TooltipEvent(type:String, item:DisplayObject, tip:DisplayObject)
		{
			super(type);
			_object = item;
			_tooltip = tip;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new TooltipEvent(type, _object, _tooltip);
		}
		
	} // end of class TooltipEvent
}