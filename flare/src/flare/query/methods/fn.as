package flare.query.methods
{
	import flare.query.Fn;
	
	/**
	 * Creates a new <code>Fn</code> query operator for a function in a query.
	 * @param name the name of the function. This should be a function
	 *  registered with the Fn class.
	 * @param args a list of arguments to the function
	 * @return the new Fn operator
	 */
	public function fn(name:String, ...args):Fn
	{
		var f:Fn = new Fn(name);
		f.setChildren(args);
		return f;
	}
}