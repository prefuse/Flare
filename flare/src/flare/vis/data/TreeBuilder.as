package flare.vis.data
{
	import flare.util.IEvaluable;
	import flare.util.Property;
	import flare.util.heap.FibonacciHeap;
	import flare.util.heap.HeapNode;
	
	import flash.utils.Dictionary;

	/**
	 * Calculates a spanning tree for a graph structure. This class can
	 * create spanning trees by breadth-first search, depth-first search, or by
	 * computing a minimum spanning tree. The default is to find a minimum
	 * spanning tree, which in turn defaults to breadth-first search if no edge
	 * weight function is provided.
	 * 
	 * <p>This class can annotate graph edges as belonging to the spanning tree
	 * (done if the <code>annotateEdges</code> property is true), and can
	 * construct a <code>Tree</code> instance (done if the
	 * <code>buildTree<code> property is true). Generated <code>Tree<code>
	 * instances are stored in the <code>tree</code> property. Generated trees
	 * contain the original nodes and edges in the input graph, and any
	 * previous parent or child links for input nodes will be cleared and
	 * overwritten.</p>
	 * 
	 * <p>This class is intended as a support class for creating spanning trees
	 * for <code>flare.vis.data.Data</code> instances. To create annotated
	 * spanning trees for other purposes, see the
	 * <code>flare.analytics.graph.SpanningTree</code> class, which provides a
	 * tree builder that can also be used a visualization operator.</p>
	 */
	public class TreeBuilder
	{
		/** Policy for a spanning tree built using depth-first search. */
		public static const DEPTH_FIRST:String   = "depth-first";
		/** Policy for a spanning tree built using breadth-first search. */
		public static const BREADTH_FIRST:String = "breadth-first";
		/** Policy for building a minimum spanning tree. */
		public static const MINIMUM_SPAN:String  = "minimum-span";
		
		private var _s:Property = Property.$("props.spanning");
		private var _w:Function = null;
		private var _policy:String = MINIMUM_SPAN;
		private var _links:int = NodeSprite.GRAPH_LINKS;
		private var _tree:Tree = null;
		
		/** Flag indicating if a spanning tree instance should be created. */
		public var buildTree:Boolean;
		/** Flag indicating if edges in the spanning tree should be annotated.
		 *  If so, the <code>spanningField</code> property will be set for
		 *  each edge in the graph. */
		public var annotateEdges:Boolean;
		
		/** The tree created by this operator. */
		public function get tree():Tree { return _tree; }
		
		/** The traveral policy used to generate the spanning tree. Should be
		 *  one of DEPTH_FIRST, BREADTH_FIRST, or MINIMUM_SPAN (default). */
		public function get policy():String { return _policy; }
		public function set policy(p:String):void {
			if (p==DEPTH_FIRST || p==BREADTH_FIRST || p==MINIMUM_SPAN) {
				_policy = p;
			} else {
				throw new Error("Unrecognized policy: "+p);
			}
		}
		
		/** The property with which to annotate edges that make up the spanning
		 *  tree. The default value is "props.spanning". This property is used
		 *  to annotate edges as "true" (if in the spanning forest) or "false"
		 *  (if not in the spanning forest). */
		public function get spanningField():String { return _s.name; }
		public function set spanningField(f:String):void { _s = Property.$(f); }
		
		/** The root node for the spanning tree. */
		public var root:NodeSprite;
		
		/** The link type to consider when constructing a spanning tree. Should
		 *  be one of <code>NodeSprite.GRAPH_LINKS</code>,
		 *  <code>NodeSprite.IN_LINKS</code>, or
		 *  <code>NodeSprite.OUT_LINKS</code>. */
		public function get links():int { return _links; }
		public function set links(linkType:int):void {
			if (linkType == NodeSprite.GRAPH_LINKS ||
				linkType == NodeSprite.IN_LINKS ||
				linkType == NodeSprite.OUT_LINKS) 
			{
				_links = linkType;
			} else {
				throw new Error("Unsupported link type: "+linkType);
			}
		}
		
		/** A function determining edge weights used in the spanning tree
		 *  calculation. When setting this value, one can pass in either a
		 *  Function, which should take an EdgeSprite as input and return a
		 *  Number as output, or a String, in which case the string will be
		 *  used as a property name from which to retrieve the edge weight
		 *  value from an EdgeSprite instance. If the value is null (the
		 *  default) all edges will be assumed to have weight 1.
		 *  
		 *  <p><b>NOTE:</b> Edge weights must be greater than or equal to zero!
		 *  </p> */
		public function get edgeWeight():Function { return _w; }
		public function set edgeWeight(w:*):void {
			if (w==null) {
				_w = null;
			} else if (w is String) {
				_w = Property.$(String(w)).getValue;
			} else if (w is IEvaluable) {
				_w = IEvaluable(w).eval;
			} else if (w is Function) {
				_w = w;
			} else {
				throw new Error("Unrecognized edgeWeight value. " +
					"The value should be a Function or String.");
			}
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SpanningTree operator
		 * @param policy the spanning tree creation policy. The default is
		 *  <code>SpanningTree.MINIMUM_SPAN</code>
		 * @param buildTree if true, this operator will build a new
		 *  <code>Tree</code> instance containing the spanning tree
		 * @param annotateEdges if true, this operator will annotate the
		 *  edges of the original graph as belonging to the spanning tree
		 * @param root the root node from which to compute the spanning tree
		 * @param edgeWeight the edge weight values. This can either be a
		 *  <code>Function</code> that returns weight values or a
		 *  <code>String</code> providing the name of a property to look up on
		 *  <code>EdgeSprite</code> instances.
		 */
		public function TreeBuilder(policy:String=null,
			buildTree:Boolean=true, annotateEdges:Boolean=false,
			root:NodeSprite=null, edgeWeight:*=null)
		{
			if (policy) this.policy = policy;
			this.buildTree = buildTree;
			this.annotateEdges = annotateEdges;
			this.root = root;
			this.edgeWeight = edgeWeight;
		}
		
		/**
		 * Calculates the spanning tree.
		 * @param data the data set containing a graph
		 * @param n the root of the spanning tree
		 */
		public function calculate(data:Data, n:NodeSprite):void
		{
			var w:Function = edgeWeight;
			if (n==null) { _tree = null; return; } // do nothing for null root
			if (!buildTree && !annotateEdges) return; // nothing to do
			
			// initialize
			if (buildTree) {
				data.nodes.visit(function(nn:NodeSprite):void {
					nn.removeEdges(NodeSprite.TREE_LINKS);
				});
				_tree = new Tree();
				_tree.root = n;
			} else {
				_tree = null;
			}
			if (annotateEdges) {
				data.edges.setProperty(_s.name, false);
			}
			
			switch (_policy) {
				case DEPTH_FIRST:
					depthFirstTree(data, n);
					return;
				case BREADTH_FIRST:
					breadthFirstTree(data, n);
					return;
				case MINIMUM_SPAN:
					if (w==null) {
						breadthFirstTree(data, n);
					} else {
						minimumSpanningTree(data, n, w);
					}
					return;
			}
		}
		
		// -- Minimum Spanning Tree -------------------------------------------
		
		private function minimumSpanningTree(data:Data, n:NodeSprite, w:Function):void
		{
			var hn:HeapNode, weight:Number, e:EdgeSprite;
			_tree = null;
			if (buildTree) {
				_tree = new Tree();
				_tree.root = n;
			}
			
			// initialize the heap
			var heap:FibonacciHeap = new FibonacciHeap();
			data.nodes.visit(function(nn:NodeSprite):void {
				nn.props.heapNode = heap.insert(nn);
			});
			heap.decreaseKey(n.props.heapNode, 0);
			
			// collect spanning tree edges (Prim's algorithm)
			while (!heap.empty) {
				hn = heap.removeMin();
				n = hn.data as NodeSprite;
				// add saved tree edge to spanning tree
				if ((e=(n.props.treeEdge as EdgeSprite))) {
					if (annotateEdges) _s.setValue(e, true);
					if (buildTree) _tree.addChildEdge(e);	
				}
				
				n.visitEdges(function(e:EdgeSprite):void {
					var nn:NodeSprite = e.other(n);
					var hnn:HeapNode = nn.props.heapNode;
					weight = (w==null ? 1 : w(e));
					if (hnn.inHeap && weight < hnn.key) {
						nn.props.treeEdge = e; // set tree edge
						heap.decreaseKey(hnn, weight);
					}
				}, _links);
			}
			
			// clean-up nodes
			data.nodes.visit(function(nn:NodeSprite):void {
				delete nn.props.treeEdge;
				delete nn.props.heapNode;
			});
		}
		
		// -- Breadth-First Traversal -----------------------------------------
		
		private function breadthFirstTree(data:Data, n:NodeSprite):void
		{
			var visited:Dictionary = buildTree ? null : new Dictionary();
			
			var q:Array = [n];
			while (q.length > 0) {
				n = q.shift();
				n.visitEdges(function(e:EdgeSprite):void {
					var nn:NodeSprite = e.other(n);
					if (buildTree ? _tree.nodes.contains(nn) : visited[nn])
						return;
					if (annotateEdges) _s.setValue(e, true);
					if (buildTree) {
						_tree.addChildEdge(e);
					} else {
						visited[nn] = true;
					}
					q.push(nn);
				}, _links);
			}
		}
		
		// -- Depth First Traversal -------------------------------------------
		
		private function depthFirstTree(data:Data, n:NodeSprite):void
		{
			depthFirstHelper(n, buildTree ? null : new Dictionary());
		}
		
		private function depthFirstHelper(n:NodeSprite, visited:Dictionary):void
		{
			n.visitEdges(function(e:EdgeSprite):void {
				var nn:NodeSprite = e.other(n);
				if (buildTree ? _tree.nodes.contains(nn) : visited[nn])
					return;
				if (annotateEdges) _s.setValue(e, true);
				if (buildTree) {
					_tree.addChildEdge(e);
				} else {
					visited[nn] = true;
				}
				if (nn.degree > 1) depthFirstHelper(nn, visited);
			}, _links);
		}
		
	} // end of class TreeBuilder
}