package flare.flex.display.buttons
{
	import flare.display.buttons.SpriteButton;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	public class DragButton extends SpriteButton
	{
		// ========================================
		// Protected constants
		// ========================================
		
		/**
		 * Drag threshold.
		 */
		protected static const DRAG_THRESHOLD:Number = 1;
		
		/**
		 * Backing variable for <code>draggable</code> property.
		 */
		protected var _draggable:Boolean;
		
	
		
		/**
		 * Indicates whether the button is currently being dragged.
		 */
		protected var isDragging:Boolean;
		
		/**
		 * Drag starting coordinate.
		 */
		protected var dragStart:Point;
		
		// ========================================
		// Public properties
		// ========================================
		
		/**
		 * Indicates whether this button is draggable.
		 */
		public function get draggable() : Boolean
		{
			return _draggable;
		}
		
		public function set draggable( value:Boolean ):void
		{
			if ( _draggable != value)
			{
				if ( _draggable )
				{
					removeEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
					
					removeDragListeners();
					dragStart = null;
				}
				else
				{
					addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
				}
				
				_draggable = value;
			}
		}
		
		
		// ========================================
		// Constructor
		// ========================================		
		
		/**
		 * Constructor.
		 */
		public function DragButton()
		{
			super();
			
			// Setup initial internal state.
			draggable = true;
		}

		/**
		 * Add drag event listeners (if not already added).
		 */
		protected function addDragListeners():void
		{
			if ( !isDragging )
			{
				isDragging = true;
				
				addEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
				addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			}
		}

		/**
		 * Remove drag event listeners (if not already removed).
		 */
		protected function removeDragListeners():void
		{
			if ( isDragging )
			{
				removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoveHandler );
				removeEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
				
				isDragging = false;
			}
		}
		
		/**
		 * Handle MouseEvent.MOUSE_DOWN.
		 */
		override protected function mouseDownHandler( event : MouseEvent ):void 
		{
			super.mouseDownHandler(event);
			
			dragStart = new Point( mouseX, mouseY );
			addDragListeners();
			
			event.stopImmediatePropagation();
		}
		
		/**
		 * Handle MouseEvent.MOUSE_MOVE.
		 */
		override protected function mouseMoveHandler( event:MouseEvent ):void
		{
			var currentPoint:Point = new Point( event.localX, event.localY );
			
			if ( event.buttonDown )
			{
				if ( dragStart && !DragManager.isDragging )
				{
					if ( Math.abs( dragStart.x - currentPoint.x ) > DRAG_THRESHOLD || Math.abs( dragStart.y - currentPoint.y ) > DRAG_THRESHOLD ) 
					{
						var dragEvent:DragEvent = new DragEvent( DragEvent.DRAG_START, true );
						
						//dragEvent.dragInitiator = this;
						dragEvent.localX = dragStart.x;
						dragEvent.localY = dragStart.y;
						dragEvent.buttonDown = true;
						
						dispatchEvent( dragEvent );
						event.stopImmediatePropagation();
						
						removeDragListeners();
					}
				}
			}
			else
			{
				removeDragListeners();
				dragStart = null;
			}
		}
		
		/**
		 * Handle MouseEvent.MOUSE_UP.
		 */
		override protected function mouseUpHandler( event:MouseEvent ):void 
		{
			super.mouseUpHandler(event);
			
			removeDragListeners();
			dragStart = null;
		}

		/**
		 * Handle MouseEvent.ROLL_OUT.
		 */
		override protected function rollOutHandler( event:MouseEvent ):void 
		{
			super.rollOutHandler(event);
			
			removeDragListeners();
			dragStart = null;
		}
	}
}
