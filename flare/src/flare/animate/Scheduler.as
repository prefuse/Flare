package flare.animate
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * Scheduler that oversees animation and time-based processing. Uses an
	 * internal timer to regularly invoke the current set of scheduled
	 * objects. Typically, interaction with the scheduler is automatically
	 * handled by Transition classes. However, custom implmentations of
	 * the ISchedulable interface will need to be scheduled. Use the
	 * <tt>Scheduler.instance</tt> property, and not the constructor, to get
	 * a reference to the active scheduler.
	 * 
	 * <p>By default, the Scheduler issues updates to all scheduled items each
	 * time the Flash Player advances to the next frame, as reported by the
	 * <code>Event.ENTER_FRAME</code> event. To instead set the update interval
	 * manually, see the <code>timerInterval</code> property.</p>
	 */
	public class Scheduler
	{
		private static const _instance:Scheduler = new Scheduler(_Lock);
		/** The default Scheduler instance. */
		public static function get instance():Scheduler { return _instance; }
		
		private var _scheduled:Array; // list of all currently scheduled items
		private var _ids:Object;      // map of all named items
		private var _timer:Timer;     // timer for interval-based scheduling
		private var _obj:Shape;       // shape for getting ENTER_FRAME events
		
		/**
		 * Sets the timer interval (in milliseconds) at which the scheduler
		 * should process events. If this value is greater than zero, a
		 * <code>Timer</code> instance will be used to trigger scheduler
		 * updates at the given interval. If this value is less than or equal
		 * to zero (the default), scheduler updates will be issued with each
		 * time the Flash Player advances to the next frame according to the
		 * <code>Event.ENTER_FRAME</code> event.
		 */
		public function get timerInterval():Number { return _timer.delay; }
		public function set timerInterval(t:Number):void {
			pause(); _timer.delay = (t>0 ? t : 0); play();
		}
		
		/**
		 * Creates a new Scheduler--this constructor should be not used;
		 * instead use the <code>instance</code> property.
		 * @param lock a lock object to emulate a private constructor
		 */
		public function Scheduler(lock:Class) {
			if (lock == _Lock) {
				_scheduled = [];
				_ids = {};
				_obj = new Shape();
				_timer = new Timer(0);
				_timer.addEventListener(TimerEvent.TIMER, tick);
			} else {
				throw new Error("Invalid constructor. Use Scheduler.instance.");
			}
		}
		
		/**
		 * Plays the scheduler, allowing it to process events.
		 */
		private function play():void
		{
			if (timerInterval <= 0) {
				if (!_obj.hasEventListener(Event.ENTER_FRAME))
					_obj.addEventListener(Event.ENTER_FRAME, tick);
			} else if (!_timer.running) {
				_timer.start();
			}
		}
		
		/**
		 * Pauses the scheduler, so that events are not processed.
		 */
		private function pause():void
		{
			if (timerInterval <= 0) {
				_obj.removeEventListener(Event.ENTER_FRAME, tick);
			} else {
				_timer.stop();
			}
		}
		
		/**
		 * Adds an object to the scheduling list.
		 * @param item a schedulable object to add
		 */
		public function add(item:ISchedulable) : void
		{
			if (item.id && _ids[item.id] != item) {
				cancel(item.id);
				_ids[item.id] = item;
			}
			_scheduled.push(item);
			play();
		}
		
		/**
		 * Removes an object from the scheduling list.
		 * @param item the object to remove
		 * @return true if the object was found and removed, false otherwise
		 */
		public function remove(item:ISchedulable) : Boolean
		{
			var idx:int = _scheduled.indexOf(item);
			if (idx >= 0) {
				_scheduled.splice(idx,1);
				if (item.id && _ids[item.id] == item) {
					if (_scheduled.indexOf(item) < 0)
						delete _ids[item.id];
				}
			}
			return (idx >= 0);
		}
		
		/**
		 * Indicates if an object with the given id is currently in the
		 * scheduler queue. 
		 * @param id the id to check for
		 * @return true if an object with that id is currently scheduled,
		 *  false otherwise
		 */
		public function isScheduled(id:String) : Boolean
		{
			return _ids[id] != undefined;
		}
		
		/**
		 * Looks up the scheduled object indicated by the given id, if any.
		 * @param id the id to lookup
		 * @return the scheduled object with matching id, of null if none
		 */
		public function lookup(id:String) : ISchedulable
		{
			return id==null ? null : _ids[id];
		}
		
		/**
		 * Cancels any scheduled object with a matching id. 
		 * @param id the id to cancel
		 * @return true if an object was found and cancelled, false otherwise
		 */
		public function cancel(id:String) : Boolean
		{
			var s:ISchedulable = _ids[id];
			if (s != null) {
				remove(s);
				s.cancelled();
				return true;
			} else {
				return false;
			}
		}
		
		/**
		 * Frame/timer callback that invokes each scheduled object.
		 * @param event the event that triggered the callback
		 */
		public function tick(event:Event) : void
        {
        	// all events will see the same timestamp
        	var time:Number = new Date().time;
        	
        	for each (var s:ISchedulable in _scheduled) {
        		if (s.evaluate(time))
        			remove(s);
        	}
        	if (_scheduled.length == 0) {
        		pause();
        	}
        }
        
	} // end of class Scheduler
}

// scheduler lock class to enforce singleton pattern
class _Lock { }