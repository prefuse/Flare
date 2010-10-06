package flare.util.palette
{
	import flare.util.Shapes;
	
	/**
	 * Palette for shape values that maps integer indices to shape drawing
	 * functions.
	 * @see flare.vis.util.graphics.Shapes
	 */
	public class ShapePalette extends Palette
	{	
		/**
		 * Creates a new, empty ShapePalette.
		 */
		public function ShapePalette() {
			_values = new Array();
		}	
		
		/**
		 * Adds a shape to this ShapePalette.
		 * @param shape the name of the shape. This name should be registered
		 *  with a drawing function using the
		 *  <code>flare.vis.util.graphics.Shapes</code> class.
		 */
		public function addShape(shape:String):void
		{
			_values.push(shape);
		}
		
		/**
		 * Gets the shape at the given index into the palette.
		 * @param idx the index of the shape
		 * @return the name of the shape
		 */
		public function getShape(idx:uint):String
		{
			return _values[idx % _values.length];
		}
		
		/**
		 * Sets the shape at the given index into the palette.
		 * @param idx the index of the shape
		 * @param shape the name of the shape. This name should be registered
		 *  with a drawing function using the
		 *  <code>flare.vis.util.graphics.Shapes</code> class.
		 */
		public function setShape(idx:uint, shape:String):void
		{
			_values[idx] = shape;
		}
		
		/**
		 * Returns a default shape palette instance. The default palette
		 * consists of (in order): circle, square, cross, "x", diamond,
		 * down-triangle, up-triangle, left-triangle, and right-triangle
		 * shapes.
		 * @return the default shape palette
		 */
		public static function defaultPalette():ShapePalette
		{
			var p:ShapePalette = new ShapePalette();
			p.addShape(Shapes.CIRCLE);
			p.addShape(Shapes.SQUARE);
			p.addShape(Shapes.CROSS);
			p.addShape(Shapes.X);
			p.addShape(Shapes.DIAMOND);
			p.addShape(Shapes.TRIANGLE_DOWN);
			p.addShape(Shapes.TRIANGLE_UP);
			p.addShape(Shapes.TRIANGLE_LEFT);
			p.addShape(Shapes.TRIANGLE_RIGHT);
			return p;
		}
		
	} // end of class ShapePalette
}