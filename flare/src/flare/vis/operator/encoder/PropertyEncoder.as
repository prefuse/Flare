package flare.vis.operator.encoder
{
	import flare.animate.Transitioner;
	import flare.util.Filter;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.operator.Operator;

	/**
	 * Encodes property values for a collection of visual items.
	 * A property encoder simply sets a group of properties to static
	 * values for all data sprites. An input object determines which
	 * properties to set and what their values are.
	 * 
	 * <p>For example, a <code>PropertyEncoder</code> created with this code:
	 * <code>new PropertyEncoder({size:1, lineColor:0xff0000ff{);</code>
	 * will set the size to 1 and the line color to blue for all
	 * data sprites processed by the encoder.</p>
	 * 
	 * <p>Property values can take a number of forms, as determined by
	 * the <code>flare.vis.data.DataList.setProperties</code> method:
	 * <ul>
	 *  <li>If a value is a <code>Function</code>, it will be evaluated
	 *      for each element and the result will be used as the property
	 *      value for that element.</li>
	 *  <li>If a value is an <code>IEvaluable</code> instance, such as
	 *      <code>flare.util.Property</code> or
	 *      <code>flare.query.Expression</code>, it will be evaluated for
	 *      each element and the result will be used as the property value
	 *      for that element.</li>
	 *  <li>In all other cases, a property value will be treated as a
	 *      literal and assigned for all elements.</li>
	 * </ul></p>
	 */
	public class PropertyEncoder extends Operator
	{
		/** The name of the data group for which to compute the encoding. */
		protected var _group:String;
		/** Boolean function indicating which items to process. */
		protected var _filter:Function;
		/** Flag indicating if property values should be set immediately. */
		protected var _ignoreTrans:Boolean;
		/** The properties to set on each invocation. */
		protected var _values:Object;
		/** A transitioner for collecting value updates. */
		protected var _t:Transitioner;
		
		/** The name of the data group for which to compute the encoding. */
		public function get group():String { return _group; }
		public function set group(g:String):void { _group = g; }
		
		/** Boolean function indicating which items to process. Only items
		 *  for which this function return true will be considered by the
		 *  labeler. If the function is null, all items will be considered.
		 *  @see flare.util.Filter */
		public function get filter():Function { return _filter; }
		public function set filter(f:*):void { _filter = Filter.$(f); }
		
		public function get ignoreTransitioner():Boolean { return _ignoreTrans; }
		public function set ignoreTransitioner(b:Boolean):void { _ignoreTrans = b; }
		
		/** The properties to set on each invocation. */
		public function get values():Object { return _values; }
		public function set values(o:Object):void { _values = o; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new PropertyEncoder
		 * @param values The properties to set on each invocation. The input
		 *  should be an object with a set of name/value pairs.
		 * @param group the data group to process
		 * @param filter a Boolean-valued function that takes a DataSprite as
		 *  input and returns true if the sprite should be processed
		 * @param ignoreTransitioner Flag indicating if values should be set
		 *  immediately rather than being processed by any transitioners
		 */		
		public function PropertyEncoder(values:Object=null,
			group:String=Data.NODES, filter:*=null,
			ignoreTransitioner:Boolean=false)
		{
			_values = values==null ? {} : values;
			_group = group;
			this.filter = filter;
			_ignoreTrans = ignoreTransitioner;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			t = (t==null || _ignoreTrans ? Transitioner.DEFAULT : t);
			if (_values == null) return;
			var list:DataList = visualization.data.group(_group);
			list.setProperties(_values, t, _filter);
		}
		
	} // end of class PropertyEncoder
}