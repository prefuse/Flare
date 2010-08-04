package flare.util
{
	/**
	 * Utility methods for working with arrays.
	 */
	public class Arrays
	{
		public static const EMPTY:Array = new Array(0);
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Arrays() {
			throw new ArgumentError("This is an abstract class.");
		}
		
		/**
		 * Returns the maximum value in an array. Comparison is determined
		 * using the greater-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the maximum value
		 */
		public static function max(a:Array, p:Property=null):Number
		{
			var x:Number = Number.MIN_VALUE;
			if (p) {
				var v:Number;
				for (var i:uint=0; i<a.length; ++i) {
					v = p.getValue(a[i]);
					if (v > x) x = v;
				}
			} else {
				for (i=0; i<a.length; ++i) {
					if (a[i] > x) x = a[i];
				}
			}
			return x;
		}
		
		/**
		 * Returns the index of a maximum value in an array. Comparison is
		 * determined using the greater-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the index of a maximum value
		 */
		public static function maxIndex(a:Array, p:Property=null):Number
		{
			var x:Number = Number.MIN_VALUE;
			var idx:int = -1;
			
			if (p) {
				var v:Number;
				for (var i:uint=0; i<a.length; ++i) {
					v = p.getValue(a[i]);
					if (v > x) { x = v; idx = i; }
				}
			} else {
				for (i=0; i<a.length; ++i) {
					if (a[i] > x) { x = a[i]; idx = i; }
				}
			}
			return idx;
		}
		
		/**
		 * Returns the minimum value in an array. Comparison is determined
		 * using the less-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the minimum value
		 */
		public static function min(a:Array, p:Property=null):Number
		{
			var x:Number = Number.MAX_VALUE;
			if (p) {
				var v:Number;
				for (var i:uint=0; i<a.length; ++i) {
					v = p.getValue(a[i]);
					if (v < x) x = v;
				}
			} else {
				for (i=0; i<a.length; ++i) {
					if (a[i] < x) x = a[i];
				}
			}
			return x;
		}
		
		/**
		 * Returns the index of a minimum value in an array. Comparison is
		 * determined using the less-than operator against arbitrary types.
		 * @param a the array
		 * @param p an optional property from which to extract the value.
		 *  If this is null, the immediate contents of the array are compared.
		 * @return the index of a minimum value
		 */
		public static function minIndex(a:Array, p:Property=null):Number
		{
			var x:Number = Number.MAX_VALUE, idx:int = -1;
			if (p) {
				var v:Number;
				for (var i:uint=0; i<a.length; ++i) {
					v = p.getValue(a[i]);
					if (v < x) { x = v; idx = i; }
				}
			} else {
				for (i=0; i<a.length; ++i) {
					if (a[i] < x) { x = a[i]; idx = i; }
				}
			}
			return idx;
		}
		
		/**
		 * Fills an array with a given value.
		 * @param a the array
		 * @param o the value with which to fill the array
		 */
		public static function fill(a:Array, o:*) : void
		{
			for (var i:uint = 0; i<a.length; ++i) {
				a[i] = o;
			}
		}
		
		/**
		 * Makes a copy of an array or copies the contents of one array to
		 * another.
		 * @param a the array to copy
		 * @param b the array to copy values to. If null, a new array is
		 *  created.
		 * @param a0 the starting index from which to copy values
		 *  of the input array
		 * @param b0 the starting index at which to write value into the
		 *  output array
		 * @param len the number of values to copy
		 * @return the target array containing the copied values
		 */
		public static function copy(a:Array, b:Array=null, a0:int=0, b0:int=0, len:int=-1) : Array {
			len = (len < 0 ? a.length : len);
			if (b==null) {
				b = new Array(b0+len);
			} else {
				while (b.length < b0+len) b.push(null);
			}

			for (var i:uint = 0; i<len; ++i) {
				b[b0+i] = a[a0+i];
			}
			return b;
		}
		
		/**
		 * Clears an array instance, removing all values.
		 * @param a the array to clear
		 */
		public static function clear(a:Array):void
		{
			while (a.length > 0) a.pop();
		}
				
		/**
		 * Removes an element from an array. Only the first instance of the
		 * value is removed.
		 * @param a the array
		 * @param o the value to remove
		 * @return the index location at which the removed element was found,
		 * negative if the value was not found.
		 */
		public static function remove(a:Array, o:Object) : int {
			var idx:int = a.indexOf(o);
			if (idx == a.length-1) {
				a.pop();
			} else if (idx >= 0) {
				a.splice(idx, 1);
			}
			return idx;
		}
		
		/**
		 * Removes the array element at the given index.
		 * @param a the array
		 * @param idx the index at which to remove an element
		 * @return the removed element
		 */
		public static function removeAt(a:Array, idx:uint) : Object {
			if (idx == a.length-1) {
				return a.pop();
			} else {
				var x:Object = a[idx];
				a.splice(idx,1);
				return x;
			}
		}
		
		/**
		 * Performs a binary search over the input array for the given key
		 * value, optionally using a provided property to extract from array
		 * items and a custom comparison function.
		 * @param a the array to search over
		 * @param key the key value to search for
		 * @param prop the property to retrieve from objecs in the array. If null
		 *  (the default) the array values will be used directly.
		 * @param cmp an optional comparison function
		 * @return the index of the given key if it exists in the array,
         *  otherwise -1 times the index value at the insertion point that
         *  would be used if the key were added to the array.
         */
		public static function binarySearch(a:Array, key:Object,
			prop:String=null, cmp:Function=null) : int
		{
			var p:Property = prop ? Property.$(prop) : null;
			if (cmp == null)
				cmp = function(a:*,b:*):int {return a>b ? 1 : a<b ? -1 : 0;}
			
			var x1:int = 0, x2:int = a.length, i:int = (x2>>1);
        	while (x1 < x2) {
        		var c:int = cmp(p ? p.getValue(a[i]) : a[i], key);
        		if (c == 0) {
                	return i;
            	} else if (c < 0) {
                	x1 = i + 1;
            	} else {
                	x2 = i;
            	}
            	i = x1 + ((x2 - x1)>>1);
        	}
        	return -1*(i+1);
		}
		
		/**
		 * Sets a named property value for items stored in an array.
		 * The value can take a number of forms:
		 * <ul>
		 *  <li>If the value is a <code>Function</code>, it will be evaluated
		 *      for each element and the result will be used as the property
		 *      value for that element.</li>
		 *  <li>If the value is an <code>IEvaluable</code> instance, it will be
		 *      evaluated for each element and the result will be used as the
		 *      property value for that element.</li>
		 *  <li>In all other cases, the property value will be treated as a
		 *      literal and assigned for all elements.</li>
		 * </ul>
		 * @param list the array to set property values for
		 * @param name the name of the property to set
		 * @param value the value of the property to set
		 * @param filter a filter function determining which items
		 *  in the array should be processed
		 * @param p an optional <code>IValueProxy</code> for setting the values
		 */
		public static function setProperty(a:Array,
			name:String, value:*, filter:Function, p:IValueProxy=null):void
		{
			if (p == null) p = Property.proxy;
			var v:Function = value is Function ? value as Function :
				value is IEvaluable ? IEvaluable(value).eval : null;
			for each (var o:Object in a) if (filter==null || filter(o))
				p.setValue(o, name, v!=null ? v(p.$(o)) : value);
		}

	} // end of class Arrays
}