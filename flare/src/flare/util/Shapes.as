package flare.util
{	
	import flash.display.Graphics;
	
	/**
	 * Utility class defining shape types and shape drawing routines. All shape
	 * drawing functions take two arguments: a <code>Graphics</code> context
	 * to draw with and a size parameter determining the radius of the shape
	 * (i.e., the height and width of the shape are twice the size parameter).
	 * 
	 * <p>All shapes are indicated by a name. This class registers these names
	 * with drawing functions, allowing the lookup of shape rendering routines
	 * by the shapes name. For example, these shape names may be assigned using
	 * a <code>flare.vis.operator.encoder.ShapeEncoder</code> and then later
	 * rendered by looking up the shape with this class, as done by the
	 * <code>flare.vis.data.render.ShapeRenderer</code> class. The set of 
	 * available shapes can be extended by using the static
	 * <code>setShape</code> method to register a new shape name and
	 * drawing function.</p>
	 */
	public class Shapes
	{
		/** Constant indicating a straight line shape. */
		public static const LINE:String = "line";
		/** Constant indicating a Bezier curve. */
		public static const BEZIER:String = "bezier";
		/** Constant indicating a cardinal spline. */
		public static const CARDINAL:String = "cardinal";
		/** Constant indicating a B-spline. */
		public static const BSPLINE:String = "bspline";
		
		/** Constant indicating a rectangular block shape. */
		public static const BLOCK:String = "block";
		/** Constant indicating a polygon shape. */
		public static const POLYGON:String = "polygon";
		/** Constant indicating a "polyblob" shape, a polygon whose
		 *  edges are interpolated with a cardinal spline. */
		public static const POLYBLOB:String = "polyblob";
		/** Constant indicating a vertical bar shape. */
		public static const VERTICAL_BAR:String = "verticalBar";
		/** Constant indicating a horizontal bar shape. */
		public static const HORIZONTAL_BAR:String = "horizontalBar";
		/** Constant indicating a wedge shape. */
		public static const WEDGE:String = "wedge";
		
		/** Constant indicating a circle shape. */
		public static const CIRCLE:String = "circle";
		/** Constant indicating a square shape. */
		public static const SQUARE:String = "square";
		/** Constant indicating a cross shape. */
		public static const CROSS:String = "cross";
		/** Constant indicating an 'X' shape. */
		public static const X:String = "x";
		/** Constant indicating a diamond shape. */
		public static const DIAMOND:String = "diamond";
		/** Constant indicating a upward-pointing triangle shape. */
		public static const TRIANGLE_UP:String = "triangleUp";
		/** Constant indicating a downward-pointing triangle shape. */
		public static const TRIANGLE_DOWN:String = "triangleDown";
		/** Constant indicating a rightward-pointing triangle shape. */
		public static const TRIANGLE_RIGHT:String = "triangleRight";
		/** Constant indicating a leftward-pointing triangle shape. */
		public static const TRIANGLE_LEFT:String = "triangleLeft";
		
		private static var _shapes:Object = {
			circle: drawCircle,
			square: drawSquare,
			cross: drawCross,
			x: drawX,
			diamond: drawDiamond,
			triangleUp: drawTriangleUp,
			triangleDown: drawTriangleDown,
			triangleRight: drawTriangleRight,
			triangleLeft: drawTriangleLeft
		};
		
		/**
		 * Gets the shape drawing function with the given name. 
		 * @param name the name of the shape to draw
		 * @return a function for drawing the shape or null if the shape name
		 *  is not found. The returned function takes two parameters:
		 *  a graphics object and a numerical size value. The size value
		 *  indicates the radius of the shape.
		 */
		public static function getShape(name:String):Function
		{
			return _shapes[name];
		}
		
		/**
		 * Sets the shape drawing function for a given shape name. 
		 * @param name the name of the shape to draw
		 * @param draw a function for drawing the shape. This function must
		 *  take two parameters: a graphics object and a numerical size value.
		 *  The size value indicates the radius of the shape.
		 */
		public static function setShape(name:String, draw:Function):void
		{
			_shapes[name] = draw;
		}
		
		/**
		 * Resets all shape drawing functions to the default settings. 
		 */
		public static function resetShapes():void
		{
			_shapes = {
				circle: drawCircle,
				square: drawSquare,
				cross: drawCross,
				x: drawX,
				diamond: drawDiamond,
				triangleUp: drawTriangleUp,
				triangleDown: drawTriangleDown,
				triangleRight: drawTriangleRight,
				triangleLeft: drawTriangleLeft
			};
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Draws a circle shape.
		 * @param g the graphics context to draw with
		 * @param size the radius of the circle
		 */
		public static function drawCircle(g:Graphics, size:Number):void
		{
			g.drawCircle(0, 0, size);
		}
		
		/**
		 * Draws a square shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the square. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawSquare(g:Graphics, size:Number):void
		{
			g.drawRect(-size, -size, 2*size, 2*size);
		}
		
		/**
		 * Draws a cross shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the cross. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawCross(g:Graphics, size:Number):void
		{
			g.moveTo(0, -size);
			g.lineTo(0, size);
			g.moveTo(-size, 0);
			g.lineTo(size, 0);
		}
		
		/**
		 * Draws an "x" shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the "x". The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawX(g:Graphics, size:Number):void
		{
			g.moveTo(-size, -size);
			g.lineTo(size, size);
			g.moveTo(size, -size);
			g.lineTo(-size, size);
		}
		
		/**
		 * Draws a diamond shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the diamond. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawDiamond(g:Graphics, size:Number):void
		{
			g.moveTo(0, size);
			g.lineTo(-size, 0);
			g.lineTo(0, -size);
			g.lineTo(size, 0);
			g.lineTo(0, size);	
		}
		
		/**
		 * Draws an upward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleUp(g:Graphics, size:Number):void
		{
			g.moveTo(-size, size);
			g.lineTo(size, size);
			g.lineTo(0, -size);
			g.lineTo(-size, size);
		}
		
		/**
		 * Draws a downward-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleDown(g:Graphics, size:Number):void
		{
			g.moveTo(-size, -size);
			g.lineTo(size, -size);
			g.lineTo(0, size);
			g.lineTo(-size, -size);
		}
		
		/**
		 * Draws a right-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleRight(g:Graphics, size:Number):void
		{
			g.moveTo(-size, -size);
			g.lineTo(size, 0);
			g.lineTo(-size, size);
			g.lineTo(-size, -size);
		}
		
		/**
		 * Draws a left-pointing triangle shape.
		 * @param g the graphics context to draw with
		 * @param size the (half-)size of the triangle. The height and width of
		 *  the shape will both be exactly twice the size parameter.
		 */
		public static function drawTriangleLeft(g:Graphics, size:Number):void
		{
			g.moveTo(size, -size);
			g.lineTo(-size, 0);
			g.lineTo(size, size);
			g.lineTo(size, -size);
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Draws an arc (a segment of a circle's circumference)
		 * @param g the graphics context to draw with
		 * @param x the center x-coordinate of the arc
		 * @param y the center y-coorindate of the arc
		 * @param radius the radius of the arc
		 * @param a0 the starting angle of the arc (in radians)
		 * @param a1 the ending angle of the arc (in radians)
		 */
		public static function drawArc(g:Graphics, x:Number, y:Number, 
									radius:Number, a0:Number, a1:Number) : void
		{
			var slices:Number = (Math.abs(a1-a0) * radius) / 4;
			var a:Number, cx:Number = x, cy:Number = y;
			
			for (var i:uint = 0; i <= slices; ++i) {
				a = a0 + i*(a1-a0)/slices;
				x = cx + radius * Math.cos(a);
				y = cy + -radius * Math.sin(a);
				if (i==0) {
					g.moveTo(x, y);
				} else {
					g.lineTo(x,y);
				}
			}
		}
		
		/**
		 * Draws a wedge defined by an angular range and inner and outer radii.
		 * An inner radius of zero results in a pie-slice shape.
		 * @param g the graphics context to draw with
		 * @param x the center x-coordinate of the wedge
		 * @param y the center y-coorindate of the wedge
		 * @param outer the outer radius of the wedge
		 * @param inner the inner radius of the wedge
		 * @param a0 the starting angle of the wedge (in radians)
		 * @param a1 the ending angle of the wedge (in radians)
		 */
		public static function drawWedge(g:Graphics, x:Number, y:Number, 
			outer:Number, inner:Number, a0:Number, a1:Number) : void
		{
			var a:Number = Math.abs(a1-a0);
			var slices:int = Math.max(4, int(a * outer / 6));
			var cx:Number = x, cy:Number = y, x0:Number, y0:Number;
			var circle:Boolean = (a >= 2*Math.PI - 0.001);

			if (slices <= 0) return;
		
			// pick starting point
			if (inner <= 0 && !circle) {
				g.moveTo(cx, cy);
			} else {
				x0 = cx + outer * Math.cos(a0);
				y0 = cy + -outer * Math.sin(a0);
				g.moveTo(x0, y0);
			}
			
			// draw outer arc
			for (var i:uint = 0; i <= slices; ++i) {
				a = a0 + i*(a1-a0)/slices;
				x = cx + outer * Math.cos(a);
				y = cy + -outer * Math.sin(a);
				g.lineTo(x,y);
			}

			if (circle) {
				// return to starting point
				g.lineTo(x0, y0);
			} else if (inner > 0) {
				// draw inner arc
				for (i = slices+1; --i >= 0;) {
					a = a0 + i*(a1-a0)/slices;
					x = cx + inner * Math.cos(a);
					y = cy + -inner * Math.sin(a);
					g.lineTo(x,y);
				}
				g.lineTo(x0, y0);
			} else {
				// return to center
				g.lineTo(cx, cy);
			}
		}
		
		/**
		 * Draws a polygon shape.
		 * @param g the graphics context to draw with
		 * @param a a flat array of x, y values defining the polygon
		 */
		public static function drawPolygon(g:Graphics, a:Array) : void
		{
			g.moveTo(a[0], a[1]);
			for (var i:uint=2; i<a.length; i+=2) {
				g.lineTo(a[i], a[i+1]);
			}
			g.lineTo(a[0], a[1]);
		}
		
		/**
		 * Draws a cubic Bezier curve.
		 * @param g the graphics context to draw with
		 * @param ax x-coordinate of the starting point
		 * @param ay y-coordinate of the starting point
		 * @param bx x-coordinate of the first control point
		 * @param by y-coordinate of the first control point
		 * @param cx x-coordinate of the second control point
		 * @param cy y-coordinate of the second control point
		 * @param dx x-coordinate of the ending point
		 * @param dy y-coordinate of the ending point
		 * @param move if true (the default), the graphics context will be
		 *  moved to the starting point before drawing starts. If false,
		 *  no move command will be issued; this is useful when connecting
		 *  multiple curves to define a filled region.
		 */
		public static function drawCubic(g:Graphics, ax:Number, ay:Number,
			bx:Number, by:Number, cx:Number, cy:Number, dx:Number, dy:Number,
			move:Boolean=true) : void
		{			
			var subdiv:int, u:Number, xx:Number, yy:Number;			
			
			// determine number of line segments
			subdiv = int((Math.sqrt((xx=(bx-ax))*xx + (yy=(by-ay))*yy) +
					      Math.sqrt((xx=(cx-bx))*xx + (yy=(cy-by))*yy) +
					      Math.sqrt((xx=(dx-cx))*xx + (yy=(dy-cy))*yy)) / 4);
			if (subdiv < 1) subdiv = 1;

			// compute Bezier co-efficients
			var c3x:Number = 3 * (bx - ax);
            var c2x:Number = 3 * (cx - bx) - c3x;
            var c1x:Number = dx - ax - c3x - c2x;
            var c3y:Number = 3 * (by - ay);
            var c2y:Number = 3 * (cy - by) - c3y;
            var c1y:Number = dy - ay - c3y - c2y;
			
			if (move) g.moveTo(ax, ay);
			for (var i:uint=0; i<=subdiv; ++i) {
				u = i/subdiv;
				xx = u*(c3x + u*(c2x + u*c1x)) + ax;
				yy = u*(c3y + u*(c2y + u*c1y)) + ay;
				g.lineTo(xx, yy);
			}
		}
		
		// -- BSpline rendering state variables --
		private static var _knot:Array  = new Array(20);
		private static var _basis:Array = new Array(36);

		/**
		 * Draws a cubic open uniform B-spline. The spline passes through the
		 * first and last control points, but not necessarily any others.
		 * @param g the graphics context to draw with
		 * @param p an array of points defining the spline control points
		 * @param slack a slack parameter determining the "tightness" of the
		 *  spline. At value 1 (the default) a normal b-spline will be drawn,
		 *  at value 0 a straight line between the first and last points will
		 *  be drawn. Intermediate values interpolate smoothly between these
		 *  two extremes.
		 * @param move if true (the default), the graphics context will be
		 *  moved to the starting point before drawing starts. If false,
		 *  no move command will be issued; this is useful when connecting
		 *  multiple curves to define a filled region.
		 */
		public static function drawBSpline(g:Graphics, p:Array, npts:int=-1,
			move:Boolean=true):void
		{
			var N:int = (npts < 0 ? p.length/2 : npts);
			var k:int = N<4 ? 3 : 4, nplusk:int = N+k;
			var i:int, j:int, s:int, subdiv:int = 40;
			var x:Number, y:Number, step:Number, u:Number;
			
			// if only two points, draw a line between them
			if (N==2) {
				if (move) g.moveTo(p[0],p[1]);
				g.lineTo(p[2],p[3]);
				return;
			}
			
			// initialize knot vector
			for (i=1, _knot[0]=0; i<nplusk; ++i) {
				_knot[i] = _knot[i-1] + (i>=k && i<=N ? 1 : 0);
			}
			
			// calculate the points on the bspline curve
			step = _knot[nplusk-1] / subdiv;
			for (s=0; s <= subdiv; ++s) {
				u = step * s;
				
				// calculate basis function -----
				for (i=0; i < nplusk-1; ++i) { // first-order
					_basis[i] = (u >= _knot[i] && u < _knot[i+1] ? 1 : 0);
				}
				for (j=2; j <= k; ++j) { // higher-order
					for (i=0; i < nplusk-j; ++i) {
						x = (_basis[i  ]==0 ? 0 : ((u-_knot[i])*_basis[i]) / (_knot[i+j-1]-_knot[i]));
						y = (_basis[i+1]==0 ? 0 : ((_knot[i+j]-u)*_basis[i+1]) / (_knot[i+j]-_knot[i+1]));
						_basis[i] = x + y;
					}
				}
				if (u == _knot[nplusk-1]) _basis[N-1] = 1; // last point
				
				// interpolate b-spline point -----
				for (i=0, j=0, x=0, y=0; i<N; ++i, j+=2) {
					x += _basis[i] * p[j];
					y += _basis[i] * p[j+1];
				}
				if (s==0) {
					if (move) g.moveTo(x, y);
				} else {
					g.lineTo(x, y);
				}
			}
		}
		
		/**
		 * Draws a cardinal spline composed of piecewise connected cubic
		 * Bezier curves. Curve control points are inferred so as to ensure
		 * C1 continuity (continuous derivative).
		 * @param g the graphics context to draw with
		 * @param p an array defining a polygon or polyline to render with a
		 *  cardinal spline
		 * @param s a tension parameter determining the spline's "tightness"
		 * @param closed indicates if the cardinal spline should be a closed
		 *  shape. False by default.
		 */
		public static function drawCardinal(g:Graphics, p:Array, npts:int=-1,
			s:Number=0.15, closed:Boolean=false) : void
		{
			// compute the size of the path
	        var len:uint = (npts < 0 ? p.length : 2*npts);
	        
	        if (len < 6)
	            throw new Error("Cardinal splines require at least 3 points");
	        
	        var dx1:Number, dy1:Number, dx2:Number, dy2:Number;
	        g.moveTo(p[0], p[1]);
	        
	        // compute first control points
	        if (closed) {
	            dx2 = p[2]-p[len-2];
	            dy2 = p[3]-p[len-1];
	        } else {
	            dx2 = p[4]-p[0]
	            dy2 = p[5]-p[1];
	        }

	        // iterate through control points
	        var i:uint = 0;
	        for (i=2; i<len-2; i+=2) {
	            dx1 = dx2; dy1 = dy2;
	            dx2 = p[i+2] - p[i-2];
	            dy2 = p[i+3] - p[i-1];
	            
	            drawCubic(g, p[i-2],    p[i-1],
						     p[i-2]+s*dx1, p[i-1]+s*dy1,
	                         p[i]  -s*dx2, p[i+1]-s*dy2,
	                         p[i],         p[i+1], false);
	        }
	        
	        // finish spline
	        if (closed) {
	            dx1 = dx2; dy1 = dy2;
	            dx2 = p[0] - p[i-2];
	            dy2 = p[1] - p[i-1];
	            drawCubic(g, p[i-2], p[i-1], p[i-2]+s*dx1, p[i-1]+s*dy1,
	            			 p[i]-s*dx2, p[i+1]-s*dy2, p[i], p[i+1], false);
	            
	            dx1 = dx2; dy1 = dy2;
	            dx2 = p[2] - p[len-2];
	            dy2 = p[3] - p[len-1];
	            drawCubic(g, p[len-2], p[len-1], p[len-2]+s*dx1, p[len-1]+s*dy1,
	            	p[0]-s*dx2, p[1]-s*dy2, p[0], p[1], false);
	        } else {
	        	drawCubic(g, p[i-2], p[i-1], p[i-2]+s*dx1, p[i-1]+s*dy1,
	        		p[i]-s*dx2, p[i+1]-s*dy2, p[i], p[i+1], false);
	        }
		}
		
		/**
		 * A helper function for consolidating end points and control points
		 * for a spline into a single array.
		 * @param x1 the x-coordinate for the first end point
		 * @param y1 the y-coordinate for the first end point
		 * @param controlPoints an array of control points
		 * @param x2 the x-coordinate for the second end point
		 * @param y2 the y-coordinate for the second end point
		 * @param p the array in which to store the consolidated points.
		 *  If null, a new array will be created and returned.
		 * @return the consolidated array of all points
		 */
		public static function consolidate(x1:Number, y1:Number,
			controlPoints:Array, x2:Number, y2:Number, p:Array=null):Array
		{
			var len:int = 4 + controlPoints.length;
			if (!p) {
				p = new Array(len);
			} else {
				while (p.length < len) p.push(0);
			}
			
			Arrays.copy(controlPoints, p, 0, 2);
			p[0] = x1;
			p[1] = y1;
			p[len-2] = x2;
			p[len-1] = y2;
			return p;
		}
		
	} // end of class Shapes
}