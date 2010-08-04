package flare.util.palette
{
	import mx.core.IMXMLObject;
	
	/**
	 * Base class for palettes, such as color and size palettes, that map from
	 * interpolated scale values into visual properties
	 */
	public class Palette implements IMXMLObject
	{
		/** Vector of palette values. */
		protected var _values:Vector.<Object>;
		
		/** The number of values in the palette. */
		public function get size():int { return _values==null ? 0 : _values.length; }
		/** Object vector of palette values. */
		public function get values():Vector.<Object> { return _values; }
		public function set values(a:Vector.<Object>):void { _values = a; }
		
		/**
		 * Retrieves the palette value corresponding to the input interpolation
		 * fraction.
		 * @param f an interpolation fraction
		 * @return the palette value corresponding to the input fraction
		 */
		public function getValue(f:Number):Object
		{
			if (_values==null || _values.length==0)
				return 0;
			return _values[uint(Math.round(f*(_values.length-1)))];
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Object, id:String):void
		{
			// do nothing
		}
		
	} // end of class Palette
}