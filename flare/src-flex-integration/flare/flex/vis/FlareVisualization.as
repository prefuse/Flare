package flare.flex.vis
{
	import flare.data.DataSet;
	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.axis.CartesianAxes;
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
		// Public properties
		// ========================================	
		
		/**
		 * Flare Visualization instance.
		 */
		public function get visualization():Visualization {
			return _visualization;
		}
		
		/** 
		 * 	The visualization operators used by this visualization. This
		 *  should be an array of IOperator instances. 
		 */
		public function set operators(a:Array):void {
			_visualization.operators.list = a;
			_visualization.update();
		}
		
		/** 
		 * 	The interactive controls used by this visualization. This
		 *  should be an array of IControl instances. 
		 */
		public function set controls(a:Array):void {
			_visualization.controls.list = a;
			_visualization.update();
		}
		
		/** 
		 * Returns the axes for the backing visualization instance. 
		 */
		public function get axes():Axes 			{ return _visualization.axes; }
		
		/** 
		 * Returns the CartesianAxes for the backing visualization instance. 
		 */
		public function get xyAxes():CartesianAxes 	{ return _visualization.xyAxes; }

		
		
		/** 
		 *  Legacy support and wrapper to function set data(val) method 
		 */
		public function set dataSet(d:*):void 		{	this.data = d;		}

		[Bindable("dataChange")]
		/** 
		 *  Sets the data visualized by this instance. The input value can be
		 *  an array of data objects, a Data instance, or a DataSet instance.
		 *  Any existing data will be removed and new NodeSprite instances will
		 *  be created for each object in the input arrary. 
		 */
		public function get data():Object {
			return _data;
		}
		public function set data( value:Object ):void {
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
		public function FlareVisualization(data:Data=null)
		{
			super();
			
			data ||= new Data();
			
			_data          = data;
			_visualization = new Visualization( _data as Data );
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
				dataChanged = false;
				
				if ( data == null )			_visualization.data = null;
				else if ( data is Data) 	_visualization.data = data as Data;
				else if ( data is Array )	_visualization.data = Data.fromArray( data as Array);
				else if ( data is DataSet )	_visualization.data = Data.fromDataSet( data as DataSet);
				else						throw new Error( "Unrecognized data set type: " + data );
				
				_visualization.operators.setup();
				_visualization.update();
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
	}
}
