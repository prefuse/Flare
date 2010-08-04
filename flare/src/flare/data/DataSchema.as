package flare.data
{
	import flare.util.Vectors;
	
	/**
	 * A data schema represents a set of data variables and their associated 
	 * types. A schema maintains a collection of <code>DataField</code>
	 * objects.
	 * @see flare.data.DataField
	 */
	public class DataSchema
	{
		public var dataRoot:String = null;
		public var hasHeader:Boolean = false;
		
		private var _fields:Vector.</*DataField*/Object> = new Vector.<Object>();
		private var _nameLookup:/*String->DataField*/Object = {};
		private var _idLookup:/*String->DataField*/Object = {};
		
		/** An objct vector containing the data fields in this schema. */
		public function get fields():Vector.<Object> { return Vectors.copy(_fields); }
		/** The number of data fields in this schema. */
		public function get numFields():int { return _fields.length; }
		
		/**
		 * Creates a new DataSchema.
		 * @param fields an ordered list of data fields to include in the
		 * schema
		 */
		public function DataSchema(...fields)
		{
			for each (var f:DataField in fields) {
				addField(f);
			}
		}
		
		/**
		 * Adds a field to this schema.
		 * @param field the data field to add
		 */
		public function addField(field:DataField):void
		{
			_fields.push(field);
			_nameLookup[field.name] = field;
			_idLookup[field.id] = field;
		}
		
		/**
		 * Retrieves a data field by name.
		 * @param name the data field name
		 * @return the corresponding data field, or null if no data field is
		 *  found matching the name
		 */
		public function getFieldByName(name:String):DataField
		{
			return _nameLookup[name];
		}
		
		/**
		 * Retrieves a data field by id.
		 * @param name the data field id
		 * @return the corresponding data field, or null if no data field is
		 *  found matching the id
		 */
		public function getFieldById(id:String):DataField
		{
			return _idLookup[id];
		}
		
		/**
		 * Retrieves a data field by its index in this schema.
		 * @param idx the index of the data field in this schema
		 * @return the corresponding data field
		 */
		public function getFieldAt(idx:int):DataField
		{
			return _fields[idx] as DataField;
		}
		
	} // end of class DataSchema
}