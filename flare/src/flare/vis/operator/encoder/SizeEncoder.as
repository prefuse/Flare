package flare.vis.operator.encoder
{
	import flare.scale.ScaleType;
	import flare.util.palette.Palette;
	import flare.util.palette.SizePalette;
	import flare.vis.data.Data;
	
	/**
	 * Encodes a data field into size values, using a scale transform and a
	 * size palette to determines an item's scale. The target property of a
	 * SizeEncoder is assumed to be the <code>DataSprite.size</code> property.
	 */
	public class SizeEncoder extends Encoder
	{
		private var _palette:SizePalette;
		
		/** @inheritDoc */
		public override function get palette():Palette { return _palette; }
		public override function set palette(p:Palette):void {
			_palette = p as SizePalette;
		}
		/** The palette as a SizePalette instance. */
		public function get sizes():SizePalette { return _palette; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SizeEncoder. By default, the scale type is set to
		 * a quantile scale grouped into 5 bins. Adjust the values of the
		 * <code>scale</code> property to change these defaults.
		 * @param source the source property
		 * @param group the data group to process
		 * @param palette the size palette to use. If null, a default size
		 *  palette will be used.
		 */
		public function SizeEncoder(source:String=null,
			group:String=Data.NODES, palette:SizePalette=null)
		{
			super(source, "size", group);
			_binding.scaleType = ScaleType.QUANTILE;
			_binding.bins = 5;
			if (palette) {
				_palette = palette;
			} else {
				_palette = new SizePalette();
				_palette.is2D = (group != Data.EDGES);
			}
		}
		
		/** @inheritDoc */
		protected override function encode(val:Object):*
		{
			return _palette.getSize(_binding.interpolate(val));
		}
		
	} // end of class SizeEncoder
}