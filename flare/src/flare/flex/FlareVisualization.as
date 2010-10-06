package flare.flex
{
	import flare.data.DataSet;
	import flare.vis.Visualization;
	import flare.vis.data.Data;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class FlareVisualization extends UIComponent implements IDataRenderer
	{
		// ========================================
		// Protected properties
		// ========================================	
		
		/**
		 * Backing variable for <code>visualization</code> property.
		 */
		protected var _visualization:Visualization;
		
		/**
		 * Backing variable for <code>data</code> property.
		 */
		protected var _data:Object;
		
		/**
		 * Indicates the <code>data</code> property was invalidated.
		 */
		protected var dataChanged:Boolean;
		
		/**
		 * Mask for Flare Visualization.
		 */
		protected var visualizationMask:Sprite;
		
		// ========================================
		// Protected properties
		// ========================================	
		
		/**
		 * Flare Visualization instance.
		 */
		public function get visualization():Visualization
		{
			return _visualization;
		}
		
		[Bindable("dataChange")]
		/**
		 * @inheritDoc
		 */
		public function get data():Object
		{
			return _data;
		}
		
		public function set data( value:Object ):void
		{
			if ( _data != value )
			{
				_data = value;
				
				dataChanged = true;
				invalidateProperties();
				
				dispatchEvent( new FlexEvent( FlexEvent.DATA_CHANGE ) );
			}
		}
		
		// ========================================
		// Constructor
		// ========================================	
		
		/**
		 * Constructor.
		 */
		public function FlareVisualization()
		{
			super();
			
			_data = new Data();
			
			_visualization = new Visualization( _data as Data );
			
			// TODO: refactor hit area implementation in Visualization
			_visualization.removeEventListener( Event.RENDER, _visualization.setHitArea );
		}
		
		// ========================================
		// Protected methods
		// ========================================	
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			addChild( _visualization );
			
			visualizationMask = new Sprite();
			addChild( visualizationMask );
			
			_visualization.mask = visualizationMask;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if ( dataChanged )
			{
				// TODO: clean up
				
				if ( data == null )
				{
					_visualization.data = null;
				}
				else if ( data is Data) 
				{
					_visualization.data = data as Data;
				} 
				else if ( data is Array )
				{
					_visualization.data = Data.fromArray( data as Array);
				}
				else if ( data is DataSet )
				{
					_visualization.data = Data.fromDataSet( data as DataSet);
				}
				else
				{
					throw new Error( "Unrecognized data set type: " + data );
				}
				
				_visualization.update();
				
				dataChanged = false;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			// draw 'hitbox'
			
			graphics.clear();
			
			graphics.beginFill( 0xffffff, 0.0 );
			graphics.drawRect( 0, 0, unscaledWidth, unscaledHeight );
			graphics.endFill();
			
			// update visualization mask
			
			visualizationMask.graphics.clear();
			
			visualizationMask.graphics.beginFill( 0xff0000 );
			visualizationMask.graphics.drawRect( 0, 0, unscaledWidth, unscaledHeight );
			visualizationMask.graphics.endFill();
			
			visualizationMask.cacheAsBitmap = true;
		}
	}
}
