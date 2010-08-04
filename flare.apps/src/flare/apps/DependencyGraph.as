package flare.apps
{
	import com.adobe.serialization.json.JSON;
	
	import flare.display.DirtySprite;
	import flare.display.TextSprite;
	import flare.query.methods.div;
	import flare.query.methods.eq;
	import flare.query.methods.neq;
	import flare.vis.Visualization;
	import flare.vis.controls.ClickControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.EdgeSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.events.SelectionEvent;
	import flare.vis.legend.Legend;
	import flare.vis.operator.encoder.PropertyEncoder;
	import flare.vis.operator.label.RadialLabeler;
	import flare.vis.operator.layout.BundledEdgeRouter;
	import flare.vis.operator.layout.CircleLayout;
	import flare.widgets.ProgressBar;
	
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class DependencyGraph extends App
	{
		/** We will be rotating text, so we embed the font. */
		[Embed(source="verdana.TTF", fontName="Verdana")]
		private static var _font:Class;
		
		private var _url:String = 
			"http://flare.prefuse.org/data/flare.json.txt";
			
		private var _vis:Visualization;
		private var _detail:TextSprite;
		private var _legend:Legend;
		private var _bar:ProgressBar;
		private var _bounds:Rectangle;
		
		private var _fmt:TextFormat = new TextFormat("Verdana", 7);
		private var _focus:NodeSprite;
		
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
			// place shorter names at the end of the data list
			// that way they will the easiest to mouse over later
			data.nodes.sortBy("-data.name.length");
			
			// prepare data with default settings
			data.nodes.setProperties({
				shape: null,                  // no shape, use labels instead
				visible: eq("childDegree",0), // only show leaf nodes
				buttonMode: true              // show hand cursor
			});
			data.edges.setProperties({
				lineWidth: 2,
				lineColor: 0xff0055cc,
				mouseEnabled: false,          // non-interactive edges
				visible: neq("source.parentNode","target.parentNode")
			});
						
			// define the visualization
			_vis = new Visualization(data);
			// place around circle by tree structure, radius mapped to depth
			// make a large inner radius so labels are closer to circumference
			_vis.operators.add(new CircleLayout("depth", null, true));
			CircleLayout(_vis.operators.last).startRadiusFraction = 3/5;
			// bundle edges to route along the tree structure
			_vis.operators.add(new BundledEdgeRouter(0.95));
			// set the edge alpha values
			// longer edge, lighter alpha: 1/(2*numCtrlPoints)
			_vis.operators.add(new PropertyEncoder(
				{alpha: div(1,"points.length")}, Data.EDGES));
			
			// add labels	
			_vis.operators.add(new RadialLabeler(
				// custom label function removes package names
				function(d:DataSprite):String {
					var txt:String = d.data.name;
					return txt.substring(txt.lastIndexOf('.')+1);
				}, true, _fmt, eq("childDegree",0))); // leaf nodes only
			_vis.operators.last.textMode = TextSprite.EMBED; // embed fonts!
			
			// update and add
			_vis.update();
			addChild(_vis);
			
			// add the legend and detail pane
			addDetail();
			
			// show all dependencies on single-click
			var linkType:int = NodeSprite.OUT_LINKS;
			_vis.controls.add(new ClickControl(NodeSprite, 1,
				function(evt:SelectionEvent):void {
					if (_focus && _focus != evt.node) {
						unhighlight(_focus);
						linkType = NodeSprite.OUT_LINKS;
					}
					_focus = evt.node;
					highlight(evt);
					showAllDeps(evt, linkType);
					_vis.controls.remove(hov);
					linkType = (linkType==NodeSprite.OUT_LINKS ?
						NodeSprite.IN_LINKS : NodeSprite.OUT_LINKS);
				},
				// show all edges and nodes as normal
				function(evt:SelectionEvent):void {
					if (_focus) unhighlight(_focus);
					_focus = null;
					_vis.data.edges["visible"] = 
						neq("source.parentNode","target.parentNode");
					_vis.data.nodes["alpha"] = 1;
					_vis.controls.add(hov);
					linkType = NodeSprite.OUT_LINKS;
				}
			));
			
			// add mouse-over details
			_vis.controls.add(new HoverControl(NodeSprite,
				HoverControl.DONT_MOVE,
				function(evt:SelectionEvent):void {
					_detail.text = evt.node.data.name;
				},
				function(evt:SelectionEvent):void {
					_detail.text = _vis.data.nodes.length + " files";
				}
			));
			
			// add mouse-over highlight
			var hov:HoverControl = new HoverControl(NodeSprite,
				HoverControl.DONT_MOVE, highlight, unhighlight);
			_vis.controls.add(hov);
			
			// compute the layout
			if (_bounds) resize(_bounds);
		}
		
		/** Add highlight to a node and connected edges/nodes */
		private function highlight(evt:SelectionEvent):void
		{
			// highlight mouse-over node
			evt.node.props.label.color = 0x0000cc;
			evt.node.props.label.bold = true;
			// highlight links for classes that depend on the focus in green
			evt.node.visitEdges(function(e:EdgeSprite):void {
				e.alpha = 0.5;
				e.lineColor = 0xff00ff00;
				e.source.props.label.color = 0x00cc00;
				_vis.marks.setChildIndex(e, _vis.marks.numChildren-1);
			}, NodeSprite.IN_LINKS);
			// highlight links the focus depends on in red
			evt.node.visitEdges(function(e:EdgeSprite):void {
				e.alpha = 0.5;
				e.lineColor = 0xffff0000;
				e.target.props.label.color = 0xff0000;
				_vis.marks.setChildIndex(e, _vis.marks.numChildren-1);
			}, NodeSprite.OUT_LINKS);
		}
		
		/** Remove highlight from a node and connected edges/nodes */
		private function unhighlight(n:*):void
		{
			var node:NodeSprite = n is NodeSprite ?
				NodeSprite(n) : SelectionEvent(n).node;
			// set everything back to normal
			node.props.label.color = 0;
			node.props.label.bold = false;
			node.setEdgeProperties({
				alpha: div(1, "points.length"),
				lineColor: 0xff0055cc,
				"source.props.label.color": 0,
				"target.props.label.color": 0
			}, NodeSprite.GRAPH_LINKS);
		}
		
		/** Traverse all dependencies for a given class */
		private function showAllDeps(evt:SelectionEvent, linkType:int):void
		{
			// first, do a breadth-first-search to compute closure
			var q:Array = evt.items.slice();
			var map:Dictionary = new Dictionary();
			while (q.length > 0) {
				var u:NodeSprite = q.shift();
				map[u] = true;
				u.visitNodes(function(v:NodeSprite):void {
					if (!map[v]) q.push(v);
				}, linkType);
			}
			// now highlight nodes and edges in the closure
			_vis.data.edges.visit(function(e:EdgeSprite):void {
				e.visible = map[e.source] && map[e.target];
			});
			_vis.data.nodes.visit(function(n:NodeSprite):void {
				n.alpha = map[n] ? 1 : 0.4;
			});
		}
		
		/** Show all reverse dependencies */
		
		
		private function addDetail():void
		{	
			var fmt:TextFormat = new TextFormat("Verdana",14);
			
			_legend = Legend.fromValues(null, [
				{color: 0xffff0000, size: 0.75, label: "Imports"},
				{color: 0xff00ff00, size: 0.75, label: "Is Imported By"}
			]);
			_legend.labelTextFormat = fmt;
			_legend.labelTextMode = TextSprite.EMBED;
			_legend.update();
			addChild(_legend);

			_detail = new TextSprite("", fmt, TextSprite.EMBED);
			_detail.textField.multiline = true;
			_detail.htmlText = _vis.data.nodes.length + " files";
			addChild(_detail);
		}
		
		public override function resize(bounds:Rectangle):void
		{
			_bounds = bounds;
			if (_bar) {
				_bar.x = _bounds.width/2 - _bar.width/2;
				_bar.y = _bounds.height/2 - _bar.height/2;
			}
			if (_vis) {
				// automatically size labels based on bounds
				var d:Number = Math.min(_bounds.width, _bounds.height);
				_vis.data.nodes.setProperty("props.label.size",
					(d <= 650 ? 7 : d <= 725 ? 8 : 9),
					null, eq("childDegree",0));
				
				// compute the visualization bounds
				_vis.bounds.x = _bounds.x;
				_vis.bounds.y = _bounds.y + (0.06 * _bounds.height);
				_vis.bounds.width = _bounds.width;
				_vis.bounds.height = _bounds.height - (0.05 * _bounds.height);
				// update
				_vis.update();
				
				// layout legend and details
				_legend.x = _bounds.width  - _legend.width;
				_legend.y = _bounds.height - _legend.border.height - 5;
				_detail.y = _bounds.height - _detail.height - 5;
				
				// forcibly render to eliminate partial update bug, as
				// the standard RENDER event routing can get delayed.
				// remove this line for faster but unsynchronized resizes
				DirtySprite.renderDirty();
			}
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates the visualized data.
		 */
		public static function buildData(tuples:Array):Data
		{
			var data:Data = new Data();
			var tree:Tree = new Tree();
			var map:Object = {};
			
			tree.root = data.addNode({name:"flare", size:0});
			map.flare = tree.root;
			
			var t:Object, u:NodeSprite, v:NodeSprite;
			var path:Array, p:String, pp:String, i:uint;
			
			// build data set and tree edges
			tuples.sortOn("name");
			for each (t in tuples) {
				path = String(t.name).split(".");
				for (i=0, p=""; i<path.length-1; ++i) {
					pp = p;
					p += (i?".":"") + path[i];
					if (!map[p]) {
						u = data.addNode({name:p, size:0});
						tree.addChild(map[pp], u);
						map[p] = u;
					}
				}
				t["package"] = p;
				u = data.addNode(t);
				tree.addChild(map[p], u);
				map[t.name] = u;
			}
			
			// create graph links
			for each (t in tuples) {
				u = map[t.name];
				for each (var name:String in t.imports) {
					v = map[name];
					if (v) data.addEdgeFor(u, v);
					else trace ("Missing node: "+name);
				}
			}
			
			// sort the list of children alphabetically by name
			for each (u in tree.nodes) {
				u.sortEdgesBy(NodeSprite.CHILD_LINKS, "target.data.name");
			}
			
			data.tree = tree;
			return data;
		}
		
	} // end of class DependencyGraph
}