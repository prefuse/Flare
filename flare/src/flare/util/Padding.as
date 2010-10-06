package flare.util
{
	import flash.geom.Rectangle;

	public class Padding
	{
		// -- Protected properties -----------------------------
		
		/**
		 * Backing variable for <code>left</code> property.
		 */
		protected var _left:Number = 0;
		
		/**
		 * Backing variable for <code>top</code> property.
		 */
		protected var _top:Number = 0;
		
		/**
		 * Backing variable for <code>right</code> property.
		 */
		protected var _right:Number = 0;
		
		/**
		 * Backing variable for <code>bottom</code> property.
		 */
		protected var _bottom:Number = 0;

		// -- Public properties --------------------------------
		
		/**
		 * Left padding.
		 */
		public function get left():Number
		{
			 return _left;
		}
		public function set left( value:Number ):void
		{
			_left = value;
		}
		
		/**
		 * Top padding.
		 */
		public function get top():Number
		{
			return _top;
		}
		public function set top( value:Number ):void
		{
			_top = value;
		}
		
		/**
		 * Right padding.
		 */
		public function get right():Number
		{
			return _right;
		}
		public function set right( value:Number ):void
		{
			_right = value;
		}
		
		/**
		 * Bottom padding.
		 */
		public function get bottom():Number
		{
			return _bottom;
		}
		public function set bottom( value:Number ):void
		{
			_bottom = value;
		}
		
		// -- Constructor --------------------------------------
		
		/**
		 * Constructor.
		 */
		public function Padding( left:Number, top:Number, right:Number, bottom:Number )
		{
			super();
			
			this.left   = left;
			this.top    = top;
			this.right  = right;
			this.bottom = bottom;
		}
		
		// -- Public methods -----------------------------------
		
		public function apply( rectangle:Rectangle ):Rectangle
		{
			var result:Rectangle = rectangle.clone();
			
			result.left   -= left;
			result.top    -= top;
			result.right  += right;
			result.bottom += bottom;
			
			return result;
		}
	}
}