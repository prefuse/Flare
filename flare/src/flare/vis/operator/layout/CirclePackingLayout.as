package flare.vis.operator.layout
{
	import flare.util.Shapes;
	import flare.util.Sort;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.render.ShapeRenderer;
	
	import flash.geom.Rectangle;

	/**
	 * Layout that places nodes as circles compacted into a larger circle.
	 * 
	 * <p>Circle sizes are determined by a node's <code>size</code> property.
	 * It is assumed that the sizes are set <i>before</i> this operator is run,
	 * for example, by placing a <code>SizeEncoder</code> prior to this layout
	 * in an operator list.</p>
	 * 
	 * <p>If the <code>treeLayout</code> property is <code>false</code>, all
	 * nodes will be treated the same and the result will be a "bubble" chart.
	 * If the <code>treeLayout<code> property is <code>true<code>, circles will
	 * be nested inside each other according to the tree structure of the data.
	 * </p>
	 * 
	 * <p>The results of this layout can vary dramatically based on the sort
	 * order of the nodes. For example, sorting the nodes by the
	 * <code>size</code> property (in either ascending or descending order)
	 * can result in much cleaner layouts. Use the <code>sort</code> property
	 * of this class to set a preferred sorting routine. By default, this
	 * operator will not perform any sorting.</p>
	 * 
	 * <p>NOTE: This operator will set a node's <code>renderer</code> and
	 * <code>shape</code> properties, overriding any previous values.</p>
	 * 
	 * <p>The algorithm used to perform the circle packing is adapted from
	 * W. Wang, H. Wang, G. Dai, and H. Wang's <a
	 * href="http://portal.acm.org/citation.cfm?id=1124772.1124851">
	 * Visualization of large hierarchical data by circle packing</a>,
	 * ACM CHI 2006.</p>
	 */
	public class CirclePackingLayout extends Layout
	{
		private var _sort:Sort = null;
		private var _order:int;
		private var _b:Rectangle = new Rectangle();
		
		/** The data group to process. This setting will be ignored if tree mode
		 *  is set to true. */
		public var group:String = Data.NODES;
		
		/** The amount of spacing between neighboring circles.
		 *  The default value is 4 pixels. */
		public var spacing:Number = 4;
		
		/** Indicates if the view should be scaled to fit within the
		 *  display bounds. The default is true. */
		public var fitInBounds:Boolean = true;
		
		/** Indicates if a tree layout (circles nested within circles) should
		 *  be computed. The default is false. Any data group settings will
		 *  be ignored if this operator uses a tree layout. */
		public var treeLayout:Boolean = false;
		
		/** A sort criteria for ordering nodes in this layout.
		 *  Ordered nodes are placed in a spiral starting at the center.
		 *  The default is null, meaning no sorting is performed. */
		public function get sort():Sort { return _sort; }
		public function set sort(s:*):void {
			_sort = s==null ? s : (s is Sort ? Sort(s) : new Sort(s));
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new CirclePackingLayout.
		 * @param spacing the minimum spacing between neighboring circles
		 * @param treeLayout if true, a hierarchical circles-within-circles
		 *  layout will be peformed; if false (the default) all nodes will be
		 *  considered equally
		 * @param sort a sort criteria for ordering nodes in the layout.
		 *  Ordered nodes are placed in a spiral starting at the center.
		 */
		public function CirclePackingLayout(spacing:Number=4,
			treeLayout:Boolean=false, sort:*=null)
		{
			this.spacing = spacing;
			this.treeLayout = treeLayout;
			this.sort = sort;
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
			_order = 0;
			
			var data:Data = visualization.data;
			data.nodes.setProperty("shape", Shapes.CIRCLE, _t);
			data.nodes.setProperty("renderer", ShapeRenderer.instance, _t);
			
			// determine layout anchor from bounds
			var bounds:Rectangle = layoutBounds;
			_anchor.x = (bounds.left + bounds.right) / 2;
			_anchor.y = (bounds.top + bounds.bottom) / 2;

			// compute the circle packing(s)
			var radius:Number;			
			if (treeLayout) {
				// perform hierarchial tree layout
				var root:NodeSprite = layoutRoot as NodeSprite;
				var cn:ChainNode = getChainNode(root); cn.x = 0; cn.y = 0;
				
				if (root.childDegree > 0) {
					radius = (cn.r = packTree(root));
					_t.$(root).size = radius / ShapeRenderer.instance.defaultSize;
				}
				shiftTree(root, cn.x, cn.y);
			} else {
				// perform flat layout
				var list:Array = []; data.group(group).visit(list.push);
				if (_sort) _sort.sort(list);
				for (var i:int=0; i<list.length; ++i)
					list[i] = getChainNode(list[i]);
				radius = packCircle(list, list.length);
			}
			
			var dr:Number = Math.max(2*radius/bounds.width, 2*radius/bounds.height);
			var scale:Number = fitInBounds ? 0.99/dr : 1;
			
			if (treeLayout) {
				// recurse through the tree
				layoutHelper(root, _anchor.x, _anchor.y, scale);
			} else {
				// layout all circles directly
				for each (var n:NodeSprite in visualization.data.group(group)) {	
					cn = n.props.chainNode;
					update(n, _anchor.x + scale*cn.x,
					          _anchor.y + scale*cn.y, scale, 1);
					delete n.props.chainNode;
				}
			}
			updateEdgePoints(_t);
		}
		
		/** Performs layout for tree structures. */
		private function layoutHelper(n:NodeSprite, xc:Number, yc:Number, scale:Number):void
		{
			var cn:ChainNode = n.props.chainNode;
			var x:Number = xc + scale*cn.x;
			var y:Number = yc + scale*cn.y;
			update(n, x, y, scale, 1);
			delete n.props.chainNode;
			
			if (n.childDegree > 0) {
				if (n.expanded) {
					for (var i:int=0; i<n.childDegree; ++i)
						layoutHelper(n.getChildNode(i), xc, yc, scale);
				} else {
					for (i=0; i<n.childDegree; ++i)
						n.getChildNode(i).visitTreeDepthFirst(
							function(n:NodeSprite):void {
								update(n, x, y, 0, 0);
							}
						);
				}
			}
		}
		
		/** Set the final position, size, and visibility */
		private function update(n:NodeSprite, x:Number, y:Number, scale:Number, alpha:Number):void
		{
			var o:Object = _t.$(n);
			o.x = x;
			o.y = y;
			o.size *= scale;
			o.alpha = alpha;
			if (treeLayout && n.parentEdge) _t.$(n.parentEdge).alpha = alpha;
		}
		
		/** Shift sub-tree coordinate spaces into correct configuration. */
		private function shiftTree(n:NodeSprite, nx:Number, ny:Number):void
		{
			for (var i:int=0; i<n.childDegree; ++i) {
				var c:NodeSprite = n.getChildNode(i);
				var cn:ChainNode = c.props.chainNode;
				cn.x += nx;
				cn.y += ny;
				if (c.childDegree > 0 && c.expanded)
					shiftTree(c, cn.x, cn.y);
			}
		}
		
		/** Perform hierarchical circle packing */
		private function packTree(n:NodeSprite):Number
		{
			// do a post-order traversal, so recurse first
			var r:Number, list:Array = [];
			for (var i:int=0; i<n.childDegree; ++i) {
				var c:NodeSprite = n.getChildNode(i);
				if (c.childDegree > 0 && c.expanded) {
					r = packTree(c) / ShapeRenderer.instance.defaultSize;
					_t.$(c).size = r;
				}
				list.push(c);
			}
			// now sort the child list and perform circle packing
			if (_sort) _sort.sort(list);
			for (i=0; i<list.length; ++i)
				list[i] = getChainNode(list[i]);
			return packCircle(list, list.length);
		}
		
		/** Pack a set of circles together */
		private function packCircle(nodes:Array, N:int):Number
		{
			var a:ChainNode, b:ChainNode, c:ChainNode, j:ChainNode, k:ChainNode;
			
			// initialize bounds and order
			_b.left  = _b.top    = Number.MAX_VALUE;
			_b.right = _b.bottom = Number.MIN_VALUE;
			_order = 0;
			
			// create first node
			a = nodes[0]; a.x = -a.r; a.y = 0; updateBounds(a,_b);
			if (N==1) return center(nodes, _b);
			
			// create second node
			b = nodes[1]; b.x = b.r; b.y = 0; updateBounds(b,_b);
			if (N==2) return center(nodes, _b);
			
			// create third node build chain
			c = nodes[2]; place(a, b, c); updateBounds(c,_b);
			a.insert(c); a.prev = c; c.insert(b); b = a.next;
			
			// now iterate through the rest
			for (var i:int=3; i<N; ++i) {
				place(a, b, c=nodes[i]);
				
				// search for an intersection with a circle on the chain
				// search in both directions and keep the nearest hit
				var isect:int = 0, s1:int = 1, s2:int = 1;
				for (j=b.next; j!=b; j=j.next, ++s1) // forward search
					if (intersects(j, c)) {
						isect = 1;
						break;
					}
				if (isect == 1) { // backward search
					for (k=a.prev; k!=j.prev; k=k.prev, ++s2) 
						if (intersects(k, c)) {
							if (s2 < s1) { isect = -1; j = k; }
							break;
						}
				}
				
				// update node chain
				if (isect == 0) {
					a.insert(c); b = c;
					updateBounds(c, _b);
				} else if (isect > 0) {
					a.splice(j); b = j; --i;
				} else if (isect < 0) {
					j.splice(b); a = j; --i;
				}
			}
			
			// return the radius that encompasses the data
			return center(nodes, _b);
		}
		
		/** Re-center a group of circles and return the encompassing radius. */
		private function center(nodes:Array, b:Rectangle):Number
		{
			var cx:Number = (b.left + b.right) / 2;
			var cy:Number = (b.top + b.bottom) / 2;
			var cr:Number = 0, r:Number;
			
			for each (var cn:ChainNode in nodes) {
				cn.x -= cx;
				cn.y -= cy;
				r = cn.r + Math.sqrt(cn.x*cn.x + cn.y*cn.y);
				if (r > cr) cr = r;
			}
			return cr;
		}
		
		/** Update the bounding box around the circles. */
		private static function updateBounds(c:ChainNode, b:Rectangle):void
		{
			if (c.x-c.r < b.left)   b.left   = c.x-c.r;
			if (c.x+c.r > b.right)  b.right  = c.x+c.r;
			if (c.y-c.r < b.top)    b.top    = c.y-c.r;
			if (c.y+c.r > b.bottom) b.bottom = c.y+c.r;
		}
		
		/** Create and initialize a ChainNode to represent the given node.  */
		private function getChainNode(n:NodeSprite):ChainNode
		{
			var cn:ChainNode, r:Number, size:Number = _t.$(n).size;
			r = spacing/2 + (size * ShapeRenderer.instance.defaultSize);
			n.props.chainNode = (cn = new ChainNode(r));
			n.props.order = _order++;
			return cn;
		}
		
		/** Check for intersection between circles. */
		private static function intersects(a:ChainNode, b:ChainNode):Boolean
		{
			var dx:Number = b.x - a.x;
			var dy:Number = b.y - a.y;
			var dr:Number = a.r + b.r;
			return (dx*dx + dy*dy) < dr*dr - 0.001; // within epsilon
		}
		
		/** Position circle c based on tangency to circles a and b. */
		private static function place(a:ChainNode, b:ChainNode,
			c:ChainNode):void
		{
			var da:Number = b.r + c.r;                // distance from b to c
			var db:Number = a.r + c.r;                // distance from a to c
			var dx:Number = (b.x - a.x);
			var dy:Number = (b.y - a.y);
			var dc:Number = Math.sqrt(dx*dx + dy*dy); // distance from a to b
			dx /= dc; dy /= dc;              // normalize directional vectors
			
			// apply law of cosines to get angle at vertex a
			var cosA:Number = (db*db + dc*dc - da*da) / (2*db*dc);
			var A:Number = Math.acos(cosA);
			
			// compute coordinates based on right triangle relations
			var x:Number = cosA * db;
			var h:Number = Math.sin(A) * db;
			c.x = (a.x + x*dx) + h*dy;
			c.y = (a.y + x*dy) - h*dx;
		}
		
	} // end of class CirclePackingLayout
}
	
class ChainNode
{
	public var r:Number;
	public var x:Number;
	public var y:Number;
	public var next:ChainNode;
	public var prev:ChainNode;
	
	public function get dist():Number {
		return x*x + y*y;
	}
	
	public function ChainNode(radius:Number) {
		r = radius;
		next = prev = this;
	}
	
	public function insert(c:ChainNode):void
	{
		var b:ChainNode = next;
		next = c;
		c.prev = this;
		c.next = b;
		b.prev = c;
	}
	
	public function splice(j:ChainNode):void
	{
		next = j;
		j.prev = this;
	}
}