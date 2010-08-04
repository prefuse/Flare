package flare.vis.axis
{
	import flare.animate.Transitioner;
	import flare.display.TextSprite;
	import flare.scale.IScaleMap;
	import flare.scale.LinearScale;
	import flare.scale.Scale;
	import flare.scale.ScaleType;
	import flare.util.Arrays;
	import flare.util.Stats;
	import flare.util.Strings;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	/**
	 * A metric data axis consisting of axis labels and gridlines.
	 * 
	 * <p>Axis labels can be configured both in terms of text formatting,
	 * orientation, and position. Use the <code>labelOffsetX</code> or
	 * <code>labelOffsetY</code> property to adjust label positioning. For
	 * example, <code>labelOffsetX = -10;</code> places the anchor point for
	 * the label ten pixels to the left of the data bounds, whereas
	 * <code>labelOffsetX = 10;</code> will place the point 10 pixels to the
	 * right of the data bounds. One could simultaneously adjust the
	 * <code>horizontalAnchor</code> property to align the labels as desired.
	 * </p>
	 * 
	 * <p>Similarly, axis gridlines can also be configured. The
	 * <code>lineCapX1</code>, <code>lineCapX2</code>, <code>lineCapY1</code>,
	 * and <code>lineCapY2</code> properties determine by how much the
	 * grid lines should exceed the data bounds. For example,
	 * <code>lineCapX1 = 5</code> causes the grid line to extend an extra
	 * 5 pixels to the left. Each of these values should be greater than or
	 * equal to zero.</p>
	 */
	public class Axis extends Sprite implements IScaleMap
	{
		// children indices
		private static const LABELS:uint = 1;
        private static const GRIDLINES:uint = 0;
		
		// axis scale
		private var _prevScale:Scale;
		// axis settings
		private var _xa:Number=0, _ya:Number=0;   // start of the axis
		private var _xb:Number=0, _yb:Number=0;   // end of the axis
		private var _xaP:Number=0, _yaP:Number=0; // previous start of the axis
		private var _xbP:Number=0, _ybP:Number=0; // previous end of the axis
		private var _xd:int, _yd:int;             // axis directions (1 or -1)
		private var _xlo:Number, _ylo:Number;     // label offsets
		// gridline settings
		private var _lineColor:uint = 0xd8d8d8;
		private var _lineWidth:Number = 0;
		// label settings
		private var _numLabels:int = -1;
		private var _anchorH:int = TextSprite.LEFT;
		private var _anchorV:int = TextSprite.TOP;
		private var _labelAngle:Number = 0;
		private var _labelColor:uint = 0;
		private var _labelFormat:String = null;
		private var _labelTextMode:int = TextSprite.BITMAP;
		private var _labelTextFormat:TextFormat = new TextFormat("Arial",12,0);
		// temporary variables
		private var _point:Point = new Point();
		
		// -- Properties ------------------------------------------------------
		
		/** Sprite containing the axis labels. */
		public function get labels():Sprite { return getChildAt(LABELS) as Sprite; }
		/** Sprite containing the axis grid lines. */
		public function get gridLines():Sprite { return getChildAt(GRIDLINES) as Sprite; }
		
		/** @inheritDoc */
		public function get x1():Number { return _xa; }
		public function set x1(x:Number):void { _xa = x; }
		
		/** @inheritDoc */
		public function get y1():Number { return _ya; }
		public function set y1(y:Number):void { _ya = y; }
		
		/** @inheritDoc */
		public function get x2():Number { return _xb; }
		public function set x2(x:Number):void { _xb = x; }
		
		/** @inheritDoc */
		public function get y2():Number { return _yb; }
		public function set y2(y:Number):void { _yb = y; }

		/** The Scale used to map values to this axis. */
		public var axisScale:Scale;
		
		/** Flag indicating if axis labels should be shown. */
		public var showLabels:Boolean = true;
		
		/** Flag indicating if labels should be removed in case of overlap. */
		public var fixLabelOverlap:Boolean = true;
		
		/** Flag indicating if axis grid lines should be shown. */
		public var showLines:Boolean = true;
		
		/** X length of axis gridlines. */
		public var lineLengthX:Number = 0;
		
		/** Y length of axis gridlines. */
		public var lineLengthY:Number = 0;	
			
		/** X offset for axis gridlines at the lower end of the axis. */
		public var lineCapX1:Number = 0;
		
		/** X offset for axis gridlines at the upper end of the axis. */
		public var lineCapX2:Number = 0;
		
		/** Y offset for axis gridlines at the lower end of the axis. */
		public var lineCapY1:Number = 0;
		
		/** Y offset for axis gridlines at the upper end of the axis. */
		public var lineCapY2:Number = 0;
		
		/** X-dimension offset value for axis labels. If negative or zero, this
		 *  value indicates how much to offset to the left of the data bounds.
		 *  If positive, the offset is made to the right of the data bounds. */
		public var labelOffsetX:Number = 0;	
			
		/** Y-dimension offset value for axis labels. If negative or zero, this
		 *  value indicates how much to offset above the data bounds.
		 *  If positive, the offset is made beneath the data bounds.*/
		public var labelOffsetY:Number = 0;
		
		/** The line color of axis grid lines. */
		public function get lineColor():uint { return _lineColor; }
		public function set lineColor(c:uint):void { _lineColor = c; updateGridLines(); }
		
		/** The line width of axis grid lines. */
		public function get lineWidth():Number { return _lineWidth; }
		public function set lineWidth(w:Number):void { _lineWidth = w; updateGridLines(); }
		
		/** The color of axis label text. */
		public function get labelColor():uint { return _labelColor; }
		public function set labelColor(c:uint):void { _labelColor = c; updateLabels(); }
		
		/** The angle (orientation) of axis label text. */
		public function get labelAngle():Number { return _labelAngle; }
		public function set labelAngle(a:Number):void { _labelAngle = a; updateLabels(); }
		
		/** TextFormat (font, size, style) for axis label text. */
		public function get labelTextFormat():TextFormat { return _labelTextFormat; }
		public function set labelTextFormat(f:TextFormat):void { _labelTextFormat = f; updateLabels(); }
		
		/** The text rendering mode to use for label TextSprites.
		 *  @see flare.display.TextSprite. */
		public function get labelTextMode():int { return _labelTextMode; }
		public function set labelTextMode(m:int):void { _labelTextMode = m; updateLabels(); }
		
		/** String formatting pattern used for axis labels, overwrites any
		 *  formatting pattern used by the <code>axisScale</code>. If null,
		 *  the formatting pattern for the <code>axisScale</code> is used. */
		public function get labelFormat():String {
			return _labelFormat==null ? null 
					: _labelFormat.substring(3, _labelFormat.length-1);
		}
		public function set labelFormat(fmt:String):void {
			_labelFormat = "{0:"+fmt+"}"; updateLabels();
		}
		
		/** The number of labels and gridlines to generate by default. If this
		 *  number is zero or less (default -1), the number of labels will be
		 *  automatically determined from the current scale and size. */
		public function get numLabels():int {
			// if set positive, return number
			if (_numLabels > 0) return _numLabels;
			// if ordinal return all labels
			if (ScaleType.isOrdinal(axisScale.scaleType)) return -1;
			// otherwise determine based on axis size (random hack...)
			var lx:Number = _xb-_xa; if (lx<0) lx = -lx;
			var ly:Number = _yb-_ya; if (ly<0) ly = -ly;
			lx = (lx > ly ? lx : ly);
			return lx > 200 ? 10 : lx < 20 ? 1 : int(lx/20);
		}
		public function set numLabels(n:int):void { _numLabels = n; }
		
		/** The horizontal anchor point for axis labels.
		 *  @see flare.display.TextSprite. */
		public function get horizontalAnchor():int { return _anchorH; }
		public function set horizontalAnchor(a:int):void { _anchorH = a; updateLabels(); }
		
		/** The vertical anchor point for axis labels.
		 *  @see flare.display.TextSprite. */
		public function get verticalAnchor():int { return _anchorV; }
		public function set verticalAnchor(a:int):void { _anchorV = a; updateLabels(); }		
		
		/** The x-coordinate of the axis origin. */
		public function get originX():Number {
			return (ScaleType.isQuantitative(axisScale.scaleType) ? X(0) : x1);
		}
		/** The y-coordinate of the axis origin. */
		public function get originY():Number {
			return (ScaleType.isQuantitative(axisScale.scaleType) ? Y(0) : y1);
		}
		
		// -- Initialization --------------------------------------------------
		
		/**
		 * Creates a new Axis.
		 * @param axisScale the axis scale to use. If null, a linear scale
		 *  is assumed.
		 */
		public function Axis(axisScale:Scale=null)
        {
            this.axisScale = axisScale ? axisScale : new LinearScale();
            _prevScale = this.axisScale;
            initializeChildren();
        }

		/**
		 * Initializes the child container sprites for labels and grid lines.
		 */
        protected function initializeChildren():void
        {
            addChild(new Sprite()); // add gridlines
            addChild(new Sprite()); // add labels
        }
		
		// -- Updates ---------------------------------------------------------
		
		/**
		 * Updates this axis, performing filtering and layout as needed.
		 * @param trans a Transitioner for collecting value updates
		 * @return the input transitioner.
		 */
		public function update(trans:Transitioner):Transitioner
        {
        	var t:Transitioner = (trans!=null ? trans : Transitioner.DEFAULT);
        	
        	// compute directions and offsets
        	_xd  = lineLengthX < 0 ? -1 : 1;
        	_yd  = lineLengthY < 0 ? -1 : 1;
        	_xlo =  _xd*labelOffsetX + (labelOffsetX>0 ? lineLengthX : 0);
        	_ylo = -_yd*labelOffsetY + (labelOffsetY<0 ? lineLengthY : 0);
        	
        	// run updates
            filter(t);
            layout(t);
            updateLabels(); // TODO run through transitioner?
            updateGridLines(); // TODO run through transitioner?
            return trans;
        }
		
		// -- Lookups ---------------------------------------------------------
		
		/**
		 * Returns the horizontal offset along the axis for the input value.
		 * @param value an input data value
		 * @return the horizontal offset along the axis corresponding to the
		 *  input value. This is the x-position minus <code>x1</code>.
		 */
		public function offsetX(value:Object):Number
        {
        	return axisScale.interpolate(value) * (_xb - _xa);
        }
        
        /**
		 * Returns the vertical offset along the axis for the input value.
		 * @param value an input data value
		 * @return the vertical offset along the axis corresponding to the
		 *  input value. This is the y-position minus <code>y1</code>.
		 */
        public function offsetY(value:Object):Number
        {
        	return axisScale.interpolate(value) * (_yb - _ya);
        }

		/** @inheritDoc */
		public function X(value:Object):Number
        {
        	return _xa + offsetX(value);
        }
        
        /** @inheritDoc */
        public function Y(value:Object):Number
        {
        	return _ya + offsetY(value);
        }
        
        /** @inheritDoc */
        public function value(x:Number, y:Number, stayInBounds:Boolean=true):Object
        {
        	// project the input point onto the axis line
        	// (P-A).(B-A) / |B-A|^2 == fractional projection onto axis line
        	var dx:Number = (_xb-_xa);
        	var dy:Number = (_yb-_ya);
        	var f:Number = ((x-_xa)*dx + (y-_ya)*dy) / (dx*dx + dy*dy);
        	// correct bounds, if desired
        	if (stayInBounds) {
        		if (f < 0) f = 0;
        		if (f > 1) f = 1;
        	}
        	// lookup and return value
        	return axisScale.lookup(f);
        }
		
		/**
		 * Clears the previous axis scale used, if cached.
		 */
		public function clearPreviousScale():void
		{
			_prevScale = axisScale;
		}
		
		// -- Filter ----------------------------------------------------------
		
		/**
		 * Performs filtering, determining which axis labels and grid lines
		 * should be visible.
		 * @param trans a Transitioner for collecting value updates.
		 */
		protected function filter(trans:Transitioner) : void
		{
			var ordinal:uint = 0, i:uint, idx:int = -1, val:Object;
			var label:AxisLabel = null;
			var gline:AxisGridLine = null;
			var nl:uint = labels.numChildren;
			var ng:uint = gridLines.numChildren;
			
			var keepLabels:Array = new Array(nl);
			var keepLines:Array = new Array(ng);
			var values:Array = axisScale.values(numLabels);
			
			if (showLabels) { // process labels
				for (i=0, ordinal=0; i<values.length; ++i) {
					val = values[i];
					if ((idx = findLabel(val, nl)) < 0) {
						label = createLabel(val);
					} else {
						label = labels.getChildAt(idx) as AxisLabel;
						keepLabels[idx] = true;
					}
					label.ordinal = ordinal++;
				}
			}
			if (showLines) { // process gridlines
				for (i=0, ordinal=0; i<values.length; ++i) {
					val = values[i];
					if ((idx = findGridLine(val, ng)) < 0) {
						gline = createGridLine(val);
					} else {
						gline = gridLines.getChildAt(idx) as AxisGridLine;
						keepLines[idx] = true;
					}
					gline.ordinal = ordinal++;
				}
			}
			markRemovals(trans, keepLabels, labels);
			markRemovals(trans, keepLines, gridLines);
		}
		
		/**
		 * Marks all items slated for removal from this axis.
		 * @param trans a Transitioner for collecting value updates.
		 * @param keep a Boolean array indicating which items to keep
		 * @param con a container Sprite whose contents should be marked
		 *  for removal
		 */
		protected function markRemovals(trans:Transitioner, keep:Array, con:Sprite) : void
		{
			for (var i:uint = keep.length; --i >= 0; ) {
				if (!keep[i]) trans.removeChild(con.getChildAt(i));
			}
		}
		
		// -- Layout ----------------------------------------------------------
		
		/**
		 * Performs layout, setting the position of labels and grid lines.
		 * @param trans a Transitioner for collecting value updates.
		 */
		protected function layout(trans:Transitioner) : void
		{
			var i:uint, label:AxisLabel, gline:AxisGridLine, p:Point;
			var _lab:Sprite = this.labels;
			var _gls:Sprite = this.gridLines;
			var o:Object;
			
			// layout labels
			for (i=0; i<_lab.numChildren; ++i) {
				label = _lab.getChildAt(i) as AxisLabel;
				p = positionLabel(label, axisScale);
				
				o = trans.$(label);
				o.x = p.x;
				o.y = p.y;
				o.alpha = trans.willRemove(label) ? 0 : 1;
			}
			// fix label overlap
			if (fixLabelOverlap) fixOverlap(trans);
			// layout gridlines
			for (i=0; i<_gls.numChildren; ++i) {
				gline = _gls.getChildAt(i) as AxisGridLine;
				p = positionGridLine(gline, axisScale);
				
				o = trans.$(gline);
				o.x1 = p.x;
				o.y1 = p.y;
				o.x2 = p.x + lineLengthX + _xd*(lineCapX1+lineCapX2);
				o.y2 = p.y + lineLengthY + _yd*(lineCapY1+lineCapY2);
				o.alpha = trans.willRemove(gline) ? 0 : 1;
			}
			// update previous scale
			_prevScale = axisScale.clone(); // clone scale
			_xaP = _xa; _yaP = _ya; _xbP = _xb; _ybP = _yb;
		}
		
		// -- Label Overlap ---------------------------------------------------
		
		/**
		 * Eliminates overlap between labels along an axis. 
		 * @param trans a transitioner, potentially storing label positions
		 */		
		protected function fixOverlap(trans:Transitioner):void
		{
			var labs:Array = [], d:DisplayObject, i:int;
			// collect and sort labels
			for (i=0; i<labels.numChildren; ++i) {
				var s:AxisLabel = AxisLabel(labels.getChildAt(i));
				if (!trans.willRemove(s)) labs.push(s);
			}
			if (labs.length == 0) return;
			labs.sortOn("ordinal", Array.NUMERIC);
			
			// stores the labels to remove
			var rem:Dictionary = new Dictionary();
			
			if (axisScale.scaleType == ScaleType.LOG) {
				fixLogOverlap(labs, rem, trans, axisScale);
			}
			
			// maintain min and max if we get down to two
			i = labs.length;
			var min:Object = labs[0];
			var max:Object = labs[i-1];
			var mid:Object = (i&1) ? labs[(i>>1)] : null;

			// fix overlap with an iterative optimization
			// remove every other label with each iteration
			while (hasOverlap(labs, trans)) {
				// reduce labels
				i = labs.length;
				if (mid && i>3 && i<8) { // use min, med, max if we can
					for each (d in labs) rem[d] = d;
					if (rem[min]) delete rem[min];
					if (rem[max]) delete rem[max];
					if (rem[mid]) delete rem[mid];
					labs = [min, mid, max];
				}
				else if (i < 4) { // use min and max if we're down to two
					if (rem[min]) delete rem[min];
					if (rem[max]) delete rem[max];
					for each (d in labs) {
						if (d != min && d != max) rem[d] = d;
					}
					break;
				}
				else { // else remove every odd element
					i = i - (i&1 ? 2 : 1);
					for (; i>0; i-=2) {
						rem[labs[i]] = labs[i];
						labs.splice(i, 1); // remove from array
					}
				}
			}
			
			// remove the deleted labels
			for each (d in rem) {
				trans.$(d).alpha = 0;
				trans.removeChild(d, true);
			}
		}
		
		private static function fixLogOverlap(labs:Array, rem:Dictionary,
			trans:Transitioner, scale:Scale):void
		{
				var base:int = int(Object(scale).base), i:int, j:int, zidx:int;
				if (!hasOverlap(labs, trans)) return;
				
				// find zero
				zidx = Arrays.binarySearch(labs, 0, "value");
				var neg:Boolean = Number(scale.min) < 0;
				var pos:Boolean = Number(scale.max) > 0;
				
				// if includes negative, traverse backwards from zero/end
				if (neg) {
					i = (zidx<0 ? labs.length : zidx) - (pos ? 1 : 2);
					for (j=pos?1:2; i>=0; ++j, --i) {
						if (j == base) {
							j = 1;
						} else {
							rem[labs[i]] = labs[i];
							labs.splice(i, 1); --zidx;
						}
					}
				}
				// if includes positive, traverse forwards from zero/start
				if (pos) {
					i = (zidx<0 ? 0 : zidx+1) + (neg ? 0 : 1);
					for (j=neg?1:2; i<labs.length; ++j) {
						if (j == base) {
							j = 1; ++i;
						} else {
							rem[labs[i]] = labs[i];
							labs.splice(i, 1);
						}
					}
				}
		}
		
		private static function hasOverlap(labs:Array, trans:Transitioner):Boolean
		{
			var d:DisplayObject = labs[0], e:DisplayObject;
			for (var i:int=1; i<labs.length; ++i) {
				if (overlaps(trans, d, (e=labs[i]))) return true;
				d = e;
			}
			return false;
		}
		
		/**
		 * Indicates if two display objects overlap, sensitive to any target
		 * values stored in a transitioner.
		 * @param trans a Transitioner, potentially with target values
		 * @param l1 a display object
		 * @param l2 a display object
		 * @return true if the objects overlap (considering values in the
		 *  transitioner, if appropriate), false otherwise
		 */
		private static function overlaps(trans:Transitioner,
			l1:DisplayObject, l2:DisplayObject):Boolean
		{
			if (trans.immediate) return l1.hitTestObject(l2);
			// get original co-ordinates
			var xa:Number = l1.x, ya:Number = l1.y;
			var xb:Number = l2.x, yb:Number = l2.y;
			var o:Object;
			// set to target co-ordinates
			o = trans.$(l1); l1.x = o.x; l1.y = o.y;
			o = trans.$(l2); l2.x = o.x; l2.y = o.y;
			// compute overlap
			var b:Boolean = l1.hitTestObject(l2);
			// reset to original coordinates
			l1.x = xa; l1.y = ya; l2.x = xb; l2.y = yb;
			return b;
		}
		
		// -- Axis Label Helpers ----------------------------------------------
		
		/**
		 * Creates a new axis label.
		 * @param val the value to create the label for
		 * @return an AxisLabel
		 */		
		protected function createLabel(val:Object) : AxisLabel
		{
			var label:AxisLabel = new AxisLabel();
			var f:Number = _prevScale.interpolate(val);
			label.alpha = 0;
			label.value = val;
			label.x = _xlo + _xaP + f*(_xbP - _xaP);
			label.y = _ylo + _yaP + f*(_ybP - _yaP);
			updateLabel(label);
			labels.addChild(label);
			return label;
		}
		
		/**
		 * Computes the position of an axis label.
		 * @param label the axis label to layout
		 * @param scale the scale used to map values to the axis
		 * @return a Point with x,y coordinates for the axis label
		 */
		protected function positionLabel(label:AxisLabel, scale:Scale) : Point
		{
			var f:Number = scale.interpolate(label.value);
			_point.x = _xlo + _xa + f*(_xb-_xa);
			_point.y = _ylo + _ya + f*(_yb-_ya);
			return _point;
		}
		
		/**
		 * Updates an axis label's settings
		 * @param label the label to update
		 */		
		protected function updateLabel(label:AxisLabel) : void
		{
			label.textFormat = _labelTextFormat;
			label.horizontalAnchor = _anchorH;
			label.verticalAnchor = _anchorV;
			label.rotation = (180/Math.PI) * _labelAngle;
			label.textMode = _labelTextMode;
			label.text = _labelFormat==null ? axisScale.label(label.value)
					   : Strings.format(_labelFormat, label.value);
		}
		
		/**
		 * Updates all axis labels.
		 */		
		protected function updateLabels() : void
		{
			var _labels:Sprite = this.labels;
			for (var i:uint = 0; i<_labels.numChildren; ++i) {
				updateLabel(_labels.getChildAt(i) as AxisLabel);
			}
		}
		
		/**
		 * Returns the index of a label in the label's container sprite for a
		 * given data value.
		 * @param val the data value to find
		 * @param len the number of labels to check
		 * @return the index of a label with matching value, or -1 if no label
		 *  was found
		 */		
		protected function findLabel(val:Object, len:uint) : int
		{
			var _labels:Sprite = this.labels;
			for (var i:uint = 0; i < len; ++i) {
				// TODO: make this robust to repeated values
				if (Stats.equal((_labels.getChildAt(i) as AxisLabel).value, val)) {
					return i;
				}
			}
			return -1;
		}
		
		// -- Axis GridLine Helpers -------------------------------------------
		
		/**
		 * Creates a new axis grid line.
		 * @param val the value to create the grid lines for
		 * @return an AxisGridLine
		 */	
		protected function createGridLine(val:Object) : AxisGridLine
		{
			var gline:AxisGridLine = new AxisGridLine();
			var f:Number = _prevScale.interpolate(val);
			gline.alpha = 0;
			gline.value = val;
			gline.x1 = _xaP + f*(_xbP-_xaP) - _xd*lineCapX1;
			gline.y1 = _yaP + f*(_ybP-_yaP) - _yd*lineCapY1;
			gline.x2 = gline.x1 + lineLengthX + _xd*(lineCapX1 + lineCapX2)
			gline.y2 = gline.y1 + lineLengthY + _yd*(lineCapY1 + lineCapY2);
			updateGridLine(gline);
			gridLines.addChild(gline);
			return gline;
		}
		
		/**
		 * Computes the position of an axis grid line.
		 * @param gline the axis grid line to layout
		 * @param scale the scale used to map values to the axis
		 * @return a Point with x,y coordinates for the axis grid line
		 */
		protected function positionGridLine(gline:AxisGridLine, scale:Scale) : Point
		{
			var f:Number = scale.interpolate(gline.value);
			_point.x = _xa + f*(_xb-_xa) - _xd*lineCapX1;
			_point.y = _ya + f*(_yb-_ya) - _yd*lineCapY1;
			return _point;
		}
		
		/**
		 * Updates an axis grid line's settings
		 * @param gline the grid line to update
		 */
		protected function updateGridLine(gline:AxisGridLine) : void
		{
			gline.lineColor = _lineColor;
			gline.lineWidth = _lineWidth;
		}
		
		/**
		 * Updates all grid lines.
		 */
		protected function updateGridLines() : void
		{
			var _glines:Sprite = this.gridLines;
			for (var i:uint = 0; i<_glines.numChildren; ++i) {
				updateGridLine(_glines.getChildAt(i) as AxisGridLine);
			}
		}
		
		/**
		 * Returns the index of a grid lines in the line's container sprite
		 * for a given data value.
		 * @param val the data value to find
		 * @param len the number of grid lines to check
		 * @return the index of a grid line with matching value, or -1 if no
		 *  grid line was found
		 */	
		protected function findGridLine(val:Object, len:uint) : int
		{
			var _glines:Sprite = this.gridLines;
			for (var i:uint = 0; i<len; ++i) {
				// TODO: make this robust to repeated values
				if (Stats.equal((_glines.getChildAt(i) as AxisGridLine).value, val)) {
					return i;
				}
			}
			return -1;
		}
		
	} // end of class Axis
}