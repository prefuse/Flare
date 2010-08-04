package flare.vis.operator.layout
{
	import flare.util.Orientation;
	import flare.vis.data.NodeSprite;
	
	import flash.geom.Rectangle;
	
	/**
	 * Layout that places nodes in an icicle layout, distributing nodes
	 * evenly within the display bounds. To get a standard icicle view, set
	 * the nodes <code>shape</code> property to <code>Shapes.BLOCK</code> and
	 * hide all edges. By default, this operator will attempt to scale the
	 * layout to fit within the display bounds. By setting
	 * <code>fitToBounds</code> false, the current <code>depthSpacing<code>
	 * will be preserved, allowing the layout to exceed the bounds along
	 * the depth dimension.
	 */
	public class IcicleTreeLayout extends Layout
	{
		private var _orient:String = Orientation.TOP_TO_BOTTOM; // orientation
		private var _dspace:Number = 50; // the spacing between depth levels
		private var _maxDepth:int = 0;
		private var _vertical:Boolean = true;
		
		/** Indicates if the layout should be scaled to fit in the bounds. */
		public var fitToBounds:Boolean = true;
		
		/** The orientation of the layout. */
		public function get orientation():String { return _orient; }
		public function set orientation(o:String):void { _orient = o; }
		
		/** The space between successive depth levels of the tree. */
		public function get depthSpacing():Number { return _dspace; }
		public function set depthSpacing(s:Number):void { _dspace = s; }
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new IcicleTreeLayout. 
		 * @param orientation the orientation of the layout
		 */
		public function IcicleTreeLayout(orientation:String=null)
		{
			if (orientation) this.orientation = orientation;
		}
		
		/** @inheritDoc */
		protected override function layout():void
		{
			// get bounds parameters
			var root:NodeSprite = layoutRoot as NodeSprite;
			var b:Rectangle = layoutBounds;
			var bMin:Number, bMax:Number, dMax:Number, d:Number, dInc:Number;
			switch (_orient) {
				case Orientation.LEFT_TO_RIGHT:
				case Orientation.RIGHT_TO_LEFT:
					bMin = b.bottom;
					bMax = b.top;
					dMax = b.width;
					_vertical = false;
					break;
				case Orientation.TOP_TO_BOTTOM:
				case Orientation.BOTTOM_TO_TOP:
					bMin = b.left;
					bMax = b.right;
					dMax = b.height;
					_vertical = true;
					break;
				default:
					throw new Error("Unrecognized orientation value");
			}
			switch (_orient) {
				case Orientation.LEFT_TO_RIGHT:
					d = b.left; dInc = _dspace; break;
				case Orientation.TOP_TO_BOTTOM:
					d = b.top; dInc = _dspace; break;
				case Orientation.RIGHT_TO_LEFT:
					d = b.right; dInc = -_dspace; break;
				case Orientation.BOTTOM_TO_TOP:
					d = b.bottom; dInc = -_dspace; break;
				default:
					throw new Error("Unrecognized orientation value");
			}
			
			// calculate depth and width
			_maxDepth = 0;
			firstPass(root, 0);
			
			// scale the depth to fit as needed
			if (fitToBounds && _maxDepth * _dspace > dMax) {
				dInc *= dMax / (_maxDepth * _dspace);
			}
			
			// perform the layout
			doLayout(root, bMin, bMax, d, dInc);
			updateEdgePoints(_t);
		}
		
		private function firstPass(n:NodeSprite, d:int):Number
		{
			if (d > _maxDepth) _maxDepth = d;
			var extent:Number = 0;
			if (n.childDegree == 0 || !n.expanded) {
				extent = 1;
			} else {
				for (var i:int=0; i<n.childDegree; ++i) {
					extent += firstPass(n.getChildNode(i), d+1)
				}	
			}
			n.props.icicleWidth = extent;
			return extent;
		}
		
		private function doLayout(n:NodeSprite, b1:Number, b2:Number,
			d:Number, dInc:Number):void
		{
			var pw:Number = n.props.icicleWidth;
			var x:Number = b1, w:Number = b2 - b1;
			
			if (n.childDegree > 0 && !n.expanded) {
				n.visitTreeDepthFirst(function(c:NodeSprite):void {
					update(c, b1 + w/2, b1 + w/2, d+dInc, dInc, false);
				});
			} else {
				for (var i:int=0; i<n.childDegree; ++i) {
					var c:NodeSprite = n.getChildNode(i);
					var cw:Number = w * c.props.icicleWidth / pw;
					doLayout(c, x, x+cw, d+dInc, dInc);
					x += cw;
				}
			}
			update(n, b1, b2, d, dInc, true);
		}
		
		private function update(n:NodeSprite, b1:Number, b2:Number, 
			d:Number, dInc:Number, visible:Boolean):void
		{
			var o:Object = _t.$(n);
			if (_vertical) {
				o.x = (b1 + b2) / 2;
				o.y = d + dInc / 2;
				o.u = b1;
				o.v = d;
				o.w = b2 - b1;
				o.h = dInc;
			} else {
				o.x = d + dInc / 2;
				o.y = (b1 + b2) / 2;
				o.u = d;
				o.v = b1;
				o.w = dInc;
				o.h = b2 - b1;
			}
			var alpha:Number = visible ? 1 : 0;
			o.alpha = alpha;
			o.mouseEnabled = visible;
			if (n.parentEdge != null)
				_t.$(n.parentEdge).alpha = alpha;
		}
		
	} // end of class IcicleTreeLayout
}