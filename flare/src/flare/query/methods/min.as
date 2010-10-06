package flare.query.methods
{
	import flare.query.Minimum;
	
	/**
	 * Creates a new <code>Minimum</code> query operator.
	 * @param expr the input expression
	 * @return the new query operator
	 */
	public function min(expr:*):Minimum
	{
		return new Minimum(expr);
	}
}