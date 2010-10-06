package flare.apps
{
	import com.adobe.serialization.json.JSON;
	
	import flare.display.TextSprite;
	import flare.query.methods.eq;
	import flare.query.methods.fn;
	import flare.util.Shapes;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.ClickControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.events.TooltipEvent;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.label.Labeler;
	import flare.vis.operator.layout.TreeMapLayout;
	import flare.widgets.ProgressBar;
	
	import flash.display.StageQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;
	
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class PackageMap extends App
	{
		private static var _tipText:String = "<b>{0}</b><br/>{1:,0} bytes";
		
		private var _src:String =
			"http://svn.prefuse.org/flare/trunk/flare/flare/src/";
		private var _url:String = 
			"http://flare.prefuse.org/data/flare.json.txt";
			
		private var _vis:Visualization;
		private var _bar:ProgressBar;
		
		protected override function init():void
		{
			// create progress bar
			addChild(_bar = new ProgressBar());
			_bar.bar.filters = [new DropShadowFilter(1)];
			
			// load data file
			var ldr:URLLoader = new URLLoader(new URLRequest(_url));
			_bar.loadURL(ldr, function():void {
				var obj:Array = JSON.decode(ldr.data as String) as Array;
				var data:Data = buildData(obj);
	            visualize(data);
	            _bar = null;
			});
  		}
		
		private function visualize(data:Data):void
		{
			// we're only drawing rectangles, so no one should notice...
			stage.quality = StageQuality.LOW;
			
			// create and add visualization
			addChild(_vis = new Visualization(data));
			
			// -- initialize visual items ----------------------
			
			// nodes are blocks, lower depths have thicker edges
			_vis.data.nodes.visit(function(n:NodeSprite):void {
				n.buttonMode = true;
				n.shape = Shapes.BLOCK;
				n.fillColor = 0xff4444ff;
				n.lineColor = 0xffcccccc;
				n.lineWidth = n.depth==1 ? 2 : n.childDegree ? 1 : 0;
				n.fillAlpha = n.depth / 25;
			});
			// no fill or mouse interaction for nodes with children
			_vis.data.nodes.setProperties({
				fillColor: 0,
				mouseEnabled: false
			}, null, "childDegree");
			
			// don't show any edges
			_vis.data.edges["visible"] = false;
			
			
			// -- define operators -----------------------------
			
			// perform a tree map layout
			_vis.operators.add(new TreeMapLayout("data.size"));

			// label top-level packages in new layer
			_vis.operators.add(new Labeler(
				// strip off the "flare." prefix
			    fn("substring","data.name",6),
				Data.NODES, new TextFormat("Arial", 14, 0, true),
				eq("depth",1), Labeler.LAYER));

			// add drop shadow to generated labels
			_vis.operators.add(new PropertyEncoder({
				"props.label.filters": [new DropShadowFilter(3,45,0x888888)]
			}, Data.NODES, eq("depth",1)));

			// run the operators
			_vis.update();
			
			
             // -- define interactive controls -----------------
			
			// highlight nodes on mouse over
			_vis.controls.add(new HoverControl(NodeSprite,
				// don't change drawing order of nodes
				HoverControl.MOVE_AND_RETURN,
				// highlight
				function(evt:SelectionEvent):void {
					evt.node.lineColor = 0xffFF0000;
					evt.node.fillColor = 0xffFFAAAA;
				},
				// unhighlight
				function(evt:SelectionEvent):void {
					var n:NodeSprite = evt.node;
					n.lineColor = 0xffcccccc;
					n.fillColor = 0xff4444FF;
					n.fillAlpha = n.depth / 25;
				}
			));
			
			// provide tooltip on mouse hover
			_vis.controls.add(new TooltipControl(NodeSprite, null,
				function(evt:TooltipEvent):void {
					TextSprite(evt.tooltip).htmlText = Strings.format(_tipText,
						evt.node.data.name, evt.node.data.size);
				}
			));
			
			// click to hyperlink to source code
			_vis.controls.add(new ClickControl(NodeSprite, 1,
				function(evt:SelectionEvent):void {
					var cls:String = evt.node.data.name;
					var url:String = _src + cls.split(".").join("/") + ".as";
					navigateToURL(new URLRequest(url), "_code");
				}
			));
			
			// perform layout
			resize(_appBounds);
		}
		
		public override function resize(b:Rectangle):void
		{
			if (_bar) {
				_bar.x = b.width/2 - _bar.width/2;
				_bar.y = b.height/2 - _bar.height/2;
			}
			if (_vis) {
				// make some extra room for the treemap border
				b.x += 1; b.y += 1; b.width -= 1; b.height -= 1;
				_vis.bounds = b;
				_vis.update();
			}
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates the visualized data.
		 */
		public static function buildData(tuples:Array):Data
		{
			var tree:Tree = new Tree();
			var map:Object = {};
			
			map.flare = tree.addRoot();
			tree.root.data = {name:"flare", size:0};
			
			var t:Object, u:NodeSprite, v:NodeSprite;
			var path:Array, p:String, pp:String, i:uint;
			
			// build package tree
			tuples.sortOn("name");
			for each (t in tuples) {
				path = String(t.name).split(".");
				for (i=0, p=""; i<path.length-1; ++i) {
					pp = p;
					p += (i?".":"") + path[i];
					if (!map[p]) {
						map[p] = (u = tree.addChild(map[pp]));
						u.data = {name:p, size:0};
					}
				}
				t["package"] = p;
				map[t.name] = (u = tree.addChild(map[p]));
				u.data = t;
			}
			
			// sort the list of children alphabetically by name
			for each (u in tree.nodes) {
				u.sortEdgesBy(NodeSprite.CHILD_LINKS, "target.data.name");
			}
			return tree;
		}
		
	} // end of class PackageMap
}