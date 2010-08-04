package flare.util.math
{
	/**
	 * Interface for a matrix of real-valued numbers.
	 */
	public interface IMatrix
	{
		/** The number of rows. */
		function get rows():int;
		/** The number of columns. */
		function get cols():int;
		/** The number of non-zero values. */
		function get nnz():int;
		/** The sum of all the entries in this matrix. */
		function get sum():Number;
		/** The sum of squares of all the entries in this matrix. */
		function get sumsq():Number;
		
		/** Creates a copy of this matrix. */
		function clone():IMatrix;
		
		/**
		 * Creates a new matrix of the same type.
		 * @param rows the number of rows in the new matrix
		 * @param cols the number of columns in the new matrix
		 * @return a new matrix
		 */
		function like(rows:int, cols:int):IMatrix;
		
		/** 
		 * Initializes the matrix to desired dimensions. This method also
		 * resets all values in the matrix to zero.
		 * @param rows the number of rows in this matrix
		 * @param cols the number of columns in this matrix
		 */
		function init(rows:int, cols:int):void;
		
		/**
		 * Returns the value at the given indices. 
		 * @param i the row index
		 * @param j the column index
		 * @return the value at position i,j
		 */
		function get(i:int, j:int):Number;
		
		/**
		 * Sets the value at the given indices. 
		 * @param i the row index
		 * @param j the column index
		 * @param v the value to set
		 * @return the input value v
		 */
		function set(i:int, j:int, v:Number):Number;
		
		/**
		 * Multiplies all values in this matrix by the input scalar.
		 * @param s the scalar to multiply by.
		 */
		function scale(s:Number):void;
		
		/**
		 * Multiplies this matrix by another. The number of rows in this matrix
		 * must match the number of columns in the input matrix.
		 * @param b the matrix to multiply by.
		 * @return a new matrix that is the product of this matrix with the
		 *  input matrix. The new matrix will be of the same type as this one.
		 */
		function multiply(b:IMatrix):IMatrix;
		
		/**
		 * Visit all non-zero values in the matrix.
		 * The input function is expected to take three arguments--the row
		 * index, the column index, and the cell value--and return a number
		 * which then becomes the new value for the cell.
		 * @param f the function to invoke for each non-zero value
		 */
		function visitNonZero(f:Function):void;
		
		/**
		 * Visit all values in the matrix.
		 * The input function is expected to take three arguments--the row
		 * index, the column index, and the cell value--and return a number
		 * which then becomes the new value for the cell.
		 * @param f the function to invoke for each value
		 */
		function visit(f:Function):void;
		
	} // end of interface IMatrix
}