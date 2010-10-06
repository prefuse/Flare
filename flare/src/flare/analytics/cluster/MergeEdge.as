package flare.analytics.cluster
{
	/**
	 * Auxiliary class that represents a merge in a clustering.
	 */
	internal class MergeEdge
	{
		public var i:int;
		public var j:int;
		public var next:MergeEdge = null;
		public var prev:MergeEdge = null;
		
		public function MergeEdge(i:int, j:int) {
			this.i = i;
			this.j = j;
		}
		
		public function update(i:int, j:int):void
		{
			this.i = i;
			this.j = j;
		}
		
		public function add(e:MergeEdge):MergeEdge {
			if (next) {
				e.next = next;
				next.prev = e;
			}
			next = e;
			e.prev = this;
			return e;
		}
		
		public function remove():void {
			if (prev) prev.next = next;
			if (next) next.prev = prev;
		}
		
	} // end of class MergeEdge
}