package flare.display.render
{
	import flare.display.DisplaySprite;
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class BackgroundRenderer implements IBackgroundRenderer
	{
		/**
		 * Backing variable for <code>instance</code> property.
		 */
		protected static var _instance:BackgroundRenderer = new BackgroundRenderer();
		
		/** 
		 * Static BackgroundRenderer instance. 
		 */
		public static function get instance():BackgroundRenderer
		{
			return _instance;
		}
		
		/**
		 * Constructor.
		 */
		public function BackgroundRenderer()
		{
			super();
		}
		
		/**
		 * @inheritDoc
		 */
		public function render( displaySprite:DisplaySprite, bounds:Rectangle ):void
		{
			if ( !displaySprite.backgroundBorder && !displaySprite.backgroundFill )
				return;
				
			var graphics:Graphics = displaySprite.graphics;
			
			graphics.clear();
			
			// Set the border (if applicable).
			
			if ( displaySprite.backgroundBorder )
			{
				graphics.lineStyle( 
					displaySprite.backgroundBorderThickness,
					displaySprite.backgroundBorderColor & 0x00ffffff, 
					displaySprite.backgroundBorderAlpha,
					displaySprite.backgroundBorderPixelHinting
				);
			}
			
			// Begin the fill (if applicable).
			
			if ( displaySprite.backgroundFill )
			{
				if ( displaySprite.backgroundFillGradient )
				{
					displaySprite.backgroundFillGradient.begin( graphics, bounds );
				}
				else
				{
					graphics.beginFill( 
						displaySprite.backgroundFillColor & 0x00ffffff, 
						displaySprite.backgroundFillAlpha 
					);
				}
			}
			
			// Draw the bounds (with rounded corners if specified).
			
			if ( displaySprite.backgroundCornerWidth > 0 || displaySprite.backgroundCornerHeight > 0 )
			{
				graphics.drawRoundRect( 
					bounds.x, bounds.y, 
					bounds.width, bounds.height,
					displaySprite.backgroundCornerWidth, displaySprite.backgroundCornerHeight );
			}
			else
			{
				graphics.drawRect( 
					bounds.x, bounds.y, 
					bounds.width, bounds.height );
			}
			
			// End the fill (if applicable).
			
			if ( displaySprite.backgroundFill )
			{
				if ( displaySprite.backgroundFillGradient )
				{
					displaySprite.backgroundFillGradient.end( graphics );
				}
				else
				{
					graphics.endFill();
				}
			}
			
			displaySprite.cacheAsBitmap = true;
		}
	}
}