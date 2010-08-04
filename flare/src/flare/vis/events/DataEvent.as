package flare.vis.events
{
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.events.Event;
	
	/**
	 * Event fired when a data collection is modified.
	 */
	public class DataEvent extends Event
	{
		/** A data added event. */
		public static const ADD:String    = "add";
		/** A data removed event. */
		public static const REMOVE:String = "remove";
		/** A data updated event. */
		public static const UPDATE:String = "update";
		
		/** @private */
		protected var _items:Array;
		/** @private */
		protected var _item:Object;
		/** @private */
		private var _list:DataList;
		
		/** The number of items in this data event. */
		public function get length():int {
			return _items ? _items.length : 1;
		}
		
		/** The list of effected data items. */
		public function get items():Array {
			if (_items == null) _items = [_item];
			return _items;
		}
		
		/** The data list (if any) the items belong to. */
		public function get list():DataList { return _list; }
		
		/** The first element in the event list as an Object. */
		public function get object():Object { return _item; }
		/** The first element in the event list as a DataSprite. */
		public function get item():DataSprite { return _item as DataSprite; }
		/** The first element in the event list as a NodeSprite. */
		public function get node():NodeSprite { return _item as NodeSprite; }
		/** The first element in the event list as an EdgeSprite. */
		public function get edge():EdgeSprite { return _item as EdgeSprite; }
		
		/**
		 * Creates a new DataEvent.
		 * @param type the event type (ADD, REMOVE, or UPDATE)
		 * @param items the DataSprite(s) that were added, removed, or updated
		 * @param list (optional) the data list that was modified
		 */
		public function DataEvent(type:String, items:*, list:DataList=null)
		{
			super(type, false, true);
			if (items is Array) {
				_items = items;
				_item = _items[0];
			} else {
				_items = null;
				_item = items;
			}
			_list = list;
		}
		
		/** @inheritDoc */
		public override function clone():Event
		{
			return new DataEvent(type, _items?_items:_item, _list);
		}
		
	} // end of class DataEvent
}