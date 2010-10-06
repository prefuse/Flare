package flare.analytics.cluster
{
	import flare.animate.Transitioner;
	import flare.util.math.IMatrix;
	import flare.vis.data.Data;
	import flare.vis.data.DataList;
	
	/**
	 * Hierarchically clusters a set of items using agglomerative clustering.
	 * This approach continually merges the most similar items (those with the
	 * minimum distance between them) into clusters, until all items have been
	 * merged into a final resulting cluster tree. Clients must provide a
	 * distance function that takes as input two <code>DataSprite</code>
	 * instances and returns a <code>Number</code>.
	 * <p>This class supports both <i>minimum-link</i> clustering, in which the
	 * distance between clusters is measured as the distance between the two
	 * nearest items in each cluster, and <i>maximum-link</i> clustering, in
	 * which distance is measured using the two furthest items in each cluster.
	 * </p>
	 * <p>For a richer description, see
	 * <a href="http://en.wikipedia.org/wiki/Cluster_analysis#Agglomerative_hierarchical_clustering">
	 * the Wikipedia article on Cluster Analysis</a>.
	 * </p>
	 */
	public class AgglomerativeCluster extends HierarchicalCluster
	{		
		/** A function defining distances between items. */
		public var distance:Function = null;
		
		/** If true, minimum-link distances are computed between clusters.
		 *  If false, maximum-link distances are computed between clusters. */
		public var minLink:Boolean = true;

		// --------------------------------------------------------------------
		
		/**
		 * Creates a new agglomerative cluster instance
		 */
		public function AgglomerativeCluster(group:String=Data.NODES)
		{
			this.group = group;
		}
		
		/** @inheritDoc */
		public override function operate(t:Transitioner=null):void
		{
			calculate(visualization.data.group(group), distance);
		}
		
		/**
		 * Calculates the community structure clustering. As a result of this
		 * method, a cluster tree will be computed and graph nodes will be
		 * annotated with both community and sequence indices.
		 * @param list a data list to cluster
		 * @param d a distance function
		 */
		public function calculate(list:DataList, d:Function):void
		{
			compute(list.distanceMatrix(d));
			_tree = buildTree(list);
			labelNodes();
		}
		
		/** Computes the clustering */
		private function compute(Z:IMatrix):void
		{
			_merges = new MergeEdge(-1, -1);
			_qvals = [];
			_size = Z.rows;
			
			var m:MergeEdge = _merges;
			var i:uint, j:uint, k:int, s:int, t:int, ii:uint, jj:uint;
			var min:Number, a:uint, b:uint, bb:uint, imax:int;
			var v:Number, sum:Number=0, Q:Number=0, Qmax:Number=0, dQ:Number;
			
			// initialize matrix
			var N:int = Z.rows;
			var idx:/*int*/Array = new Array(N);
			for (i=0; i<N; ++i) {
				idx[i] = i;
				Z.set(i,i,Number.POSITIVE_INFINITY);
			}
			
			// run the clustering algorithm
			for (var iter:int=0; iter<N-1; ++iter) {
				// find the nodes to merge
				min = Number.MAX_VALUE;
				for (ii=0; ii<idx.length; ++ii) {
					i = idx[ii];
					for (jj=ii+1; jj<idx.length; ++jj) {
						j = idx[jj];
						v = Z.get(i,j);
						if (v < min) {
							min = v;
							a = i;
							b = j; bb = jj;
						}
					}
				}
				i = a; j = b; jj = bb;
				
				// perform merge on graph
				for (k=0; k<N; ++k) {
					if (minLink) {
						v = Math.min(Z.get(i,k), Z.get(j,k)); // min link
					} else {
						v = Math.max(Z.get(i,k), Z.get(j,k)); // max link
					}
					Z.set(i, k, v);
					Z.set(k, i, v);
				}
				for (k=0; k<N; ++k) {
					Z.set(j, k, Number.POSITIVE_INFINITY);
					Z.set(k, j, Number.POSITIVE_INFINITY);
				}
				idx.splice(jj, 1);
				
				Q += min;
				if (Q > Qmax) {
					Qmax = Q;
					imax = iter;
				}
				_qvals.push(Q);
				m = m.add(new MergeEdge(i,j));
			}
		}
		
	} // end of class AgglomerativeCluster
}