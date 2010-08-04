package flare.scale
{
	/**
	 * Constants defining known scale types, such as linear, log, and
	 * date/time scales.
	 */
	public class ScaleType
	{
		/** Constant indicating an unknown scale. */
		public static const UNKNOWN:String = "unknown";
		/** Constant indicating a categorical scale. */
		public static const CATEGORIES:String = "categories";
		/** Constant indicating an ordinal scale. */
		public static const ORDINAL:String = "ordinal";
		/** Constant indicating a linear numeric scale. */
		public static const LINEAR:String = "linear";
		/** Constant indicating a root-transformed numeric scale. */
		public static const ROOT:String = "root";
		/** Constant indicating a log-transformed numeric scale. */
		public static const LOG:String = "log";
		/** Constant indicating a quantile scale. */
		public static const QUANTILE:String = "quantile";
		/** Constant indicating a date/time scale. */
		public static const TIME:String = "time";
		
		/**
		 * Constructor, throws an error if called, as this is an abstract class.
		 */
		public function ScaleType() {
			throw new Error("This is an abstract class.");
		}
		
		/**
		 * Tests if a given scale type indicates an ordinal scale 
		 * @param type the scale type
		 * @return true if the type indicates an ordinal scale, false otherwise
		 */
		public static function isOrdinal(type:String):Boolean
		{
			return type==ORDINAL || type==CATEGORIES;
		}
		
		/**
		 * Tests if a given scale type indicates a quantitative scale 
		 * @param type the scale type
		 * @return true if the type indicates a quantitative scale,
		 *  false otherwise
		 */
		public static function isQuantitative(type:String):Boolean
		{
			return type==LINEAR || type==ROOT || type==LOG;
		}
		
	} // end of class ScaleType
}