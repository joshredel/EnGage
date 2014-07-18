package org.ten.classes
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.ten.utils.PHPUtil;
	
	[Bindable]
	public final class Slide
	{
		/**
		 * Our instance variables.
		 */
		public var id:uint;
		public var owner:User;
		public var slideName:String;
		public var fileLocation:String;
		public var publishState:String;
		public var publishStartDate:Date;
		public var publishEndDate:Date;
		public var approvalState:String;
		public var type:String;
		public var takeOver:Boolean;
		public var durationTime:uint;
		
		/**
		 * The SlideSPOT who uses this slide.
		 */
		public var slideSPOT:SlideSPOT;
		
		/**
		 * The clients this slide is seen on.
		 */
		public var clients:ArrayCollection;
		
		/**
		 * The aproval notes that belong to this slide.
		 */
		public var approvalNotes:ArrayCollection;
		
		/**
		 * Constants for the publishState.
		 */
		public static const PUBLISHED_ALWAYS:String = "Always Published";
		public static const PUBLISHED_UNPUBLISHED:String = "Unpublished";
		public static const PUBLISHED_DATE_RANGE:String = "Published on a Date Range";
		public static const PUBLISHED_STATES:ArrayCollection = new ArrayCollection([PUBLISHED_UNPUBLISHED,
																					PUBLISHED_ALWAYS,
																					PUBLISHED_DATE_RANGE]);
		
		/**
		 * Contstants for the approvalState.
		 */
		public static const APPROVAL_PENDING:String = "Pending";
		public static const APPROVAL_REJECTED:String = "Rejected";
		public static const APPROVAL_ACCEPTED:String = "Accepted";
		public static const APPROVAL_MORE_INFO:String = "Requested More Information";
		public static const APPROVAL_STATES:ArrayCollection = new ArrayCollection([APPROVAL_PENDING,
																				   APPROVAL_REJECTED,
																				   APPROVAL_ACCEPTED,
																				   APPROVAL_MORE_INFO]);
		
		/**
		 * Constant for the possible duration times of a slide.
		 */
		public static const DURATION_TIMES:ArrayCollection = new ArrayCollection(["2 seconds",
																				  "5 seconds",
																				  "10 seconds",
																				  "20 seconds"]);
		
		/**
		 * Constants for the type.
		 */
		public static const TYPE_IMAGE:String = "Image";
		public static const TYPE_MOVIE:String = "Movie";
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
		public function Slide()
		{
			// let's create a standard slide
			// id of 0 will mark it as new when adding to database
			this.id = 0;
			
			this.owner = null;
			this.slideName = "";
			this.fileLocation = "";
			this.publishState = PUBLISHED_UNPUBLISHED;
			this.publishStartDate = null;
			this.publishEndDate = null;
			if(dataShop.currentUser != null && (!dataShop.currentUser.requiresApproval || dataShop.currentUser.isAdministrator))
			{
				this.approvalState = APPROVAL_ACCEPTED;
			}
			else
			{
				this.approvalState = APPROVAL_PENDING;
			}
			this.type = TYPE_IMAGE;
			this.takeOver = false;
			this.durationTime = 10000;
			this.slideSPOT = null;
			this.clients = new ArrayCollection();
			this.approvalNotes = new ArrayCollection();
		}
		
		/**
		 * Returns the slide based on the passed ID.
		 * 
		 * @param slideId the ID of the desired slide.
		 * @return the slide with the matching ID, null if nothing found
		 */
		public static function getSlideWithID(slideId:uint):Slide
		{
			for each(var slide:Slide in dataShop.slides)
			{
				if(slide.id == slideId)
				{
					return slide;
				}
			}
			
			// if we get here, nothing was found!
			return null;
		}
		
		/**
		 * Gets all slides stored in the system.
		 */
		public static function getSlides():void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/GetSlides.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleGetSlidesResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the result of a get all slides command.
		 */
		private static function handleGetSlidesResult(event:ResultEvent):void
		{
			var fetchedSlides:XMLList = event.result.slide;
			var newSlides:ArrayCollection = new ArrayCollection();
			var mySlides:ArrayCollection = new ArrayCollection();
			
			// clear all user records of existing Slides
			User.clearAllUsersSlides();
			
			// loop through all returned Slides
			for(var i:Number = 0; i < fetchedSlides.length(); i++)
			{
				// create the data from the XML
				var newSlide:Slide = new Slide();
				newSlide.id = fetchedSlides[i].id
				newSlide.slideName = fetchedSlides[i].slideName;
				newSlide.fileLocation = fetchedSlides[i].fileLocation;
				newSlide.publishState = fetchedSlides[i].publishState;
				newSlide.publishStartDate = new Date(fetchedSlides[i].publishStartDate);
				newSlide.publishEndDate = new Date(fetchedSlides[i].publishEndDate);
				newSlide.approvalState = fetchedSlides[i].approvalState;
				newSlide.type = fetchedSlides[i].type;
				newSlide.takeOver = PHPUtil.intToBool(fetchedSlides[i].takeOver);
				newSlide.durationTime = fetchedSlides[i].durationTime;
				
				// associate this to a user and vice versa
				var user:User = User.getUserWithID(uint(fetchedSlides[i].ownerId));
				if(fetchedSlides[i].ownerId != 0 && user != null)
				{
					newSlide.owner = user;
					user.slides.addItem(newSlide);
				}
				
				// associate clients to this slide
				var clientIds:Array = String(fetchedSlides[i].clientIds).split(",");
				for each(var id:uint in clientIds)
				{
					newSlide.clients.addItem(Client.getClientWithID(id));
				}
				
				// associate approval notes to this slide
				var noteIds:Array = String(fetchedSlides[i].approvalNoteIds).split(",");
				for each(var noteId:uint in noteIds)
				{
					newSlide.approvalNotes.addItem(ApprovalNote.getApprovalNoteWithID(id));
				}
				
				// add it to our collection
				newSlides.addItem(newSlide);
				
				// add it to the "my" collection, if appropriate
				if(dataShop.currentUser != null && dataShop.currentUser.id == newSlide.owner.id)
				{
					mySlides.addItem(newSlide);
				}
			}
			
			// store the reference to our Slides!
			dataShop.slides = newSlides;
			dataShop.mySlides = mySlides;
		}
		
		/**
		 * Gets all slides stored in the system that 
		 * should be displayed on the current client.
		 */
		public static function getMyClientsSlides():void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/GetClientSlides.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleGetMyClientsSlides);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			if(dataShop.clientLoggedIn && dataShop.currentClient != null)
			{
				// set it up with our request
				connect.request.id = dataShop.currentClient.id;
				
				// send it!
				connect.send();
			}
		}
		
		/**
		 * @private
		 * Handles the result of a get all slides command.
		 */
		private static function handleGetMyClientsSlides(event:ResultEvent):void
		{
			var fetchedSlides:XMLList = event.result.slide;
			var newSlides:ArrayCollection = new ArrayCollection();
			
			// loop through all returned Slides
			for(var i:Number = 0; i < fetchedSlides.length(); i++)
			{
				// create the data from the XML
				var newSlide:Slide = new Slide();
				newSlide.id = fetchedSlides[i].id
				newSlide.slideName = fetchedSlides[i].slideName;
				newSlide.fileLocation = fetchedSlides[i].fileLocation;
				newSlide.publishState = fetchedSlides[i].publishState;
				newSlide.publishStartDate = new Date(fetchedSlides[i].publishStartDate);
				newSlide.publishEndDate = new Date(fetchedSlides[i].publishEndDate);
				newSlide.approvalState = fetchedSlides[i].approvalState;
				newSlide.type = fetchedSlides[i].type;
				newSlide.takeOver = PHPUtil.intToBool(fetchedSlides[i].takeOver);
				newSlide.durationTime = fetchedSlides[i].durationTime;
				
				// add it to our collection
				newSlides.addItem(newSlide);
			}
			
			// store the reference to our Slides!
			dataShop.slides = newSlides;
		}
		
		/**
		 * Creates or saves a slide (an ID of 0 will create a new one)
		 */
		public static function saveSlide(slide:Slide):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/SaveSlide.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteSlideResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = slide.id;
			connect.request.ownerId = slide.owner == null ? 0 : slide.owner.id;
			connect.request.slideName = slide.slideName;
			connect.request.fileLocation = slide.fileLocation;
			connect.request.publishState = slide.publishState;
			connect.request.publishStartDate = slide.publishStartDate.getTime() / 1000;
			connect.request.publishEndDate = slide.publishEndDate.getTime() / 1000;
			connect.request.approvalState = slide.approvalState;
			connect.request.type = slide.type;
			connect.request.takeOver = slide.takeOver;
			connect.request.durationTime = slide.durationTime;
			connect.request.clientIds = "";
			connect.request.approvalNoteIds = "";
			
			// send the client ids as well
			if(slide.clients != null && slide.clients.length > 0)
			{
				for(var i:Number = 0; i < slide.clients.length; i++)
				{
					connect.request.clientIds += slide.clients.getItemAt(i).id;
					
					if(i < slide.clients.length - 1)
					{
						connect.request.clientIds += ",";
					}
				}
			}
			
			// send the approval note ids as well
			if(slide.approvalNotes != null && slide.approvalNotes.length > 0)
			{
				
				for(var j:Number = 0; j < slide.approvalNotes.length; j++)
				{
					connect.request.approvalNoteIds += slide.approvalNotes.getItemAt(j).id;
					
					if(j < slide.approvalNotes.length - 1)
					{
						connect.request.approvalNoteIds += ",";
					}
				}
			}
			
			// send it!
			connect.send();
		}
		
		/**
		 * Deletes a slide from the database.  This is irreversible.
		 */
		public static function deleteSlide(slide:Slide):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/DeleteSlide.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteSlideResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = slide.id;
			
			// oh, and ask to delete the slide too
			deleteSlideFile(slide.fileLocation);
			
			// send it!
			connect.send();
		}
		
		/**
		 * Handles the result of a save or delete user command.
		 */
		private static function handleSaveDeleteSlideResult(event:ResultEvent):void
		{
			// refresh the users in our singleton
			Slide.getSlides();
		}
		
		/**
		 * Deletes a slide file in the slides folder on the server.
		 */
		public static function deleteSlideFile(filename:String):void
		{
			// abandon if the file is nothing
			if(filename == "")
			{
				return;
			}
			
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/DeleteSlideFile.php";
			connect.resultFormat = "text";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.filename = filename;
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the faults of database connection failures.
		 */
		private static function handleFault(event:FaultEvent):void
		{
			Alert.show(event.fault.faultString, "Data Transmission Error:");
			
			// add doubling retry timer here
		}
	}
}