package flare.vis.operator.layout
{
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places nodes randomly within the layout bounds.
	 */
	public class RandomLayout extends Layout
	{
		/** The data group to layout. */
		public var group:String;
		
		/**
		 * Creates a new RandomLayout instance. 
		 * @param group the data group to layout
		 */
		public function RandomLayout(group:String=Data.NODES) {
			this.group = group;
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
			var r:Rectangle = layoutBounds;
			visualization.data.visit(function(d:DataSprite):void
			{
				var o:Object = _t.$(d);
				o.x = r.x + r.width * Math.random();
				o.y = r.y + r.height * Math.random();
			}, group);
		}
		
	} // end of class RandomLayout
}