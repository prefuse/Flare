package flare.vis.operator.layout
{
	import flare.scale.LinearScale;
	import flare.scale.OrdinalScale;
	import flare.scale.QuantitativeScale;
	import flare.scale.Scale;
	import flare.scale.TimeScale;
	import flare.util.Arrays;
	import flare.util.Maths;
	import flare.util.Orientation;
	import flare.util.Stats;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Rectangle;
	
	/**
	 * Layout that consecutively places items on top of each other. The layout
	 * currently assumes that each column value is available as separate
	 * properties of individual DataSprites.
	 */
	public class StackedAreaLayout extends Layout
	{
		// -- Properties ------------------------------------------------------
		
		private var _columns:Array;
    	private var _peaks:Array;
    	private var _poly:Array;
		
		private var _orient:String = Orientation.BOTTOM_TO_TOP;
		private var _horiz:Boolean = false;
		private var _top:Boolean = false;
		private var _initAxes:Boolean = true;
		
		private var _normalize:Boolean = false;
		private var _padding:Number = 0.05;
		private var _threshold:Number = 1.0;
		
		private var _scale:QuantitativeScale = new LinearScale(0,0,10,true);
		private var _colScale:Scale;
		
		/** Array containing the column names. */
		public function get columns():Array { return _columns; }
		public function set columns(cols:Array):void {
			_columns = Arrays.copy(cols);
			_peaks = new Array(cols.length);
			_poly = new Array(cols.length);
			_colScale = getScale(_columns);
		}
		
		/** Flag indicating if the visualization should be normalized. */		
		public function get normalize():Boolean { return _normalize; }
		public function set normalize(b:Boolean):void { _normalize = b; }
		
		/** Value indicating the padding (as a percentage of the view)
		 *  that should be reserved within the visualization. */
		public function get padding():Number { return _padding; }
		public function set padding(p:Number):void {
			if (p<0 || isNaN(p) || !isFinite(p)) return;
			_padding = p;
		}
		
		/** Threshold size value (in pixels) that at least one column width
		 *  must surpass for a stack to remain visible. */
		public function get threshold():Number { return _threshold; }
		public function set threshold(t:Number):void { _threshold = t; }
		
		/** The orientation of the layout. */
		public function get orientation():String { return _orient; }
		public function set orientation(o:String):void {
			_orient = o;
			_horiz = Orientation.isHorizontal(_orient);
        	_top   = (_orient == Orientation.TOP_TO_BOTTOM ||
        			  _orient == Orientation.LEFT_TO_RIGHT);
        	initializeAxes();
		}
		
		/** The scale used to layout the stacked values. */
		public function get scale():QuantitativeScale { return _scale; }
		public function set scale(s:QuantitativeScale):void {
			_scale = s; _scale.dataMin = 0;
		}
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new StackedAreaLayout.
		 * @param cols an ordered array of properties for the column values
		 * @param padding percentage of space to leave as a padding margin
		 *  for the stacked chart
		 */		
		public function StackedAreaLayout(cols:Array=null, padding:Number=0.05)
		{
			layoutType = CARTESIAN;
			if (cols != null) this.columns = cols;
			this.padding = padding;
		}
		
		private static function getScale(cols:Array):Scale
		{
			var stats:Stats = new Stats(cols);
			switch (stats.dataType) {
				case Stats.NUMBER:
					return new LinearScale(stats.minimum, stats.maximum, 10, true);
				case Stats.DATE:
					return new TimeScale(stats.minDate, stats.maxDate, true);
				case Stats.OBJECT:
				default:
					return new OrdinalScale(stats.distinctValues, true, false);
			}
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			if (!_initAxes || visualization==null) return;
			initializeAxes();
			(_horiz ? xyAxes.yAxis : xyAxes.xAxis).showLines = false;
		}
		
		/**
		 * Initializes the axes prior to layout.
		 */
		protected function initializeAxes():void
		{
			if (!_initAxes || visualization==null) return;
			var axes:CartesianAxes = xyAxes;
			if (_horiz) {
				axes.xAxis.axisScale = _scale;
				axes.yAxis.axisScale = _colScale;
			} else {
				axes.xAxis.axisScale = _colScale;
				axes.yAxis.axisScale = _scale;
			}
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
	        // get the orientation specifics sorted out
	        var bounds:Rectangle = layoutBounds;
	        var hgt:Number, wth:Number;
	        var xbias:int, ybias:int, sign:int, len:int;
	        hgt = (_horiz ? bounds.width : bounds.height);
	        wth = (_horiz ? -bounds.height : bounds.width);
	        xbias = (_horiz ? 1 : 0);
	        ybias = (_horiz ? 0 : 1);
	        sign = _top ? 1 : -1;
	        len = _columns.length;

	        var minX:Number = _horiz ? bounds.bottom : bounds.left;
	        var minY:Number = _horiz ? (_top ? bounds.left : bounds.right)
	                                 : (_top ? bounds.top : bounds.bottom);
	                                 
			// perform first walk to get the data distribution
	        _scale.dataMax = peaks();
	        initializeAxes();
	        
	        // initialize current polygon
	        var axes:CartesianAxes = super.xyAxes;
	        var scale:Scale = (_horiz ? axes.yAxis : axes.xAxis).axisScale;
	        var xx:Number;
	        for (var j:uint=0; j<len; ++j) {
				xx = minX + wth * scale.interpolate(_columns[j]);
	            _poly[2*(len+j)+xbias] = xx;
	            _poly[2*(len+j)+ybias] = minY;
	            _poly[2*(len-1-j)+xbias] = xx;
	            _poly[2*(len-1-j)+ybias] = minY;
	        }
	        
	        // perform second walk to compute polygon layout
	        visualization.data.nodes.visit(function(d:NodeSprite):void
	        {
	        	var obj:Object = _t.$(d);
	        	var height:Number = 0, i:uint;
	        	var visible:Boolean = d.visible && d.alpha>0;
	        	var filtered:Boolean = !obj.visible;
	        	
	        	// set full polygon to current baseline
	            for (i=0; i<len; ++i) {
	            	_poly[2*(len-1-i)+ybias] = _poly[2*(len+i)+ybias];
	            }
	            
	            // if not visible, flatten on current baseline
	        	if (!visible || filtered) {
	        		if (!visible || _t.immediate) {
	        			// if already hidden, skip transitioner
	        			d.points = Arrays.copy(_poly, d.points);
	        		} else {
	        			// otherwise interpolate the change
	        			obj.points = Arrays.copy(_poly, d.props.poly);
	        		}
	        		return;
	        	}
	        	if (d.points == null) d.points = Arrays.copy(_poly);
	        	
	        	// if visible, compute the new heights
	            for (i=0; i<len; ++i) {
	                var base:int = 2*(len+i), h:Number;
	                var value:Number = d.data[_columns[i]];
	                
	                if (_normalize) {
	                	_poly[base+ybias] += sign * hgt * Maths.invLinearInterp(value,0,_peaks[i]);
	                } else {
	                	_poly[base+ybias] += sign * hgt * _scale.interpolate(value);
	                }
	                
	                h = Math.abs(_poly[2*(len-1-i)+ybias] - _poly[base+ybias]);
	                if (h > height) height = h;
	            }
	            
	            // if size is beneath threshold, then hide
	            if (height < _threshold) {
	            	d.visible = false;
	            }
	            
	            // update data sprite layout
	            obj.x = 0; obj.y = 0;
	            if (_t.immediate) {
	            	d.points = Arrays.copy(_poly, d.points);
	            } else {
	            	obj.points = Arrays.copy(_poly, d.props.poly);
	            }
	        }, null, true);
		}
		
		private function peaks():Number
		{
			var sum:Number = 0;
	        
	        // first, compute max value of the current data
	        Arrays.fill(_peaks, 0);
	        visualization.data.nodes.visit(function(d:NodeSprite):void {
	        	if (!d.visible || d.alpha <= 0 || !_t.$(d).visible)
	        		return;
	        	
	        	for (var i:uint=0; i<_columns.length; ++i) {
	        		var val:Number = d.data[_columns[i]];
	        		_peaks[i] += val;
	        		sum += val;
	        	}
	        });
	        var max:Number = Arrays.max(_peaks);
	        
	        // update peaks array as needed
	        // adjust peaks to include padding space
	        if (!_normalize) {
	        	Arrays.fill(_peaks, max);
	            for (var i:uint=0; i<_peaks.length; ++i) {
	                _peaks[i] += _padding * _peaks[i];
	            }
	            max += _padding*max;
	        }
	        
	        // return max range value
	        if (_normalize) max = 1.0;
	        if (isNaN(max)) max = 0;
	        return max;
		}
		
	} // end of class StackedAreaLayout
}