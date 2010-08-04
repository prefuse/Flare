package flare.animate.interpolate
{
	import flare.util.Vectors;

	/**
	 * Interpolator for numeric <code>Vector</code> values. Each value
	 * contained in the vector should be a numeric (<code>Number</code> or
	 * <code>int</code>) value.
	 */
	public class VectorInterpolator extends Interpolator
	{
		private var _start:Vector.<Object>;
		private var _end:Vector.<Object>;
		private var _cur:Vector.<Object>;
		
		/**
		 * Creates a new VectorInterpolator.
		 * @param target the object whose property is being interpolated
		 * @param property the property to interpolate
		 * @param start the starting vector of values to interpolate from
		 * @param end the target vector to interpolate to. This should be an
		 *  array of numerical values.
		 */
		public function VectorInterpolator(target:Object, property:String,
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
			_end = end as Vector.<Object>;
			if (!end) throw new Error("Target vector is null!");
			if (_start && _start.length != _end.length) _start = null;
			_start = Vectors.copy(start as Vector.<Object>, _start);
			
			if (_start.length != _end.length)
				throw new Error("Vector dimensions don't match");
				
			var cur:Vector.<Object> = _prop.getValue(_target) as Vector.<Object>;
			if (cur == end) cur = null;
			_cur = Vectors.copy(_start, cur);
		}
		
		/**
		 * Calculate and set an interpolated property value.
		 * @param f the interpolation fraction (typically between 0 and 1)
		 */
		public override function interpolate(f:Number) : void
		{
			for (var i:uint=0; i<_cur.length; ++i) {
				_cur[i] = (_start[i] as Number) + f*((_end[i] as Number) - (_start[i] as Number));
			}
			_prop.setValue(_target, _cur);
		}
		
	} // end of class ArrayInterpolator
}