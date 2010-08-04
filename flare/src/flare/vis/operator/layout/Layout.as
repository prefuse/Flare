package flare.vis.operator.layout
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.axis.CartesianAxes;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Base class for all operators that perform spatial layout. Provides
	 * methods for retrieving the desired layout bounds, providing a layout
	 * anchor point, and returning the layout root (for tree layouts in
	 * particular). This class also provides convenience methods for
	 * manipulating the visibility of axes and performing common updates
	 * to edge control points in graph/tree visualizations.
	 */
	public class Layout extends Operator
	{
		/** Constant indicating Cartesian (x, y) coordinates. */
		public static const CARTESIAN:String = "cartesian";
		/** Constant indicating polar (radius, angle) coordinates. */
		public static const POLAR:String = "polar";
		
		/** @private */
		protected static const _dummy:Shape = new Shape();
		/** @private */
		protected static const _rect:Rectangle = new Rectangle();
		
		// -- Properties ------------------------------------------------------
				
		/** The type of layout and axes. This value should be
		 *  <code>CARTESIAN</code> for x,y axes, <code>POLAR</code> for polar
		 *  coordinates (radius, angle), or null for no axes. */
		public var layoutType:String = null;
		
		/** A transitioner for storing value updates. */
		protected var _t:Transitioner = null;
		
		protected var _anchor:Point = new Point(0,0);
		protected var _setAnchor:Boolean = false;
		
		private var _bounds:Rectangle = null;
		private var _root:DataSprite = null;
		
		/** The layout bounds for the layout. If this value is not explicitly
		 *  set, the bounds for the visualization is returned. */
		public function get layoutBounds():Rectangle {
			if (_bounds != null) return _bounds;
			if (visualization != null) return visualization.bounds;
			return null;
		}
		public function set layoutBounds(b:Rectangle):void { _bounds = b; }
		
		/** The layout anchor, used by some layout instances to place an
		 *  initial item or determine a focal point. */
		public function get layoutAnchor():Point {
			if (!_setAnchor)
				autoAnchor();
			return _anchor;
		}
		public function set layoutAnchor(p:Point):void {
			_anchor = p;
			_setAnchor = true;
		}
		
		/** Automatically-generate an anchor point. */
		protected function autoAnchor():void
		{
			if (layoutType == POLAR) {
				var b:Rectangle = layoutBounds;
				_anchor.x = (b.left + b.right) / 2;
				_anchor.y = (b.top + b.bottom) / 2;
			} else {
				_anchor.x = 0;
				_anchor.y = 0;
			}
		}
		
		/** The layout root, the root node for tree layouts. */
		public function get layoutRoot():DataSprite {
			if (_root != null) return _root;
			if (visualization != null) {
				return visualization.data.tree.root;
			}
			return null;
		}
		public function set layoutRoot(r:DataSprite):void { _root = r; }
		
				
		// -- Placement and Axis Helpers --------------------------------------
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			_t = (t ? t : Transitioner.DEFAULT);
			adjustAxes();
			layout();
			_t = null;
		}
		
		/**
		 * Calculates the spatial layout of visualized items. Layout operators
		 * override this method with their layout implementations.
		 * @param t a Transitioner instance for collecting value updates.
		 */
		protected function layout():void
		{
			// sub-classes should override
		}
		
		/** @private */
		protected function adjustAxes():void
		{
			if (layoutType == CARTESIAN) {
				showAxes(_t);
			} else {
				hideAxes(_t);
			}
		}
		
		/**
		 * Reveals the axes.
		 * @param t a transitioner to collect value updates
		 * @return the input transitioner
		 */
		public function showAxes(t:Transitioner=null):Transitioner
		{
			var axes:Axes = visualization.axes;
			if (axes == null || axes.visible) return t;
			
			if (t==null || t.immediate) {
				axes.alpha = 1;
				axes.visible = true;
			} else {
				t.$(axes).alpha = 1;
				t.$(axes).visible = true;
			}
			return t;
		}
		
		/**
		 * Hides the axes.
		 * @param t a transitioner to collect value updates
		 * @return the input transitioner
		 */
		public function hideAxes(t:Transitioner=null):Transitioner
		{
			var axes:Axes = visualization.axes;
			if (axes == null || !axes.visible) return t;
			
			if (t==null || t.immediate) {
				axes.alpha = 0;
				axes.visible = false;
			} else {
				t.$(axes).alpha = 0;
				t.$(axes).visible = false;
			}
			return t;
		}
		
		/**
		 * Returns the visualization's axes as a CartesianAxes instance.
		 * Creates/modifies existing axes as needed to ensure the
		 * presence of CartesianAxes.
		 */
		protected function get xyAxes():CartesianAxes
		{
			var vis:Visualization = visualization;
			if (vis == null) return null;
			
			if (vis.xyAxes == null) {
				vis.axes = new CartesianAxes();
			}
			return vis.xyAxes;
		}
		
		/**
		 * Returns an angle value that minimizes the angular distance
		 * between a reference angle and a target angle. This
		 * method may shift the angle value by multiples of 2 pi.
		 * @param a1 the reference angle to stay close to
		 * @param a2 the target angle value
		 * @return an angle that minimizes the distance
		 */
	    protected function minAngle(a1:Number, a2:Number):Number
		{
			var inc:Number = 2*Math.PI*(a1 > a2 ? 1 : -1);
			for (; Math.abs(a1-a2) > Math.PI; a2 += inc);
			return a2;
		}
		
		// -- Edge Helpers ----------------------------------------------------
		
		private static var _clear:Boolean;
		
		/**
		 * Updates all edges to be straight lines. Useful for undoing the
		 * results of layouts that route edges using edge control points.
		 * @param list a data list of edges to straighten
		 * @param t a transitioner to collect value updates
		 */
		public static function straightenEdges(list:DataList,
			t:Transitioner):Transitioner
		{
			// set end points to mid-points
			list.visit(function(e:EdgeSprite):void {
				if (e.points == null) return;
				_clear = true;
				
				var src:NodeSprite = e.source;
				var trg:NodeSprite = e.target;
				
				// create new control points
				var i:uint, len:uint = e.points.length, f:Number;
				var cp:Array = new Array(len);
				var x1:Number, y1:Number, x2:Number, y2:Number;
				
				// get target end points
				x1 = t.$(src).x; y1 = t.$(src).y;
				x2 = t.$(trg).x; y2 = t.$(trg).y;
				
				for (i=0; i<len; i+=2) {
					f = (i+2)/(len+2);
					cp[i]   = x1 + f * (x2 - x1);
					cp[i+1] = y1 + f * (y2 - y1);
				}
				t.$(e).points = cp;
			});
			return t;
		}
		
		/** @private */
		protected function updateEdgePoints(t:Transitioner=null):void
		{
			if (t==null || t.immediate || layoutType==POLAR) {
				clearEdgePoints();
			} else {
				_clear = false;
				straightenEdges(visualization.data.edges, t);
				// after transition, clear out control points
				if (_clear) {
					var f:Function = function(evt:Event):void {
						clearEdgePoints();
						t.removeEventListener(TransitionEvent.END, f);
					};
					t.addEventListener(TransitionEvent.END, f);
				}
			}
		}
		
		/**
		 * Strips all EdgeSprites in a visualization of any control points.
		 */
		public function clearEdgePoints():void
		{
			visualization.data.edges["points"] = null;
		}
		
	} // end of class Layout
}