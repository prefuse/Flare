package flare.vis.operator.filter
{
	import flare.animate.Transitioner;
	import flare.util.Filter;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.Operator;

	/**
	 * Filter operator that sets item visibility based on a filtering
	 * condition. Filtering conditions are specified using Boolean-valued
	 * predicate functions that return true if the item meets the filtering
	 * criteria and false if it does not. For items which meet the criteria,
	 * this class sets the <code>visibility</code> property to true and
	 * the <code>alpha</code> value to 1. For those items that do not meet
	 * the criteria, this class sets the <code>visibility</code> property to
	 * false and the <code>alpha</code> value to 0.
	 * 
	 * <p>Predicate functions can either be arbitrary functions that take
	 * a single argument and return a Boolean value, or can be systematically
	 * constructed using the <code>Expression</code> language provided by the
	 * <code>flare.query</code> package.</p>
	 * 
	 * @see flare.query
	 */
	public class VisibilityFilter extends Operator
	{
		private var _filter:Function;
		
		/** Predicate function determining item visibility. */
		public var predicate:Function;

		/** The name of the data group for which to compute the encoding. 
		 *  The default is <code>Data.NODES</code>. */
		public var group:String;
		
		/** Boolean function indicating which items to process. This function
		 *  <strong>does not</strong> determine which items will be visible, it
		 *  only determines which items are visited by this operator. Only
		 *  items for which this function return true will be considered by the
		 *  VisibilityFilter. If the function is null, all items will be
		 *  considered.
		 *  @see flare.util.Filter */
		public function get filter():Function { return _filter; }
		public function set filter(f:*):void { _filter = Filter.$(f); }
		
		/** Immediate mode sets the visibility settings immediately, bypassing
		 *  any transitioner provided. */
		public var immediate:Boolean = false;
		
		/**
		 * Creates a new VisibilityFilter.
		 * @param predicate the predicate function for filtering items. This
		 *  should be a Boolean-valued function that returns true for items
		 *  that pass the filtering criteria and false for those that do not.
		 * @param group the data group to process.
		 * @param filter a Boolean-valued filter function that determines which
		 *  items are considered by this visibility filter. Only tems that pass
		 *  this filter will then have their visibility value set according
		 *  to the <code>predicate</code> argument.
		 */
		public function VisibilityFilter(predicate:Function=null,
						group:String=Data.NODES, filter:*=null)
		{
			this.predicate = predicate;
			this.group = group;
			this.filter = filter;
		}

		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			t = (t==null ? Transitioner.DEFAULT : t);
			
			if (immediate) {
				visualization.data.visit(function(d:DataSprite):void {
					var visible:Boolean = predicate(d);
					d.alpha = visible ? 1 : 0;
					d.visible = visible;
				}, group, filter);
			} else {
				visualization.data.visit(function(d:DataSprite):void {
					var visible:Boolean = predicate(d);
					t.$(d).alpha = visible ? 1 : 0;
					t.$(d).visible = visible;
				}, group, filter);
			}
		}
		
	} // end of class VisibilityFilter
}