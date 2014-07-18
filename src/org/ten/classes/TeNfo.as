package org.ten.classes
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.ten.DataShop;

	//import org.ten.utils.PHPUtil;
	
	[Bindable]
	public class TeNfo
	{
		/**
		 * Our instance variables
		 */
		public var id:uint;
//		public var owner:User;
		public var content:String;
		public var publishState:String;
		public var publishStartDate:Date;
		public var publishEndDate:Date;
		public var approvalState:String;
		
		/**
		 * The clients this tenfo is seen on.
		 */
		public var clients:ArrayCollection;
		
		/**
		 * The aproval notes that belong to this tenfo.
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
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.instance;
		
		public function TeNfo() {
			// let's create a standard TeNfo
			// id of 0 marks it as new when adding it to the database
			this.id = 0;
			
//			this.owner = null;
			this.content = "";
			this.publishState = PUBLISHED_UNPUBLISHED;
			this.publishStartDate = null;
			this.publishEndDate = null;
			this.approvalState = APPROVAL_ACCEPTED;
			this.clients = new ArrayCollection();
			this.approvalNotes = new ArrayCollection();
		}
		
//		/**
//		 * Returns the TeNfo based on the passed ID.
//		 * 
//		 * @param tenfoId the ID of the desired tenfo.
//		 * @return the tenfo with the matching ID, null if nothing found
//		 */
//		public static function getTeNfoWithID(tenfoId:uint):TeNfo {
//			for each(var tenfo:TeNfo in dataShop.tenfos) {
//				if(tenfo.id == tenfoId) {
//					return tenfo;
//				}
//			}
//			
//			// if we get here, nothing was found!
//			return null;
//		}
//		
//		/**
//		 * Gets all tenfos stored in the system.
//		 */
//		public static function getTeNfos():void {
//			// prepare the service for connection
//			var connect:HTTPService = new HTTPService();
//			connect.url = "http://ten.mcgilleus.ca/actions/GetTeNfos.php";
//			connect.resultFormat = "e4x";
//			connect.method = "POST";
//			connect.useProxy = false;
//			connect.addEventListener(ResultEvent.RESULT, handleGetTeNfosResult);
//			connect.addEventListener(FaultEvent.FAULT, handleFault);
//			
//			// send it!
//			connect.send();
//		}
		
//		/**
//		 * @private
//		 * Handles the result of a get all tenfos command.
//		 */
//		private static function handleGetTeNfosResult(event:ResultEvent):void
//		{
//			var fetchedTeNfos:XMLList = event.result.tenfo;
//			var newTeNfos:ArrayCollection = new ArrayCollection();
//			var myTeNfos:ArrayCollection = new ArrayCollection();
//			
//			// clear all user records of existing TeNfos
//			User.clearAllUsersTeNfos();
//			
//			// loop through all returned TeNfos
//			for(var i:Number = 0; i < fetchedTeNfos.length(); i++) {
//				// create the data from the XML
//				var newTeNfo:TeNfo = new TeNfo();
//				newTeNfo.id = fetchedTeNfos[i].id
//				newTeNfo.content = fetchedTeNfos[i].content;
//				newTeNfo.publishState = fetchedTeNfos[i].publishState;
//				newTeNfo.publishStartDate = new Date(fetchedTeNfos[i].publishStartDate);
//				newTeNfo.publishEndDate = new Date(fetchedTeNfos[i].publishEndDate);
//				newTeNfo.approvalState = fetchedTeNfos[i].approvalState;
//				
//				// associate this to a user and vice versa
//				var user:User = User.getUserWithID(uint(fetchedTeNfos[i].ownerId));
//				if(fetchedTeNfos[i].ownerId != 0 && user != null)
//				{
//					newTeNfo.owner = user;
//					user.tenfos.addItem(newTeNfo);
//				}
//				
//				// associate clients to this tenfo
//				var clientIds:Array = String(fetchedTeNfos[i].clientIds).split(",");
//				for each(var id:uint in clientIds)
//				{
//					newTeNfo.clients.addItem(Client.getClientWithID(id));
//				}
//				
//				// associate approval notes to this tenfo
//				var noteIds:Array = String(fetchedTeNfos[i].approvalNoteIds).split(",");
//				for each(var noteId:uint in noteIds)
//				{
//					newTeNfo.approvalNotes.addItem(ApprovalNote.getApprovalNoteWithID(id));
//				}
//				
//				// add it to our collection
//				newTeNfos.addItem(newTeNfo);
//				
////				// add it to the "my" collection, if appropriate
////				if(dataShop.currentUser != null && newTeNfo.owner != null && dataShop.currentUser.id == newTeNfo.owner.id)
////				{
////					myTeNfos.addItem(newTeNfo);
////				}
//			}
//			
//			// store the reference to our TeNfos!
//			dataShop.tenfos = newTeNfos;
//			dataShop.myTeNfos = myTeNfos;
//		}
		
		/**
		 * Gets all tenfos stored in the system that 
		 * should be displayed on the current client.
		 */
		public static function getMyClientsTeNfos(event:TimerEvent = null):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/GetClientTeNfos.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleGetMyClientsTeNfos);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			//if(dataShop.clientLoggedIn && dataShop.currentClient != null) {
			if(dataShop.clientId) {
				// set it up with our request
				connect.request.id = dataShop.clientId;
				
				// send it!
				connect.send();
				trace("[INFO] Made call to get client TeNfos");
			} else {
				trace("[INFO] Racing to get TeNfos; waiting one second for config to load.");
				var waitTimer:Timer = new Timer(1000, 1);
				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, getMyClientsTeNfos);
				waitTimer.start();
				return;
			}
		}
		
		/**
		 * @private
		 * Handles the result of a get all tenfos command.
		 */
		private static function handleGetMyClientsTeNfos(event:ResultEvent):void
		{
			var fetchedTeNfos:XMLList = event.result.tenfo;
			var newTeNfos:ArrayCollection = new ArrayCollection();
			
			// loop through all returned TeNfos
			for(var i:Number = 0; i < fetchedTeNfos.length(); i++)
			{
				// create the data from the XML
				var newTeNfo:TeNfo = new TeNfo();
				newTeNfo.id = fetchedTeNfos[i].id
				newTeNfo.content = fetchedTeNfos[i].content;
				newTeNfo.publishState = fetchedTeNfos[i].publishState;
				newTeNfo.publishStartDate = new Date(fetchedTeNfos[i].publishStartDate);
				newTeNfo.publishEndDate = new Date(fetchedTeNfos[i].publishEndDate);
				newTeNfo.approvalState = fetchedTeNfos[i].approvalState;
				
				// add it to our collection
				newTeNfos.addItem(newTeNfo);
			}
			
			// store the reference to our TeNfos!
			dataShop.tenfos = newTeNfos;
		}
		
//		/**
//		 * Creates or saves a tenfo (an ID of 0 will create a new one)
//		 */
//		public static function saveTeNfo(tenfo:TeNfo):void
//		{
//			// prepare the service for connection
//			var connect:HTTPService = new HTTPService();
//			connect.url = "http://ten.mcgilleus.ca/actions/SaveTeNfo.php";
//			connect.resultFormat = "e4x";
//			connect.method = "POST";
//			connect.useProxy = false;
//			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteTeNfoResult);
//			connect.addEventListener(FaultEvent.FAULT, handleFault);
//			
//			// set it up with our request
//			connect.request.id = tenfo.id;
//			connect.request.ownerId = tenfo.owner == null ? 0 : tenfo.owner.id;
//			connect.request.content = tenfo.content;
//			connect.request.publishState = tenfo.publishState;
//			connect.request.publishStartDate = tenfo.publishStartDate.getTime() / 1000;
//			connect.request.publishEndDate = tenfo.publishEndDate.getTime() / 1000;
//			connect.request.approvalState = tenfo.approvalState;
//			connect.request.clientIds = "";
//			connect.request.approvalNoteIds = "";
//			
//			// send the client ids as well
//			if(tenfo.clients != null && tenfo.clients.length > 0)
//			{
//				for(var i:Number = 0; i < tenfo.clients.length; i++)
//				{
//					connect.request.clientIds += tenfo.clients.getItemAt(i).id;
//					
//					if(i < tenfo.clients.length - 1)
//					{
//						connect.request.clientIds += ",";
//					}
//				}
//			}
//			
//			// something below really messes up in the following situation:
//			// trying to save changes to a tenfo that was being edited
//			// send the approval note ids as well
////			if(tenfo.approvalNotes != null && tenfo.approvalNotes.length > 0)
////			{
////				for(var j:Number = 0; j < tenfo.approvalNotes.length; j++)
////				{
////					connect.request.approvalNoteIds += tenfo.approvalNotes.getItemAt(j).id;
////					
////					if(j < tenfo.approvalNotes.length - 1)
////					{
////						connect.request.approvalNoteIds += ",";
////					}
////				}
////			}
//			
//			// send it!
//			connect.send();
//		}
		
//		/**
//		 * Deletes a tenfo from the database.  This is irreversible.
//		 */
//		public static function deleteTeNfo(tenfo:TeNfo):void
//		{
//			// prepare the service for connection
//			var connect:HTTPService = new HTTPService();
//			connect.url = "http://ten.mcgilleus.ca/actions/DeleteTeNfo.php";
//			connect.resultFormat = "e4x";
//			connect.method = "POST";
//			connect.useProxy = false;
//			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteTeNfoResult);
//			connect.addEventListener(FaultEvent.FAULT, handleFault);
//			
//			// set it up with our request
//			connect.request.id = tenfo.id;
//			
//			// send it!
//			connect.send();
//		}
//		
//		/**
//		 * Handles the result of a save or delete user command.
//		 */
//		private static function handleSaveDeleteTeNfoResult(event:ResultEvent):void
//		{
//			// refresh the users in our singleton
//			TeNfo.getTeNfos();
//		}
		
		/**
		 * @private
		 * Handles the faults of database connection failures.
		 */
		private static function handleFault(event:FaultEvent):void {
			// record it
			trace("[DATA ERROR] " + event.fault.faultString);
			
			// retry later
			var waitTimer:Timer = new Timer(300000, 1);
			waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, getMyClientsTeNfos);
			waitTimer.start();
			
			// add doubling retry timer here
		}
	}
}