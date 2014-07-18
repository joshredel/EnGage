package org.ten.classes
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.ten.utils.PHPUtil;
	
	
	[Bindable]
	public class User
	{
		/**
		 * Our instance variables
		 */
		public var id:int;
		public var username:String;
		public var password:String;
		public var type:String;
		public var isAdministrator:Boolean;
		public var requiresApproval:Boolean;
		public var canTakeOver:Boolean;
		public var canChooseDurationTime:Boolean;
		public var privateGroupNumber:int;
		public var slideSPOTs:ArrayCollection;
		public var slides:ArrayCollection;
		public var tenfos:ArrayCollection;
		
		/**
		 * Constants for type.
		 */
		public static const TYPE_PERSON:String = "Person";
		public static const TYPE_GROUP:String = "Group";
		public static const TYPES:ArrayCollection = new ArrayCollection([TYPE_PERSON, TYPE_GROUP]);
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
		/**
		 * Create a default user.
		 */
		public function User()
		{
			// let's create a standard user
			// id of 0 will mark it as new when adding it to the database
			this.id = 0;
			
			this.username = "";
			this.password = "";
			this.type = TYPE_PERSON;
			this.isAdministrator = false;
			this.requiresApproval = true;
			this.canTakeOver = false;
			this.canChooseDurationTime = false;
			this.slideSPOTs = new ArrayCollection();
			this.slides = new ArrayCollection();
			this.tenfos = new ArrayCollection();
		}
		
		/**
		 * Searches for a slide in the SlideSPOT collection
		 * with a matching id
		 * 
		 * @param spotId the ID of the SlideSPOT we are looking for
		 * @return the match if found, null otherwise
		 */
		public function getSlideSPOTWithID(spotId:uint):SlideSPOT
		{
			for each(var spot:SlideSPOT in this.slideSPOTs)
			{
				if(spot.id == spotId)
				{
					return spot;
				}
			}
			
			// if we get here, nothing was found
			return null;
		}
		
		
		/**
		 * Our static functions
		 */
		
		/**
		 * Clears each user's SlideSPOT collection
		 * so that we can retrieve the fresh version.
		 */
		public static function clearAllUsersSlideSPOTs():void
		{
			for each(var user:User in dataShop.users)
			{
				user.slideSPOTs = new ArrayCollection();
			}
		}
		
		/**
		 * Clears each user's slides collection
		 * so that we can retrieve the fresh version.
		 */
		public static function clearAllUsersSlides():void
		{
			for each(var user:User in dataShop.users)
			{
				user.slides = new ArrayCollection();
			}
		}
		
		/**
		 * Clears each user's TeNfo collection
		 * so that we can retrieve the fresh version.
		 */
		public static function clearAllUsersTeNfos():void
		{
			for each(var user:User in dataShop.users)
			{
				user.tenfos = new ArrayCollection();
			}
		}
		
		/**
		 * Returns the user based on the passed ID.
		 * 
		 * @param userId the ID of the desired user.
		 * @return the user with the matching ID, null if nothing found
		 */
		public static function getUserWithID(userId:uint):User
		{
			for each(var user:User in dataShop.users)
			{
				if(user.id == userId)
				{
					return user;
				}
			}
			
			// if we get here, nothing was found!
			return null;
		}
		
		/**
		 * Attempt to login to the server.  The static
		 * variables of this class will be set appropriately
		 * if a user is successfully logged in.
		 * @param username the username to connect with
		 * @param password the password, pre-hashed, to send
		 */
		public static function attemptLogin(username:String, password:String):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/AttemptLogin.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleLoginResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.username = username;
			connect.request.password = password;
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the result of the login attempt
		 */
		private static function handleLoginResult(event:ResultEvent):void
		{
			var users:XMLList = event.result.user;
			var returnedUser:User = new User();
			returnedUser.id = users[0].id;
			
			if(returnedUser.id == -1)
			{
				dataShop.userLoggedIn = false;
				dataShop.currentUser = null;
				dataShop.userLoginFailed = true;
			}
			else
			{
				returnedUser.username = users[0].username;
				returnedUser.password = users[0].password;
				returnedUser.type = users[0].type;
				returnedUser.isAdministrator = PHPUtil.intToBool(users[0].isAdministrator);
				returnedUser.requiresApproval = PHPUtil.intToBool(users[0].requiresApproval);
				returnedUser.canTakeOver = PHPUtil.intToBool(users[0].canTakeOver);
				returnedUser.canChooseDurationTime = PHPUtil.intToBool(users[0].canChooseDurationTime);
				returnedUser.privateGroupNumber = users[0].privateGroupNumber;
				
				dataShop.currentUser = returnedUser;
				dataShop.userLoggedIn = true;
				
				User.getUsers();
				Client.getClients();
				Slide.getSlides();
				SlideSPOT.getSlideSPOTs();
				TeNfo.getTeNfos();
			}
		}
		
		/**
		 * Logs the user out.  The static variables of the class
		 * will be set to match.  Also, the server side will be notified.
		 */
		public static function logout():void
		{
			// reset static variables
			dataShop.userLoggedIn = false;
			dataShop.userLoginFailed = false;
			dataShop.currentUser = null;
			
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/Logout.php";
			connect.useProxy = false;
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * Checks to see if a session exists on the PHP backend.
		 * If it does, the user stored will be loaded.
		 */
		public static function checkForSession():void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/CheckForSession.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSessionResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the result of the search for a session.
		 */
		private static function handleSessionResult(event:ResultEvent):void
		{
			var users:XMLList = event.result.user;
			var returnedUser:User = new User();
			returnedUser.id = users[0].id;
			
			if(returnedUser.id == -1)
			{
				dataShop.userLoggedIn = false;
				dataShop.currentUser = null;
			}
			else
			{
				returnedUser.username = users[0].username;
				returnedUser.password = users[0].password;
				returnedUser.type = users[0].type;
				returnedUser.isAdministrator = PHPUtil.intToBool(users[0].isAdministrator);
				returnedUser.requiresApproval = PHPUtil.intToBool(users[0].requiresApproval);
				returnedUser.canTakeOver = PHPUtil.intToBool(users[0].canTakeOver);
				returnedUser.canChooseDurationTime = PHPUtil.intToBool(users[0].canChooseDurationTime);
				returnedUser.privateGroupNumber = users[0].privateGroupNumber;
				
				dataShop.currentUser = returnedUser;
				dataShop.userLoggedIn = true;
				
				User.getUsers();
				Client.getClients();
				Slide.getSlides();
				SlideSPOT.getSlideSPOTs();
				TeNfo.getTeNfos();
			}
		}
		
		/**
		 * Gets all users stored in the system.
		 */
		public static function getUsers():void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/GetUsers.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleGetUsersResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the result of a get all users command.
		 */
		private static function handleGetUsersResult(event:ResultEvent):void
		{
			var users:XMLList = event.result.user;
			var newUsers:ArrayCollection = new ArrayCollection();
			
			// loop through all returned users
			for(var i:Number = 0; i < users.length(); i++)
			{
				// create the data from the XML
				var newUser:User = new User();
				newUser.id = users[i].id;
				newUser.username = users[i].username;
				newUser.password = users[i].password;
				newUser.type = users[i].type;
				newUser.isAdministrator = PHPUtil.intToBool(users[i].isAdministrator);
				newUser.requiresApproval = PHPUtil.intToBool(users[i].requiresApproval);
				newUser.canTakeOver = PHPUtil.intToBool(users[i].canTakeOver);
				newUser.canChooseDurationTime = PHPUtil.intToBool(users[i].canChooseDurationTime);
				newUser.privateGroupNumber = users[0].privateGroupNumber;
				
				// add it to our collection
				newUsers.addItem(newUser);
			}
			
			// store the reference to our users!
			dataShop.users = newUsers;
			
			// get slides!
			Slide.getSlides();
			
			// now request SlideSPOTs
			SlideSPOT.getSlideSPOTs();
			
			// get TeNfos
			TeNfo.getTeNfos();
		}
		
		/**
		 * Creates or saves a user (an ID of 0 will create a new one)
		 */
		public static function saveUser(user:User):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/SaveUser.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteUserResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = user.id;
			connect.request.username = user.username;
			connect.request.password = user.password;
			connect.request.type = user.type;
			connect.request.isAdministrator = user.isAdministrator;
			connect.request.requiresApproval = user.requiresApproval;
			connect.request.canTakeOver = user.canTakeOver;
			connect.request.canChooseDurationTime = user.canChooseDurationTime;
			
			// send it!
			connect.send();
		}
		
		/**
		 * Deletes a user from the database.  This is irreversible.
		 */
		public static function deleteUser(user:User):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/DeleteUser.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteUserResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = user.id;
			
			// send it!
			connect.send();
		}
		
		/**
		 * Handles the result of a save or delete user command.
		 */
		private static function handleSaveDeleteUserResult(event:ResultEvent):void
		{
			// refresh the users in our singleton
			User.getUsers();
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