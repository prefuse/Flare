package flare.analytics.graph
{
	import flare.animate.Transitioner;
	import flare.util.Property;
	import flare.vis.data.Data;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.Operator;
	
	import flash.utils.Dictionary;
	
	/**
	 * Calculates the maximum flow along edges of a graph using the
	 * Edmonds-Karp method. Each edge in the graph will be annotated with its
	 * final flow value, as well as a boolean value indicating if the edge
	 * is part of the minimum cut of the flow graph. Nodes are annotated with
	 * their partition according to the minimum cut: a partition value of 0
	 * indicates the source-side of the cut, a value of 1 indicates the
	 * sink-side of the cut.
	 */
	public class MaxFlowMinCut extends Operator
	{
		private var _c:Property = Property.$("props.capacity");
		private var _f:Property = Property.$("props.flow");
		private var _p:Property = Property.$("props.predecessor");
		private var _k:Property = Property.$("props.mincut");
		private var _cap:Function = null;
		
		/** The property in which to store computed flow values. This property
		 *  is used to annotate edges with the computed flow. The default
		 *  value is "props.flow". */
		public function get flowField():String { return _f.name; }
		public function set flowField(f:String):void { _f = Property.$(f); }
		
		/** The property in which to store minimum-cut data. The default value
		 *  is "props.mincut". This property is used to annotate nodes with
		 *  their partition (0 for source-side, 1 for sink-side) and to
		 *  annotate edges with min-cut membership (true if part of the
		 *  minimum cut, false otherwise). */
		public function get mincutField():String { return _k.name; }
		public function set mincutField(f:String):void { _k = Property.$(f); }
		
		/** The source node for which to compute the max flow. */
		public var source:NodeSprite;
		/** The sink node for which to compute the max flow. */
		public var sink:NodeSprite;
		/** A function defining the edge capacities for flow. When setting
		 *  this value, one can pass in either a Function, which should take an
		 *  EdgeSprite as input and return a Number as output, or a String, in
		 *  which case the string will be used as a property name from which to
		 *  retrieve the edge capacity value from an EdgeSprite instance.
		 *  If the value is null (the default) all edges will be assumed to have
		 *  capacity 1.
		 *  
		 *  <p><b>NOTE:</b> Capacities must be greater than or equal to zero!
		 *  </p> */
		public function get edgeCapacity():Function { return _cap; }
		public function set edgeCapacity(c:*):void {
			if (c==null) {
				_cap = null;
			} else if (c is String) {
				_cap = Property.$(String(c)).getValue;
			} else if (c is Function) {
				_cap = c;
			} else {
				throw new Error("Unrecognized edgeCapacity value. " +
					"The value should be a Function or String.");
			}
		}
		
		/** The computed maximum flow value. This value is zero by default
		 *  and is populated once the max flow calculation is run. */
		public function get maxFlow():Number { return _maxFlow; }
		
		private var _data:Data, _s:NodeSprite, _t:NodeSprite;
		private var _maxFlow:Number = 0;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new MaxFlowMinCut operator.
		 * @param source the source node in the flow graph
		 * @param sink the sink node in the flow graph
		 * @param edgeCapacity the edge capacity values. This can either be a
		 *  <code>Function</code> that returns capacity values or a
		 *  <code>String</code> providing the name of a property to look up on
		 *  <code>EdgeSprite</code> instances.
		 */
		public function MaxFlowMinCut(source:NodeSprite=null,
			sink:NodeSprite=null, edgeCapacity:*=null)
		{
			this.source = source;
			this.sink = sink;
			this.edgeCapacity = edgeCapacity;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			calculate(visualization.data, source, sink, _cap);
		}
		
		/**
		 * Calculates the maximum flow and minimum cut for the given data 
		 * @param data the data set containing the flow graph
		 * @param s the source node in the flow graph
		 * @param t the target or "sink" node in the flow graph
		 * @param c a function returning capacity values for edges
		 */
		public function calculate(data:Data, s:NodeSprite, t:NodeSprite,
			c:Function=null):void
        {
        	_data = data; _s = s; _t = t;
        	_data.nodes.visit(function(n:NodeSprite):void {
        		_c.setValue(n, 0);
        		_f.setValue(n, 0);
        		_p.setValue(n, null);
        	});
        	_data.edges.visit(function(e:EdgeSprite):void {
        		var cap:Number = (c==null ? 1 : c(e));
				if (cap < 0) throw new Error("Edge capacity must be > 0!");
        		_c.setValue(e, cap);
        	});
            
            // update flows until no more augmenting path
            while (augmentingPath()) {
            	var cap:Number = _c.getValue(_t);
            	_maxFlow += cap;
            	var v:NodeSprite = _t, u:NodeSprite, e:EdgeSprite;
            	while (v != _s) {
            		e = _p.getValue(v);
            		u = e.source;
            		
            		_f.setValue(e, _f.getValue(e) + cap);
            		_c.setValue(e, _c.getValue(e) - cap);
            		v = u;
            	}
            }
            minCut();
            
            _data.visit(_c.deleteValue);
            _data.nodes.visit(_p.deleteValue);
        }
 
 		/**
 		 * Uses a breadth-first-search to find an augmenting path that
 		 * increases the net flow through the graph.
 		 */
        private function augmentingPath():Boolean
        {
        	_data.nodes.setProperty(_c.name, Number.MAX_VALUE);
        	var visited:Dictionary = new Dictionary();
        	var queue:Array = [_s], u:NodeSprite, b:Boolean;
        	
        	while (queue.length > 0) {
        		visited[u = queue.shift()] = true;
        		b = u.visitEdges(function(e:EdgeSprite):Boolean {
        			// get residual capacity on edge
        			var cap:Number = _c.getValue(e);
        			var v:NodeSprite = e.other(u);
        			if (visited[v] || cap <= 0) return false;
        			
        			_c.setValue(v, Math.min(_c.getValue(u), cap));
        			_p.setValue(v, e);
        			if (v == _t) return true;
        			queue.push(v);
        			return false;
        		}, NodeSprite.OUT_LINKS);
        		if (b) return true;
        	}
            return false;
        }
        
        /**
         * Given that the max flow has been computed, finds the minimum-cut
         * of the flow graph, annotating nodes according to their partition
         * (source-side or sink-side) and annotating the edges that constitute
         * the minimum cut.
         */
        private function minCut():void
        {
        	_data.nodes.setProperty(_k.name, 1);
        	var visited:Dictionary = new Dictionary();
        	var queue:Array = [_s], u:NodeSprite, b:Boolean;
        	
        	while (queue.length > 0) {
        		visited[u = queue.shift()] = true;
        		_k.setValue(u, 0);
        		
        		u.visitEdges(function(e:EdgeSprite):void {
        			var v:NodeSprite = e.other(u);
        			if (!(visited[v] || _c.getValue(e) <= 0))
        				queue.push(v);
        		}, NodeSprite.OUT_LINKS);
        	}
            
            _data.edges.visit(function(e:EdgeSprite):void {
            	var up:int = _k.getValue(e.source);
            	var vp:int = _k.getValue(e.target);
            	_k.setValue(e, (up==0 && vp==1));
            });
        }

	} // end of class MaxFlowMinCut
}