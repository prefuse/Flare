package flare.demos.util
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class LinkGroup extends Sprite
	{
		private var _cur:Link = null;
		private var _map:Dictionary = new Dictionary();
		
		public override function addChild(child:DisplayObject):DisplayObject
		{
			child.x = width + (width>0 ? 10 : 0);
			super.addChild(child);
			return child;
		}
		
		public function add(link:Link):void {
			if (_map[link]) return;
			
			_map[link] = link;
			link.addEventListener(MouseEvent.CLICK, 
			function(evt:MouseEvent):void { select(link); });

			addChild(link);
		}
		
		public function remove(link:Link):void {
			delete _map[link];
		}
		
		public function select(link:Link):void {
			if (link != null && !_map[link]) return;
			if (_cur) _cur.selected = false;
			_cur = link;
			if (_cur) _cur.selected = true;
		}
		
	} // end of class LinkGroup
}