package flare.vis.operator
{
	import flare.animate.Transitioner;
	import flare.util.IEvaluable;
	import flare.util.Property;
	import flare.vis.Visualization;
	
	/**
	 * Operators performs processing tasks on the contents of a Visualization.
	 * These tasks include layout, and color, shape, and size encoding.
	 * Custom operators can be defined by subclassing this class.
	 */
	public class Operator implements IOperator
	{
		// -- Properties ------------------------------------------------------
		
		private var _vis:Visualization;
		private var _enabled:Boolean = true;
		
		/** The visualization processed by this operator. */
		public function get visualization():Visualization { return _vis; }
		public function set visualization(v:Visualization):void {
			_vis = v; setup();
		}
		
		/** Indicates if the operator is enabled or disabled. */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(b:Boolean):void { _enabled = b; }
		
		/** @inheritDoc */
		public function set parameters(params:Object):void
		{
			applyParameters(this, params);
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Performs an operation over the contents of a visualization.
		 * @param t a Transitioner instance for collecting value updates.
		 */
		public function operate(t:Transitioner=null) : void {
			// for sub-classes to implement	
		}
		
		/**
		 * Setup method invoked whenever this operator's visualization
		 * property is set.
		 */
		public function setup():void
		{
			// for subclasses
		}
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Object, id:String):void
		{
			// do nothing
		}
		
		// -- Parameterization ------------------------------------------------
		
		/**
		 * Static method that applies parameter settings to an operator.
		 * @param op the operator
		 * @param p the parameter object
		 */
		public static function applyParameters(op:IOperator,params:Object):void
		{
			if (op==null || params==null) return;
			var o:Object = op as Object;
			for (var name:String in params) {
				var p:Property = Property.$(name);
				var v:* = params[name];
				var f:Function = v as Function;
				if (v is IEvaluable) f = IEvaluable(v).eval;
				p.setValue(op, f==null ? v : f(op));
			}
		}
		
	} // end of class Operator
}