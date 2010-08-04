 package flare.demos
{
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.ShapeRenderer;
	
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	
	/**
	 * Demo showcasing basic animation techniques. 
	 */
	public class Animation extends Demo
	{
		private var trans:Transitioner;
		private var timer:Timer;
		private var rev:Boolean = false;
		
		public function Animation() {
			name = "Animation";
		}
		
		public override function init():void
		{
			var N:uint = 9;
			
			// create a new renderer to use with increased size
			var sr:ShapeRenderer = new ShapeRenderer(15);
			
			// create an array of circles to animate
			var items:Array = [];
			for (var i:int=-N/2; i<N/2; ++i) {
				var d:DataSprite = new DataSprite();
				d.renderer = sr;
				d.x = 40*i;
				d.fillColor = 0x8888ff;
				d.fillAlpha = 0.8;
				d.render();
				d.mouseEnabled = false;
				addChild(d);
				items.push(d);
			}

			// set visual effects on circles
			items[0].filters = [new GlowFilter(0xff0000,1,10,10,2,5,false,false)];
			items[1].filters = [new DropShadowFilter()];
			items[2].filters = [new BlurFilter()];
			items[6].filters = [new BlurFilter()];
			items[7].filters = [new DropShadowFilter()];
			items[8].filters = [new GlowFilter(0xff0000,1,10,10,2,5,false,false)];
			
			// define animations using a transitioner
			trans = new Transitioner(2.5);
			trans.delay = 0.5;
			var o:Object;
			with (trans) {
				// the $() function returns an object for setting target values
				o = trans.$(items[5]); o.x = 0; o.y = 200;  o.alpha = 0;
				o = trans.$(items[3]); o.x = 0; o.y = -200; o.alpha = 0;
				o = trans.$(items[7]); o.x = 0; o.y = -200; o.alpha = 0;
				o = trans.$(items[1]); o.x = 0; o.y = 200;  o.alpha = 0;
				o = trans.$(items[8]); o.x = 0; o.y = 200;  o.alpha = 0;
				o = trans.$(items[0]); o.x = 0; o.y = -200; o.alpha = 0;

				$(items[2]).fillColor = 0xffCC3355;
				$(items[6]).fillColor = 0xffCC3355;
				$(items[5]).scaleX = 20;
				$(items[5]).scaleY = 20;
				$(items[3]).scaleX = 20;
				$(items[3]).scaleY = 20;
			}
		}
		
		public override function resize():void
		{
			x = (bounds.x + bounds.width) / 2;
			y = (bounds.y + bounds.height) / 2;
		}
		
		public override function play():void
		{
			trans.addEventListener(TransitionEvent.END, replay);
			trans.play();
			this.addEventListener(Event.ENTER_FRAME, onRotate);
		}
		
		public override function stop():void
		{
			trans.removeEventListener(TransitionEvent.END, replay);
			trans.stop();
			this.removeEventListener(Event.ENTER_FRAME, onRotate);
		}

		private function replay(event:Event):void {
			trans.play(!trans.reverse);
		}

		private function onRotate(event:Event) : void {
			this.rotation += 1;			
		}
		
	} // end of class Animation
}