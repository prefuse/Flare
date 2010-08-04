package flare.animate
{
	/**
	 * Interface for "schedulable" objects that can be run by
	 * the Scheduler class.
	 */
	public interface ISchedulable
	{
		/**
		 * Evaluate a scheduled call.
		 * @param time the current time in milliseconds
		 * @return true if this item should be removed from the scheduler,
		 * false if it should continue to be run.
		 */
		function evaluate(time:Number) : Boolean;
		
		/** A unique name identifying this schedulable object. The default
		 *  is <code>null<code>. If non-null, any other scheduled items with
		 *  the same id will be canceled upon scheduling.
		 *  
		 *  <p>Once an item has been scheduled, it's id should not be changed.
		 *  However, it is left to subclasses to respect this convention.
		 *  If it is not followed, erratic cancels may occur.</p> */
		function get id():String;
		function set id(n:String):void;
		
		/** Invoked if a scheduled item is cancelled by the scheduler. */
		function cancelled():void;
		
	} // end of interface ISchedulable
}