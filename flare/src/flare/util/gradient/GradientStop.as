package flare.util.gradient
{
	import flare.util.Colors;

	public class GradientStop
	{
		// -- Protected Properties -----------------------------

		/**
		 * Backing variable for <code>backgroundFillColor</code> property. 
		 */
		protected var _color:uint;

		/**
		 * Backing variable for <code>backgroundCornerHeight</code> property. 
		 */
		protected var _ratio:Number;
		
		// -- Public Properties --------------------------------
		
		/**
		 * Color.
		 */
		public function get color():uint
		{
			return _color;
		}
		public function set color( value:uint ):void
		{
			_color = value;
		}

		/** 
		 * Alpha (Number between 0 and 1).
		 */
		public function get alpha():Number
		{ 
			return Colors.a( _color ) / 255;
		}
		public function set alpha( value:Number ):void
		{
			_color = Colors.setAlpha( _color, uint( 255 * value ) % 256 );
		}

		/** 
		 * Hue component of the color in HSV color space. 
		 */
		public function get colorHue():Number
		{ 
			return Colors.hue( _color );
		}
		public function set colorHue( hue:Number ):void
		{
			_color = 
				Colors.hsv( 
					hue, 
					Colors.saturation( _color ), 
					Colors.value( _color ), 
					Colors.a( _color )
				);
		}
		
		/** 
		 * Saturation component of the color in HSV color space. 
		 */
		public function get colorSaturation():Number
		{ 
			return Colors.saturation( _color );
		}
		public function set colorSaturation( saturation:Number ):void
		{
			_color = 
				Colors.hsv( 
					Colors.hue( _color ), 
					saturation,
					Colors.value( _color ), 
					Colors.a( _color )
				);
		}
		
		/** 
		 * Value component of the color in HSV color space. 
		 */
		public function get colorValue():Number
		{ 
			return Colors.value( _color );
		}
		public function set colorValue( value:Number ):void
		{
			_color = 
				Colors.hsv( 
					Colors.hue( _color ), 
					Colors.saturation( _color ), 
					value, 
					Colors.a( _color )
				);
		}		
		
		/**
		 * Ratio (Number between 0 and 1).
		 */
		public function get ratio():Number
		{
			return _ratio;
		}
		public function set ratio( value:Number ):void
		{
			_ratio = value;
		}
		
		// -- Constructor --------------------------------------
		
		public function GradientStop( color:uint, ratio:Number )
		{
			super();
			
			this.color = color;
			this.ratio = ratio;
		}
	}
}