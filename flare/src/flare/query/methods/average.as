package flare.query.methods
{
	import flare.query.Average;
	
	/**
	 * Creates a new <code>Average</code> query operator.
	 * @param expr the input expression
	 * @return the new query operator
	 */
	public function average(expr:*):Average
	{
		return new Average(expr);
	}
}