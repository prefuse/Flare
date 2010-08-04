package flare.vis.data
{
	import flare.vis.data.render.ArrowType;
	import flare.vis.data.render.EdgeRenderer;
	
	/**
	 * Visually represents a connection between two data elements. Examples
	 * include an edge in a graph structure or a line between points in a line
	 * chart. EdgeSprites maintain <code>source</code> and <code>target</code>
	 * properties for accessing the NodeSprites connected by this edge. By
	 * default, EdgeSprites are drawn using an <code>EdgeRenderer</code>.
	 * EdgeSprites are typically managed by a <code>Data</code> object.
	 */
	public class EdgeSprite extends DataSprite
	{		
		// -- Properties ------------------------------------------------------
		
		/** The x-coordinate for the first end point of this edge. */
		public var x1:Number;
		/** The y-coordinate for the first end point of this edge. */
		public var y1:Number;
		/** The x-coordinate for the second end point of this edge. */
		public var x2:Number;
		/** The y-coordinate for the second end point of this edge. */
		public var y2:Number;
		
		/** The first, or source, node upon which this edge is incident. */
		public var source:NodeSprite;
		/** The second, or target, node upon which this edge is incident. */
		public var target:NodeSprite;
		
		/** Flag indicating if this edge is directed (true) or undirected
		 *  (false). */
		public var directed:Boolean = false;
		
		/** The type of arrow to be used on the edge. Default is Arrows.NONE */
		public var arrowType:String = ArrowType.NONE;
		/** The width of the arrow head. The default is -1, in which case the
		 *  width is automatically determined based on the arrow height or
		 *  the line width. */
		public var arrowWidth:Number = -1;
		/** The height of the arrow head. The default is -1, in which case the
		 *  height is automatically determined based on the arrow width or
		 *  the line width. */
		public var arrowHeight:Number = -1;
		
		
		// -- Methods ---------------------------------------------------------
		
		/**
		 * Creates a new EdgeSprite.
		 * @param source the source node
		 * @param target the target node
		 * @param directed true for a directed edge, false for undirected
		 */		
		public function EdgeSprite(source:NodeSprite=null,
			target:NodeSprite=null, directed:Boolean=false)
		{
			this.source = source;
			this.target = target;
			this.directed = directed;
			_lineColor = 0xffcccccc;
			_renderer = EdgeRenderer.instance;
		}
		
		/**
		 * Given a node upon which this edge is incident, return the other
		 * node connected by this edge.
		 * @param n a node upon which this edge is incident
		 * @return the other node
		 */		
		public function other(n:NodeSprite):NodeSprite
		{
			if (n == source) return target;
			if (n == target) return source;
			else return null;	
		}
		
		/**
		 * Clears the edge, removing references to the edge's nodes.
		 */		
		public function clear():void
		{
			source = null;
			target = null;
		}
		
		/** @inheritDoc */
		public override function render():void
		{
			if (source != null) {
				x1 = source.x;
				y1 = source.y;
			}
			if (target != null) {
				x2 = target.x;
				y2 = target.y;
			}
			super.render();
		}
		
	} // end of class EdgeSprite
}