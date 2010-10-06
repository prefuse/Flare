package flare.display
{
	import flare.display.render.BackgroundRenderer;
	import flare.display.render.IBackgroundRenderer;
	import flare.util.Colors;
	import flare.util.Padding;
	import flare.util.gradient.Gradient;
	import flare.util.gradient.GradientStop;
	
	import flash.geom.Rectangle;

	public class DisplaySprite extends DirtySprite
	{
		// -- Protected Properties -----------------------------

		/**
		 * Backing variable for <code>backgroundRenderer</code> property.
		 */
		protected var _backgroundRenderer:IBackgroundRenderer = BackgroundRenderer.instance;
		
		/**
		 * Backing variable for <code>backgroundBorder</code> property. 
		 */
		protected var _backgroundBorder:Boolean;
		
		/**
		 * Backing variable for <code>backgroundBorderColor</code> property. 
		 */
		protected var _backgroundBorderColor:uint;
		
		/**
		 * Backing variable for <code>backgroundBorderThickness</code> property. 
		 */
		protected var _backgroundBorderThickness:Number;
		
		/**
		 * Backing variable for <code>backgroundBorderPixelHinting</code> property.
		 */
		protected var _backgroundBorderPixelHinting:Boolean;
		
		/**
		 * Backing variable for <code>backgroundFill</code> property.
		 */
		protected var _backgroundFill:Boolean;
		
		/**
		 * Backing variable for <code>backgroundFillColor</code> property. 
		 */
		protected var _backgroundFillColor:uint;
		
		/**
		 * Backing variable for <code>backgroundFillGradient</code> property.
		 */
		protected var _backgroundFillGradient:Gradient;

		/**
		 * Backing variable for <code>backgroundCornerWidth</code> property. 
		 */
		protected var _backgroundCornerWidth:Number;

		/**
		 * Backing variable for <code>backgroundCornerHeight</code> property. 
		 */
		protected var _backgroundCornerHeight:Number;

		/**
		 * Backing variable for <code>backgroundPadding</code> property. 
		 */
		protected var _backgroundPadding:Padding;		
		
		// -- Display Properties -------------------------------
	
		/**
		 * Background renderer.
		 */
		public function get backgroundRenderer():IBackgroundRenderer
		{
			return _backgroundRenderer;
		}
		public function set backgroundRenderer( value:IBackgroundRenderer ):void
		{
			_backgroundRenderer = value;
			dirty();
		}
		
		/**
		 * Indicates whether to renderer a background border.
		 */
		public function get backgroundBorder():Boolean
		{
			return _backgroundBorder;
		}
		public function set backgroundBorder( value:Boolean ):void
		{ 
			_backgroundBorder = value; 
			dirty();
		}

		/**
		 * Background border color.
		 */
		public function get backgroundBorderColor():uint
		{
			return _backgroundBorderColor;
		}
		public function set backgroundBorderColor( value:uint ):void
		{
			_backgroundBorderColor = value;
			dirty();
		}
		
		/** 
		 * Background border alpha (Number between 0 and 1).
		 */
		public function get backgroundBorderAlpha():Number
		{ 
			return Colors.a( _backgroundBorderColor ) / 255;
		}
		public function set backgroundBorderAlpha( value:Number ):void
		{
			_backgroundBorderColor = Colors.setAlpha( _backgroundBorderColor, uint( 255 * value ) % 256 );
			dirty();
		}

		/** 
		 * Hue component of the background border color in HSV color space. 
		 */
		public function get backgroundBorderHue():Number
		{ 
			return Colors.hue( _backgroundBorderColor );
		}
		public function set backgroundBorderHue( hue:Number ):void
		{
			_backgroundBorderColor = 
				Colors.hsv( 
					hue, 
					Colors.saturation( _backgroundBorderColor ), 
					Colors.value( _backgroundBorderColor ), 
					Colors.a( _backgroundBorderColor )
				);
			dirty();
		}
		
		/** 
		 * Saturation component of the background border color in HSV color space. 
		 */
		public function get backgroundBorderSaturation():Number
		{ 
			return Colors.saturation( _backgroundBorderColor );
		}
		public function set backgroundBorderSaturation( saturation:Number ):void
		{
			_backgroundBorderColor = 
				Colors.hsv( 
					Colors.hue( _backgroundBorderColor ), 
					saturation,
					Colors.value( _backgroundBorderColor ), 
					Colors.a( _backgroundBorderColor )
				);
			dirty();
		}
		
		/** 
		 * Value component of the background border color in HSV color space. 
		 */
		public function get backgroundBorderValue():Number
		{ 
			return Colors.value( _backgroundBorderColor );
		}
		public function set backgroundBorderValue( value:Number ):void
		{
			_backgroundBorderColor = 
				Colors.hsv( 
					Colors.hue( _backgroundBorderColor ), 
					Colors.saturation( _backgroundBorderColor ), 
					value, 
					Colors.a( _backgroundBorderColor )
				);
			dirty();
		}
		
		/**
		 * Background border thickness.
		 */
		public function get backgroundBorderThickness():Number
		{
			return _backgroundBorderThickness;
		}
		public function set backgroundBorderThickness( value:Number ):void
		{
			_backgroundBorderThickness = value;
			dirty();
		}

		/**
		 * Indicates whether to use pixel hinting when rendering the background border.
		 */
		public function get backgroundBorderPixelHinting():Boolean
		{
			return _backgroundBorderPixelHinting;
		}
		public function set backgroundBorderPixelHinting( value:Boolean ):void
		{
			_backgroundBorderPixelHinting = value;
			dirty();
		}
		
		/**
		 * Indicates whether to render a background fill.
		 */
		public function get backgroundFill():Boolean
		{
			return _backgroundFill;
		}
		public function set backgroundFill( value:Boolean ):void
		{
			_backgroundFill = value;
			dirty();
		}
		
		/**
		 * Background fill color.
		 */
		public function get backgroundFillColor():uint
		{
			return _backgroundFillColor;
		}
		public function set backgroundFillColor( value:uint ):void
		{
			_backgroundFillColor = value;
			dirty();
		}
		
		/** 
		 * Background fill alpha (Number between 0 and 1).
		 */
		public function get backgroundFillAlpha():Number
		{ 
			return Colors.a( _backgroundFillColor ) / 255;
		}
		public function set backgroundFillAlpha( value:Number ):void
		{
			_backgroundFillColor = Colors.setAlpha( _backgroundFillColor, uint( 255 * value ) % 256 );
			dirty();
		}

		/** 
		 * Hue component of the background fill color in HSV color space. 
		 */
		public function get backgroundFillHue():Number
		{ 
			return Colors.hue( _backgroundFillColor );
		}
		public function set backgroundFillHue( hue:Number ):void
		{
			_backgroundFillColor = 
				Colors.hsv( 
					hue, 
					Colors.saturation( _backgroundFillColor ), 
					Colors.value( _backgroundFillColor ), 
					Colors.a( _backgroundFillColor )
				);
			dirty();
		}
		
		/** 
		 * Saturation component of the background fill color in HSV color space. 
		 */
		public function get backgroundFillSaturation():Number
		{ 
			return Colors.saturation( _backgroundFillColor );
		}
		public function set backgroundFillSaturation( saturation:Number ):void
		{
			_backgroundFillColor = 
				Colors.hsv( 
					Colors.hue( _backgroundFillColor ), 
					saturation,
					Colors.value( _backgroundFillColor ), 
					Colors.a( _backgroundFillColor )
				);
			dirty();
		}
		
		/** 
		 * Value component of the background fill color in HSV color space. 
		 */
		public function get backgroundFillValue():Number
		{ 
			return Colors.value( _backgroundFillColor );
		}
		public function set backgroundFillValue( value:Number ):void
		{
			_backgroundFillColor = 
				Colors.hsv( 
					Colors.hue( _backgroundFillColor ), 
					Colors.saturation( _backgroundFillColor ), 
					value, 
					Colors.a( _backgroundFillColor )
				);
			dirty();
		}

		/**
		 * Background fill gradient.
		 * 
		 * @see flare.util.gradient.Gradient
		 */
		public function get backgroundFillGradient():Gradient
		{
			return _backgroundFillGradient;
		}
		public function set r( value:Gradient ):void
		{
			_backgroundFillGradient = value;
			dirty();
		}		
		
		/**
		 * Background corner width.
		 */
		public function get backgroundCornerWidth():Number
		{
			return _backgroundCornerWidth;
		}
		public function set backgroundCornerWidth( value:Number ):void
		{
			_backgroundCornerWidth = value;
			dirty();
		}

		/**
		 * Background corner height.
		 */
		public function get backgroundCornerHeight():Number
		{
			return _backgroundCornerHeight;
		}
		public function set backgroundCornerHeight( value:Number ):void
		{
			_backgroundCornerHeight = value;
			dirty();
		}

		/**
		 * Background padding.
		 */
		public function get backgroundPadding():Padding
		{
			return _backgroundPadding;
		}
		public function set backgroundPadding( value:Padding ):void
		{
			_backgroundPadding = value;
			dirty();
		}		
		
		// -- Constructor --------------------------------------

		/**
		 * Constructor.
		 */
		public function DisplaySprite()
		{
			super();
			
			_backgroundBorder 				= false;
			_backgroundFill 				= false;
			_backgroundBorderThickness 		= 1.0;
			_backgroundBorderPixelHinting 	= true;
			_backgroundCornerHeight 		= 0;
			_backgroundCornerWidth 			= 0;
			_backgroundPadding 				= null;
				
			// TODO: Externalize this configuration via the Labeler.
			
			_backgroundBorder 				= true;
			_backgroundBorderColor 			= 0xff9a9a9a;
			_backgroundFill 				= true;
			
			_backgroundCornerHeight 		= 16;
			_backgroundCornerWidth 			= 16;
			
			var gradient:Gradient = new Gradient(
				[
					new GradientStop( 0xff454545, 0.0 ),
					new GradientStop( 0xff262626, 1.0 )
				],
				Math.PI / 2 
			);
			
			_backgroundFillGradient 		= gradient;
			
			_backgroundPadding 				= new Padding( 2, 2, 2, 2 );
		}
		
		// -- Public methods -----------------------------------
		
		/**
		 * @inheritDoc
		 * 
		 * @see #renderBackground()
		 */
		override public function render():void
		{
			// Subclasses should override.
		}
		
		/**
		 * Render the background.
		 * 
		 * NOTE: Be sure to call graphics.clear() and complete all layout and drawing first.
		 */
		public function renderBackground():void
		{
			if ( _backgroundRenderer != null) {
				var bounds:Rectangle = getBounds( this );
				
				if ( _backgroundPadding != null )
					bounds = _backgroundPadding.apply( bounds );
				
				_backgroundRenderer.render( this, bounds );
			}
		}
	}
}