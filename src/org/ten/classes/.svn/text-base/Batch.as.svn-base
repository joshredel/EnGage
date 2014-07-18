package org.ten.classes
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Batch
	{
		/**
		 * Our instance variables.
		 */
		public var id:uint;
		public var batchName:String;
		public var slides:ArrayCollection;
		
		public function Batch()
		{
			// let's create a standard batch
			// id of 0 will mark it as new when it is added to the database
			this.id = 0;
			
			this.batchName = "";
			this.slides = new ArrayCollection();
		}
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
	}
}