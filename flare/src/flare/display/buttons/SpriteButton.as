package flare.display.buttons
{
	import flare.display.render.BitmapRenderer;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 *  
	 * @author thomasburleson
	 * 
	 */
	public class SpriteButton extends Sprite
	{

		
		// ========================================
		// Protected constants
		// ========================================
		
		/**
		 * Drag threshold.
		 */
		protected static const DRAG_THRESHOLD:Number = 1;
		
		
		/**
		 * BitmapData cache (by Bitmap Class).
		 */
		protected static const bitmapDataCache:Dictionary = new Dictionary();

		// ========================================
		// Protected properties
		// ========================================
		
		/**
		 * Backing variable for <code>disabled</code> property.
		 */
		protected var _disabled:Boolean;
		
		/**
		 * Backing variable for <code>icon</code> property.
		 */
		protected var _icon:Class;

		/**
		 * Backing variable for <code>upSkinBitmapClass</code> property.
		 */
		protected var _upSkinBitmapClass:Class;
		
		/**
		 * Backing variable for <code>overSkinBitmapClass</code> property.
		 */
		protected var _overSkinBitmapClass:Class;
		
		/**
		 * Backing variable for <code>downSkinBitmapClass</code> property.
		 */
		protected var _downSkinBitmapClass:Class;
		
		/**
		 * Backing variable for <code>disabledSkinBitmapClass</code> property.
		 */
		protected var _disabledSkinBitmapClass:Class;
		
		/**
		 * Backing variable for <code>minWidth</code> property.
		 */
		protected var _minWidth:Number;
		
		/**
		 * Backing variable for <code>minHeight</code> property.
		 */
		protected var _minHeight:Number;			
		
		/**
		 * Button phase.
		 */
		protected var buttonPhase:String;
		
		protected var renderer : BitmapRenderer = new BitmapRenderer();;
		
		/**
		 * Backing variable for <code>verticalPadding</code> property.
		 */
		protected var _verticalPadding:Number = 0;
		
		/**
		 * Backing variable for <code>horizontalPadding</code> property.
		 */
		protected var _horizontalPadding:Number = 0;		
		
		// ========================================
		// Public properties
		// ========================================
		
		/**
		 * Indicates whether this button is disabled.
		 */
		public function get disabled():Boolean
		{
			return _disabled;
		}
		
		public function set disabled( value:Boolean ):void
		{
			if ( _disabled != value  )
			{
				_disabled = value;
				
				refresh();
			}
		}
		
		/**
		 * Icon.
		 * 
		 * NOTE: Unlike a Flex Button, SpriteButton displays EITHER an icon OR a label.
		 */
		public function get icon():Class
		{
			return _icon;
		}
		
		public function set icon( value:Class ):void
		{
			if ( _icon != value  )
			{
				_icon = value;
				
				refresh();
			}
		}
		
		/**
		 * Bitmap skin for the 'up' button state.
		 */
		public function get upSkinBitmapClass():Class
		{
			return _upSkinBitmapClass;
		}
		
		public function set upSkinBitmapClass( value:Class ):void
		{
			if ( _upSkinBitmapClass != value )
			{
				_upSkinBitmapClass = value;
				
				refresh();
			}
		}		
		
		/**
		 * Bitmap skin for the 'over' button state.
		 */
		public function get overSkinBitmapClass():Class
		{
			return _overSkinBitmapClass;
		}
		
		public function set overSkinBitmapClass( value:Class ):void
		{
			if ( _overSkinBitmapClass != value )
			{
				_overSkinBitmapClass = value;
				
				refresh();
			}
		}
		
		/**
		 * Bitmap skin for the 'down' button state.
		 */
		public function get downSkinBitmapClass():Class
		{
			return _downSkinBitmapClass;
		}
		
		public function set downSkinBitmapClass( value:Class ):void
		{
			if ( _downSkinBitmapClass != value )
			{
				_downSkinBitmapClass = value;
				
				refresh();
			}
		}

		/**
		 * Bitmap skin for the 'disabled' button state.
		 */
		public function get disabledSkinBitmapClass():Class
		{
			return _disabledSkinBitmapClass;
		}
		
		public function set disabledSkinBitmapClass( value:Class ):void
		{
			if ( _disabledSkinBitmapClass != value )
			{
				_disabledSkinBitmapClass = value;
				
				refresh();
			}
		}
		
		/**
		 * Vertical padding.
		 */
		public function get verticalPadding():Number
		{
			return _verticalPadding;
		}
		
		public function set verticalPadding( value:Number ):void
		{
			if ( _verticalPadding != value )
			{
				_verticalPadding = value;
				
				refresh();
			}
		}
		
		/**
		 * Horizontal padding.
		 */
		public function get horizontalPadding():Number
		{
			return _horizontalPadding;
		}
		
		public function set horizontalPadding( value:Number ):void
		{
			if ( _horizontalPadding != value )
			{
				_horizontalPadding = value;
				
				refresh();
			}
		}
		
		/**
		 * Minimum width.
		 */
		public function get minWidth():Number
		{
			return _minWidth;
		}
		
		public function set minWidth( value:Number ):void
		{
			if ( _minWidth != value )
			{
				_minWidth = value;
				
				refresh();
			}
		}
		
		/**
		 * Minimum height.
		 */
		public function get minHeight():Number
		{
			return _minHeight;
		}
		
		public function set minHeight( value:Number ):void
		{
			if ( _minHeight != value )
			{
				_minHeight = value;
				
				refresh();
			}
		}
		
		// ========================================
		// Constructor
		// ========================================		
		
		/**
		 * Constructor.
		 */
		public function SpriteButton()
		{
			super();
			
			// Configure Sprite.
			
			mouseEnabled = true;
			mouseChildren = false;
			useHandCursor = true;
			buttonMode = true;
			
			// Setup initial internal state.
			
			buttonPhase = ButtonPhase_UP;
			
			// Add MouseEvent.ROLL_OVER, MouseEvent.ROLL_OUT listeners.
			
			addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			addEventListener( MouseEvent.ROLL_OVER, rollOverHandler );
			addEventListener( MouseEvent.ROLL_OUT, rollOutHandler );
			
			refresh();
		}

		protected function refresh():void
		{
			graphics.clear();
			
			// Draw the button skin.

			var buttonSkin:Class = getBitmapSkinForButtonPhase();
			if ( buttonSkin != null ) {
				graphics.clear();
				renderer.drawBitmap(graphics,buttonSkin,0,0);	
			}
			
			// Draw the icon OR the label.
			
			if ( icon != null ) renderer.drawBitmap( graphics, icon, horizontalPadding, verticalPadding);
			
			// Update width / height to remain with specified <code>minWidth</code. and <code>maxWidth</code>.
			
			width  = Math.max( width,  minWidth );
			height = Math.max( height, minHeight );
		}		
		
		protected function getBitmapSkinForButtonPhase():Class
		{
			switch ( buttonPhase )
			{
				default:
				case ButtonPhase_UP:
					return upSkinBitmapClass;
				
				case ButtonPhase_OVER:
					return ( overSkinBitmapClass != null ) ? overSkinBitmapClass : upSkinBitmapClass;
					
				case ButtonPhase_DOWN:
					return ( downSkinBitmapClass != null ) ? downSkinBitmapClass : upSkinBitmapClass;
			}
		}
		
		/**
		 * Handle MouseEvent.MOUSE_DOWN.
		 */
		protected function mouseDownHandler( event : MouseEvent ):void
		{
			buttonPhase = ButtonPhase_DOWN;
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			refresh();
		}
		
		/**
		 * Handle MouseEvent.MOUSE_MOVE.
		 */
		protected function mouseMoveHandler( event:MouseEvent ):void {
		}
		
		/**
		 * Handle MouseEvent.MOUSE_UP.
		 */
		protected function mouseUpHandler( event:MouseEvent ):void
		{
			buttonPhase = ButtonPhase_UP;
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			refresh();
		}

		/**
		 * Handle MouseEvent.ROLL_OVER.
		 */
		protected function rollOverHandler( event:MouseEvent ):void
		{
			buttonPhase = ( event.buttonDown ) ? ButtonPhase_DOWN : ButtonPhase_OVER;
			
			refresh();
		}
		
		/**
		 * Handle MouseEvent.ROLL_OUT.
		 */
		protected function rollOutHandler( event:MouseEvent ):void
		{
			buttonPhase = ButtonPhase_UP;
			
			refresh();
		}

		// ************************************************************************
		// Copies of values in mx.controls.ButtonPhase so dependency is removed!
		// ************************************************************************
		
		/**
		 *  @private
		 */
		public static const ButtonPhase_DOWN:String = "down";
		
		/**
		 *  @private
		 */
		public static const ButtonPhase_OVER:String = "over";
		
		/**
		 *  @private
		 */
		public static const ButtonPhase_UP:String = "up";
	}
}
