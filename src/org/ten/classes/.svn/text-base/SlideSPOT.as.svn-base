package org.ten.classes
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Bindable]
	public class SlideSPOT
	{
		/**
		 * Our instance variables.
		 * Because we can get the IDs of the slide and owner from their object,
		 * we will simply store references to those objects.  If they are null,
		 * we can assume the ID was 0.
		 */
		public var id:uint;
		public var slide:Slide;
		public var owner:User;
		public var orderRank:int;
		public var typeRestriction:String;
		
		/**
		 * Constants for the typeRestriction.
		 */
		public static const RESTRICTION_NONE:String = "No Restriction";
		public static const RESTRICTION_IMAGE:String = "Image";
		public static const RESTRICTION_MOVIE:String = "Movie";
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
		public function SlideSPOT()
		{
			// let's create a standard SlideSPOT
			// id of 0 will mark it as new when adding it to the database.
			this.id = 0;
			
			this.slide = null;
			this.owner = null;
			
			// a rank of -1 will put after all of the ordered spots
			this.orderRank = -1;
			
			this.typeRestriction = RESTRICTION_NONE;
		}
		
		/**
		 * Returns the SlideSPOT based on the passed ID.
		 * 
		 * @param spotId the ID of the desired SlideSPOT.
		 * @return the SlideSPOT with the matching ID, null if nothing found
		 */
		public static function getSlideSPOTWithID(spotId:uint):SlideSPOT
		{
			for each(var spot:SlideSPOT in dataShop.slideSPOTs)
			{
				if(spot.id == spotId)
				{
					return spot;
				}
			}
			
			// if we get here, nothing was found!
			return null;
		}
		
		/**
		 * Gets all SlideSPOTs stored in the system.
		 */
		public static function getSlideSPOTs():void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/GetSlideSPOTs.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleGetSlideSPOTsResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the result of a get all users command.
		 */
		private static function handleGetSlideSPOTsResult(event:ResultEvent):void
		{
			var spots:XMLList = event.result.slidespot;
			var newSpots:ArrayCollection = new ArrayCollection();
			var mySpots:ArrayCollection = new ArrayCollection();
			dataShop.availableSlideSPOTs = 0;
			
			// clear all user records of existing SlideSPOTs
			User.clearAllUsersSlideSPOTs();
			
			// loop through all returned SlideSPOTs
			for(var i:Number = 0; i < spots.length(); i++)
			{
				// create the data from the XML
				var newSpot:SlideSPOT = new SlideSPOT();
				newSpot.id = spots[i].id
				newSpot.orderRank = spots[i].orderRank;
				newSpot.typeRestriction = spots[i].typeRestriction;
				
				// associate this to a slide and vice versa
				var slide:Slide = Slide.getSlideWithID(uint(spots[i].slideId));
				if(spots[i].slideId != 0 && slide != null)
				{
					newSpot.slide = slide;
					slide.slideSPOT = newSpot;
				}
				
				// associate this to a user and vice versa
				var user:User = User.getUserWithID(uint(spots[i].ownerId));
				if(spots[i].ownerId != 0 && user != null)
				{
					newSpot.owner = user;
					user.slideSPOTs.addItem(newSpot);
				}
				
				// add it to our collection
				newSpots.addItem(newSpot);
				
				// add it to the "my" collection, if appropriate
				if(dataShop.currentUser != null && dataShop.currentUser.id == newSpot.owner.id)
				{
					mySpots.addItem(newSpot);
					
					// increase our available count
					if(newSpot.slide == null)
					{
						dataShop.availableSlideSPOTs++;
					}
				}
			}
			// store the reference to our SlideSPOTs!
			dataShop.slideSPOTs = newSpots;
			dataShop.mySlideSPOTs = mySpots;
		}
		
		/**
		 * Creates or saves a user (an ID of 0 will create a new one)
		 */
		public static function saveSlideSPOT(slideSPOT:SlideSPOT, refresh:Boolean = true):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/SaveSlideSPOT.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			if(refresh)
			{
				// only request updated SlideSPOTs if requested (yes by default)
				connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteSlideSPOTResult);
			}
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = slideSPOT.id;
			connect.request.slideId = slideSPOT.slide == null ? 0 : slideSPOT.slide.id;
			connect.request.ownerId = slideSPOT.owner == null ? 0 : slideSPOT.owner.id;
			connect.request.orderRank = slideSPOT.orderRank;
			connect.request.typeRestriction = slideSPOT.typeRestriction;
			
			// send it!
			connect.send();
		}
		
		/**
		 * Deletes a user from the database.  This is irreversible.
		 */
		public static function deleteSlideSPOT(slideSPOT:SlideSPOT):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/DeleteSlideSPOT.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteSlideSPOTResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = slideSPOT.id;
			
			// send it!
			connect.send();
		}
		
		/**
		 * Handles the result of a save or delete user command.
		 */
		private static function handleSaveDeleteSlideSPOTResult(event:ResultEvent):void
		{
			// refresh the users in our singleton
			SlideSPOT.getSlideSPOTs();
		}
		
		/**
		 * @private
		 * Handles the faults of database connection failures.
		 */
		private static function handleFault(event:FaultEvent):void
		{
			Alert.show(event.fault.faultString, "Data Transmission Error:");
		}
	}
}