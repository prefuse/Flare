package flare.query.methods
{
	import flare.query.Count;
	
	/**
	 * Creates a new <code>Count</code> query operator.
	 * @param expr the input expression
	 * @return the new query operator
	 */
	public function count(expr:*):Count
	{
		return new Count(expr);
	}
}