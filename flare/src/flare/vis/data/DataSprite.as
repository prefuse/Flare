package flare.vis.data
{
	import flare.display.DirtySprite;
	import flare.util.Colors;
	import flare.vis.data.render.IRenderer;
	import flare.vis.data.render.ShapeRenderer;

	/**
	 * Base class for display objects that represent visualized data.
	 * DataSprites support a number of visual properties beyond those provided
	 * by normal sprites. These include properties for colors, shape, size,
	 * setting the position in polar coordinates (<code>angle</code> and
	 * <code>radius</code>), and others.
	 * 
	 * <p>The actual appearance of DataSprite instances are determined using
	 * pluggable renderers that draw graphical content for the sprite. These
	 * renderers can be changed at runtime to dynamically control appearances.
	 * Furthermore, since these are sprites, they can contain arbitrary display
	 * objects as children on the display list, including entire nested
	 * visualizations.</p>
	 * 
	 * <p>DataSprites provides two additional properties worth noting. First,
	 * the <code>data</code> property references an object containing backing
	 * data to be visualized. This data object is typically the data record
	 * (or tuple) this DataSprite visually represents, and its values are often
	 * used to determined visual encodings. Second, the <code>props</code>
	 * objects is a dynamic object provided for attaching arbitrary properties
	 * to a DataSprite instance. For example, some layout algorithms require
	 * additional parameters on a per-item basis and store these values in the
	 * <code>props</code> property.</p>
	 */
	public class DataSprite extends DirtySprite
	{
		// -- Properties ------------------------------------------------------
		
		/** The renderer for drawing this DataSprite. */
		protected var _renderer:IRenderer = ShapeRenderer.instance;
		/** Selection state for this DataSprite. */
		protected var _selected:Boolean = false;
		/** Object storing backing data values. */
		protected var _data:Object = {};
		/** Object for attaching additional properties to this sprite. */
		protected var _prop:Object = {};
		
		/** Fixed flag to prevent this sprite from being re-positioned. */
		protected var _fixed:int = 0;
		/** The fill color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		protected var _fillColor:uint = 0xffcccccc;
		/** The line color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		protected var _lineColor:uint = 0xff000000;
		/** The line width for this data sprite. */
		protected var _lineWidth:Number = 0;

		/** Optional array of x,y values for specifying arbitrary shapes. */
		protected var _points:Array;
		/** Code indicating the shape value of this data sprite. */
		protected var _shape:String = "circle";
		/** The size value of this data sprite (1 by default). */
		protected var _size:Number = 1;
		
		/** Auxiliary property often used as a width parameter. */
		protected var _w:Number = 0;
		/** Auxiliary property often used as a height parameter. */
		protected var _h:Number = 0;
		/** Auxiliary property often used as a shape parameter. */
		protected var _u:Number = 0;
		/** Auxiliary property often used as a shape parameter. */
		protected var _v:Number = 0;
		
		// -- General Properties -------------------------------
		
		/** The renderer for drawing this DataSprite. */
		public function get renderer():IRenderer { return _renderer; }
		public function set renderer(r:IRenderer):void { _renderer = r; dirty(); }
		
		/** Flag indicating if this node is currently selected. This flag can
		 *  be used by renderers to display selection state. */
		public function get selected():Boolean { return _selected; }
		public function set selected(b:Boolean):void { if (b != _selected) {_selected = b; dirty(); } }	
		
		/** Object storing backing data values. */
		public function get data():Object { return _data; }
		public function set data(d:Object):void { _data = d; }
		
		/** Object for attaching additional properties to this sprite. */
		public function get props():Object { return _prop; }
		public function set props(p:Object):void { _prop = p; _prop.self = this; }
		
		// -- Interaction Properties ---------------------------
		
		/** Fixed flag to prevent this sprite from being re-positioned. */
		public function get fixed():Boolean { return _fixed > 0; }
		/**
		 * Increments the fixed counter. If the fixed counter is greater than
		 * zero, the data sprite should be fixed. A counter is used so that if
		 * different components both adjust the fixed settings, they won't
		 * overwrite each other.
		 * @param num the amount to increment the counter by (default 1)
		 */
		public function fix(num:uint=1):void { _fixed += num; }
		/**
		 * Decrements the fixed counter. If the fixed counter is greater than
		 * zero, the data sprite should be fixed. A counter is used so that if
		 * different components both adjust the fixed settings, they won't
		 * overwrite each other. This method does not allow the fixed counter
		 * to go below zero.
		 * @param num the amount to decrement the counter by (default 1)
		 */
		public function unfix(num:uint=1):void { _fixed = Math.max(0, _fixed-num); }
		 
		// -- Visual Properties --------------------------------

		/** Auxiliary property often used as a shape parameter. */
		public function get u():Number { return _u; }
		public function set u(u:Number):void { _u = u; dirty(); }
		
		/** Auxiliary property often used as a shape parameter. */
		public function get v():Number { return _v; }
		public function set v(v:Number):void { _v = v; dirty(); }
		
		/** Auxiliary property often used as a width parameter. */
		public function get w():Number { return _w; }
		public function set w(v:Number):void { _w = v; dirty(); }
		
		/** Auxiliary property often used as a height parameter. */
		public function get h():Number { return _h; }
		public function set h(v:Number):void { _h = v; dirty(); }
		
		/** The fill color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public function get fillColor():uint { return _fillColor; }
		public function set fillColor(c:uint):void { _fillColor = c; dirty();	}
		/** The alpha channel (a value between 0 and 1) for the fill color. */
		public function get fillAlpha():Number { return Colors.a(_fillColor) / 255; }
		public function set fillAlpha(a:Number):void {
			_fillColor = Colors.setAlpha(_fillColor, uint(255*a)%256);
			dirty();
		}
		/** The hue component of the fill color in HSV color space. */
		public function get fillHue():Number { return Colors.hue(_fillColor); }
		public function set fillHue(h:Number):void {
			_fillColor = Colors.hsv(h, Colors.saturation(_fillColor),
				Colors.value(_fillColor), Colors.a(_fillColor));
			dirty();
		}
		/** The saturation component of the fill color in HSV color space. */
		public function get fillSaturation():Number { return Colors.saturation(_fillColor); }
		public function set fillSaturation(s:Number):void {
			_fillColor = Colors.hsv(Colors.hue(_fillColor), s,
				Colors.value(_fillColor), Colors.a(_fillColor));
			dirty();
		}
		/** The value (brightness) component of the fill color in HSV color space. */
		public function get fillValue():Number { return Colors.value(_fillColor); }
		public function set fillValue(v:Number):void {
			_fillColor = Colors.hsv(Colors.hue(_fillColor),
				Colors.saturation(_fillColor), v, Colors.a(_fillColor));
			dirty();
		}
				
		/** The line color for this data sprite. This value is specified as an
		 *  unsigned integer representing an ARGB color. Notice that this
		 *  includes the alpha channel in the color value. */
		public function get lineColor():uint { return _lineColor; }
		public function set lineColor(c:uint):void { _lineColor = c; dirty(); }
		/** The alpha channel (a value between 0 and 1) for the line color. */
		public function get lineAlpha():Number { return Colors.a(_lineColor) / 255; }
		public function set lineAlpha(a:Number):void {
			_lineColor = Colors.setAlpha(_lineColor, uint(255*a)%256);
			dirty();
		}
		/** The hue component of the line color in HSV color space. */
		public function get lineHue():Number { return Colors.hue(_lineColor); }
		public function set lineHue(h:Number):void {
			_lineColor = Colors.hsv(h, Colors.saturation(_lineColor),
				Colors.value(_lineColor), Colors.a(_lineColor));
			dirty();
		}
		/** The saturation component of the line color in HSV color space. */
		public function get lineSaturation():Number { return Colors.saturation(_lineColor); }
		public function set lineSaturation(s:Number):void {
			_lineColor = Colors.hsv(Colors.hue(_lineColor), s,
				Colors.value(_lineColor), Colors.a(_lineColor));
			dirty();
		}
		/** The value (brightness) component of the line color in HSV color space. */
		public function get lineValue():Number { return Colors.value(_lineColor); }
		public function set lineValue(v:Number):void {
			_lineColor = Colors.hsv(Colors.hue(_lineColor),
				Colors.saturation(_lineColor), v, Colors.a(_lineColor));
			dirty();
		}
		
		/** The line width for this data sprite. */
		public function get lineWidth():Number { return _lineWidth; }
		public function set lineWidth(w:Number):void { _lineWidth = w; dirty(); }

		/** The size value of this data sprite (1 by default). */
		public function get size():Number { return _size; }
		public function set size(s:Number):void { _size = s; dirty(); }

		/** Name of the shape value of this data sprite. 
		 *  @see flare.vis.util.Shapes */
		public function get shape():String { return _shape; }
		public function set shape(s:String):void { _shape = s; dirty(); }
		
		/** Optional array of x,y values for specifying arbitrary shapes. */
		public function get points():Array { return _points; }
		public function set points(p:Array):void { _points = p; dirty(); }
		
		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new DataSprite.
		 */		
		public function DataSprite() {
			super();
			_prop.self = this;
		}
		
		/** @inheritDoc */
		public override function render() : void
		{
			if (_renderer != null && !isNaN(size)) {
				_renderer.render(this);
			} else {
				this.graphics.clear();
			}
		}

	} // end of class DataSprite
}