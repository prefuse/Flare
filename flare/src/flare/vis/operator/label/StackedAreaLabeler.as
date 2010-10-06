package flare.vis.operator.label
{
	import flare.display.TextSprite;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	
	/**
	 * Labeler for a stacked area chart. Use in conjunction with the
	 * <code>StackedAreaLayout</code> operator. Adds labels to stacks whose
	 * maximum height in pixels exceeds the minimum <code>threshold</code>
	 * value.
	 * 
	 * <p><b>NOTE</b>: This has only been tested for use with horizontally
	 * oriented stacks. In the future, this will be extended to work with
	 * vertically oriented stacks as well.</p>
	 */
	public class StackedAreaLabeler extends Labeler
	{
		/** The minimum width for a stack to receive a label (default 12). */
		public var threshold:Number = 12;
		/** The base (minimum) size for labels. */
		public var baseSize:int = 6;
		/** Indicates the first column considered for label placement. This
		 *  prevents columns on the edges of the display from being labeled,
		 *  as the labels might then bleed outside the display. */
		public var columnIndex:int = 2;
		
		/**
		 * Creates a new StackedAreaLabeler. 
		 * @param source the property from which to retrieve the label text.
		 *  If this value is a string or property instance, the label text will
		 *  be pulled directly from the named property. If this value is a
		 *  Function or Expression instance, the value will be used to set the
		 *  <code>textFunction<code> property and the label text will be
		 *  determined by evaluating that function.
		 */
		public function StackedAreaLabeler(source:*=null,
			group:String=Data.NODES)
		{
			super(source, group, null, null, LAYER);
		}

		/** @inheritDoc */
		protected override function process(d:DataSprite):void
		{
			var label:TextSprite;
				
			// early exit if no chance of label visibility
			if (!d.visible && !(_t.$(d).visible)) {
				label = getLabel(d, false);
				if (label) label.visible = false;
				return;
			}
			label = getLabel(d, true, false);
				
			// find maximal point
			var pts:Array = _t.$(d).points, len:uint = pts.length/2;
			var i:uint, j:uint, i0:uint = 2*columnIndex;
            var x:Number, y:Number, h:Number, height:Number=-1;
            for (i=i0+1; i<len-i0; i+=2) {
            	h = pts[i] - pts[pts.length-i];
            	if (h > height) {
            		height = h;
            		x = pts[i-1];
            		y = pts[i]-h/2;
            		j = i;
            	}
            }
            // hide and exit if beneath visibility threshold
            if (height < threshold) {
            	label.visible = false;
            	return;
            }
            
            // if label was hidden, reveal it
			if (!label.visible && (pts=d.points)) {
				var x0:Number=x, y0:Number=y, h0:Number=height;
				if ((pts=d.points)) {
					x0 = pts[j-1];
					y0 = (pts[j] + pts[pts.length-j])/2;
				}
				label.visible = true;
				label.x = x0;
				label.y = y0;
				label.size = 0;
			}
			// set the next position
			var o:Object = _t.$(label);
            o.x = x;
            o.y = y;
            o.size = baseSize + Math.sqrt(height);
		}
				
	} // end of class StackedAreaLabeler
}