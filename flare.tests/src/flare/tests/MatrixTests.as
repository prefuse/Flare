package flare.tests
{
	import flare.util.math.DenseMatrix;
	import flare.util.math.IMatrix;
	import flare.util.math.SparseMatrix;
	
	import unitest.TestCase;

	public class MatrixTests extends TestCase
	{
		public function MatrixTests()
		{
			addTest("testDenseMatrix");
			addTest("testSparseMatrix");
		}
		
		private static function testMatrix(mat:IMatrix):void
		{
			var i:int, j:int, c:int = 7, v:Number;
			
			// populate matrix
			for (i=0; i<mat.cols; ++i) mat.set(1,i,c);
			for (i=0; i<mat.rows; ++i) mat.set(i,1,c);
			for (i=0; i<mat.rows; ++i) mat.set(i,i,i+1);
			
			// test properties
			assertEquals(5, mat.rows);
			assertEquals(5, mat.cols);
			assertEquals(13, mat.nnz);
			
			var s:Number=0, ss:Number=0;
			for (i=0; i<mat.rows; ++i) {
				for (j=0; j<mat.cols; ++j) {
					v = mat.get(i,j);
					s += v;
					ss += v*v;
				}
			}
			assertEquals(s, mat.sum);
			assertEquals(ss, mat.sumsq);
			
			// test copy and scale
			var like:IMatrix = mat.clone(); like.scale(1 / s);
			for (i=0; i<mat.rows; ++i) {
				for (j=0; j<mat.cols; ++j) {
					assertEquals(mat.get(i,j)*(1/s), like.get(i,j));
				}
			}
			
			// test matrix access
			var test:Function = function(i:int, j:int, v:Number):Number {
				if (i==j)              assertEquals(i+1, v);
				else if (i==1 || j==1) assertEquals(c, v);
				else                   assertEquals(0, v);
				return v;
			};
			var nonZero:Function = function(i:int, j:int, v:Number):Number {
				assertNotEquals(0, v);
				return v;
			};
			
			for (i=0; i<mat.rows; ++i) {
				for (j=0; j<mat.cols; ++j) test(i, j, mat.get(i,j));
			}
			mat.visit(test);
			mat.visitNonZero(test);
			mat.visitNonZero(nonZero);
			
			for (i=0; i<mat.rows; ++i) {
				mat.set(i,i,0);
			}
			assertEquals(8, mat.nnz);
			mat.visitNonZero(nonZero);
		}
		
		public function testDenseMatrix():void
		{
			testMatrix(new DenseMatrix(5,5));
		}
		
		public function testSparseMatrix():void
		{
			testMatrix(new SparseMatrix(5,5));
		}
		
	} // end of class MatrixTests
}