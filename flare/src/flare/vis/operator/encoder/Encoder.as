package flare.vis.operator.encoder
{
	import flare.animate.Transitioner;
	import flare.util.Filter;
	import flare.util.Property;
	import flare.util.palette.Palette;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.ScaleBinding;
	import flare.vis.operator.Operator;

	/**
	 * Base class for Operators that perform encoding of visual variables such
	 * as color, shape, and size. All Encoders share a similar structure:
	 * A source property (e.g., a data field) is mapped to a target property
	 * (e.g., a visual variable) using a <tt>ScaleBinding</tt> instance to map
	 * between values and a <tt>Palette</tt> instance to map scaled output
	 * into visual variables such as color, shape, and size.
	 */
	public class Encoder extends Operator
	{
		/** Boolean function indicating which items to process. */
		protected var _filter:Function;
		/** The target property. */
		protected var _target:String;
		/** A transitioner for collecting value updates. */
		protected var _t:Transitioner;
		/** A scale binding to the source data. */
		protected var _binding:ScaleBinding;

		/** A scale binding to the source data. */
		public function get scale():ScaleBinding { return _binding; }
		public function set scale(b:ScaleBinding):void {
			if (_binding) {
				if (!b.property) b.property = _binding.property;
				if (!b.group) b.group = _binding.group;
				if (!b.data) b.data = _binding.data;
			}
			_binding = b;
		}

		/** Boolean function indicating which items to process. Only items
		 *  for which this function return true will be considered by the
		 *  labeler. If the function is null, all items will be considered.
		 *  @see flare.util.Filter */
		public function get filter():Function { return _filter; }
		public function set filter(f:*):void { _filter = Filter.$(f); }

		/** The name of the data group for which to compute the encoding. */
		public function get group():String { return _binding.group; }
		public function set group(g:String):void { _binding.group = g; }
		
		/** The source property. */
		public function get source():String { return _binding.property; }
		public function set source(f:String):void { _binding.property = f; }
		
		/** The target property. */
		public function get target():String { return _target; }
		public function set target(f:String):void { _target = f; }
		
		/** The palette used to map scale values to visual values. */
		public function get palette():Palette { return null; }
		public function set palette(p:Palette):void { }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Encoder.
		 * @param source the source property
		 * @param target the target property
		 * @param group the data group to process
		 * @param filter a filter function controlling which items are encoded
		 */		
		public function Encoder(source:String=null, target:String=null,
							group:String=Data.NODES, filter:*=null)
		{
			_binding = new ScaleBinding();
			_binding.property = source;
			_binding.group = group;
			_target = target;
			this.filter = filter;
		}
		
		/** @inheritDoc */
		public override function setup():void
		{
			if (visualization==null) return;
			_binding.data = visualization.data;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			if (visualization == null) return;
			
			_t = (t!=null ? t : Transitioner.DEFAULT);
			var p:Property = Property.$(_binding.property);
			_binding.updateBinding();
			
			visualization.data.visit(function(d:DataSprite):void {
				_t.setValue(d, _target, encode(p.getValue(d)));
			}, _binding.group, _filter);
			
			_t = null;
		}
		
		/**
		 * Computes an encoding for the input value.
		 * @param val a data value to encode
		 * @return the encoded visual value
		 */
		protected function encode(val:Object):*
		{
			// sub-classes can override this
			return null;
		}
		
	} // end of class Encoder
}