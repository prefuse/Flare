package flare.vis.data.render
{
	import flare.util.Geometry;
	import flare.util.Shapes;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	
	import flash.geom.Point;
	
	/**
	 * Renderer that draws connecting edges as orthogonal lines.
	 * 
	 * @author ThomasBurleson
	 */
	public class OrthogonalEdgeRenderer extends EdgeRenderer implements IRenderer
	{		
		public var minimizeSegments : Boolean = false;
		
		/**
		 * If the line shape is a "straight" line, render line segments for an orthogonal
		 * connection between the source and target points. 
		 * 
		 * NOTE: This "adds" two extra segments so the source "bottom" connects orthogonally 
		 * to the target "top". If you wanted a "side-to-top" connection you would only 
		 * need 1 extra segment; so set the minimizeSegments == "true"
		 * 
		 * @param e EdgeSprite
		 */
		override public function render(d:DataSprite):void {
			var e:EdgeSprite = d as EdgeSprite;
			if (e == null) return;
			
			e.shape = Shapes.POLYGON;
			injectSegments(e);
			
			super.render(e);
		}
		
		/**
		 * Inject the intermediate segment end Points in the 
		 * "points" array before the render occurs.
		 *  
		 * @param e EdgeSprite
		 * 
		 */
		protected function injectSegments(e:EdgeSprite):void {
			var intermediates : Array = buildIntermediatePoints(e);
			var results       : Array = [ ];
			
			for each (var pt:Point in intermediates) {
				results.push(pt.x);
				results.push(pt.y);
			}
			
			e.points = results;
		}
		
		/**
		 * Calculate the array of intermediate points that will comprise line segments
		 * between the source and target endPoints
		 *  
		 * @param e EdgeSprite with source and target endPoints
		 * @return Array of intermediate Points
		 * 
		 */
		protected function buildIntermediatePoints(e:EdgeSprite):Array {
			var results : Array = [ ];
			
			switch(e.shape) {
				case Shapes.BEZIER 		:
				case Shapes.CARDINAL	:
				case Shapes.BSPLINE		:	
					
					break;		// do NOTHING 
				
				default					:
				{
					var s : Point = new Point(e.x1,e.y1);	// source
					var t : Point = new Point(e.x2,e.y2);	// target
					
					var c : Point = minimizeSegments ? Geometry.intersectionCorner(s,t) : Geometry.midPoint(s,t);
					
					var sameY : Boolean = c.y != s.y && c.y != t.y;
					var sameX : Boolean = c.x != s.x && c.x != t.x;
					
					if ( !sameY || !sameX ) {
						/*  psuedo-code for the logic... adds 2 more line segments
						
						result.moveTo( sx, sy );
						result.lineTo( sx, midy );
						result.lineTo( tx, midy );
						result.lineTo( tx, ty );
						*/
						
						// Add the two (2) intermediate points to the rendering...
						results.push( new Point(s.x, c.y) );
						results.push( new Point(t.x, c.y) );
					} 
				}
			}
			
			return results;
		}
		
		
	} 
}