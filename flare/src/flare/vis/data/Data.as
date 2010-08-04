package flare.vis.data
{
	import flare.data.DataField;
	import flare.data.DataSchema;
	import flare.data.DataSet;
	import flare.util.Arrays;
	import flare.util.Property;
	import flare.util.Sort;
	import flare.vis.events.DataEvent;
	
	import flash.events.EventDispatcher;
	
	[Event(name="add",    type="flare.vis.events.DataEvent")]
	[Event(name="remove", type="flare.vis.events.DataEvent")]
	
	/**
	 * Data structure for managing a collection of visual data objects. The
	 * Data class manages both unstructured data and data organized in a
	 * general graph (or network structure), maintaining collections of both
	 * nodes and edges. Collections of data sprites are maintained by
	 * <code>DataList</code> instances. The individual data lists provide
	 * methods for accessing, manipulating, sorting, and generating statistics
	 * about the visual data objects.
	 * 
	 * <p>In addition to the required <code>nodes</code> and <code>edges</code>
	 * lists, clients can add new custom lists (for example, to manage a
	 * selected subset of the data) by using the <code>addGroup</code> method
	 * and then accessing the list with the <code>group</code> method.
	 * Individual data groups can be directly processed by many of the
	 * visualization operators in the <code>flare.vis.operator</code> package.
	 * </p>
	 * 
	 * <p>While Data objects maintain a collection of visual DataSprites,
	 * they are not themselves visual object containers. Instead a Data
	 * instance is used as input to a <code>Visualization</code> that
	 * is responsible for processing the DataSprite instances and adding
	 * them to the Flash display list.</p>
	 * 
	 * <p>The data class also manages the automatic generation of spanning
	 * trees over a graph when needed for tree-based operations (such as tree
	 * layout algorithms). This implemented by a
	 * <code>flare.analytics.graph.SpanningTree</code> operator which can be
	 * parameterized using the <code>treePolicy</code>,
	 * <code>treeEdgeWeight</code>, and <code>root</code> properties of this
	 * class. Alternatively, clients can create their own spanning trees as
	 * a <code>Tree</code instance and set this as the spanning tree.</p>
	 * 
	 * @see flare.vis.data.DataList
	 * @see flare.analytics.graph.SpanningTree
	 */
	public class Data extends EventDispatcher
	{
		/** Constant indicating the nodes in a Data object. */
		public static const NODES:String = "nodes";
		/** Constant indicating the edges in a Data object. */
		public static const EDGES:String = "edges";
		
		/** Internal list of NodeSprites. */
		protected var _nodes:DataList = new DataList(NODES);
		/** Internal list of EdgeSprites. */
		protected var _edges:DataList = new DataList(EDGES);
		/** Internal set of data groups. */
		protected var _groups:Object;
		
		/** The total number of items (nodes and edges) in the data. */
		public function get length():int { return _nodes.length + _edges.length; }
		
		/** The collection of NodeSprites. */
		public function get nodes():DataList { return _nodes; }
		/** The collection of EdgeSprites. */
		public function get edges():DataList { return _edges; }
		
		/** The default directedness of new edges. */
		public var directedEdges:Boolean;
		
		
		// -- Methods ---------------------------------------------------------

		/**
		 * Creates a new Data instance.
		 * @param directedEdges the default directedness of new edges
		 */
		public function Data(directedEdges:Boolean=false) {
			this.directedEdges = directedEdges;
			_groups = { nodes: _nodes, edges: _edges };
			
			// add listeners to enforce type and connectivity constraints
			_nodes.addEventListener(DataEvent.ADD, onAddNode);
			_nodes.addEventListener(DataEvent.REMOVE, onRemoveNode);
			_edges.addEventListener(DataEvent.ADD, onAddEdge);
			_edges.addEventListener(DataEvent.REMOVE, onRemoveEdge);
		}
		
		/**
		 * Creates a new Data instance from an array of tuples. The object in
		 * the array will become the data objects for NodeSprites.
		 * @param a an Array of data objects
		 * @return a new Data instance, with NodeSprites populated with the
		 *  input data.
		 */
		public static function fromArray(a:Array):Data {
			var d:Data = new Data();
			for each (var tuple:Object in a) {
				d.addNode(tuple);
			}
			return d;
		}
		
		/**
		 * Creates a new Data instance from a data set.
		 * @param ds a DataSet to visualize. For example, this data set may be
		 *  loaded using a data converter in the flare.data library.
		 * @return a new Data instance, with NodeSprites and EdgeSprites
		 *  populated with the input data.
		 */
		public static function fromDataSet(ds:DataSet):Data {			
			var d:Data = new Data(), i:int;
			var schema:DataSchema, f:DataField;
			
			// copy node data defaults
			if ((schema = ds.nodes.schema)) {
				for (i=0; i<schema.numFields; ++i) {
					f = schema.getFieldAt(i);
					if (f.defaultValue)
						d.nodes.setDefault("data."+f.name, f.defaultValue);
				}
			}
			// add node data
			for each (var tuple:Object in ds.nodes.data) {
				d.addNode(tuple);
			}
			// exit if there is no edge data
			if (!ds.edges) return d;
				
			var nodes:DataList = d.nodes, map:Object = {};
			var id:String = "id"; // TODO: generalize these fields?
			var src:String = "source";
			var trg:String = "target";
			var dir:String = "directed";
			
			// build node map
			for (i=0; i<nodes.length; ++i) {
				map[nodes[i].data[id]] = nodes[i];
			}
			
			// copy edge data defaults
			if ((schema = ds.edges.schema)) {
				for (i=0; i<schema.numFields; ++i) {
					f = schema.getFieldAt(i);
					if (f.defaultValue)
						d.edges.setDefault("data."+f.name, f.defaultValue);
				}
				if ((f = schema.getFieldByName(dir))) {
					d.directedEdges = Boolean(f.defaultValue);
				}
			}
			// add edge data
			for each (tuple in ds.edges.data) {
				var n1:NodeSprite = map[tuple[src]];
				if (!n1) throw new Error("Missing node id="+tuple[src]);
				var n2:NodeSprite = map[tuple[trg]];
				if (!n2) throw new Error("Missing node id="+tuple[trg]);
				d.addEdgeFor(n1, n2, tuple[dir], tuple);
			}
			
			return d;
		}		
		
		// -- Group Management ---------------------------------
		
		/**
		 * Adds a new data group. If a group of the same name already exists,
		 * it will be replaced, except for the groups "nodes" and "edges",
		 * which can not be replaced. 
		 * @param name the name of the group to add
		 * @param group the data list to add, if null a new,
		 *  empty <code>DataList</code> instance will be created.
		 * @return the added data group
		 */
		public function addGroup(name:String, group:DataList=null):DataList
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			if (group==null) group = new DataList(name);
			_groups[name] = group;
			return group;
		}
		
		/**
		 * Removes a data group. An error will be thrown if the caller
		 * attempts to remove the groups "nodes" or "edges". 
		 * @param name the name of the group to remove
		 * @return the removed data group
		 */
		public function removeGroup(name:String):DataList
		{
			if (name=="nodes" || name=="edges") {
				throw new ArgumentError("Illegal group name. "
					+ "\"nodes\" and \"edges\" are reserved names.");
			}
			var group:DataList = _groups[name];
			if (group) delete _groups[name];
			return group;
		}
		
		/**
		 * Retrieves the data group with the given name. 
		 * @param name the name of the group
		 * @return the data group
		 */
		public function group(name:String):DataList
		{
			return _groups[name] as DataList;
		}
		
		// -- Containment --------------------------------------
		
		/**
		 * Indicates if this Data object contains the input DataSprite.
		 * @param d the DataSprite to check for containment
		 * @return true if the sprite is in this data collection, false
		 *  otherwise.
		 */
		public function contains(d:DataSprite):Boolean
		{
			return (_nodes.contains(d) || _edges.contains(d));
		}
		
		// -- Add ----------------------------------------------
		
		/**
		 * Adds a node to this data collection.
		 * @param d either a data tuple or NodeSprite object. If the input is
		 *  a non-null data tuple, this will become the new node's
		 *  <code>data</code> property. If the input is a NodeSprite, it will
		 *  be directly added to the collection.
		 * @return the newly added NodeSprite
		 */
		public function addNode(d:Object=null):NodeSprite
		{
			var ns:NodeSprite = NodeSprite(d is NodeSprite ? d : newNode(d));
			_nodes.add(ns);
			return ns;
		}
		
		/**
		 * Add an edge to this data set. The input must be of type EdgeSprite,
		 * and must have both source and target nodes that are already in
		 * this data set. If any of these conditions are not met, this method
		 * will return null. Note that no exception will be thrown on failures.
		 * @param e the EdgeSprite to add
		 * @return the newly added EdgeSprite
		 */
		public function addEdge(e:EdgeSprite):EdgeSprite
		{
			return EdgeSprite(_edges.add(e));
		}
		
		/**
		 * Generates edges for this data collection that connect the nodes
		 * according to the input properties. The nodes are sorted by the
		 * sort argument and grouped by the group-by argument. All nodes
		 * with the same group are sequentially connected to each other in
		 * sorted order by new edges. This method is useful for generating
		 * line charts from a plot of nodes.
		 * <p>If an edge already exists between nodes, by default this method
		 * will not add a new edge. Use the <code>ignoreExistingEdges</code>
		 * argument to change this behavior. </p>
		 * 
		 * @param sortBy the criteria for sorting the nodes, using the format
		 *  of <code>flare.util.Sort</code>. The input can either be a string
		 *  with a single property name, or an array of property names.  Items
		 *  are sorted in ascending order by default, prefix a property name
		 *  with a "-" (minus) character to sort in descending order.
		 * @param groupBy the criteria for grouping the nodes, using the format
		 *  of <code>flare.util.Sort</code>. The input can either be a string
		 *  with a single property name, or an array of property names. Items
		 *  are sorted in ascending order by default, prefix a property name
		 *  with a "-" (minus) character to sort in descending order.
		 * @param ignoreExistingEdges if false (the default), this method will
		 *  not create a new edge if one already exists between two nodes. If
		 *  true, new edges will be created regardless.
		 */
		public function createEdges(sortBy:*=null, groupBy:*=null,
			ignoreExistingEdges:Boolean=false):void
		{
			// create arrays and sort criteria
			var a:Array = Arrays.copy(_nodes.list);
			var g:Array = groupBy ? 
				(groupBy is Array ? groupBy as Array : [groupBy]) : [];
			var len:int = g.length;
			if (sortBy is Array) {
				var s:Array = sortBy as Array;
				for (var i:uint=0; i<s.length; ++i)
					g.push(s[i]);
			} else {
				g.push(sortBy);
			}
			
			// sort to group by, then ordering
			a.sort(Sort.$(g));
			
			// get property instances for value operations
			var p:Array = new Array();
			for (i=0; i<len; ++i) {
				if (g[i] is String)
					p.push(Property.$(g[i]));
			}
			var f:Property = p[p.length-1];
			
			// connect all items who match on the last group by field
			for (i=1; i<a.length; ++i) {
				if (!f || f.getValue(a[i-1]) == f.getValue(a[i])) {
					if (!ignoreExistingEdges && a[i].isConnected(a[i-1]))
						continue;
					var e:EdgeSprite = addEdgeFor(a[i-1], a[i], directedEdges);
					// add data values from nodes
					for (var j:uint=0; j<p.length; ++j) {
						p[j].setValue(e, p[j].getValue(a[i]));
					}
				}
			}
		}
		
		/**
		 * Creates a new edge between the given nodes and adds it to the
		 * data collection.
		 * @param source the source node (must already be in this data set)
		 * @param target the target node (must already be in this data set)
		 * @param directed indicates the directedness of the edge (null to
		 *  use this Data's default, true for directed, false for undirected)
		 * @param data a data tuple containing data values for the edge
		 *  instance. If non-null, this will become the EdgeSprite's
		 *  <code>data</code> property.
		 * @return the newly added EdgeSprite
 		 */
		public function addEdgeFor(source:NodeSprite, target:NodeSprite,
			directed:Object=null, data:Object=null):EdgeSprite
		{
			if (!_nodes.contains(source) || !_nodes.contains(target)) {
				return null;
			}
			var d:Boolean = directed==null ? directedEdges : Boolean(directed);
			var e:EdgeSprite = newEdge(source, target, d, data);
			if (data != null) e.data = data;
			source.addOutEdge(e);
			target.addInEdge(e);
			return addEdge(e);
		}
		
		/**
		 * Internal function for creating a new node. Creates a NodeSprite,
		 * sets its data property, and applies default values.
		 * @param data the new node's data property
		 * @return the newly created node
		 */
		protected function newNode(data:Object):NodeSprite
		{
			var ns:NodeSprite = new NodeSprite();
			_nodes.applyDefaults(ns);
			if (data != null) { ns.data = data; }
			return ns;
		}
		
		/**
		 * Internal function for creating a new edge. Creates an EdgeSprite,
		 * sets its data property, and applies default values.
		 * @param s the source node
		 * @param t the target node
		 * @param d the edge's directedness
		 * @param data the new edge's data property
		 * @return the newly created node
		 */		
		protected function newEdge(s:NodeSprite, t:NodeSprite,
								   d:Boolean, data:Object):EdgeSprite
		{
			var es:EdgeSprite = new EdgeSprite(s,t,d);
			_edges.applyDefaults(es);
			if (data != null) { es.data = data; }
			return es;
		}
		
		// -- Remove -------------------------------------------
		
		/**
		 * Clears this data set, removing all nodes and edges.
		 */
		public function clear():void
		{
			_edges.clear();
			_nodes.clear();
			for (var name:String in _groups) {
				_groups[name].clear();
			}
		}
		
		/**
		 * Removes a DataSprite (node or edge) from this data collection.
		 * @param d the DataSprite to remove
		 * @return true if removed successfully, false if not found
		 */
		public function remove(d:DataSprite):Boolean
		{
			if (d is NodeSprite) return removeNode(d as NodeSprite);
			if (d is EdgeSprite) return removeEdge(d as EdgeSprite);
			return false;
		}
				
		/**
		 * Removes a node from this data set. All edges incident on this
		 * node will also be removed. If the node is not found in this
		 * data set, the method returns null.
		 * @param n the node to remove
		 * @returns true if sucessfully removed, false if not found in the data
		 */
		public function removeNode(n:NodeSprite):Boolean
		{
			return _nodes.remove(n);
		}
		
		/**
		 * Removes an edge from this data set. The nodes connected to
		 * this edge will have the edge removed from their edge lists.
		 * @param e the edge to remove
		 * @returns true if sucessfully removed, false if not found in the data
		 */
		public function removeEdge(e:EdgeSprite):Boolean
		{
			return _edges.remove(e);
		}
				
		// -- Events -------------------------------------------
		
		/** @private */
		protected function onAddNode(evt:DataEvent):void
		{
			for each (var d:DataSprite in evt.items) {
				var n:NodeSprite = d as NodeSprite;
				if (!n) {
					evt.preventDefault();
					return;
				}
			}
			fireEvent(evt);
		}
		
		/** @private */
		protected function onRemoveNode(evt:DataEvent):void
		{
			for each (var n:NodeSprite in evt.items) {
				for (var i:uint=n.outDegree; --i>=0;)
					removeEdge(n.getOutEdge(i));
				for (i=n.inDegree; --i>=0;)
					removeEdge(n.getInEdge(i));
			}
			fireEvent(evt);
		}
		
		/** @private */
		protected function onAddEdge(evt:DataEvent):void
		{
			for each (var d:DataSprite in evt.items) {
				var e:EdgeSprite = d as EdgeSprite;
				if (!(e && _nodes.contains(e.source)
					&& _nodes.contains(e.target)))
				{
					evt.preventDefault();
					return;
				}
			}
			fireEvent(evt);
		}
		
		/** @private */
		protected function onRemoveEdge(evt:DataEvent):void
		{
			for each (var e:EdgeSprite in evt.items) {
				e.source.removeOutEdge(e);
				e.target.removeInEdge(e);
			}
			fireEvent(evt);
		}
		
		/** @private */
		protected function fireEvent(evt:DataEvent):void
		{			
			// reset the spanning tree on adds and removals
			if (evt.type != DataEvent.UPDATE)
				_tree = null;
			
			// fire event, if anyone is listening
			if (hasEventListener(evt.type)) {
				dispatchEvent(evt);
			}
		}
		
		// -- Visitors -----------------------------------------
		
		/**
		 * Visit items, invoking a function on all visited elements.
		 * @param v the function to invoke on each element. If the function
		 *  return true, the visitation is ended with an early exit
		 * @param group the data group to visit (e.g., NODES or EDGES). If this
		 *  value is null, both nodes and edges will be visited.
		 * @param filter an optional predicate function indicating which
		 *  elements should be visited. Only items for which this function
		 *  returns true will be visited.
  		 * @param reverse an optional parameter indicating if the visitation
		 *  traversal should be done in reverse (the default is false).
		 * @return true if the visitation was interrupted with an early exit
		 */
		public function visit(v:Function, group:String=null,
			filter:*=null, reverse:Boolean=false):Boolean
		{
			if (group == null) {
				if (_edges.length > 0 && _edges.visit(v, filter, reverse))
					return true;
				if (_nodes.length > 0 && _nodes.visit(v, filter, reverse))
					return true;
			} else {
				var list:DataList = _groups[group];
				if (list.length > 0 && list.visit(v, filter, reverse))
					return true;
			}
			return false;
		}
		
		
		// -- Spanning Tree ---------------------------------------------------
		
		/** The spanning tree constructor class. */
		protected var _span:TreeBuilder = new TreeBuilder();
		/** The root node of the spanning tree. */
		protected var _root:NodeSprite = null;
		/** The the spanning tree. */
		protected var _tree:Tree = null;
		
		/** The spanning tree creation policy. 
		 *  @see flare.analytics.graph.SpanningTree */
		public function get treePolicy():String { return _span.policy; }
		public function set treePolicy(p:String):void {
			if (_span.policy != p) {
				_span.policy = p;
				_tree = null;
			}
		}
		
		/** The edge weight function for computing a minimum spanning tree.
		 *  This function will only have an effect if the
		 *  <code>treePolicy</code> is
		 *  <code>SpanningTree.MINIMUM_SPAN</code> */
		public function get treeEdgeWeight():Function {
			return (_span ? _span.edgeWeight : null);
		}
		public function set treeEdgeWeight(w:*):void {
			_span.edgeWeight = w;
		}
		
		/** The root node of the spanning tree. */
		public function get root():NodeSprite { return _root; }
		public function set root(n:NodeSprite):void {
			if (n != null && !_nodes.contains(n))
				throw new ArgumentError("Spanning tree root must be within the graph.");
			if (_root != n) {
				_tree = null;
				_span.root = (_root = n);
			}
		}
		
		/**
		 * A spanning tree for this graph. The spanning tree generated is
		 * determined by the <code>root</code>, <code>treePolicy</code>,
		 * and <code>treeEdgeWeight</code> properties. By default, the tree
		 * is built using a breadth-first spanning tree using the first node
		 * in the graph as the root.
		 */
		public function get tree():Tree
		{
			if (_tree == null) { // build tree if necessary
				if (_root == null) _span.root = _nodes[0];
				_span.calculate(this, _span.root);
				_tree = _span.tree;
			}
			return _tree;	
		}
		public function set tree(t:Tree):void
		{
			if (t==null) { _tree = null; return; }
			
			var ok:Boolean;
			ok = t.root.visitTreeDepthFirst(function(n:NodeSprite):Boolean {
				return _nodes.contains(n);
			});
			if (ok) _tree = t;
		}

	} // end of class Data
}