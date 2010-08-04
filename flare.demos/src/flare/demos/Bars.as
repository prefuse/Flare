package flare.demos
{
	import flare.animate.Transitioner;
	import flare.demos.util.Link;
	import flare.display.TextSprite;
	import flare.scale.ScaleType;
	import flare.util.Shapes;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.events.TooltipEvent;
	import flare.vis.operator.encoder.ColorEncoder;
	import flare.vis.operator.layout.AxisLayout;
	
	import flash.events.MouseEvent;
	
	/**
	 * Demo showcasing a bar chart layout and tooltips. 
	 */
	public class Bars extends Demo
	{
		/** The tooltip format string. */
		private static const _tipText:String =
			"<b>Category</b>: {0}<br/>" + 
			"<b>Position</b>: {1}<br/>" +
			"<b>Value</b>: {2}";
		
		private var vis:Visualization;
		
		public function Bars() {
			name = "Bars";
		}
		
		public override function init():void
		{
			// create the visualization
			vis = new Visualization(getData(44,20));
			vis.bounds = bounds;
			vis.data.nodes.setProperties({
				shape: Shapes.HORIZONTAL_BAR,
				lineAlpha: 0,
				size: 2.5 * bounds.height / vis.data.nodes.length
			});
			vis.operators.add(new AxisLayout("data.x", "data.y", true, false));
			vis.operators.add(new ColorEncoder("data.s", "nodes", "fillColor", ScaleType.CATEGORIES));
			vis.xyAxes.yAxis.showLines = false;
			vis.update();
			addChild(vis);
			vis.x = 50; vis.y = 20;
			
			// add tooltip showing data values
			vis.controls.add(new TooltipControl(DataSprite, null,
				function(evt:TooltipEvent):void {
					var d:DataSprite = evt.node;
					TextSprite(evt.tooltip).htmlText = 
						Strings.format(_tipText, d.data.s, d.data.y, d.data.x);
				}
			));
			
			// add data update link
			var link:Link = new Link("Update Values"); links.add(link);
			link.addEventListener(MouseEvent.CLICK, function(evt:MouseEvent):void
			{
				updateData(vis.data);
				vis.update(new Transitioner(2)).play();
			});
		}
		
		public override function resize():void
		{
			bounds.width -= 100;
			bounds.height -= 50;
			if (vis) {
				vis.bounds = bounds;
				vis.update();
				var size:Number = 2.5 * bounds.height / vis.data.length;
				vis.data.nodes.setProperty("size", size);
			}
		}
		
		public static function getData(N:int, M:int):Data
		{
			var data:Data = new Data();
			for (var i:uint=0; i<N; ++i) {
				for (var j:uint=0; j<M; ++j) {
					var s:String = String(i<10?"0"+i:i);
					data.addNode({
						y:s, s:j, x: int(1 + 10*Math.random())
					});
				}
			}
			return data;
		}
		
		public static function updateData(data:Data):void
		{
			data.nodes.visit(function(d:DataSprite):void {
				d.data.x = int(1 + 10*Math.random());
			});
		}
		
	} // end of class Bars
}