package flare.tests
{
	import flare.util.Displays;
	import flare.util.Sort;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import unitest.TestCase;

	public class SortTests extends TestCase
	{
		public function SortTests() {
			addTest("testSort");
			addTest("testSortDisplayChildren");
		}
		
		// --------------------------------------------------------------------

		private var a:Object = {x:1, y:1, z:1};
		private var b:Object = {x:2, y:1, z:1};
		private var c:Object = {x:3, y:2, z:1};
		private var d:Object = {x:4, y:2, z:1};
		private var e:Object = {x:5, y:3, z:2};
		private var f:Object = {x:6, y:3, z:2};
		private var g:Object = {x:7, y:4, z:2};
		private var h:Object = {x:8, y:4, z:2};
		
		public function testSort():void
		{
			var tests:Array = [
				{
				 items:[a, b, c, d, e, f, g, h],
				 check:[h, g, f, e, d, c, b, a],
				 sort: Sort.$("-x")
				},
				{
				 items:[a, b, c, d, e, f, g, h],
				 check:[g, h, e, f, c, d, a, b],
				 sort: Sort.$("-y")
				},
				{
				 items:[a, b, c, d, e, f, g, h],
				 check:[e, f, g, h, a, b, c, d],
				 sort: Sort.$("-z", "+x")
				},
				{
				 items:[a, b, c, d, e, f, g, h],
				 check:[b, a, d, c, f, e, h, g],
				 sort: Sort.$("y", "-x")
				},
				{
				 items:[a, b, c, d, e, f, g, h],
				 check:[a, b, c, d, e, f, g, h],
				 sort: Sort.$("z", "y", "x")
				},
				{
				 items:[a, b, c, d, e, f, g, h],
				 check:[g, h, e, f, c, d, a, b],
				 sort: Sort.$(["-z", "-y", "x"])
				},
			];
			
			for each (var test:Object in tests) {
				test.items.sort(test.sort);
				for (var i:int=0; i<test.items.length; ++i)
					assertEquals(test.check[i], test.items[i]);
			}
		}
		
		public function testSortDisplayChildren():void
		{
			var p:Sprite = new Sprite();
			var sa:Shape = new Shape(); sa.x = a.x; sa.y = a.y;
			var sb:Shape = new Shape(); sb.x = b.x; sb.y = b.y;
			var sc:Shape = new Shape(); sc.x = c.x; sc.y = c.y;
			var sd:Shape = new Shape(); sd.x = d.x; sd.y = d.y;
			var se:Shape = new Shape(); se.x = e.x; se.y = e.y;
			var sf:Shape = new Shape(); sf.x = f.x; sf.y = f.y;
			var sg:Shape = new Shape(); sg.x = g.x; sg.y = g.y;
			var sh:Shape = new Shape(); sh.x = h.x; sh.y = h.y;
			
			var tests:Array = [
				{
				 items:[sa, sb, sc, sd, se, sf, sg, sh],
				 check:[sh, sg, sf, se, sd, sc, sb, sa],
				 sort: Sort.$("-x")
				},
				{
				 items:[sa, sb, sc, sd, se, sf, sg, sh],
				 check:[sg, sh, se, sf, sc, sd, sa, sb],
				 sort: Sort.$("-y")
				},
				{
				 items:[sa, sb, sc, sd, se, sf, sg, sh],
				 check:[sb, sa, sd, sc, sf, se, sh, sg],
				 sort: Sort.$("y", "-x")
				}
			];
			
			for each (var test:Object in tests) {
				// clear children
				for (var i:int=p.numChildren; --i>=0;)
					p.removeChildAt(i);
				// add children
				for (i=0; i<test.items.length; ++i)
					p.addChild(test.items[i]);
				// sort
				Displays.sortChildren(p, test.sort);
				// check result
				for (i=0; i<test.items.length; ++i)
					assertEquals(test.check[i], p.getChildAt(i));
			}
		}
		
	} // end of class SortTests
}