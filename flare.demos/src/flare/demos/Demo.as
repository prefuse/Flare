package flare.demos
{
	import flare.demos.util.LinkGroup;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
		
	public class Demo extends Sprite
	{
		public static var LINK_X:Number;
		public static var LINK_Y:Number;
		
		private var _init:Boolean = false;
		private var _bounds:Rectangle;
		private var _links:LinkGroup;
		
		public function get bounds():Rectangle { return _bounds; }
		public function set bounds(b:Rectangle):void {
			_bounds = b;
			if (_links) {
				_links.x = LINK_X;
				_links.y = LINK_Y;
				setChildIndex(_links, numChildren-1);
			}
			resize();
		}
		
		protected function get links():LinkGroup { return _links; }
		protected function set links(links:LinkGroup):void
		{
			if (_links) removeChild(_links);
			_links = links;
			if (links != null) addChildAt(_links, numChildren);
		}
		
		// --------------------------------------------------------------------
		
		public function Demo() {
			this.links = new LinkGroup();
		}
		
		public function start():void
		{
			if (!_init) { init(); _init = true; }
			play();
			if (_links) {
				_links.x = LINK_X;
				_links.y = LINK_Y;
				setChildIndex(_links, numChildren-1);
			}
		}
		
		public function init() : void
		{
		}

		public function play() : void
		{
		}
		
		public function stop() : void
		{
		}
		
		public function resize():void
		{
		}
		
	} // end of class Demo
}