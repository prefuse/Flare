package flare.demos.util
{
	import flare.display.TextSprite;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;

	public class Link extends TextSprite
	{		
		public var textColor:uint  = 0x555555;
		public var selColor:uint   = 0xff0000;
		public var hoverColor:uint = 0xff7777;
		private var _selected:Boolean = false;
		
		public function get selected():Boolean { return _selected; }
		public function set selected(b:Boolean):void {
			_selected = b;
			color = b ? selColor : textColor;
		}
		
		public function Link(text:String=null, size:int=14)
		{
			super(text, new TextFormat("Verdana",size,textColor));
			name = text;
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void {
				color = selected ? selColor : hoverColor;
			});
			addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void {
				color = _selected ? selColor : textColor;
			});
		}
		
	}
}