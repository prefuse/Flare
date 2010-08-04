package flare.vis.operator.layout
{
	import flare.scale.ScaleType;
	import flare.util.Property;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.ScaleBinding;
	
	/**
	 * Layout that places items along the X and Y axes according to data
	 * properties. The AxisLayout can also compute stacked layouts, in which
	 * elements that share the same data values along an axis are consecutively
	 * stacked on top of each other.
	 */
	public class AxisLayout extends Layout
	{
		protected var _xStacks:Boolean = false;
		protected var _yStacks:Boolean = false;
		
		protected var _xField:Property;
		protected var _yField:Property;
		protected var _xBinding:ScaleBinding;
		protected var _yBinding:ScaleBinding;
		
		// ------------------------------------------------
		
		/** The x-axis source property. */
		public function get xField():String { return _xBinding.property; }
		public function set xField(f:String):void { _xBinding.property = f; }
		
		/** The y-axis source property. */
		public function get yField():String { return _yBinding.property; }
		public function set yField(f:String):void { _yBinding.property = f; }
		
		/** Flag indicating if values should be stacked according to their
		 *  x-axis values. */
		public function get xStacked():Boolean { return _xStacks; }
		public function set xStacked(b:Boolean):void { _xStacks = b; }

		/** Flag indicating if values should be stacked according to their
		 *  y-axis values. */
		public function get yStacked():Boolean { return _yStacks; }
		public function set yStacked(b:Boolean):void { _yStacks = b; }
		
		/** The scale binding for the x-axis. */
		public function get xScale():ScaleBinding { return _xBinding; }
		public function set xScale(b:ScaleBinding):void {
			if (_xBinding) {
				if (!b.property) b.property = _xBinding.property;
				if (!b.group) b.group = _xBinding.group;
				if (!b.data) b.data = _xBinding.data;
			}
			_xBinding = b;
		}
		
		/** The scale binding for the y-axis. */
		public function get yScale():ScaleBinding { return _yBinding; }
		public function set yScale(b:ScaleBinding):void {
			if (_yBinding) {
				if (!b.property) b.property = _yBinding.property;
				if (!b.group) b.group = _yBinding.group;
				if (!b.data) b.data = _yBinding.data;
			}
			_yBinding = b;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new AxisLayout
		 * @param xAxisField the x-axis source property
		 * @param yAxisField the y-axis source property
		 * @param xStacked indicates if values should be stacked according to
		 *  their x-axis values
		 * @param yStacked indicates if values should be stacked according to
		 *  their y-axis values
		 */		
		public function AxisLayout(xAxisField:String=null, yAxisField:String=null,
								   xStacked:Boolean=false, yStacked:Boolean=false)
		{
			layoutType = CARTESIAN;
			
			_xBinding = new ScaleBinding();
			_xBinding.group = Data.NODES;
			_xBinding.property = xAxisField;
			_xStacks = xStacked;
			
			_yBinding = new ScaleBinding();
			_yBinding.group = Data.NODES;
			_yBinding.property = yAxisField;
			_yStacks = yStacked;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			if (visualization==null) return;
			_xBinding.data = visualization.data;
			_yBinding.data = visualization.data;
			
			var axes:CartesianAxes = super.xyAxes;
			axes.xAxis.axisScale = _xBinding;
			axes.yAxis.axisScale = _yBinding;
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
			_xField = Property.$(_xBinding.property);
			_yField = Property.$(_yBinding.property);
			
			var axes:CartesianAxes = super.xyAxes;
			_xBinding.updateBinding(); axes.xAxis.axisScale = _xBinding;
			_yBinding.updateBinding(); axes.yAxis.axisScale = _yBinding;
			
			if (_xStacks || _yStacks) { rescale(); }			
			var x0:Number = axes.originX;
			var y0:Number = axes.originY;

			var xmapPos:Object = _xStacks ? new Object() : null;
			var xmapNeg:Object = _xStacks ? new Object() : null;
			var ymapPos:Object = _yStacks ? new Object() : null;
			var ymapNeg:Object = _yStacks ? new Object() : null;
			
			visualization.data.nodes.visit(function(d:DataSprite):void {
				var dx:Object, dy:Object, x:Number, y:Number, s:Number, z:Number;
				var o:Object = _t.$(d);
				dx = _xField.getValue(d); dy = _yField.getValue(d);
				
				var map:Object;
				if (_xField != null) {
					x = axes.xAxis.X(dx);
					if (_xStacks) {
						map = (dx < 0 ? xmapNeg : xmapPos);
						z = x - x0;
						s = z + (isNaN(s=map[dy]) ? 0 : s);
						o.x = x0 + s;
						o.w = z;
						map[dy] = s;
					} else {
						o.x = x;
						o.w = x - x0;
					}
				}
				if (_yField != null) {
					y = axes.yAxis.Y(dy);
					if (_yStacks) {
						map = (dy < 0 ? ymapNeg : ymapPos);
						z = y - y0;
						s = z + (isNaN(s=map[dx]) ? 0 : s);
						o.y = y0 + s;
						o.h = z;
						map[dx] = s;
					} else {
						o.y = y;
						o.h = y - y0;
					}
				}
			});
		}
		
		/** @private */
		protected function rescale():void {
			var xmapPos:Object = _xStacks ? new Object() : null;
			var xmapNeg:Object = _xStacks ? new Object() : null;
			var ymapPos:Object = _yStacks ? new Object() : null;
			var ymapNeg:Object = _yStacks ? new Object() : null;
			var xmax:Number = 0;
			var xmin:Number = 0;
			var ymax:Number = 0;
			var ymin:Number = 0;
			
			visualization.data.nodes.visit(function(d:DataSprite):void {
				var x:Object = _xField.getValue(d);
				var y:Object = _yField.getValue(d);
				var v:Number;
				
				if (_xStacks) {
					if (x < 0) { 
						v = isNaN(xmapNeg[y]) ? 0 : xmapNeg[y];
						xmapNeg[y] = v = (Number(x) + v);
						if (v < xmin) xmin = v;
					} else {
						v = isNaN(xmapPos[y]) ? 0 : xmapPos[y];
						xmapPos[y] = v = (Number(x) + v);
						if (v > xmax) xmax = v;
					}
				}
				if (_yStacks) {
					if (y < 0) {
						v = isNaN(ymapNeg[x]) ? 0 : ymapNeg[x];
						ymapNeg[x] = v = (Number(y) + v);
						if (v < ymin) ymin = v;
						
					} else {
						v = isNaN(ymapPos[x]) ? 0 : ymapPos[x];
						ymapPos[x] = v = (Number(y) + v);
						if (v > ymax) ymax = v;
					}
				}
			});
			
			if (_xStacks) {
				_xBinding.scaleType = ScaleType.LINEAR;
				_xBinding.preferredMin = xmin;
				_xBinding.preferredMax = xmax;
			}
			if (_yStacks) {
				_yBinding.scaleType = ScaleType.LINEAR;
				_yBinding.preferredMin = ymin;
				_yBinding.preferredMax = ymax;
			}
		}
		
	} // end of class AxisLayout
}