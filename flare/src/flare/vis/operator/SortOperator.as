package flare.vis.operator
{
	import flare.animate.Transitioner;
	import flare.util.Arrays;
	import flare.vis.data.Data;
	
	/**
	 * A SortOperator sorts a data group. This can be used to sort
	 * elements prior to running a subsequent operation such as layout.
	 * @see flare.util.Sort
	 */
	public class SortOperator extends Operator
	{
		/** The data group to sort. */
		public var group:String;
		
		/** The sorting criteria. Sort criteria are expressed as an
		 *  array of property names to sort on. These properties are accessed
		 *  by sorting functions using the <code>Property</code> class.
		 *  The default is to sort in ascending order. If the field name
		 *  includes a "-" (negative sign) prefix, that variable will instead
		 *  be sorted in descending order. */
		public function get criteria():Array { return Arrays.copy(_crit); }
		public function set criteria(crit:*):void {
			if (crit is String) {
				_crit = [crit];
			} else if (crit is Array) {
				_crit = Arrays.copy(crit as Array);
			} else {
				throw new ArgumentError("Invalid Sort specification type. " +
					"Input must be either a String or Array");
			}
		}
		private var _crit:Array;
		
		/**
		 * Creates a new SortOperator.
		 * @param criteria the sorting criteria. Sort criteria are expressed as
		 *  an array of property names to sort on. These properties are
		 *  accessed by sorting functions using the <code>Property</code>
		 *  class. The default is to sort in ascending order. If the field name
		 *  includes a "-" (negative sign) prefix, that variable will instead
		 *  be sorted in descending order.
		 * @param group the data group to sort
		 */
		public function SortOperator(criteria:Array, group:String=Data.NODES)
		{
			this.group = group;
			this.criteria = criteria;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			visualization.data.group(group).sortBy(_crit);
		}
		
	} // end of class SortOperator
}