package flare.demos
{
	import flare.demos.util.GraphUtil;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.controls.HoverControl;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.operator.layout.TreeMapLayout;
	
	import flash.display.StageQuality;
	
	/**
	 * Demo showcasing a treemap display and mouse-hover highlighting. 
	 */
	public class TreeMap extends Demo
	{
		private var vis:Visualization;
		
		public function TreeMap() {
			name = "Treemap";
		}
		
		public override function init():void
		{
			var tree:Tree = GraphUtil.balancedTree(4,5);
			var e:EdgeSprite, n:NodeSprite;
			
			// create the visualization
			vis = new Visualization(tree);
			vis.tree.nodes.visit(function(n:NodeSprite):void {
				n.size = Math.random();
				n.shape = Shapes.BLOCK; // needed for treemap sqaures
				n.fillColor = 0xff8888FF; n.lineColor = 0;
				n.fillAlpha = n.lineAlpha = n.depth / 25;
			});
			vis.data.edges.setProperty("visible", false);
			vis.operators.add(new TreeMapLayout());
			vis.bounds = bounds;
			vis.update();
			addChild(vis);
			
			// create a hover control to highlight nodes on mouse-over
			vis.controls.add(new HoverControl(NodeSprite,
				HoverControl.MOVE_AND_RETURN, rollOver, rollOut));
		}
		
		private function rollOver(evt:SelectionEvent):void {
			var n:NodeSprite = evt.node;
			n.lineColor = 0xffFF0000; n.lineWidth = 2;
			n.fillColor = 0xffFFFFAAAA;
		}
		
		private function rollOut(evt:SelectionEvent):void {
			var n:NodeSprite = evt.node;
			n.lineColor = 0; n.lineWidth = 0;
			n.fillColor = 0xff8888FF;
			n.fillAlpha = n.lineAlpha = n.depth / 25;
		}
		
		public override function resize():void
		{
			if (vis) {
				vis.bounds = bounds;
				vis.update();
			}
		}
		
		public override function play():void
		{
			stage.quality = StageQuality.LOW;
		}
		
		public override function stop():void
		{
			stage.quality = StageQuality.HIGH;
		}
		
	} // end of class TreeMap
}