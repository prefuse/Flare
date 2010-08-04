package flare.widgets
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	[Event(name="search", type="flash.events.Event")]

	public class SearchBox extends Sprite
	{
		public static const SEARCH:String = "search";
		
		private var _label:TextField;
		private var _input:TextField;
		private var _clear:ClearButton;
		private var _hit:Sprite;
		
		private var _fmt:TextFormat;
		private var _border:Boolean = true;
		private var _borderColor:uint = 0xcccccc;
		private var _autoHide:Boolean = false;
		
		public function get label():TextField { return _label; }
		public function get input():TextField { return _input; }
		
		public function get query():String { return _input.text; }
		public function set query(q:String):void { _input.text=q; onSearch(); }
		
		public function get border():Boolean { return _border; }
		public function set border(b:Boolean):void {
			if (b != _border) { _border = b; resize(); }
		}
		
		public function get borderColor():uint { return _borderColor; }
		public function set borderColor(c:uint):void {
			if (c != _borderColor) { _borderColor = c; resize(); }
		}
		
		public function get autoHideCancel():Boolean { return _autoHide; }
		public function set autoHideCancel(b:Boolean):void {
			if (_autoHide == b) return;
			_autoHide = b;
			if (b) {
				addEventListener(MouseEvent.ROLL_OVER, autoShow);
				addEventListener(MouseEvent.ROLL_OUT, autoHide);
				autoHide();
			} else {
				removeEventListener(MouseEvent.ROLL_OVER, autoShow);
				removeEventListener(MouseEvent.ROLL_OUT, autoHide);
				autoShow();
			}
		}
		
		// --------------------------------------------------------------------
		
		public function SearchBox(fmt:TextFormat=null, labelText:String=">> ",
			searchBoxWidth:Number=250)
		{
			_fmt = fmt ? fmt : new TextFormat();
			init(labelText, searchBoxWidth);
		}
		
		protected function init(labelText:String, boxWidth:Number):void
		{
			// create search box label
			_label = new TextField();
			_label.defaultTextFormat = _fmt;
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.selectable = false;
			_label.text = labelText;
			_label.x = 0
			addChild(_label);
			
			// create search box
			_input = new TextField();
			_input.type = TextFieldType.INPUT;
			_input.defaultTextFormat = _fmt;
			_input.selectable = true;
			_input.width = boxWidth;
			_input.height = _label.height;
			_input.text = "";
			_input.wordWrap = false;
			_input.addEventListener(KeyboardEvent.KEY_UP, onSearch);
			addChild(_input);
			
			// create clear button
			_clear = new ClearButton();
			_clear.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				_input.text = "";
				onSearch();
			});
			addChild(_clear);
			
			addChild(_hit = new Sprite());
			_hit.visible = false;
			
			resize();
		}
		
		public function resize():void {
			_label.x = 0;
			_input.x = _label.x + _label.width + (_border ? 5 : 1);
			_clear.x = _input.x + _input.width + 2;
			_clear.size = _input.height/2 - 1;
			_clear.y = _input.height / 4 + 1;
			
			graphics.clear();
			if (_border) drawBorder();
			
			_hit.graphics.clear();
			_hit.graphics.beginFill(0);
			_hit.graphics.drawRect(0, 0, width, height);
			hitArea = _hit;
		}
		
		private function drawBorder():void {
			graphics.lineStyle(0, _borderColor);
			graphics.drawRect(_input.x-3, 0,
				_clear.x+_clear.width - _input.x + 6,
				_input.height);
		}
		
		private function onSearch(evt:Event=null):void
		{
			this.dispatchEvent(new Event(SEARCH));
		}
		
		private function autoHide(evt:Event=null):void
		{
			_clear.visible = false;
		}
		
		private function autoShow(evt:Event=null):void
		{
			if (_input.text.length > 0)
				_clear.visible = true;
		}
		
	} // end of class SearchBox
}

import flash.display.CapsStyle;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;
	
class ClearButton extends Sprite
{
	private var _size:Number = 12;
	private var _defColor:uint = 0xffcccc;
	private var _selColor:uint = 0xff0000;
	private var _selected:Boolean = false;
	
	public function get size():Number { return _size; }
	public function set size(s:Number):void { _size = s; render(); }
	
	public function get selected():Boolean { return _selected; }
	public function set selected(s:Boolean):void { _selected = s; render(); }
	
	public function get defaultColor():uint { return _defColor; }
	public function set defaultColor(c:uint):void { _defColor = c; render(); }
	
	public function get selectedColor():uint { return _selColor; }
	public function set selectedColor(c:uint):void { _selColor = c; render(); }
	
	public function ClearButton(size:Number=12,
		defaultColor:uint=0xffcccc, selectedColor:uint=0xff0000)
	{
		_size = size;
		_defColor = defaultColor;
		_selColor = selectedColor;
		buttonMode = true;
		render();
		
		var sel:Function = function(e:Event):void { selected = true; };
		var des:Function = function(e:Event):void { selected = false; };
		addEventListener(MouseEvent.MOUSE_OVER, sel);
		addEventListener(MouseEvent.MOUSE_OUT, des);
		addEventListener(MouseEvent.MOUSE_DOWN, des);
		addEventListener(MouseEvent.MOUSE_UP, sel);
	}
	
	private function render():void
	{
		var c:uint = _selected ? _selColor : _defColor;
		graphics.clear();
		graphics.lineStyle(int(_size/3)+1, c, 1, false, "normal", CapsStyle.ROUND);
		graphics.moveTo(0, 0);
		graphics.lineTo(_size, _size);
		graphics.moveTo(_size, 0);
		graphics.lineTo(0, _size);
	}
	
} // end of class ClearButton