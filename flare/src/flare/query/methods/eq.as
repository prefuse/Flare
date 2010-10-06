package flare.query.methods
{
	import flare.query.Comparison;
	
	/**
	 * Creates a new equality <code>Comparison</code> query operator.
	 * @param a the left side argument. 
	 *  This value can be an expression or a literal value.
	 *  Literal values are parsed using the Expression.expr method.
	 * @param b the right side argument
	 *  This value can be an expression or a literal value.
	 *  Literal values are parsed using the Expression.expr method.
	 * @return the new query operator
	 */
	public function eq(a:*, b:*):Comparison
	{
		return Comparison.Equal(a, b);
	}
}