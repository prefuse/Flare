package flare.vis.data
{
	import flare.scale.LinearScale;
	import flare.scale.LogScale;
	import flare.scale.OrdinalScale;
	import flare.scale.QuantileScale;
	import flare.scale.QuantitativeScale;
	import flare.scale.RootScale;
	import flare.scale.Scale;
	import flare.scale.ScaleType;
	import flare.scale.TimeScale;
	import flare.util.Stats;
	import flare.vis.events.DataEvent;
	
	/**
	 * Utility class that binds a data property to a descriptive scale.
	 * A ScaleBinding provides a layer of indirection between a data field and
	 * a data scale describing that field. The created scale can be used for
	 * layout and encoding of data values. When scale parameters such as the
	 * scale type or value range are updated, an underlying scale instance will
	 * be updated accordingly or a new instance will be created as needed.
	 */
	public class ScaleBinding extends Scale
	{
		/** @private */
		protected var _scale:Scale = null;
		/** @private */
		protected var _scaleType:String = null;
		/** @private */
		protected var _pmin:Object = null;
		/** @private */
		protected var _pmax:Object = null;
		/** @private */
		protected var _base:Number = 10;
		/** @private */
		protected var _bins:int = 5;
		/** @private */
		protected var _power:Number = NaN;
		/** @private */
		protected var _zeroBased:Boolean = false;
		/** @private */
		protected var _ordinals:Array = null;
		
		/** @private */
		protected var _property:String;
		/** @private */
		protected var _group:String;
		/** @private */
		protected var _data:Data;
		/** @private */
		protected var _stats:Stats;
		
		/** If true, updates to the underlying data will be ignored, as will
		 *  any calls to <code>updateBinding</code>. Set this flag if you want
		 *  to prevent the scale values from changing automatically. */
		public var ignoreUpdates:Boolean = false;
		
		/** The type of scale to create. */
		public override function get scaleType():String {
			return _scaleType ? _scaleType : scale.scaleType;
		}
		public function set scaleType(type:String):void {
			_scaleType = type;
			_scale = null;
		}
		
		/** The preferred minimum data value for the scale. If null, the scale
		 *  minimum will be determined from the data directly. */
		public function get preferredMin():Object { return _pmin; }
		public function set preferredMin(val:Object):void {
			_pmin = val;
			if (_scale && _pmin) {
				_scale.min = _pmin;
				if (_zeroBased) zeroAlignScale(_scale);
			}
		}
		
		/** The preferred maximum data value for the scale. If null, the scale
		 *  maximum will be determined from the data directly. */
		public function get preferredMax():Object { return _pmax; }
		public function set preferredMax(val:Object):void {
			_pmax = val;
			if (_scale && _pmax) {
				_scale.max = _pmax;
				if (_zeroBased) zeroAlignScale(_scale);
			}
		}
		
		/** @inheritDoc */
		public override function get max():Object { return scale.max; }
		public override function set max(v:Object):void { scale.max = v; }
		
		/** @inheritDoc */
		public override function get min():Object { return scale.min; }
		public override function set min(v:Object):void { scale.min = v; }
		
		/** The number base to use for a quantitative scale (10 by default). */
		public function get base():Number { return _base; }
		public function set base(val:Number):void {
			_base = val;
			if (_scale is QuantitativeScale) {
				QuantitativeScale(_scale).base = _base;
			}
		}
		
		/** A free parameter that indicates the exponent for a RootScale. */
		public function get power():Number { return _power; }
		public function set power(val:Number):void {
			_power = val;
			if (_scale is RootScale) {
				RootScale(_scale).power = _power;
			}
		}
		
		/** The number of bins for quantile scales. */
		public function get bins():int { return _bins; }
		public function set bins(count:int):void {
			_bins = count;
			if (_scale is QuantileScale) {
				_scale = null;
			}
		}
		
		/** Flag indicating if the scale bounds should be flush with the data.
		 *  @see flare.scale.Scale#flush */
		public override function get flush():Boolean { return _flush; }
		public override function set flush(val:Boolean):void {
			_flush = val;
			if (_scale) _scale.flush = _flush;
		}
		
		/** Formatting pattern for formatting labels for scale values.
		 *  @see flare.vis.scale.Scale#labelFormat. */
		public override function get labelFormat():String { return _format; }
		public override function set labelFormat(fmt:String):void {
			_format = fmt;
			if (_scale) _scale.labelFormat = fmt;
		}
		
		/** Flag indicating if a zero-based scale should be used. If set to
		 *  true, and the scale type is numerical, the minimum or maximum
		 *  scale value will automatically be adjusted to include the zero
		 *  point as necessary. */
		public function get zeroBased():Boolean { return _zeroBased; }
		public function set zeroBased(val:Boolean):void {
			_zeroBased = val;
			if (_scale) zeroAlignScale(_scale);
		}
		
		/** An ordered array of values for defining an ordinal scale. */
		public function get ordinals():Array { return _ordinals; }
		public function set ordinals(ord:Array):void {
			_ordinals = ord;
			if (ScaleType.isOrdinal(_scaleType)) {
				_stats = null;
				_scale = null;
			}
		}
		
		// -----------------------------------------------------
		
		/** The data instance to bind to. */
		public function get data():Data { return _data; }
		public function set data(data:Data):void {
			if (_data != null) { // remove existing listeners
				_data.removeEventListener(DataEvent.ADD,   onDataEvent);
				_data.removeEventListener(DataEvent.REMOVE, onDataEvent);
				_data.removeEventListener(DataEvent.UPDATE, onDataEvent);
			}
			_data = data;
			if (_data != null) { // add new listeners
				_data.addEventListener(DataEvent.ADD,
					onDataEvent, false, 0, true);
				_data.addEventListener(DataEvent.REMOVE,
					onDataEvent, false, 0, true);
				_data.addEventListener(DataEvent.UPDATE,
					onDataEvent, false, 0, true);
			}
		}
		
		/** The data group to bind to. */
		public function get group():String { return _group; }
		public function set group(name:String):void {
			if (name != _group) {
				_group = name;
				_stats = null;
				_scale = null;
			}
		}
		
		/** The data property to bind to. */
		public function get property():String { return _property; }
		public function set property(name:String):void {
			if (name != _property) {
				_property = name;
				_stats = null;
				_scale = null;
			}
		}
		
		/** The underlying scale created by this binding. */
		protected function get scale():Scale {
			if (!_data || !_group || !_property) {
				throw new Error("Can't create scale with data to bind to.");
			}
			if (!_scale) {
				_stats = _data.group(_group).stats(_property);
				_scale = buildScale(_stats);
			}
			return _scale;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ScaleBinding.
		 */
		public function ScaleBinding()
		{
		}
		
		/**
		 * Checks to see if the binding is current. If not, the internal stats
		 * and scale for this binding will be cleared and lazily recomputed.
		 * @return true if the binding was updated, false otherwise
		 */
		public function updateBinding():Boolean
		{
			if (ignoreUpdates) return false;
			var stats:Stats = _data.group(_group).stats(_property);
			if (stats !== _stats) { // object identity test
				_stats = null;
				_scale = null;
				return true;
			}
			return false;
		}
		
		/**
		 * Internal listener for data events that clears the current scale
		 * instance as needed.
		 * @param evt a DataEvent
		 */
		private function onDataEvent(evt:DataEvent):void
		{
			if (ignoreUpdates) return;
			if (evt.list.name == _group) {
				if (evt.type == DataEvent.UPDATE) {
					updateBinding();
				} else {
					_stats = null;
					_scale = null;
				}
			}
		}
		
		/** @inheritDoc */
		public override function clone() : Scale
		{
			return scale.clone();
		}
		
		/**
		 * Returns the index of the input value in the ordinal array if the
		 * scale is ordinal or categorical, otherwise returns -1.
		 * @param value the value to lookup
		 * @return the index of the input value. If the value is not contained
		 *  in the ordinal array, this method returns -1.
		 */
		public function index(value:Object):int
		{
			var s:OrdinalScale = scale as OrdinalScale;
			return (s ? s.index(value) : -1);
		}
		
		/** The number of distinct values in this scale, if ordinal. */
		public function get length():int
		{
			var s:OrdinalScale = scale as OrdinalScale;
			return (s ? s.length : -1);
		}
		
		/** @inheritDoc */
		public override function interpolate(value:Object) : Number
		{
			return scale.interpolate(value);
		}

		/** @inheritDoc */
		public override function lookup(f:Number) : Object
		{
			return scale.lookup(f);
		}

		/** @inheritDoc */
		public override function values(num:int=-1) : Array
		{
			return scale.values(num);
		}
		
		/** @inheritDoc */
		public override function label(value:Object) : String
		{
			return scale.label(value);
		}
		
		/** @private */
		protected function buildScale(stats:Stats):Scale
		{
			var type:String = _scaleType ? _scaleType : ScaleType.UNKNOWN;
			var vals:Array = _ordinals ? _ordinals : stats.distinctValues;
			var scale:Scale;
			
			switch (stats.dataType) {
				case Stats.NUMBER:
					switch (type) {
						case ScaleType.LINEAR:
						case ScaleType.UNKNOWN:
							scale = new LinearScale(stats.minimum, stats.maximum, _base, _flush, _format);
							break;
						case ScaleType.ROOT:
							var pow:Number = isNaN(_power) ? 2 : _power;
							scale = new RootScale(stats.minimum, stats.maximum, _base, _flush, pow, _format);
							break;
						case ScaleType.LOG:
							scale = new LogScale(stats.minimum, stats.maximum, _base, _flush, _format);
							break;
						case ScaleType.QUANTILE:
							scale = new QuantileScale(_bins, stats.values, true, _format);
							break;
						default:
							scale = new OrdinalScale(vals, _flush, false, _format);
							break;
					}
					break;
				case Stats.DATE:
					switch (type) {
						case ScaleType.UNKNOWN:
						case ScaleType.LINEAR:
						case ScaleType.TIME:
							scale = new TimeScale(stats.minDate, stats.maxDate, _flush, _format);
							break;
						default:
							scale = new OrdinalScale(vals, _flush, false, _format);
							break;
					}
					break;
				default:
					scale = new OrdinalScale(vals, _flush, false, _format);
					break;
			}
			
			if (_pmin) scale.min = _pmin;
			if (_pmax) scale.max = _pmax;
			if (_zeroBased) zeroAlignScale(scale);
			
			return scale;
		}
		
		private static function zeroAlignScale(scale:Scale):void
		{
			if (scale is QuantitativeScale) {
				var qs:QuantitativeScale = QuantitativeScale(scale);
				if (qs.scaleMin > 0) qs.dataMin = 0;
				if (qs.scaleMax < 0) qs.dataMax = 0;
			}
		}

	} // end of class ScaleBinding
}