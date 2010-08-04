package flare.query
{
	/**
	 * Expression operator that type checks a sub-expression.
	 */
	public class IsA extends Expression
	{
		private var _type:Class;
		private var _clause:Expression;
		
		/** The class type to check for. */
		public function get type():Class { return _type; }
		
		/** The sub-expression clause to type check. */
		public function get clause():Expression { return _clause; }
		public function set clause(e:*):void {
			_clause = e==null ? null : Expression.expr(e);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function get numChildren():int { return _clause ? 1 : 0; }
		
		/**
		 * Creates a new IsA operator. 
		 * @param type the class type to check for
		 * @param clause the sub-expression clause to type check. If null,
		 *  the input object (rather than a sub-property or expression result)
		 *  will be type checked.
		 */
		public function IsA(type:Class, clause:*=null) {
			_type = type;
			this.clause = clause;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function clone():Expression
		{
			return new IsA(_type, _clause.clone());
		}
		
		/**
		 * @inheritDoc
		 */
		public override function eval(o:Object=null):*
		{
			return predicate(o);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function predicate(o:Object):Boolean
		{
			if (_clause) {
				return _clause.eval(o) is _type;
			} else {
				return o is _type;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public override function getChildAt(idx:int):Expression
		{
			return (idx==0 ? _clause : null);
		}
		
		/**
		 * @inheritDoc
		 */
		public override function setChildAt(idx:int, expr:Expression):Boolean
		{
			if (idx == 0) {
				_clause = expr;
				return true;
			}
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function toString():String
		{
			var c:String = _clause ? _clause.toString() : "<object>";
			return "("+c + " IS " + _type.toString()+")";
		}
		
	} // end of class IsA
}