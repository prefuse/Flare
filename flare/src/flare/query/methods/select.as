package flare.query.methods
{
	import flare.query.Query;
	
	/**
	 * Create a new <code>Query</code> with the given select clauses.
	 * @param terms a list of select clauses
	 * @return the created query.
	 */
	public function select(...terms):Query
	{
		return new Query(terms);
	}
}