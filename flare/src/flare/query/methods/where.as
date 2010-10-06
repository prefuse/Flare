package flare.query.methods
{
	import flare.query.Query;
	
	/**
	 * Create a new <code>Query</code> with the given filter expression.
	 * @param expr the filter expression
	 * @return the created query.
	 */
	public function where(expr:*):Query
	{
		return new Query().where(expr);
	}
}