package flare.demos
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.demos.util.Link;
	import flare.util.Colors;
	import flare.util.Shapes;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.operator.layout.StackedAreaLayout;
	
	import flash.display.Shape;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Demo showcasing an animated stacked area chart.
	 */
	public class Stacks extends Demo
	{
		private var vis:Visualization;
		private var labelMask:Shape = new Shape();
		
		public function Stacks() {
			name = "Stacks";
		}
		
		public override function init():void
		{
			// get data set with data values and column names
			var dataset:Object = getData(500);
			
			// create the visualization
			vis = new Visualization(dataset.data);
			vis.bounds = bounds;
			vis.operators.add(new StackedAreaLayout(dataset.columns));
			vis.data.nodes.visit(function(d:DataSprite):void {
				d.fillColor = Colors.rgba(0xAA,0xAA,100 + uint(155*Math.random()));
				d.fillAlpha = 1;
				d.lineAlpha = 0;
				d.shape = Shapes.POLYGON;
			});
			vis.x = 60;
			vis.y = 15;
			vis.update();
			addChild(vis);
			
			// add mask to hide animating labels
			vis.xyAxes.addChild(labelMask);
			vis.xyAxes.yAxis.labels.mask = labelMask;
			
			// add "show all" link to make all stacks visible
			var show:Link = new Link("Show All"); links.add(show);
			show.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
				vis.data.nodes["visible"] = true;
				update(new Transitioner(1.5));
			});
			
			// add "filter randomly" link
			var filt:Link = new Link("Filter Randomly"); links.add(filt);
			filt.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
				var t:Transitioner = new Transitioner(1.5);
				var thresh:Number = 0.25 + 0.75 * Math.random();
				vis.data.nodes.visit(function(d:DataSprite):void {
					t.$(d).visible = Math.random() < thresh;
				});
				update(t);
			});
			links.select(show);
		}
		
		public override function resize():void
		{
			bounds.width -= 85;
			bounds.height -= 50;
			if (vis) {
				vis.bounds = bounds;
				vis.update();
			}
			// mask the y-axis labels to hide extreme animation
			labelMask.graphics.clear();
			labelMask.graphics.beginFill(0);
			labelMask.graphics.drawRect(
				bounds.left-50, -10+bounds.top, 50, 20+bounds.height);
		}
		
		private function update(t:Transitioner):void
		{
			// toggle screen quality during animation to boost frame rate
			t.addEventListener(TransitionEvent.START,
				function(e:Event):void {stage.quality = StageQuality.LOW});
			t.addEventListener(TransitionEvent.END,
				function(e:Event):void {stage.quality = StageQuality.HIGH});	
			vis.update(t).play();
		}
		
		public static function getData(N:int):Object
		{
			var cols:Array = [-3,1,3,4,5,6,7,8,9,10];
			var i:uint, col:String;
			
			var data:Data = new Data();
			for (i=0; i<N; ++i) {
				var d:DataSprite = data.addNode();
				var j:uint = 0, s:Number;
				for each (col in cols) {
					s = 1 + int((j++)/2);
					d.data[col] = s*Math.random();
				}
			}
			
			return { data:data, columns:cols };
		}
		
	} // end of class Stacks
}