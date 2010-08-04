package flare.demos
{
	import flare.animate.FunctionSequence;
	import flare.animate.Transition;
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.demos.util.GraphUtil;
	import flare.demos.util.Link;
	import flare.query.methods.add;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.controls.DragControl;
	import flare.vis.controls.ExpandControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.IControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.OperatorSwitch;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.layout.CircleLayout;
	import flare.vis.operator.layout.CirclePackingLayout;
	import flare.vis.operator.layout.DendrogramLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	import flare.vis.operator.layout.IcicleTreeLayout;
	import flare.vis.operator.layout.IndentedTreeLayout;
	import flare.vis.operator.layout.Layout;
	import flare.vis.operator.layout.NodeLinkTreeLayout;
	import flare.vis.operator.layout.RadialTreeLayout;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Demo showcasing a number of tree and graph layout algorithms.
	 */
	public class Layouts extends Demo
	{
		private var vis:Visualization;
		private var os:OperatorSwitch;
		private var shape:String = null;
		
		private var opt:Array;
		private var idx:int = -1;
		
		public function Layouts() {
			name = "Layouts";
		}
		
		public override function init():void
		{
			// create a collection of layout options
			opt = options(bounds.width, bounds.height);
			idx = 0;
			
			// create data and set defaults
			var data:Data = GraphUtil.diamondTree(3,4,4);
			data.nodes.setProperties(opt[idx].nodes);
			data.edges.setProperties(opt[idx].edges);
			for (var j:int=0; j<data.nodes.length; ++j) {
				data.nodes[j].data.label = String(j);
				data.nodes[j].buttonMode = true;
			}
			// sort to ensure that children nodes are drawn over parents
			data.nodes.sortBy("depth");
			
			// create the visualization
			vis = new Visualization(data);
			vis.bounds = bounds;
			vis.operators.add(opt[idx].op);
			vis.setOperator("nodes", new PropertyEncoder(opt[idx].nodes, "nodes"));
			vis.setOperator("edges", new PropertyEncoder(opt[idx].edges, "edges"));
			vis.controls.add(new HoverControl(NodeSprite,
				// by default, move highlighted items to front
				HoverControl.MOVE_AND_RETURN,
				// highlight node border on mouse over
				function(e:SelectionEvent):void {
					e.node.lineWidth = 2;
					e.node.lineColor = 0x88ff0000;
				},
				// remove highlight on mouse out
				function(e:SelectionEvent):void {
					e.node.lineWidth = 0;
					e.node.lineColor = opt[idx].nodes.lineColor;
				}));
			vis.controls.add(opt[idx].ctrl);
			vis.update();
			addChild(vis);

			// create links for switching between layouts
			for (var i:uint=0; i<opt.length; ++i) {
				var link:Link = new Link(opt[i].name);
				link.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
					switchTo(event.target.text).play();
				});
				links.add(link);
				if (i==0) links.select(link);
			}
		}
		
		public override function resize():void
		{
			bounds.x += 15; bounds.width -= 30;
			bounds.y += 15;	bounds.height -= 15;
			if (vis) {
				vis.bounds = bounds;
				vis.update();
			}
		}
				
		private function switchTo(name:String):Transition
		{
			// determine the old and current layouts
			var old:Object = opt[idx];
			for (idx=0; idx<opt.length; ++idx) {
				if (opt[idx].name == name) break;
			}
			var cur:Object = opt[idx];
			
			// initialize the visualization
			vis.continuousUpdates = false;
			vis.operators.clear();
			vis.operators.add(cur.op);
			vis.setOperator("nodes", new PropertyEncoder(cur.nodes, "nodes"));
			vis.setOperator("edges", new PropertyEncoder(cur.edges, "edges"));
			// update controls
			HoverControl(vis.controls[0]).movePolicy = cur.dontMove
				? HoverControl.DONT_MOVE : HoverControl.MOVE_AND_RETURN;
			vis.controls.removeControlAt(1);
			if (cur.ctrl != null) vis.controls.add(cur.ctrl);
			
			// To handle animated transtions, we use a function sequence
			// this is like a normal animation sequence, except that each
			// animation segment is created lazily by a function when needed,
			// rather than generating the values for all segments up front.
			// This can help simplify the handling of intermediate values.
			var seq:FunctionSequence = new FunctionSequence();
			var nodes:DataList = vis.data.nodes;
			var edges:DataList = vis.data.edges;
			
			// First, straighten any edge-bends as needed
			if (old.straighten && !(cur.straighten || cur.canStraighten)) {
				seq.add(Layout.straightenEdges(edges, new Transitioner(1)));
			}
			// Now, build the main body of the animation
			if (old.nodes.shape != cur.nodes.shape) {
				if (old.nodes.shape == Shapes.CIRCLE) {
					// If the preceding shape is a circle, re-layout the nodes
					// first, then grow into the new shape type
					if (old.nodes.size != cur.nodes.size)
						seq.push(nodes.setLater({size: cur.nodes.size}), 0.5);
					seq.push(vis.updateLater(), 2);
					seq.push(vis.updateLater("edges"), 0.5);
					seq.push(nodes.setLater({scaleX:0, scaleY:0}), 0.5);
					seq.push(vis.updateLater("nodes"), 0);
					seq.push(nodes.setLater({scaleX:1, scaleY:1}), 0.5);
				} else if (cur.nodes.shape == Shapes.CIRCLE) {
					// If the current shape is a circle, change the shape type
					// first, and then re-layout the nodes
					seq.push(nodes.setLater({scaleX:0, scaleY:0}), 0.5);
					seq.push(vis.updateLater("nodes", "edges"), 0);
					seq.push(nodes.setLater({scaleX:1, scaleY:1}), 0.5);
					if (!cur.update)
						seq.push(vis.updateLater(), 2);
				} else {
					// If neither shape is a circle, switch to a circle shape,
					// re-layout the nodes, then switch to the final shape
					seq.push(nodes.setLater({scaleX:0, scaleY:0}), 0.5);
					seq.push(nodes.setLater({shape: Shapes.CIRCLE, size:1}), 0);
					seq.push(nodes.setLater({scaleX:1, scaleY:1}), 0.25);
					seq.push(vis.updateLater(), 2);
					seq.push(nodes.setLater({scaleX:0, scaleY:0}), 0.25);
					seq.push(vis.updateLater("nodes","edges"), 0);
					seq.push(nodes.setLater({scaleX:1, scaleY:1}), 0.5);
				}
			} else if (!cur.update) {
				// If there is no change in shape, update everything at once
				seq.push(vis.updateLater("nodes", "edges", "main"), 2);
			}
			// Finally, if performing a force-directed layout, set up
			// continuous updates and ease in the edge tensions.
			if (cur.update) {
				cur.op.defaultSpringTension = 0;
				seq.addEventListener(TransitionEvent.END,
					function(evt:Event):void {
						var t:Transitioner = vis.update(2, "nodes", "edges");
						t.$(cur.op).defaultSpringTension =
							cur.param.defaultSpringTension;
						t.play();
						vis.continuousUpdates = true;
					}
				);
			}
			return seq;
		}
		
		public override function play():void
		{
			if (opt[idx].update) vis.continuousUpdates = true;
		}
		
		public override function stop():void
		{
			vis.continuousUpdates = false;
		}
		
		/**
		 * This method builds a collection of layout operators and node
		 * and edge settings to be applied in the demo.
		 */
		private function options(w:Number, h:Number):Array
		{
			var a:Array = [
				{
					name: "Tree",
					op: new NodeLinkTreeLayout("topToBottom",20,5,10),
					canStraighten: true
				},
				{
					name: "Force",
					op: new ForceDirectedLayout(true),
					param: {
						"simulation.dragForce.drag": 0.2,
						defaultParticleMass: 3,
						defaultSpringLength: 40,
						defaultSpringTension: 0.5
					},
					update: true,
					ctrl: new DragControl(NodeSprite)
				},
				{
					name: "Indent",
					op: new IndentedTreeLayout(20),
					param: {layoutAnchor: new Point(350,40)},
					straighten: true
				},
				{
					name: "Radial",
					op: new RadialTreeLayout(50, false),
					param: {angleWidth: -2*Math.PI}
				},
				{
					name: "Circle",
					op: new CircleLayout(null, null, true),
					param: {angleWidth: -2*Math.PI},
					ctrl: new DragControl(NodeSprite)
				},
				{
					name: "Dendrogram",
					op: new DendrogramLayout(),
					nodes: {alpha: 0, visible: false},
					edges: {lineWidth:2},
					straighten: true
				},
				{
					name: "Bubbles",
					op: new CirclePackingLayout(4, false, "depth"),
					nodes: {size: add(1, "depth")},
					edges: {alpha:0, visible:false},
					ctrl: new DragControl(NodeSprite),
					canStraighten: true
				},
				{
					name: "Circle Pack",
					op: new CirclePackingLayout(4, true, "childDegree"),
					edges: {alpha:0, visible:false},
					canStraighten: true,
					dontMove: true
				},
				{
					name: "Icicle",
					op:	new IcicleTreeLayout("topToBottom"),
					nodes: {shape: Shapes.BLOCK, lineColor: 0xffffffff},
					edges: {alpha: 0, visible:false}
				},
				{
					name: "Sunburst",
					op: new RadialTreeLayout(50, false),
					param: {angleWidth: -2*Math.PI},
					nodes: {shape: Shapes.WEDGE, lineColor: 0xffffffff},
					edges: {alpha: 0, visible:false}
				}
			];
			
			// default values
			var nodes:Object = {
				shape: Shapes.CIRCLE,
				fillColor: 0x88aaaaaa,
				lineColor: 0xdddddddd,
				lineWidth: 1,
				size: 1.5,
				alpha: 1,
				visible: true
			}
			var edges:Object = {
				lineColor: 0xffcccccc,
				lineWidth: 1,
				alpha: 1,
				visible: true
			}
			var ctrl:IControl = new ExpandControl(NodeSprite,
				function():void { vis.update(1, "nodes","main").play(); });
			
			// apply defaults where needed
			var name:String;
			for each (var o:Object in a) {
				if (!o.nodes)
					o.nodes = nodes;
				else for (name in nodes)
					if (o.nodes[name]==undefined)
						o.nodes[name] = nodes[name];
					
				if (!o.edges)
					o.edges = edges;
				else for (name in edges)
					if (o.edges[name]==undefined)
						o.edges[name] = edges[name];
				
				if (!("ctrl" in o)) o.ctrl = ctrl;
				if (o.param) o.op.parameters = o.param;
			}
			return a;
		}
		
	} // end of class Layouts
}