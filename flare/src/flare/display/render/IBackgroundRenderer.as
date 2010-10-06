package flare.display.render
{
	import flare.display.DisplaySprite;
	
	import flash.geom.Rectangle;

	/**
	 * Interface for DisplaySprite background rendering modules.
	 */
	public interface IBackgroundRenderer
	{
		/**
		 * Renders background content for the input DisplaySprite.
		 * @param displaySprite the DisplaySprite to draw
		 * @param bounds the background Rectangle bounds
		 */
		function render( displaySprite:DisplaySprite, bounds:Rectangle ):void;
		
	}
}