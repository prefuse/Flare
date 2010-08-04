package flare.util
{		
	/**
	 * Utility class for accessing arbitrary property chains, allowing
	 * nested property expressions (e.g., <code>x.a.b.c</code> or 
	 * <code>x.a[1]</code>). To reduce initialization times, this class also
	 * maintains a static cache of all Property instances created using the
	 * static <code>$()</code> method.
	 */
	public class Property implements IEvaluable, IPredicate
	{
		private static const DELIMITER:* = /[\.|\[(.*)\]]/;
		
		private static var __cache:Object = {};
		private static var __stack:Array = [];
		private static var __proxy:IValueProxy;

		/**
		 * Requests a Property instance for the given property name. This is a
		 * factory method that caches and reuses property instances, saving
		 * memory and construction time. This method is the preferred way of
		 * getting a property and should be used instead of the constructor.
		 * @param name the name of the property
		 * @return the requested property instance
		 */
		public static function $(name:String):Property
		{
			if (name == null) return null;
			var p:Property = __cache[name];
			if (p == null) {
				p = new Property(name);
				__cache[name] = p;
			}
			return p;
		}
		
		/**
		 * Clears the cache of created Property instances
		 */
		public static function clearCache():void
		{
			__cache = {};
		}

		/** A minimal <code>IValueProxy</code> instance that gets and sets
		 *  property values through <code>Property</code> instances. */
		public static function get proxy():IValueProxy {
			if (__proxy == null) __proxy = new PropertyProxy();
			return __proxy;
		}
		
		// --------------------------------------------------------------------
		
		private var _field:String;
		private var _chain:Array;
		
		/** The property name string. */
		public function get name():String { return _field; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Property, in most cases the static <code>$</code>
		 * method should be used instead of this constructor.
		 * @param name the property name string
		 */
		public function Property(name:String) {
			if (name == null) {
				throw new ArgumentError("Not a valid property name: "+name);
			}
			
			_field = name;
			_chain = null;
			
			if (_field != null) {
				var parts:Array = _field.split(DELIMITER);
				if (parts.length > 1) {
					_chain = [];
					for (var i:int=0; i<parts.length; ++i) {
						if (parts[i].length > 0)
							_chain.push(parts[i]);
					}
				}
			}
		}
		
		/**
		 * Gets the value of this property for the input object.
		 * @param x the object to retrieve the property value for
		 * @return the property value
		 */
		public function getValue(x:Object):*
		{
			if (x == null) {
				return null;
			} else if (_chain == null) {
				return x[_field];
			} else {
				for (var i:uint=0; i<_chain.length; ++i) {
					x = x[_chain[i]];
				}
				return x;
			}
		}
		
		/**
		 * Gets the value of this property for the input object; this
		 * is the same as <code>getValue</code>, but provided in order to
		 * implement the <code>IEvaluable</code> interface.
		 * @param x the object to retrieve the property value for
		 * @return the property value
		 */
		public function eval(x:Object=null):*
		{
			if (x == null) {
				return null;
			} else if (_chain == null) {
				return x[_field];
			} else {
				for (var i:uint=0; i<_chain.length; ++i) {
					x = x[_chain[i]];
				}
				return x;
			}
		}
		
		/**
		 * Gets the value of this property and casts the result to a
		 * Boolean value.
		 * @param x the object to retrieve the property value for
		 * @return the property value as a Boolean
		 */
		public function predicate(x:Object):Boolean
		{
			return Boolean(eval(x));
		}
		
		/**
		 * Sets the value of this property for the input object. If the reset
		 * flag is true, all properties along a property chain will be updated.
		 * Otherwise, only the last property in the chain is updated.
		 * @param x the object to set the property value for
		 * @param val the value to set
		 */
		public function setValue(x:Object, val:*):void
		{
			if (_chain == null) {
				x[_field] = val;
			} else {
				__stack.push(x);
				for (var i:uint=0; i<_chain.length-1; ++i) {
					__stack.push(x = x[_chain[i]]);	
				}
				
				var p:Object = __stack.pop();
				p[_chain[i]] = val;
				
				for (i=_chain.length-1; --i >= 0; ) {
					x = p;
					p = __stack.pop();
					try {
						p[_chain[i]] = x;
					} catch (err:Error) {}
				}
			}
		}
		
		/**
		 * Deletes a dynamically-bound property from an object.
		 * @param x the object from which to delete the property
		 */
		public function deleteValue(x:Object):void
		{
			if (_chain == null) {
				delete x[_field];
			} else {
				for (var i:uint=0; i<_chain.length-1; ++i) {
					x = x[_chain[i]];
				}
				delete x[_chain[i]];
			}
		}
		
	} // end of class Property
}

import flare.util.IValueProxy;
import flare.util.Property;

/** A simple value proxy that uses Property instances to set and
 *  get values for input objects. */
class PropertyProxy implements IValueProxy
{
	public function setValue(o:Object, name:String, value:*):void
	{
		Property.$(name).setValue(o, value);
	}
	public function getValue(o:Object, name:String):*
	{
		return Property.$(name).getValue(o);
	}
	public function $(o:Object):Object
	{
		return o;
	}
}