package flare.query.methods
{
	import flare.query.IsA;

	/**
	 * Creates a new <code>IsType</code> query operator.
	 * @param type the class type to check for
	 * @param x the expression to type check
	 *  This value can be an expression or a literal value.
	 *  Literal values are parsed using the Expression.expr method.
	 * @return the new query operator
	 */
	public function isa(type:Class, x:*=null):IsA
	{
		return new IsA(type, x);
	}	
}