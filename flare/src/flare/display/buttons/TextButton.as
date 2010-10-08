package flare.display.buttons
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TextButton extends SpriteButton
	{

		/**
		 * Backing variable for <code>label</code> property.
		 */
		protected var _label:String;
		
		/**
		 * Backing variable for <code>fontFamily</code> property.
		 */
		protected var _fontFamily:String;

		/**
		 * Backing variable for <code>fontSize</code> property.
		 */
		protected var _fontSize:Number;
		
		/**
		 * Backing variable for <code>color</code> property.
		 */
		protected var _color:uint;

		/**
		 * Indicates whether text formatting has been invalidated.
		 */
		protected var textFormattingChanged:Boolean;
		
		/**
		 * Text field for label.
		 */
		protected var textField:TextField;

		
		// ========================================
		// Public properties
		// ========================================
		
		/**
		 * Label.
		 * 
		 * NOTE: Unlike a Flex Button, TextButton displays EITHER an icon OR a label.
		 */
		public function get label():String
		{
			return _label;
		}
		
		public function set label( value:String ):void
		{
			if ( _label != value )
			{
				_label = value;
				
				refresh();
			}
		}

		/**
		 * Label font family.
		 */
		public function get fontFamily():String
		{
			return _fontFamily;
		}
		
		public function set fontFamily( value:String ):void
		{
			if ( _fontFamily != value )
			{
				_fontFamily = value;
				
				textFormattingChanged = true;
				
				refresh();
			}
		}
		
		/**
		 * Label font size.
		 */
		public function get fontSize():Number
		{
			return _fontSize;
		}
		
		public function set fontSize( value:Number ):void
		{
			if ( _fontSize != value )
			{
				_fontSize = value;
				
				textFormattingChanged = true;
				
				refresh();
			}
		}

		/**
		 * Label text color.
		 */
		public function get color():uint
		{
			return _color;
		}
		
		public function set color( value:uint ):void
		{
			if ( _color != value )
			{
				_color = value;
				
				textFormattingChanged = true;
				
				refresh();
			}
		}		
		
		
		// ========================================
		// Constructor
		// ========================================		
		
		/**
		 * Constructor.
		 */
		public function TextButton()
		{
			super();
			
			// Create and add the label TextField
			
			textField = new TextField();
			
			textField.embedFonts = true;
			textField.selectable = false;
			
			addChild( textField );
						
		}

		override protected function refresh():void
		{
			super.refresh();
			
			textField.x = horizontalPadding;
			textField.y = verticalPadding;
			
			if ( textFormattingChanged )
			{
				var textFormat:TextFormat = new TextFormat( fontFamily, fontSize, color );
				
				textField.defaultTextFormat = textFormat;
				textField.textColor = color;
				
				textFormattingChanged = false;
			}				
			
			textField.visible = true;
			
		}		
		
	}
}
