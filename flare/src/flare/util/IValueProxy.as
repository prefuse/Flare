package flare.util
{
	/**
	 * Interface for classes that get and set named property values of objects.
	 */
	public interface IValueProxy
	{
		/**
		 * Gets a named property value for an object. 
		 * @param object the object
		 * @param name the property name
		 * @return the value
		 */
		function getValue(object:Object, name:String):*;
		
		/**
		 * Sets a named property value for an object.
		 * @param object the object
		 * @param name the property name
		 * @param value the value
		 */
		function setValue(object:Object, name:String, value:*):void;
		
		/**
		 * Returns a value proxy object for getting and setting values. 
		 * @param object the object
		 * @return a value proxy object upon which clients can get and set
		 *  properties directly
		 */
		function $(object:Object):Object;
		
	} // end of interface IValueProxy
}