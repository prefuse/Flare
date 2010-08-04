package flare.query.methods
{
	import flare.query.Xor;
	import flare.util.Vectors;
	
	/**
	 * Creates a new <code>Xor</code> (exclusive or) query operator.
	 * @param rest a list of expressions to include in the exclusive or
	 * @return the new query operator
	 */
	public function xor(...rest):Xor
	{
		var x:Xor = new Xor();
		x.setChildren(Vectors.copyFromArray(rest));
		return x;
	}	
}