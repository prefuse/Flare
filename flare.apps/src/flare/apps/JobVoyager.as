package flare.apps
{
	import flare.animate.Transitioner;
	import flare.data.DataSet;
	import flare.data.DataSource;
	import flare.display.TextSprite;
	import flare.query.methods.eq;
	import flare.query.methods.iff;
	import flare.util.Orientation;
	import flare.util.Shapes;
	import flare.util.Strings;
	import flare.vis.Visualization;
	import flare.vis.controls.ClickControl;
	import flare.vis.controls.HoverControl;
	import flare.vis.controls.TooltipControl;
	import flare.vis.data.Data;
	import flare.vis.data.DataSprite;
	import flare.vis.data.NodeSprite;
	import flare.vis.events.SelectionEvent;
	import flare.vis.events.TooltipEvent;
	import flare.vis.legend.Legend;
	import flare.vis.legend.LegendItem;
	import flare.vis.operator.filter.VisibilityFilter;
	import flare.vis.operator.label.StackedAreaLabeler;
	import flare.vis.operator.layout.StackedAreaLayout;
	import flare.widgets.ProgressBar;
	import flare.widgets.SearchBox;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.text.TextFormat;
	
	[SWF(backgroundColor="#ffffff", frameRate="30")]
	public class JobVoyager extends App
	{
		private var _bar:ProgressBar;
		private var _bounds:Rectangle;
		
		private var _vis:Visualization;
		private var _labelMask:Shape;
		private var _title:TextSprite;
		private var _search:SearchBox;
		private var _gender:Legend;
		
		private var _fmt:TextFormat = new TextFormat("Helvetica,Arial",16,0,true);
		private var _dur:Number = 1.25; // animation duration
		
		private var _t:Transitioner;
		
		private var _query:Array;
		private var _filter:String = "All";
		private var _exact:Boolean = false;
		
		private var _url:String = "http://flare.prefuse.org/data/jobs.txt";
		private var _cols:Array = [1850,1860,1870,1880,1900,1910,1920,1930,
								   1940,1950,1960,1970,1980,1990,2000];
		private var _titleText:String =
			"Reported Occupations - U.S. Labor Force, 1850 - 2000 " + 
			"(source: <a href='http://ipums.org'>http://ipums.org</a>)";
		
		protected override function init():void
		{
			addChild(_bar = new ProgressBar());
			_bar.bar.filters = [new DropShadowFilter(1)];
			
			var ds:DataSource = new DataSource(_url, "tab");
			var ldr:URLLoader = ds.load();
			_bar.loadURL(ldr, function():void {
				// get loaded data, reshape for stacked columns
  				var ds:DataSet = ldr.data as DataSet;
            	var dr:Array = reshape(ds.nodes.data, ["occupation","sex"],
            		"year", "people", _cols);
            	visualize(Data.fromArray(dr));
        		_bar = null;
			});
  		}
  		
  		private function visualize(data:Data):void
		{
			// prepare data with default settings and sort
			data.nodes.sortBy("data.occupation","data.sex");
			data.nodes.setProperties({
				shape: Shapes.POLYGON,
				lineColor: 0,
				fillValue: 1,
				fillSaturation: 0.5
			});
			// expression sets male -> blue, female -> red
			data.nodes.setProperty("fillHue", iff(eq("data.sex",1), 0.7, 0));
			
			// define the visualization
			_vis = new Visualization(data);
			// first, set the visibility according to the query
			_vis.operators.add(new VisibilityFilter(filter));
			_vis.operators[0].immediate = true; // filter immediately!
			// second, layout the stacked chart
			_vis.operators.add(new StackedAreaLayout(_cols, 0));
			_vis.operators[1].scale.labelFormat = "0.####%"; // show as percent
			// third, label the stacks
			_vis.operators.add(new StackedAreaLabeler("data.occupation"));
			// fourth, set the color saturation for the current view
			_vis.operators.add(new SaturationEncoder());
			
			// initialize y-axis labels: align and add mask
			_labelMask = new Shape();
			_vis.xyAxes.addChild(_labelMask); // hides extreme labels
			_vis.xyAxes.yAxis.labels.mask = _labelMask;
			_vis.xyAxes.yAxis.verticalAnchor = TextSprite.TOP;
			_vis.xyAxes.yAxis.horizontalAnchor = TextSprite.RIGHT;
			_vis.xyAxes.yAxis.labelOffsetX = 50;  // offset labels to the right
			_vis.xyAxes.yAxis.lineCapX1 = 15; // extra line length to the left
			_vis.xyAxes.yAxis.lineCapX2 = 50; // extra line length to the right
			_vis.xyAxes.showBorder = false;
			
			// place and update
			_vis.update();
			addChild(_vis);
						
			// add mouse-over highlight
			_vis.controls.add(new HoverControl(NodeSprite,
			    // move highlighted node to be drawn on top
				HoverControl.MOVE_AND_RETURN,
				// highlight node to full saturation
				function(e:SelectionEvent):void {
					e.node.props.saturation = e.node.fillSaturation;
					e.node.fillSaturation = 1;
				},
				// return node to previous saturation
				function(e:SelectionEvent):void {
					e.node.fillSaturation = e.node.props.saturation;
				}
			));
				
			// add filter on click
			_vis.controls.add(new ClickControl(NodeSprite, 1,
				// set search query to the occupation name
				function(e:SelectionEvent):void {
					_exact = true; // force an exact search
					_search.query = e.node.data.occupation;
				}
			));
			
			// add tooltips
			_vis.controls.add(new TooltipControl(NodeSprite, null,
			    // update on both roll-over and mouse-move
				updateTooltip, updateTooltip));
			
			// add title and search box
			addControls();
			layout();
		}
		
		private function updateTooltip(e:TooltipEvent):void
		{
			// get current year value from axes, and map to data
			var yr:Number = Number(
				_vis.xyAxes.xAxis.value(_vis.mouseX, _vis.mouseY));
			var year:String = (10 * Math.round(yr/10)).toString();
			var def:Boolean = (e.node.data[year] != undefined);
			
			TextSprite(e.tooltip).htmlText = Strings.format(
				"<b>{0}</b><br/>{1} in {2}: "+(def?"{3:0.###%}":"<i>{3}</i>"),
				e.node.data.occupation, e.node.data.sex==1?"Males":"Females",
				year, (def ? e.node.data[year] : "Missing Data"));
		}
		
		public override function resize(bounds:Rectangle):void
		{
			if (_bar) {
				_bar.x = bounds.width/2 - _bar.width/2;
				_bar.y = bounds.height/2 - _bar.height/2;
			}
			bounds.width -= (15 + 50);
			bounds.height -= (75 + 25);
			bounds.x += 15;
			bounds.y += 75;
			_bounds = bounds;
			layout();
		}
		
		private function layout():void
		{
			if (_vis) {
				// compute the visualization bounds
				_vis.bounds = _bounds;
				// mask the y-axis labels to hide extreme animation
				_labelMask.graphics.clear();
				_labelMask.graphics.beginFill(0);
				_labelMask.graphics.drawRect(_vis.bounds.right,
					 _vis.bounds.top, 60, 1+_vis.bounds.height);
				// update
				_vis.update();
			}
			if (_title) {
				_title.x = -1;
				_title.y = _bounds.top - _title.height - 45;
			}
			if (_search) {
				_search.x = 0;
				_search.y = _title.y + _title.height + 4;
			}
			if (_gender) {
				_gender.x = stage.stageWidth - _gender.width;
				_gender.y = _search.y;
			}
			
		}
		
		/** Filter function for determining visibility. */
		private function filter(d:DataSprite):Boolean
		{
			if (_filter == "Male" && d.data.sex != 1) {
				return false;
			} else if (_filter == "Female" && d.data.sex != 2) {
				return false;
			} else if (!_query || _query.length==0) {
				return true;
			} else {
				var s:String = String(d.data["occupation"]).toLowerCase();
				for each (var q:String in _query) {
					var len:int = q.length;
					if (len == 0) continue;
					if (!_exact && s.substr(0,len)==q) return true;
					if (_exact && q==s) return true;
				}
				return false;
			}
		}
		
		/** Callback for filter events. */
		private function onFilter(evt:Event=null):void
		{
			_query = _search.query.toLowerCase().split(/\|/);
			if (_query.length==1 && _query[0].length==0) _query.pop();
			
			if (_t && _t.running) _t.stop();
			_t = _vis.update(_dur);
			_t.play();
			
			_exact = false; // reset exact match after each search
		}
		
		// --------------------------------------------------------------------
		
		private function addControls():void
		{			
			// create title
			_title = new TextSprite("", _fmt, TextSprite.DEVICE);
			_title.htmlText = _titleText;
			_title.textField.selectable = false;
			addChild(_title);
			
			// create search box
			_search = new SearchBox(_fmt, ">", 250);
			_search.borderColor = 0xdedede;
			_search.input.tabIndex = 0;
			_search.input.restrict = "a-zA-Z \\-";
			_search.addEventListener(SearchBox.SEARCH, onFilter);
			addChild(_search);
			
			// create gender filter
			_gender = Legend.fromValues(null, [
				{label:"All",    color:0xff888888},
				{label:"Male",   color:0xff8888ff},
				{label:"Female", color:0xffff8888}
			]);
			_gender.orientation = Orientation.LEFT_TO_RIGHT;
			_gender.labelTextFormat = _fmt;
			_gender.margin = 3;
			_gender.setItemProperties({buttonMode:true, alpha:0.3});
			_gender.items.getChildAt(0).alpha = 1;
			_gender.update();
			addChild(_gender);
			
			// change alpha value on legend mouse-over
			new HoverControl(LegendItem, 0,
				function(e:SelectionEvent):void { e.object.alpha = 1; },
				function(e:SelectionEvent):void {
					var li:LegendItem = LegendItem(e.object);
					if (li.text != _filter) li.alpha = 0.3;
				}
			).attach(_gender);
			
			// filter by gender on legend click
			new ClickControl(LegendItem, 1, function(e:SelectionEvent):void {
				_gender.setItemProperties({alpha:0.3});
				e.object.alpha = 1;
				_filter = LegendItem(e.object).text;
				onFilter();
			}).attach(_gender);
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Reshapes a data set, pivoting from rows to columns. For example, if
		 * yearly data is stored in individual rows, this method can be used to
		 * map each year into a column and the full time series into a single
		 * row. This is often needed to use the stacked area layout.
		 * @param tuples an array of data tuples
		 * @param cats the category values to maintain
		 * @param dim the dimension upon which to pivot. The values of this
		 *  property should correspond to the names of newly created columns.
		 * @param measure the numerical value of interest. The values of this
		 *  property will be used as the values of the new columns.
		 * @param cols an ordered array of the new column names. These should
		 *  match the values of the <code>dim</code> property.
		 * @param normalize a flag indicating if the data should be normalized
		 */
		public static function reshape(tuples:Array, cats:Array, dim:String,
			measure:String, cols:Array, normalize:Boolean=true):Array
		{
			var t:Object, d:Object, val:Object, name:String;
			var data:Array = [], names:Array = []
			var totals:Object = {};
			for each (val in cols) totals[val] = 0;
			
			// create data set
			for each (t in tuples) {
				// create lookup hash for tuple
				var hash:String = "";
				for each (name in cats) hash += t[name];
				
				if (names[hash] == null) {
					// create a new data tuple
					data.push(d = {});
					for each (name in cats) d[name] = t[name];
					d[t[dim]] = t[measure];
					names[hash] = d;
				} else {
					// update an existing data tuple
					names[hash][t[dim]] = t[measure];
				}
				totals[t[dim]] += t[measure];
			}
			// zero out missing data
			for each (t in data) {
				var max:Number = 0;
				for each (name in cols) {
					if (!t[name]) t[name] = 0; // zero out null entries
					if (normalize)
						t[name] /= totals[name]; // normalize
					if (t[name] > max) max = t[name];
				}
				t.max = max;
			}
			return data;
		}
		
	} // end of class Stacks	
}

import flare.animate.Transitioner;
import flare.vis.data.DataSprite;
import flare.vis.operator.Operator;

class SaturationEncoder extends Operator
{
	public override function operate(t:Transitioner=null):void
	{
		t = (t ? t : Transitioner.DEFAULT);
		var m:Number=0, f:Number=0;
		
		// first pass: determine maximum visible value
		visualization.data.nodes.visit(function(d:DataSprite):void {
			if (d.data.sex == 1) {
				m = Math.max(m, d.data.max);
			} else {
				f = Math.max(f, d.data.max);
			}
		}, "visible");
		
		// second pass: set saturation
		visualization.data.nodes.visit(function(d:DataSprite):void {
			var s:Number = .3 + .3*d.data.max/((d.data.sex==1)?m:f);
			t.$(d).fillSaturation = s;
		}, "visible");
	}
	
} // end of class SaturationEncoder