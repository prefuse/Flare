package flare.display.render
{
	import flare.vis.data.DataSprite;
	import flare.vis.data.render.IRenderer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class BitmapRenderer implements IRenderer
	{
		// ========================================
		// Protected constants
		// ========================================	
		
		/**
		 * BitmapData cache (by Class).
		 */
		protected static const bitmapDataCache:Dictionary = new Dictionary();
		
		/**
		 * BitmapData center Point cache (by Class).
		 */
		protected static const bitmapDataCenterCache:Dictionary = new Dictionary();
		
		// ========================================
		// Constructor.
		// ========================================	

		/**
		 * Constructor.
		 */
		public function BitmapRenderer()
		{
			super();
		}
		
		// ========================================
		// Public methods
		// ========================================	
		
		/**
		 * @inheritDoc
		 */
		public function render( d:DataSprite ):void
		{
			// Override and implement in subclasses.
		}

		// ========================================
		// Protected methods
		// ========================================			
		
		/**
		 * Draw the specified Bitmap Class centered at the specified coordinates in the specified Graphics context.
		 */
		public function drawBitmap( graphics:Graphics, bitmapClass:Class, x:Number = 0.0, y:Number = 0.0, scale:Number = 1.0, fromCenter:Boolean = true ):void
		{
			var bitmapData:BitmapData = getCachedBitmapData( bitmapClass );
			
			var center:Point = fromCenter ? calculateCenterPoint( bitmapClass ) : new Point( 0, 0 );
			var point:Point = new Point( x, y );
				point.offset( -center.x*scale, -center.y*scale);
			
			var matrix:Matrix = new Matrix();
				matrix.scale(scale,scale);
				matrix.translate( point.x, point.y );
			
			graphics.lineStyle( 1, 0, 0, true );
			graphics.beginBitmapFill( bitmapData, matrix, false, true );
			graphics.drawRect( point.x, point.y, bitmapData.width*scale, bitmapData.height*scale);
			graphics.endFill();
		}		
		
		/**
		 * Calculate (from cache) the center point for the specified Bitmap Class.
		 */
		protected function calculateCenterPoint( bitmapClass:Class ):Point
		{
			// NOTE: Assumes the specified BitmapData was obtained via getCachedBitmapData()
			
			return bitmapDataCenterCache[ bitmapClass ] as Point;
		}
		
		/**
		 * Get (or create and cache) BitmapData for the specified Bitmap Class.
		 */
		protected function getCachedBitmapData( bitmapClass:Class ):BitmapData
		{
			if ( bitmapDataCache[ bitmapClass ] == null )
			{
				var bitmap:Bitmap = new bitmapClass() as Bitmap;
				
				bitmapDataCache[ bitmapClass ] = bitmap.bitmapData;
				bitmapDataCenterCache[ bitmapClass ] = new Point( bitmap.bitmapData.width / 2.0, bitmap.bitmapData.height / 2.0 );
			}
			
			return bitmapDataCache[ bitmapClass ] as BitmapData;
		}
	}
}