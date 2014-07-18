package org.ten.classes
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Bindable]
	public class Client
	{
		/**
		 * Our instance variables
		 */
		public var id:int;
		public var clientname:String;
		public var password:String;
		public var location:String;
		public var nativeScreenWidth:uint;
		public var nativeScreenHeight:uint;
		
		/**
		 * A static reference to the data shop holding all information
		 */
		private static var dataShop:DataShop = DataShop.getInstance();
		
		public function Client()
		{
			// let's create a standard client
			// id of 0 will mark it as new when adding it to the database
			this.id = 0;
			
			this.clientname = "";
			this.password = "";
			this.location = "";
			
			// in this release, the screen's will all be the LG 42" with
			// a native resolution of 1360x768
			this.nativeScreenWidth = 1360;
			this.nativeScreenHeight = 768;
		}
		
		/**
		 * Returns the client based on the passed ID.
		 * 
		 * @param clientId the ID of the desired client.
		 * @return the client with the matching ID, null if nothing found
		 */
		public static function getClientWithID(clientId:uint):Client
		{
			for each(var client:Client in dataShop.clients)
			{
				if(client.id == clientId)
				{
					return client;
				}
			}
			
			// if we get here, nothing was found!
			return null;
		}
		
		/**
		 * Attempt to login to the server.  The static
		 * variables of this class will be set appropriately
		 * if a client is successfully logged in.
		 * @param clientname the clientname to connect with
		 * @param password the password, pre-hashed, to send
		 */
		public static function attemptLogin(clientname:String, password:String):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/AttemptClientLogin.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleLoginResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.clientname = clientname;
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
			var clients:XMLList = event.result.client;
			var returnedClient:Client = new Client();
			returnedClient.id = clients[0].id;
			
			if(returnedClient.id == -1)
			{
				dataShop.currentClient = null;
				dataShop.clientLoggedIn = false;
				dataShop.clientLoginFailed = true;
			}
			else
			{
				returnedClient.clientname = clients[0].clientname;
				returnedClient.password = clients[0].password;
				returnedClient.location = clients[0].location;
				returnedClient.nativeScreenWidth = clients[0].nativeScreenWidth;
				returnedClient.nativeScreenHeight = clients[0].nativeScreenHeight;
				
				dataShop.currentClient = returnedClient;
				dataShop.clientLoggedIn = true;
			}
		}
		
		/**
		 * Logs the client out.  The static variables of the class
		 * will be set to match.  Also, the server side will be notified.
		 */
		public static function logout():void
		{
			// reset static variables
			dataShop.clientLoggedIn = false;
			dataShop.clientLoginFailed = false;
			dataShop.currentClient = null;
			
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/ClientLogout.php";
			connect.useProxy = false;
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * Gets all clients stored in the system.
		 */
		public static function getClients():void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/GetClients.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleGetClientsResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// send it!
			connect.send();
		}
		
		/**
		 * @private
		 * Handles the result of a get all clients command.
		 */
		private static function handleGetClientsResult(event:ResultEvent):void
		{
			var clients:XMLList = event.result.client;
			var newClients:ArrayCollection = new ArrayCollection();
			
			// loop through all returned clients
			for(var i:Number = 0; i < clients.length(); i++)
			{
				// create the data from the XML
				var newClient:Client = new Client();
				newClient.id = clients[i].id;
				newClient.clientname = clients[i].clientname;
				newClient.password = clients[i].password;
				newClient.location = clients[i].location;
				newClient.nativeScreenWidth = clients[i].nativeScreenWidth;
				newClient.nativeScreenHeight = clients[i].nativeScreenHeight;
				
				// add it to our collection
				newClients.addItem(newClient);
			}
			
			// store the reference to our clients!
			dataShop.clients = newClients;
		}
		
		/**
		 * Creates or saves a client (an ID of 0 will create a new one)
		 */
		public static function saveClient(client:Client):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/SaveClient.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteClientResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = client.id;
			connect.request.clientname = client.clientname;
			connect.request.password = client.password;
			connect.request.location = client.location;
			connect.request.nativeScreenWidth = client.nativeScreenWidth;
			connect.request.nativeScreenHeight = client.nativeScreenHeight;
			
			// send it!
			connect.send();
		}
		
		/**
		 * Deletes a client from the database.  This is irreversible.
		 */
		public static function deleteClient(client:Client):void
		{
			// prepare the service for connection
			var connect:HTTPService = new HTTPService();
			connect.url = "http://ten.mcgilleus.ca/actions/DeleteClient.php";
			connect.resultFormat = "e4x";
			connect.method = "POST";
			connect.useProxy = false;
			connect.addEventListener(ResultEvent.RESULT, handleSaveDeleteClientResult);
			connect.addEventListener(FaultEvent.FAULT, handleFault);
			
			// set it up with our request
			connect.request.id = client.id;
			
			// send it!
			connect.send();
		}
		
		/**
		 * Handles the result of a save or delete client command.
		 */
		private static function handleSaveDeleteClientResult(event:ResultEvent):void
		{
			// refresh the clients in our singleton
			Client.getClients();
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