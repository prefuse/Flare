package flare.demos
{
	import flare.demos.util.Link;
	import flare.display.TextSprite;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.events.TooltipEvent;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.label.RadialLabeler;
	import flare.vis.operator.layout.PieLayout;
	
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	
	/**
	 * Demo showcasing a pie chart layout, tooltips, and labels. 
	 */
	public class Pie extends Demo
	{
		private var vis:Visualization;
		
		public function Pie() {
			name = "Pie";
		}
		
		public override function init():void
		{
			// create pie chart
			vis = new Visualization(getData(16));
			vis.bounds = bounds;
			vis.data.nodes.setProperty("lineAlpha", 0);
			vis.operators.add(new PieLayout("data.value", 0.7));
			vis.operators.add(new ColorEncoder("data.value","nodes","fillColor"));
			// Add text labels. The LAYER constant indicates labels should be
			// placed in separate layer of the visualization
			vis.operators.add(new RadialLabeler("data.id", false,
				new TextFormat("Arial",15,0,true), null, Labeler.LAYER));
			vis.operators.last.radiusOffset = 15;
			vis.update();
			addChild(vis);
			
			// -- add tooltips ------------------------------------------------
			
			// create a tooltip with the underlying data value and percentage
			var sum:Number = vis.data.nodes.stats("data.value").sum;
			vis.controls.add(new TooltipControl(DataSprite, null,
				function(e:TooltipEvent):void {
					var v:Number = e.node.data.value;
					TextSprite(e.tooltip).htmlText = Strings.format(
						"<b>Value</b>: {0:0.0} ({1:0.0%})", v, v/sum);
				}
			));
			
			// -- add links ---------------------------------------------------
			
			// donut chart link
			var expand:Link = new Link("Donut"); links.add(expand);
			expand.addEventListener(MouseEvent.CLICK,
				function(evt:MouseEvent):void
				{
					PieLayout(vis.operators[0]).width = 0.7;
					vis.update(1).play();
				}
			);
			links.select(expand);
			
			// pie chart link
			var collapse:Link = new Link("Pie"); links.add(collapse);
			collapse.addEventListener(MouseEvent.CLICK, 
				function(evt:MouseEvent):void {
					PieLayout(vis.operators[0]).width = 0;
					vis.update(1).play();
				}
			);
		}
		
		public override function resize():void
		{
			bounds.x += 35; bounds.width -= 70;
			bounds.y += 35; bounds.height -= 55;
			if (vis) {
				vis.bounds = bounds;
				vis.update();
			}
		}
		
		public static function getData(N:int):Data
		{
			var data:Data = new Data();
			for (var i:uint=0; i<N; ++i) {
				data.addNode({
					id: String.fromCharCode("A".charCodeAt(0)+i),
					value: 100*Math.random()
				});
			}
			return data;
		}
		
	} // end of class Pie
}