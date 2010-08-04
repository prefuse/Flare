package flare.animate
{
	import flash.events.Event;

	/**
	 * Event fired when a <code>Transition</code>
	 * starts, steps, ends, or is canceled.
	 */
	public class TransitionEvent extends Event
	{
		/** A transition start event. */
		public static const START:String = "start";
		/** A transition step event. */
		public static const STEP:String = "step";
		/** A transition end event. */
		public static const END:String = "end";
		/** A transition cancel event. */
		public static const CANCEL:String = "cancel";
		
		private var _t:Transition;
		
		/** The transition this event corresponds to. */
		public function get transition():Transition { return _t; }
		
		/**
		 * Creates a new TransitionEvent.
		 * @param type the event type (START, STEP, or END)
		 * @param t the transition this event corresponds to
		 */		
		public function TransitionEvent(type:String, t:Transition)
		{
			super(type);
			_t = t;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new TransitionEvent(type, _t);
		}
		
	} // end of class TransitionEvent
}