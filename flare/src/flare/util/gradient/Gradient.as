package flare.util.gradient
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Gradient
	{
		// -- Protected properties -----------------------------

		/**
		 * Backing variable for <code>angle</code> property.
		 */
		protected var _angle:Number;
		
		/**
		 * Backing variable for <code>focalPointRatio</code> property.
		 */
		protected var _focalPointRatio:Number;
		
		/**
		 * Backing variable for <code>gradientStops</code> property.
		 */
		protected var _gradientStops:Array;
		
		/**
		 * Backing variable for <code>gradientType</code> property.
		 */
		protected var _gradientType:String;
		
		/**
		 * Backing variable for <code>interpolationMethod</code> property.
		 */
		protected var _interpolationMethod:String;
		
		/**
		 * Backing variable for <code>spreadMethod</code> property.
		 */
		protected var _spreadMethod:String;

		// -- Public properties --------------------------------

		/**
		 * Angle (in radians).
		 */
		public function get angle():Number
		{
			return _angle;
		}
		public function set angle( value:Number ):void
		{
			_angle = value;
		}

		/**
		 * Focal point ratio.
		 */
		public function get focalPointRatio():Number
		{
			return _focalPointRatio;
		}
		public function set focalPointRatio( value:Number ):void
		{
			_focalPointRatio = value;
		}		
		
		[ArrayElementType("flare.util.gradient.GradientStop")]
		/**
		 * Gradient stop(s).
		 * 
		 * @see flare.util.gradient.GradientStop
		 */
		public function get gradientStops():Array
		{
			return _gradientStops;
		}
		public function set gradientStops( value:Array ):void
		{
			_gradientStops = value;
		}

		/**
		 * Gradient type.
		 * 
		 * @see flash.display.GradientType
		 */
		public function get gradientType():String
		{
			return _gradientType;
		}
		public function set gradientType( value:String ):void
		{
			_gradientType = value;
		}

		/**
		 * Interpolation method.
		 * 
		 * @see flash.display.InterpolationMethod
		 */
		public function get interpolationMethod():String
		{
			return _interpolationMethod;
		}
		public function set interpolationMethod( value:String ):void
		{
			_interpolationMethod = value;
		}
		
		/**
		 * Spread method.
		 * 
		 * @see flash.display.SpreadMethod
		 */
		public function get spreadMethod():String
		{
			return _spreadMethod;
		}
		public function set spreadMethod( value:String ):void
		{
			_spreadMethod = value;
		}		
		
		// -- Constructor --------------------------------------

		/**
		 * Constructor.
		 */
		public function Gradient( gradientStops:Array, angle:Number = 0.0, gradientType:String = "linear" /* GradientType.LINEAR */, focalPointRatio:Number = 0.0, spreadMethod:String = "pad" /* SpreadMethod.PAD */, interpolationMethod:String = "rgb" /* InterpolationMethod.RGB */ )
		{
			super();
			
			this.gradientStops = gradientStops;
			this.angle = angle;
			this.gradientType = gradientType;
			this.focalPointRatio = focalPointRatio;
			this.spreadMethod = spreadMethod;
			this.interpolationMethod = interpolationMethod;
		}

		// -- Public methods -----------------------------------
		
		/**
		 * Begin the gradient fill in the specified graphics context.
		 */
		public function begin( graphics:Graphics, bounds:Rectangle ):void
		{
			var colors:Array = [];
			var alphas:Array = [];
			var ratios:Array = [];
			
			for each ( var gradientStop:GradientStop in gradientStops )
			{
				colors.push( gradientStop.color & 0x00ffffff );
				alphas.push( gradientStop.alpha );
				ratios.push( gradientStop.ratio * 255 );
			}
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox( bounds.width, bounds.height, angle, bounds.x, bounds.y );
			
			graphics.beginGradientFill( gradientType, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio );
		}
		
		/**
		 * End the gradient fill in the specified graphics context.
		 */
		public function end( graphics:Graphics ):void
		{
			graphics.endFill();
		}
	}
}