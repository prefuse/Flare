package flare.analytics.optimization
{
	import flare.animate.Transitioner;
	import flare.scale.Scale;
	import flare.util.Arrays;
	import flare.util.Property;
	import flare.vis.Visualization;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.Operator;
	
	/**
	 * Computes an optimized aspect ratio for drawing a line chart.
	 * This operator will update the visualization's bounds to reflect the
	 * optimized aspect ratio. Place this operator in an
	 * <code>OperatorList</code> <b>before</b> the <code>AxisLayout</code>
	 * operator, and set the <code>dataField</code> property to be the
	 * same as the axis data field that should be banked. For example, in
	 * a time series chart with time on the x-axis, the data field for this
	 * operator should be the same as the data field used for the y-axis.
	 * By default this class assumes that the data field is being laid out
	 * on the y-axis. If this is not the case (e.g., you have a vertically
	 * oriented line chart), be sure to set the <code>bankYAxis</code>
	 * property to <code>false</code>.
	 */
	public class AspectRatioBanker extends Operator
	{
		private var _z:Property = null;
		
		/** The maximum width for the visualization bounds. */
		public var maxWidth:Number = 500;
		/** The maximum height for the visualization bounds. */
		public var maxHeight:Number = 500;
		/** Indicates if the data field is on the y-axis (default true). */
		public var bankYAxis:Boolean = true;
		/** The banking function to use. This is a function that takes an
		 *  array of Numbers as input and returns an aspect ratio. It is
		 *  expected that this function will be one of the static functions of
		 *  this class. The default is <code>averageAbsoluteAngle</code>. */
		public var banker:Function = averageAbsoluteAngle;
		
		/** The data field of the values to bank. */
		public function get dataField():String { return _z.name; }
		public function set dataField(f:String):void {
			_z = Property.$(f); setup();
		}
		
		/**
		 * Creates a new AspectRatioBanker. 
		 * @param dataField the data field from which pull numeric values from
		 *  NodeSprites. These values are then used to determine the optimal
		 *  aspect ratio.
		 */
		public function AspectRatioBanker(dataField:String=null,
			bankYAxis:Boolean=true, maxWidth:Number=500, maxHeight:Number=500)
		{
			if (dataField) _z = Property.$(dataField);
			this.bankYAxis = bankYAxis;
			this.maxWidth  = maxWidth;
			this.maxHeight = maxHeight;
		}

		// --------------------------------------------------------------------
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			if (_z == null) return; // nothing to do
			
			// extract data
			var v:Array = [];
			visualization.data.nodes.visit(function(d:DataSprite):void {
				v.push(_z.getValue(d));
			});
			
			// compute the aspect ratio (= width/height)
			var ar:Number = banker(v);
			if (!bankYAxis) ar = 1/ar;
			ar = adjustToAxes(visualization, ar);
			
			// set visualization bounds and update axes
			visualization.setAspectRatio(ar, maxWidth, maxHeight);
			visualization.axes.update(t);
		}
		
		/**
		 * Adjusts an aspect ratio for the "data rectangle" bounding the data
		 * points to an new ratio that factors in the axis scale settings.
		 * @param ar the desired aspect ratio of the data rectangle
		 * @return the adjusted aspect ratio
		 */
		private static function adjustToAxes(vis:Visualization, ar:Number):Number
		{
			// get axis scales for each data field
			var axes:CartesianAxes = vis.xyAxes;
			var xsc:Scale = axes.xAxis.axisScale;
			var ysc:Scale = axes.yAxis.axisScale;
			
			// compute adjusted aspect ratio: this is the inverse aspect ratio
			// of the interpolated data rectangle in data space multipled by
			// the desired aspect ratio for the data rectangle in screen space
			var dy:Number, dx:Number;			
			dy = ysc.interpolate(ysc.max) - ysc.interpolate(ysc.min);
			dx = xsc.interpolate(xsc.max) - xsc.interpolate(xsc.min);
			return ar * dy / dx;
		}

		// --------------------------------------------------------------------
		
		/**
	     * Bank the average absolute orientation to 45 degrees.
	     * "Slopeless" lines are culled before the banking is computed.
	     * Solved using Newton-Raphson iteration.
	     * <pre>
	     * a     = aspect ratio (as height / width)
	     * ci    = normalized slope = N * abs(y_i+1 - y_i) / range(y)
	     * x     = a * ci
	     * f(a)  = sum(atan(x)) / N - pi/4
	     * f'(a) = sum(ci/(1 + x^2)) / N
	     * </pre>
	     * @param a an array of data values to be banked. It is assumed that
	     *  values on the opposite axis are evenly spaced.
	     * @return the optimized aspect ratio
	     */
	    public static function averageAbsoluteAngle(a:Array):Number
	    {
	    	var alpha:Number=0, alpha_p:Number, f:Number, fprime:Number;
	    	var x:Number, Ry:Number = Arrays.max(a) - Arrays.min(a);
	    	var N:int = a.length-1, iter:int = 0, i:int, j:int;
	
	        // compute constants, perform culling
	        var c:Array = [];
	        for (i=0, j=0; i<N; ++i) {
	        	var slope:Number = Math.abs(a[i+1] - a[i]) / Ry;
	        	if (slope > 1e-5) c.push(N * slope);
	        }
	        N = c.length;
	        
	        // Newton-Raphson iteration
	        do {
	            iter++;
	            alpha_p = alpha;
	            
	            // compute function and function derivative
	            f = fprime = 0;
	            for (i=0; i<N; ++i) {
	                x = c[i] * alpha;
	                f += Math.atan(x);
	                fprime += c[i] / (1 + x*x);
	            }
	            f /= N;
	            fprime /= N;
	            f -= Math.PI/4;
	            
	            // apply the Newton-Raphson increment
	            alpha = alpha_p - f/fprime;
	            
	         // finish iteration when update difference drops beneath tolerance
	         } while (Math.abs(alpha - alpha_p) > 1e-5);
	         
	         return 1/alpha;
	    }
	    
	    /**
	     * Bank the median absolute slope to 45 degrees.
	     * "Slopeless" lines are culled before the banking is computed.
	     * @param a an array of data values to be banked. It is assumed that
	     *  values on the opposite axis are evenly spaced.
	     * @return the optimized aspect ratio
	     */
	    public static function medianAbsoluteSlope(a:Array):Number
	    {
	    	var slopes:Array = [], i:int;
	    	var yRange:Number = Arrays.max(a) - Arrays.min(a);
	        
	        for (i=1; i<a.length; ++i) {
	            var slope:Number = Math.abs(a[i] - a[i-1]);
	            if (slope/yRange > 1e-5) {
	                slopes.push(slope);
	            }
	        }
	        slopes.sort(Array.NUMERIC);
	        var median:Number = slopes[slopes.length>>1];
	        return (median*(a.length-1)) / yRange;
	    }

	} // end of class AspectRatioBanker
}