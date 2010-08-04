package flare.util.math
{
	import flash.utils.Dictionary;
	
	/**
	 * A matrix of numbers implemented using a hashtable of values.
	 */
	public class SparseMatrix implements IMatrix
	{
		private var _r:int;
		private var _c:int;
		private var _nnz:int;
		private var _v:Dictionary;
		
		/** @inheritDoc */
		public function get rows():int { return _r; }
		/** @inheritDoc */
		public function get cols():int { return _c; }
		/** @inheritDoc */
		public function get nnz():int {
			var count:int = 0;
			for (var key:String in _v)
				++count;
			return count;
		}
		/** @inheritDoc */
		public function get sum():Number {
			var sum:Number = 0;
			for (var key:String in _v)
				sum += _v[key];
			return sum;
		}
		/** @inheritDoc */
		public function get sumsq():Number {
			var sumsq:Number = 0, v:Number;
			for (var key:String in _v) {
				v = _v[key];
				sumsq += v*v;
			}
			return sumsq;
		}
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new SparseMatrix with the given size. 
		 * @param rows the number of rows
		 * @param cols the number of columns
		 */
		public function SparseMatrix(rows:int, cols:int) {
			init(rows, cols);
		}
		
		/** @inheritDoc */
		public function clone():IMatrix {
			var m:SparseMatrix = new SparseMatrix(_r, _c);
			for (var key:String in _v)
				m._v[key] = _v[key];
			return m;
		}
		
		/** @inheritDoc */
		public function like(rows:int, cols:int):IMatrix {
			return new SparseMatrix(rows, cols);
		}
		
		/** @inheritDoc */
		public function init(rows:int, cols:int):void {
			_r = rows;
			_c = cols;
			_nnz = 0;
			_v = new Dictionary();
		}
		
		/** @inheritDoc */
		public function get(i:int, j:int):Number {
			var v:* = _v[i*_c + j];
			return (v ? Number(v) : 0);
		}
		
		/** @inheritDoc */
		public function set(i:int, j:int, v:Number):Number {
			var key:int = i*_c + j;
			if (v==0) {
				delete _v[key];
			} else {
				_v[key] = v;
			}
			return v;
		}
		
		/** @inheritDoc */
		public function scale(s:Number):void {
			for (var key:String in _v) _v[key] *= s;
		}
		
		/** @inheritDoc */
		public function multiply(b:IMatrix):IMatrix {
			if (cols != b.rows)
				throw new Error("Incompatible matrix dimensions.");
			var z:IMatrix = like(rows, b.cols);
			for (var i:uint=0; i<z.rows; ++i) {
				for (var j:uint=0; j<z.cols; ++j) {
					var v:Number = 0;
					for (var k:uint=0; k<cols; ++k)
						v += get(i,k) * b.get(k,j);
					if (v != 0)
						z.set(i, j, v);
				}
			}
			return z;
		}
		
		/** @inheritDoc */
		public function visitNonZero(f:Function):void {
			var i:int, j:int, k:int, v:Number;
			for (var key:String in _v) {
				k = int(key);
				i = k / _c;
				j = k % _c;
				v = _v[k];
				v = f(i,j,v);
				if (v==0) {
					delete _v[key];
				} else {
					_v[key] = v;
				}
			}
		}
		
		/** @inheritDoc */
		public function visit(f:Function):void {
			var k0:int, k:int, u:*, v:Number;
			for (var i:int=0; i<_r; ++i) {
				k0 = i*_c;
				for (var j:int=0; j<_c; ++j) {
					k = k0 + j;
					u = _v[k];
					v = u ? Number(u) : 0;
					v = f(i,j,v);
					if (v==0) {
						delete _v[k];
					} else {
						_v[k] = v;
					}
				}
			}
		}

	} // end of class SparseMatrix
}