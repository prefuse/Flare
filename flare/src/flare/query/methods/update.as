package flare.query.methods
{
	import flare.query.Query;
	
	/**
	 * Create a new <code>Query</code> with the given update clauses.
	 * @param terms a list of update clauses
	 * @return the created query.
	 */
	public function update(...terms):Query
	{
		return new Query().update(terms);
	}
}
