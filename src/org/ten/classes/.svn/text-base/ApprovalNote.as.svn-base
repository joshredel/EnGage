package org.ten.classes
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class ApprovalNote
	{
		/**
		 * Our instance variables.
		 * Because we can get the ID of the slide from its object,
		 * we will simply store a reference to that object.  If it is null,
		 * we can assume the ID was 0.
		 */
		public var id:uint;
		public var slide:Slide;
		public var dateSubmitted:Date;
		public var message:String;
		public var submitter:User;
		
		public function ApprovalNote()
		{
			// let's create a standard approval note
			// id of 0 will mark it as new when it is added to the database
			this.id = 0;
			
			this.slide = null;
			this.dateSubmitted = null;
			this.message = "";
		}
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
		/**
		 * Returns the approval note based on the passed ID.
		 * 
		 * @param approvalNoteId the ID of the desired approval note.
		 * @return the approval note with the matching ID, null if nothing found
		 */
		public static function getApprovalNoteWithID(approvalNoteId:uint):ApprovalNote
		{
			for each(var note:ApprovalNote in dataShop.approvalNotes)
			{
				if(note.id == approvalNoteId)
				{
					return note;
				}
			}
			
			// if we get here, nothing was found!
			return null;
		}
	}
}