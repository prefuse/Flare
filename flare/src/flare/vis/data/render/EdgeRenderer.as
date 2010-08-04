package flare.vis.data.render
{
	import flare.util.Geometry;
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Renderer that draws edges as lines. The EdgeRenderer supports straight
	 * lines, poly lines, and curves as Bezier or cardinal splines. The type
	 * of edge drawn is determined from an EdgeSprite's <code>shape</code>
	 * property and control points found in the <code>points</code> property.
	 * The line rendering properties are set by the <code>setLineStyle</code>
	 * method, which can be overridden by subclasses. By default, the line
	 * rendering settings are determined using default property values set
	 * on this class (for example, the <code>scaleMode<code> and 
	 * <code>caps</code> properties).
	 */
	public class EdgeRenderer implements IRenderer
	{		
		private static const ROOT3:Number = Math.sqrt(3);
		
		private static var _instance:EdgeRenderer = new EdgeRenderer();
		/** Static EdgeRenderer instance. */
		public static function get instance():EdgeRenderer { return _instance; }
		
		/** Pixel hinting flag for line rendering. */
		public var pixelHinting:Boolean = false;
		/** Scale mode for line rendering (normal by default). */
		public var scaleMode:String = "normal";
		/** The joint style for line rendering. */
		public var joints:String = null;
		/** The caps style for line rendering. */
		public var caps:String = null;
		/** The miter limit for line rendering. */
		public var miterLimit:int = 3;
		
		// temporary variables
		private var _p:Point = new Point(), _q:Point = new Point();
		private var _pts:Array = new Array(20);
		
		/** @inheritDoc */
		public function render(d:DataSprite):void
		{
			var e:EdgeSprite = d as EdgeSprite;
			if (e == null) { return; } // TODO: throw exception?
			var s:NodeSprite = e.source;
			var t:NodeSprite = e.target;
			var g:Graphics = e.graphics;
			
			var ctrls:Array = e.points as Array;
			var x1:Number = e.x1, y1:Number = e.y1;
			var x2:Number = e.x2, y2:Number = e.y2;
			var xL:Number = ctrls==null ? x1 : ctrls[ctrls.length-2];
			var yL:Number = ctrls==null ? y1 : ctrls[ctrls.length-1];
			var dx:Number, dy:Number, dd:Number;

			// modify end points as needed to accomodate arrow
			if (e.arrowType != ArrowType.NONE)
			{
				// determine arrow head size
				var ah:Number = e.arrowHeight, aw:Number = e.arrowWidth/2;
				if (ah < 0 && aw < 0)
					aw = 1.5 * e.lineWidth;
				if (ah < 0) {
					ah = ROOT3 * aw;
				} else if (aw < 0) {
					aw = ah / ROOT3;
				}
				
				// get arrow tip point as intersection of edge with bounding box
				if (t==null) {
					_p.x = x2; _p.y = y2;
				} else {
					var r:Rectangle = t.getBounds(t.parent);
					if (Geometry.intersectLineRect(xL,yL,x2,y2, r, _p,_q) <= 0)
					{
						_p.x = x2; _p.y = y2;
					}
				}
				
				// get unit vector along arrow line
				dx = _p.x - xL; dy = _p.y - yL;
				dd = Math.sqrt(dx*dx + dy*dy);
				dx /= dd; dy /= dd;
				
				// set final point positions
				dd = e.lineWidth/2;
				// if drawing as lines, offset arrow tip by half the line width
				if (e.arrowType == ArrowType.LINES) {
					_p.x -= dd*dx;
					_p.y -= dd*dy;
					dd += e.lineWidth;
				}
				// offset the anchor point (the end point for the edge connector)
				// so that edge doesn't "overshoot" the arrow head
				dd = ah - dd;
				x2 = _p.x - dd*dx;
				y2 = _p.y - dd*dy;
			}

			// draw the edge
			g.clear(); // clear it out
			setLineStyle(e, g); // set the line style
			if (e.shape == Shapes.BEZIER && ctrls != null && ctrls.length > 1) {
				if (ctrls.length < 4)
				{
					g.moveTo(x1, y1);
					g.curveTo(ctrls[0], ctrls[1], x2, y2);
				}
				else
				{
					Shapes.drawCubic(g, x1, y1, ctrls[0], ctrls[1],
									 ctrls[2], ctrls[3], x2, y2);
				}
			}
			else if (e.shape == Shapes.CARDINAL)
			{
				Shapes.consolidate(x1, y1, ctrls, x2, y2, _pts);
				Shapes.drawCardinal(g, _pts, 2+ctrls.length/2);
			}
			else if (e.shape == Shapes.BSPLINE)
			{
				Shapes.consolidate(x1, y1, ctrls, x2, y2, _pts);
				Shapes.drawBSpline(g, _pts, 2+ctrls.length/2);
			}
			else
			{
				g.moveTo(x1, y1);
				if (ctrls != null) {
					for (var i:uint=0; i<ctrls.length; i+=2)
						g.lineTo(ctrls[i], ctrls[i+1]);
				}
				g.lineTo(x2, y2);
			}
			
			// draw an arrow
			if (e.arrowType != ArrowType.NONE) {
				// get other arrow points
				x1 = _p.x - ah*dx + aw*dy; y1 = _p.y - ah*dy - aw*dx;
				x2 = _p.x - ah*dx - aw*dy; y2 = _p.y - ah*dy + aw*dx;
								
				if (e.arrowType == ArrowType.TRIANGLE) {
					g.lineStyle();
					g.moveTo(_p.x, _p.y);
					g.beginFill(e.lineColor, e.lineAlpha);
					g.lineTo(x1, y1);
					g.lineTo(x2, y2);
					g.endFill();
				} else if (e.arrowType == ArrowType.LINES) {
					g.moveTo(x1, y1);
					g.lineTo(_p.x, _p.y);
					g.lineTo(x2, y2);
				}
			}
		}
		
		/**
		 * Sets the line style for edge rendering.
		 * @param e the EdgeSprite to render
		 * @param g the Graphics context to draw with
		 */
		protected function setLineStyle(e:EdgeSprite, g:Graphics):void
		{
			var lineAlpha:Number = e.lineAlpha;
			if (lineAlpha == 0) return;
			
			g.lineStyle(e.lineWidth, e.lineColor, lineAlpha, 
				pixelHinting, scaleMode, caps, joints, miterLimit);
		}

	} // end of class EdgeRenderer
}