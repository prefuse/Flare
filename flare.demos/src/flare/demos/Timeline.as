package flare.demos
{
	import flare.analytics.optimization.AspectRatioBanker;
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.demos.util.Link;
	import flare.display.TextSprite;
	import flare.scale.ScaleType;
	import flare.util.Maths;
	import flare.vis.Visualization;
	import flare.vis.controls.DragControl;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.operator.OperatorList;
	import flare.vis.operator.OperatorSwitch;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.layout.AxisLayout;
	import flare.vis.operator.layout.ForceDirectedLayout;
	
	import flash.events.MouseEvent;
	
	/**
	 * Demo showcasing a timeline layout (and a bad idea). 
	 */
	public class Timeline extends Demo
	{
		private var vis:Visualization;
		private var banker:AspectRatioBanker;
		
		public function Timeline() {
			name = "Timeline";
		}
		
		public override function init():void
		{
			// timeline visualization definition
			var timeline:OperatorList = new OperatorList(
				// the banker automatically selects the visualization
				// bounds to optimize the perception of trends in the chart
				banker = new AspectRatioBanker("data.count", true,
					bounds.width, bounds.height),
				new AxisLayout("data.date", "data.count"),
				new ColorEncoder("data.series", Data.EDGES,
					"lineColor", ScaleType.CATEGORIES),
				new ColorEncoder("data.series", Data.NODES,
					"fillColor", ScaleType.CATEGORIES),
				new PropertyEncoder({
					lineAlpha: 0, alpha: 0.5, buttonMode: false,
					scaleX: 1, scaleY: 1, size: 0.5
				}),
				new PropertyEncoder({lineWidth:2}, Data.EDGES)
			);
			timeline[1].xScale.flush = true; // tight margins on timeline
			
			// "bad idea" graph layout definition
			var forces:ForceDirectedLayout = new ForceDirectedLayout(true);
			forces.simulation.nbodyForce.gravitation = -10;
			forces.defaultSpringLength = 20;
			
			// create the visualization
			vis = new Visualization(getTimeline(50,3));
			// add a switch to select between visual encodings
			vis.operators.add(new OperatorSwitch(timeline, forces));
			vis.operators[0].index = 0;
			with (vis.xyAxes.xAxis) {
				// position axis labels along timeline
				horizontalAnchor = TextSprite.LEFT;
				verticalAnchor = TextSprite.MIDDLE;
				labelAngle = Math.PI / 2;
			}
			vis.bounds = bounds.clone();
			vis.update();
			vis.x = 40;
			vis.y = 40;
			addChild(vis);
			
			// -- add links ---------------------------------------------------
			
			// add link to show the timeline
			var time:Link = new Link("Timeline");
			time.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void {
				if (vis.operators[0].index != 0) {
					vis.continuousUpdates = false;
					vis.operators[0].index = 0;
					vis.controls.clear();
					
					// update, and delay axis visibility to after the update
					var t:Transitioner = vis.update(1.5);
					t.$(vis.axes).alpha = 0;
					t.$(vis.axes).visible = false;
					t.addEventListener(TransitionEvent.END,
						function(evt:TransitionEvent):void {
							forces.showAxes(new Transitioner(0.5)).play();
						}
					);
					t.play();
				}
			});
			links.add(time);
			links.select(time);
			
			// add "bad idea" link to transform timeline into a graph
			var bad:Link = new Link("Bad Idea!!");
			bad.addEventListener(MouseEvent.CLICK,function(evt:MouseEvent):void
			{
				if (vis.operators[0].index != 1) {
					vis.operators[0].index = 1;
					vis.bounds = bounds.clone();
					vis.continuousUpdates = true;
					vis.controls.add(new DragControl(NodeSprite));
					
					vis.data.nodes.setProperties({
						buttonMode:true, scaleX:2, scaleY:2
					}, 1).play();
				}
			});
			links.add(bad);
		}
		
		public override function resize():void
		{
			bounds.width -= 80;
			bounds.height -= 80;
			if (vis) {
				vis.bounds = bounds.clone();
				banker.maxWidth = bounds.width;
				banker.maxHeight = bounds.height;
				if (!vis.continuousUpdates) {
					vis.update();
				}
			}
		}
		
		public override function play():void
		{
			if (vis && vis.operators[0].index==1)
				vis.continuousUpdates = true;
		}
		
		public override function stop():void
		{
			vis.continuousUpdates = false;
		}
		
		public static function getTimeline(N:int, M:int):Data
		{
			var MAX:Number = 60;
			var t0:Date = new Date(1979,5,15);
			var t1:Date = new Date(1982,2,19);
			var x:Number, f:Number;
			
			var data:Data = new Data();
			for (var j:uint=0; j<M; ++j) {
				for (var i:uint=0; i<N; ++i) {
					f = i/(N-1);
					x = t0.time + f*(t1.time - t0.time);
					data.addNode({
						series: int(j),
						date: new Date(x),
						count:int((j*MAX/M) + MAX/M * (1+Maths.noise(13*f,j)))
					});
				}
			}
			// create timeline edges connecting items sorted by date
			// and grouped by series
			data.createEdges("data.date", "data.series");

			return data;
		}
		
	} // end of class Timeline
}