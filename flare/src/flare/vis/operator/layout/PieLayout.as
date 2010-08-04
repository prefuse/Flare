package flare.vis.operator.layout
{
	import flare.util.Property;
	import flare.util.Shapes;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places wedges for pie and donut charts. In addition to
	 * the layout, this operator updates each node to have a "wedge" shape.
	 */
	public class PieLayout extends Layout
	{
		private var _field:Property;
		
		/** The source property determining wedge size. */
		public function get source():String { return _field.name; }
		public function set source(f:String):void { _field = Property.$(f); }

		/** The data group to layout. */
		public var group:String = Data.NODES;
		
		/** The radius of the pie/donut chart. If this value is not a number
		 *  (NaN) the radius will be determined from the layout bounds. */
		public var radius:Number = NaN;		
		/** The width of wedges, negative for a full pie slice. */
		public var width:Number = -1;
		/** The initial angle for the pie layout (in radians). */
		public var startAngle:Number = Math.PI/2;
		/** The total angular size of the layout (in radians, default 2 pi). */
		public var angleWidth:Number = 2*Math.PI;
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new PieLayout
		 * @param field the source data field for determining wedge size
		 * @param width the radial width of wedges, negative for full slices
		 */		
		public function PieLayout(field:String=null, width:Number=-1,
								  group:String=Data.NODES)
		{
			layoutType = POLAR;
			this.group = group;
			this.width = width;
			_field = (field==null) ? null : new Property(field);
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
			var b:Rectangle = layoutBounds;
			var r:Number = isNaN(radius) ? Math.min(b.width, b.height)/2 : radius;
			var a:Number = startAngle, aw:Number;
			var list:DataList = visualization.data.group(group);
			var sum:Number = list.stats(_field.name).sum;
			var anchor:Point = layoutAnchor;
			
			list.visit(function(d:DataSprite):void {
				var aw:Number = -angleWidth * (_field.getValue(d)/sum);
				var rh:Number = (width < 0 ? 0 : width) * r;
				var o:Object = _t.$(d);
				
				d.origin = anchor;
				
				//o.angle = a + aw/2;  // angular mid-point
				//o.radius = (r+rh)/2; // radial mid-point
				o.x = 0;
				o.y = 0;
				
				o.u = a;  // starting angle
				o.w = aw; // angle width
				o.h = r;  // outer radius
				o.v = rh; // inner radius
				o.shape = Shapes.WEDGE;

				a += aw;
			});
		}
		
	} // end of class PieLayout
}