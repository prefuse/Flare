package {
	import flare.animate.TransitionEvent;
	import flare.animate.Transitioner;
	import flare.demos.Animation;
	import flare.demos.Bars;
	import flare.demos.Demo;
	import flare.demos.Distortions;
	import flare.demos.Layouts;
	import flare.demos.Pie;
	import flare.demos.Scatter;
	import flare.demos.Smoke;
	import flare.demos.Stacks;
	import flare.demos.Timeline;
	import flare.demos.TreeMap;
	import flare.demos.util.Link;
	import flare.demos.util.LinkGroup;
	import flare.display.LineSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	[SWF(width="1000",height="700",backgroundColor="#ffffff", frameRate="30")]
	public class demos extends Sprite
	{
		private var _demos:Array;
		private var _links:LinkGroup;
		private var _demo:Sprite;
		private var _home:FlareLogo;
		private var _logo:FlareLogo;
		private var _line:LineSprite;
		private var _cur:int = -1;
		
		public function demos()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			
			// create logo
			_logo = new FlareLogo();
			_logo.play();
			addChild(_logo);
				
			// create demos
			createDemos();
			onResize();
		}
		
		private function createDemos():void
		{
			addChild(_line = new LineSprite());
			
			_demo = new Sprite();
			addChild(_demo);
			
			_demos = new Array();
			_demos.push(new Animation());
			_demos.push(new Smoke());
			_demos.push(new Layouts());
			_demos.push(new Distortions());
			_demos.push(new TreeMap());
			_demos.push(new Stacks());
			_demos.push(new Timeline());
			_demos.push(new Scatter());
			_demos.push(new Bars());
			_demos.push(new Pie());
			
			_home = new FlareLogo(4.5, false);
			_home.name = "Logo";
			_home.buttonMode = true;
			_home.glow.play();
			_home.addEventListener(MouseEvent.CLICK, cancel);
			addChild(_home);
			
			_links = new LinkGroup(); addChild(_links);
			for (var i:uint=0; i<_demos.length; ++i) {
				var link:Link = new Link(_demos[i].name, 18);
				link.addEventListener(MouseEvent.CLICK, showDemo);
				_links.add(link);
			}
			
			_home.x = 15;
			_home.y = 15;
			_links.x = _home.x + _home.width + 15;
			_links.y = 13;
			Demo.LINK_X = _links.x;
			Demo.LINK_Y = _links.y + (4/5)*_links.height + 1;
			_line.lineColor = 0xffededed;
			_line.x1 = 0; _line.x2 = stage.stageWidth;
			_line.y = _home.y + _home.height + 8;
			
		}
		
		private function showDemo(event:MouseEvent):void
		{
			if (_cur >= 0) {
				_demos[_cur].stop();
				_demo.removeChild(_demos[_cur] as Sprite);
				_cur = -1;
			}
			
			var tgt:DisplayObject = event.target as DisplayObject;
			_cur = _links.getChildIndex(tgt);
			_demo.alpha = 0;
			_demo.addChild(_demos[_cur] as Sprite);
			
			var t:Transitioner = new Transitioner(1);
			t.$(_logo).alpha = 0;
			t.play();
						
			t = new Transitioner(1);
			t.delay = 0.5;
			t.addEventListener(TransitionEvent.START,
				function(evt:Event):void {
					onResize();
					_demos[_cur].start();
				}
			);
			t.$(_demo).alpha = 1;
			t.play();
			_logo.pause();
		}
		
		private function cancel(event:MouseEvent=null):void
		{
			_links.select(null);
			
			var t:Transitioner = new Transitioner(1);
			t.$(_demo).alpha = 0;
			
			t.addEventListener(TransitionEvent.END, function(evt:Event):void {
				_demos[_cur].stop();
				_demo.removeChild(_demos[_cur] as Sprite);
				_cur = -1;
			});
			t.play();
			
			t = new Transitioner(1);
			t.delay = 0.5;
			t.$(_logo).alpha = 1;
			t.play();
			_logo.play();
		}
		
		private function onResize(event:Event=null):void
		{
			_logo.x = stage.stageWidth / 2;
			_logo.y = (stage.stageHeight + 50) / 2;
			_line.x2 = stage.stageWidth;
			if (_cur >= 0) {
				_demos[_cur].bounds = new Rectangle(0, _line.y,
					stage.stageWidth, stage.stageHeight-(_line.y));
			}
		}
		
	} // end of class demos
}