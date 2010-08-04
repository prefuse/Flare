package flare.util
{	
	/**
	 * Utility methods for creating filter functions. The static
	 * <code>$()</code> method takes an arbitrary object and generates a
	 * corresponding filter function.
	 * 
	 * <p>Filter functions are functions that take one argument and return a
	 * <code>Boolean</code> value. The input argument to a filter function
	 * passes the filter if the function returns true and fails the
	 * filter if the function returns false.</p>
	 */
	public class Filter
	{
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Filter()
		{
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Convenience method that returns a filter function determined by the
		 * input object.
		 * <ul>
		 *  <li>If the input is null or a <code>Function</code>, it is simply
		 *      returned.</li>
		 *  <li>If the input is an <code>IPredicate</code>, its
		 *      <code>predicate</code> function is returned.</li>
		 *  <li>If the input is a <code>String</code>, a <code>Property</code>
		 *      instance with the string as the property name is generated, and
		 *      the <code>predicate</code> function of the property is
		 *      returned.</li>
		 *  <li>If the input is a <code>Class</code> instance, a function that
		 *      performs type-checking for that class type is returned.</li>
		 *  <li>In any other case, an error is thrown.</li>
		 * </ul>
		 * @param f an input object specifying the filter criteria
		 * @return the filter function
		 */
		public static function $(f:*):Function
		{
			if (f==null || f is Function) {
				return f;
			} else if (f is IPredicate) {
				return IPredicate(f).predicate;
			} else if (f is String) {
				return Property.$(f).predicate;
			} else if (f is Class) {
				return typeChecker(Class(f));
			} else {
				throw new ArgumentError("Unrecognized filter type");
			}
		}
		
		/**
		 * Returns a filter function that performs type-checking. 
		 * @param type the <code>Class</code> type to check for
		 * @return a <code>Boolean</code>-valued type checking filter function
		 */
		public static function typeChecker(type:Class):Function
		{
			return function(o:Object):Boolean { return o is type; }
		}

	} // end of class Filter
}