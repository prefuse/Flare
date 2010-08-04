package flare.demos
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.demos.util.GraphUtil;
	import flare.demos.util.Link;
	import flare.vis.Visualization;
	import flare.vis.controls.AnchorControl;
	import flare.vis.operator.OperatorSwitch;
	import flare.vis.operator.distortion.BifocalDistortion;
	import flare.vis.operator.distortion.FisheyeDistortion;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.layout.Layout;
	import flare.vis.operator.layout.NodeLinkTreeLayout;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Demo showcasing different layout distortions. 
	 */
	public class Distortions extends Demo
	{
		private var vis:Visualization;
		private var layout:Layout;
		private var distort:Layout;
		private var oswitch:OperatorSwitch;
		
		public function Distortions() {
			name = "Distortions";
		}
		
		public override function init():void
		{	
			// create visualization
			addChild(vis = new Visualization(GraphUtil.diamondTree(4, 6, 6)));
			vis.bounds = bounds;
			vis.x = 15;
			vis.y = 30;
			vis.operators.add(new PropertyEncoder({scaleX:1, scaleY:1}));
			vis.operators.add(layout=new NodeLinkTreeLayout());
			// create a switch for choosing between distortions
			oswitch = new OperatorSwitch(
				new FisheyeDistortion(4,0,2),
				new FisheyeDistortion(0,4,2),
				new FisheyeDistortion(4,4,2),
				new BifocalDistortion(0.1, 3.0, 0.1, 1.0),
				new BifocalDistortion(0.1, 1.0, 0.1, 3.0),
				new BifocalDistortion(0.1, 3.0, 0.1, 3.0)
			);
			vis.operators.add(oswitch);
			distort = oswitch[oswitch.index=0] as Layout;
			play();
			vis.update();
			
			// create distortion selection links
			var names:Array = ["Fisheye X","Fisheye Y","Fisheye XY",
							   "Bifocal X","Bifocal Y","Bifocal XY"];
			for (var i:uint=0; i<names.length; ++i) {
				var link:Link = new Link(names[i]);
				link.addEventListener(MouseEvent.CLICK, function(e:Event):void
				{
					setDistortion(links.getChildIndex(DisplayObject(e.target)));
				});
				links.add(link);
				if (i==0) links.select(link);
			}
		}
		
		private function setDistortion(idx:int):void
		{
			// update the switch index and re-init the anchor control
			oswitch[idx].layoutAnchor = oswitch[oswitch.index].layoutAnchor;
			oswitch.index = idx;
			distort = oswitch.getOperatorAt(idx) as Layout;
			stop();
			var t:Transitioner = vis.update(1);
			t.addEventListener(TransitionEvent.END,
				function(e:TransitionEvent):void { play(); });
			t.play();
		}
		
		public override function resize():void
		{
			bounds.width -= 30;
			bounds.height -= 60;
			if (vis) {
				vis.bounds = bounds;
				vis.update();
			}
		}
		
		public override function play():void {
			vis.controls.add(new AnchorControl(distort));
		}
		
		public override function stop():void {
			vis.controls.clear();
		}

	} // end of class Distortions
}