package flare.query.methods
{
	import flare.query.Sum;
	
	/**
	 * Creates a new 'sum' <code>Arithmetic</code> query operator.
	 * @param expr the input expression
	 * @return the new query operator
	 */
	public function sum(expr:*):Sum
	{
		return new Sum(expr);
	}
}