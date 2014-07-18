package org.ten.classes
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Group
	{
		/**
		 * Our instance variables.
		 */
		public var id:uint;
		public var groupName:String;
		public var isAdministrative:Boolean;
		public var requiresApproval:Boolean;
		public var canTakeOver:Boolean;
		public var canChooseDurationTime:Boolean;
		public var users:ArrayCollection;
		
		public function Group()
		{
			// let's create a standard group
			// id of 0 will mark it as new when it is added to the database
			this.id = 0;
			
			this.groupName = "";
			this.isAdministrative = false;
			this.requiresApproval = true;
			this.canTakeOver = false;
			this.canChooseDurationTime = false;
			this.users = new ArrayCollection();
		}
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
	}
}