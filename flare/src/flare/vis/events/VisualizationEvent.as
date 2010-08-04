package flare.vis.events
{
	import flare.animate.Transitioner;
	
	import flash.events.Event;

	/**
	 * Event fired in response to visualization updates.
	 */
	public class VisualizationEvent extends Event
	{
		/** A visualization update event. */
		public static const UPDATE:String = "update";
		
		private var _trans:Transitioner;
		private var _params:Array;
		
		/** Transitioner used in the visualization update. */
		public function get transitioner():Transitioner { return _trans; }
		
		/** Parameter provided to the visualization update. If not null,
		 *  this string indicates the named operators that were run. */
		public function get params():Array { return _params; }
		
		/**
		 * Creates a new VisualizationEvent.
		 * @param type the event type
		 * @param trans the Transitioner used in the visualization update
		 */		
		public function VisualizationEvent(type:String,
			trans:Transitioner=null, params:Array=null)
		{
			super(type);
			_params = params;
			_trans = trans==null ? Transitioner.DEFAULT : trans;
		}
		
	} // end of class VisualizationEvent
}