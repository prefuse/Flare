package flare.vis.operator.encoder
{
	import flare.scale.ScaleType;
	import flare.util.palette.Palette;
	import flare.util.palette.ShapePalette;
	import flare.vis.data.Data;
	
	/**
	 * Encodes a data field into shape values, using an ordinal scale.
	 * Shape values are integer indices that map into a shape palette, which
	 * provides drawing routines for shapes. See the
	 * <code>flare.palette.ShapePalette</code> and 
	 * <code>flare.data.render.ShapeRenderer</code> classes for more.
	 */
	public class ShapeEncoder extends Encoder
	{
		private var _palette:ShapePalette;
		
		/** @inheritDoc */
		public override function get palette():Palette { return _palette; }
		public override function set palette(p:Palette):void {
			_palette = p as ShapePalette;
		}
		/** The palette as a ShapePalette instance. */
		public function get shapes():ShapePalette { return _palette; }
		public function set shapes(p:ShapePalette):void { _palette = p; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new ShapeEncoder.
		 * @param source the source property
		 * @param group the data group to process
		 * @param palette the shape palette for assigning shapes
		 */
		public function ShapeEncoder(field:String=null,
			group:String=Data.NODES, palette:ShapePalette=null)
		{
			super(field, "shape", group);
			_binding.scaleType = ScaleType.CATEGORIES;
			_palette = palette ? palette : ShapePalette.defaultPalette();
		}
		
		/** @inheritDoc */
		protected override function encode(val:Object):*
		{
			return _palette.getShape(_binding.index(val));
		}
		
	} // end of class ShapeEncoder
}