package flare.query.methods
{
	import flare.query.Or;
	import flare.util.Vectors;
	
	/**
	 * Creates a new <code>Or</code> query operator.
	 * @param rest a list of expressions to include in the or
	 * @return the new query operator
	 */
	public function or(...rest):Or
	{
		var o:Or = new Or();
		o.setChildren(Vectors.copyFromArray(rest));
		return o;
	}	
}