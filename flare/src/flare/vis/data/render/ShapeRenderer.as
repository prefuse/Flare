package flare.vis.data.render
{
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	
	import flash.display.Graphics;

	/**
	 * Renderer that draws shapes. The ShapeRender uses a ShapePalette instance
	 * as needed to look up shape drawing routines based on the DataSprite
	 * <code>shape</code> property.
	 * @see flare.vis.palette.ShapePalette
	 */
	public class ShapeRenderer implements IRenderer
	{
		private static var _instance:ShapeRenderer = new ShapeRenderer();
		/** Static ShapeRenderer instance. */
		public static function get instance():ShapeRenderer { return _instance; }
		
		/** The default size value for drawn shapes. This value is multiplied
		 *  by a DataSprite's size property to determine the final size. */
		public var defaultSize:Number;
		
		/**
		 * Creates a new ShapeRenderer 
		 * @param defaultSize the default size (radius) for shapes
		 */
		public function ShapeRenderer(defaultSize:Number=6) {
			this.defaultSize = defaultSize;
		}
		
		/** @inheritDoc */
		public function render(d:DataSprite):void
		{
			var lineAlpha:Number = d.lineAlpha;
			var fillAlpha:Number = d.fillAlpha;
			var size:Number = d.size * defaultSize;
			
			var g:Graphics = d.graphics;
			g.clear();
			if (fillAlpha > 0) g.beginFill(d.fillColor, fillAlpha);
			if (lineAlpha > 0) g.lineStyle(d.lineWidth, d.lineColor, lineAlpha);
			
			switch (d.shape) {
				case null:
					break;
				case Shapes.BLOCK:
					g.drawRect(d.u-d.x, d.v-d.y, d.w, d.h);
					break;
				case Shapes.POLYGON:
					if (d.points!=null)
						Shapes.drawPolygon(g, d.points);
					break;
				case Shapes.POLYBLOB:
					if (d.points!=null)
						Shapes.drawCardinal(g, d.points,
											d.points.length/2, 0.15, true);
					break;
				case Shapes.VERTICAL_BAR:
					g.drawRect(-size/2, -d.h, size, d.h); 
					break;
				case Shapes.HORIZONTAL_BAR:
					g.drawRect(-d.w, -size/2, d.w, size);
					break;
				case Shapes.WEDGE:
					Shapes.drawWedge(g, d.origin.x-d.x, d.origin.y-d.y,
									 d.h, d.v, d.u, d.u+d.w);
					break;
				default:
					Shapes.getShape(d.shape)(g, size);
			}
			
			if (fillAlpha > 0) g.endFill();
		}
		
	} // end of class ShapeRenderer
}