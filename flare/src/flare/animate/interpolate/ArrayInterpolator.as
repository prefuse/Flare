package flare.animate.interpolate
{
	import flare.util.Arrays;
	
	/**
	 * Interpolator for numeric <code>Array</code> values. Each value
	 * contained in the array should be a numeric (<code>Number</code> or
	 * <code>int</code>) value.
	 */
	public class ArrayInterpolator extends Interpolator
	{
		private var _start:Array;
		private var _end:Array;
		private var _cur:Array;
		
		/**
		 * Creates a new ArrayInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param start the starting array of values to interpolate from
		 * @param end the target array to interpolate to. This should be an
		 *  array of numerical values.
		 */
		public function ArrayInterpolator(target:Object, property:String,
		                                  start:Object, end:Object)
		{
			super(target, property, start, end);
		}
		
		/**
		 * Initializes this interpolator.
		 * @param start the starting value of the interpolation
		 * @param end the target value of the interpolation
		 */
		protected override function init(start:Object, end:Object) : void
		{
			_end = end as Array;
			if (!end) throw new Error("Target array is null!");
			if (_start && _start.length != _end.length) _start = null;
			_start = Arrays.copy(start as Array, _start);
			
			if (_start.length != _end.length)
				throw new Error("Array dimensions don't match");
				
			var cur:Array = _prop.getValue(_target) as Array;
			if (cur == end) cur = null;
			_cur = Arrays.copy(_start, cur);
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			for (var i:uint=0; i<_cur.length; ++i) {
				_cur[i] = _start[i] + f*(_end[i] - _start[i]);
			}
			_prop.setValue(_target, _cur);
		}
		
	} // end of class ArrayInterpolator
}