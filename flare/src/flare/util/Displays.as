package flare.util
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Utility methods for working with display objects. The methods include
	 * support for panning, rotating, and zooming objects, generating thumbnail
	 * images, traversing children lists, and adding stage listeners.
	 */
	public class Displays
	{
		private static var _point:Point = new Point();
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function Displays()
		{
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Adds a listener to the stage via a given display object. If the
		 * display object has already been added to the stage, the listener
		 * will be added to the stage immediately. Otherwise, the listener will
		 * be added whenever the display object is added to the stage. This
		 * method allows you to add listeners for stage events without having
		 * to explicitly manage the case where the defining elements have not
		 * yet been added to the stage.
		 * @param d the display object through which to access the stage
		 * @param eventType the event type
		 * @param listener the event listener
		 * @param useCapture the event useCapture flag
		 * @param priority the event listener priority
		 * @param useWeakReference the event useWeakReference flag
		 * @return the function that will add the listener to the stage upon
		 *  an added to stage event, or null if the listener was directly
		 *  added to the stage
		 * @see flash.events.Event
		 */
		public static function addStageListener(d:DisplayObject,
			eventType:String, listener:Function, useCapture:Boolean=false,
			priority:Number=0, useWeakReference:Boolean=false):Function
		{
			if (d.stage) {
				d.stage.addEventListener(eventType, listener, useCapture,
					priority, useWeakReference);
				return null;
			} else {
				var add:Function = function(e:Event=null):void
				{
					d.stage.addEventListener(eventType, listener,
						useCapture, priority, useWeakReference);
					d.removeEventListener(Event.ADDED_TO_STAGE, add);
					d.stage.invalidate();
				}
				d.addEventListener(Event.ADDED_TO_STAGE, add);
				return add;
			}
		}
		
		/**
		 * Iterates over the children of the input display object container,
		 * invoking a visitor function on each. If the visitor function returns
		 * a Boolean true value, the iteration will stop with an early exit.
		 * @param con the container to visit
		 * @param visitor the visitor function to invoke on the children
		 * @param filter an optional filter indicating which items should be
		 *  visited
		 * @param reverse optional flag indicating if the list should be
		 *  visited in reverse order
		 * @return true if the visitation was interrupted with an early exit
		 */
		public static function visitChildren(con:DisplayObjectContainer,
			visitor:Function, filter:*=null, reverse:Boolean=false):Boolean
		{
			var i:uint, o:DisplayObject;
			var f:Function = Filter.$(filter);
			if (reverse)
				for (i=con.numChildren; --i>=0; ) {
					o = con.getChildAt(i);
					if ((f==null || f(o)) && (visitor(o) as Boolean))
						return true;
				}
			else
				for (i=0; i<con.numChildren; ++i) {
					o = con.getChildAt(i);
					if ((f==null || f(o)) && (visitor(o) as Boolean))
						return true;
				}
			return false;
		}
		
		/**
		 * Sorts the children of the given <code>DisplayObjectContainer</code>
		 * using a comparator function.
		 * @param d a display object container to sort. The sort may change the
		 *  rendering order in which the contained display objects are drawn.
		 * @param cmp a comparator <code>Function</code>.
		 */
		public static function sortChildren(
			d:DisplayObjectContainer, cmp:Function):void
		{
			if (d==null) return;
			var a:Array = new Array(d.numChildren);
			for (var i:int=0; i<a.length; ++i) {
				a[i] = d.getChildAt(i);
			}
			if (cmp==null) a.sort() else a.sort(cmp);
			for (i=0; i<a.length; ++i) {
				d.setChildIndex(a[i], i);
			}
		}
		
		/**
		 * Sets property values on all children items. The values
		 * within the <code>vals</code> argument can take a number of forms:
		 * <ul>
		 *  <li>If a value is a <code>Function</code>, it will be evaluated
		 *      for each element and the result will be used as the property
		 *      value for that element.</li>
		 *  <li>If a value is an <code>IEvaluable</code> instance, such as
		 *      <code>flare.util.Property</code> or
		 *      <code>flare.query.Expression</code>, it will be evaluated for
		 *      each element and the result will be used as the property value
		 *      for that element.</li>
		 *  <li>In all other cases, a property value will be treated as a
		 *      literal and assigned for all elements.</li>
		 * </ul>
		 * @param d the container whose children's properties should be set.
		 * @param vals an object containing the properties and values to set.
		 * @param p an optional IValueProxy for collecting value updates.
		 */
		public static function setChildrenProperties(d:DisplayObjectContainer,
			vals:Object, p:IValueProxy=null):void
		{
			if (p==null) p = Property.proxy;
			var o:Object, i:uint;
			
			for (var name:String in vals) {
				var value:* = vals[name];
				var v:Function = value is Function ? value as Function
					 : value is IEvaluable ? IEvaluable(value).eval : null;
				
				for (i=0; i<d.numChildren; ++i) {
					o = d.getChildAt(i);
					p.setValue(o, name, v!=null ? v(p.$(o)) : value);
				}
			}
		}
		
		/**
		 * Creates a thumbnail image of the input object using the (optional)
		 * given size.  If no width, height, or bitmap data parameters are
		 * provided then the natural size of the display object will be used.
		 * If no width or height values are provided (i.e., they are less than
		 * or equal to zero) but a bitmap data is provided, than the dimensions
		 * of the bitmap data will be used. If all parameters are provided but
		 * the width and height exceed the size of the bitmap data, then the
		 * object will be drawn to match the provided width and height, but the
		 * thumbnail will be clipped to the size of the bitmap data. If only
		 * one of the width or height values are provided, than the other will
		 * automatically be selected to preserve the original aspect ratio of
		 * the object.
		 * @param src the DisplayObject to create a thumbnail image of
		 * @param width the desired width of the object in the thumbnail. If
		 *  this value is less than or equal to zero it is ignored.
		 * @param height the desired height of the object in the thumbnail If
		 *  this value is less than or equal to zero it is ignored.
		 * @param bd a BitmapData instance into which to draw the thumbnail.
		 *  If no value is provided, a new BitmapData instance of the needed
		 *  width and height will automatically be created.
		 * @return the thumbnail image as a BitmapData instance
		 */
		public static function thumbnail(src:DisplayObject, width:Number=-1,
			height:Number=-1, bd:BitmapData=null):BitmapData
		{
			try {
				// make sure everything is rendered if DirtySprites exist
				getDefinitionByName("flare.display.DirtySprite").renderDirty();
			} catch (err:Error) { /* do nothing */ }
			
			var r:Rectangle = src.getBounds(src);
			var hasW:Boolean = width>0, hasH:Boolean = height>0;
			
			// get thumbnail dimensions
			if (hasW && !hasH) {
				height = r.height * width / r.width;
			} else if (!hasW && hasH) {
				width = r.width * height / r.height;
			} else {
				width  = hasW ? width  : (bd ? bd.width  : r.width);
				height = hasH ? height : (bd ? bd.height : r.height);
			}
			// create bitmap data as needed
			bd = bd ? bd : new BitmapData(width, height, true, 0);
			
			// determine object transformation
			var mat:Matrix = new Matrix();
			mat.translate(-r.left, -r.top);
			mat.scale(width/r.width, height/r.height);
			
			// draw the thumbnail and return
			bd.draw(src, mat, src.transform.colorTransform, src.blendMode);
			return bd;
		}
		
		// -- Transformation Routines -----------------------------------------
		
		/**
		 * Performs a pan (translation) on an input matrix.
		 * The result is a transformation matrix including the translation.
		 * @param mat an input transformation matrix
		 * @param dx the change in x position
		 * @param dy the change in y position
		 * @return the resulting, panned transformation matrix
		 */
		public static function panMatrixBy(mat:Matrix, dx:Number, dy:Number):Matrix
		{
			mat.translate(dx, dy);
			return mat;
		}
		
		/**
		 * Performs a zoom about a specific point on an input matrix.
		 * The result is a transformation matrix including the zoom.
		 * @param mat an input transformation matrix
		 * @param scale a scale factor specifying the amount to zoom. A value
		 *  of 2 will zoom in such that objects are twice as large. A value of
		 *  0.5 will zoom out such that objects are half the size.
		 * @param p the point about which to zoom in or out
		 * @return the resulting, zoomed transformation matrix
		 */
		public static function zoomMatrixBy(mat:Matrix, scale:Number, p:Point):Matrix
		{
			mat.translate(-p.x, -p.y);
			mat.scale(scale, scale);
			mat.translate(p.x, p.y);
			return mat;
		}
		
		/**
		 * Performs a rotation around a specific point on an input matrix.
		 * The result is a transformation matrix including the rotation.
		 * @param mat an input transformation matrix
		 * @param angle the rotation angle, in degrees
		 * @param p the point about which to zoom in or out
		 * @return the resulting, rotated transformation matrix
		 */
		public static function rotateMatrixBy(mat:Matrix, angle:Number, p:Point):Matrix
		{
			mat.translate(-p.x, -p.y);
			mat.rotate(angle * Math.PI/180);
			mat.translate(p.x, p.y);
			return mat;
		}
		
		/**
		 * Pan the "camera" by the specified amount.
		 * @param obj the display object to treat as the camera
		 * @param dx the change in x position, in the parent's coordinate space
		 * @param dy the change in y position, in the parent's coordinate space
		 * @param vp an optional value proxy (such as a
		 *  <code>Transitioner</code>) for storing the new transform matrix
		 */
		public static function panBy(obj:DisplayObject, dx:Number, dy:Number,
			vp:IValueProxy=null):void
		{
			var mat:Matrix = panMatrixBy(obj.transform.matrix, dx, dy);
			if (vp==null) obj.transform.matrix = mat;
			else vp.setValue(obj, "transform.matrix", mat);
		}
		
		/**
		 * Zoom the "camera" by the specified scale factor.
		 * @param obj the display object to treat as the camera
		 * @param scale a scale factor specifying the amount to zoom. A value
		 *  of 2 will zoom in such that objects are twice as large. A value of
		 *  0.5 will zoom out such that objects are half the size.
		 * @param xp the x-coordinate around which to zoom, in stage
		 *  coordinates. If this value is <code>NaN</code>, 0 will be used.
		 * @param yp the y-coordinate around which to zoom, in stage
		 *  coordinates. If this value is <code>NaN</code>, 0 will be used.
		 * @param vp an optional value proxy (such as a
		 *  <code>Transitioner</code>) for storing the new transform matrix
		 */		
		public static function zoomBy(obj:DisplayObject, scale:Number,
			xp:Number=NaN, yp:Number=NaN, vp:IValueProxy=null):void
		{
			var p:Point = getLocalPoint(obj, xp, yp);
			var mat:Matrix = zoomMatrixBy(obj.transform.matrix, scale, p);
			if (vp==null) obj.transform.matrix = mat;
			else vp.setValue(obj, "transform.matrix", mat);
		}
		
		/**
		 * Helper routine that maps points from stage coordinates to this
		 * camera's parent's coordinate space. If either input value is NaN,
		 * a value of zero is assumed.
		 */
		private static function getLocalPoint(obj:DisplayObject, xp:Number, yp:Number):Point
		{
			var xn:Boolean = isNaN(xp);
			var yn:Boolean = isNaN(yp);
			var p:Point = _point;
			
			if (!(xn && yn)) {
				p.x = xp;
				p.y = yp;
				p = obj.parent.globalToLocal(p);
			}
			if (xn) p.x = 0;
			if (yn) p.y = 0;
			return p;
		}

	} // end of class Displays
}