package org.ten.classes
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public final class DataShop
	{
		/**
		 * Our singleton functionality.
		 */
		
		/**
		 * @private
		 * The private refernce to the single instance of the data shop.
		 */
		private static var instance:DataShop;
		
		/**
		 * Returns a reference to our singleton instance or
		 * creates the instance if necessary.
		 */
		public static function getInstance():DataShop
		{
			if(instance == null)
			{
				instance = new DataShop(new SingletonEnforcer());
			}
			
			return instance;
		}
		
		public function DataShop(access:SingletonEnforcer)
		{
			if(access == null)
			{
				throw new Error("Singleton enforcement failed.");
			}
			
			instance = this;
		}
		
		/**
		 * All of the approval notes from the server.
		 */
		public var approvalNotes:ArrayCollection = new ArrayCollection();
		
		/**
		 * Whether or not a client is logged in.
		 */
		public var clientLoggedIn:Boolean = false;
		
		/**
		 * The client currently logged in.
		 */
		public var currentClient:Client = null;
		
		/**
		 * A status marker if the client login failed.
		 */
		public var clientLoginFailed:Boolean = false;
		
		/**
		 * All of the clients from the server.
		 */
		public var clients:ArrayCollection = new ArrayCollection();
		
		/**
		 * All of the slides from the server.
		 */
		public var slides:ArrayCollection = new ArrayCollection();
		
		/**
		 * All of the slides belonging to the current user.
		 */
		public var mySlides:ArrayCollection = new ArrayCollection();
		
		/**
		 * All of the SlideSPOTs from the server.
		 */
		public var slideSPOTs:ArrayCollection = new ArrayCollection();
		
		/**
		 * All of the SlideSPOTs belonging to the current user.
		 */
		public var mySlideSPOTs:ArrayCollection = new ArrayCollection();
		
		/**
		 * All of the TeNfos from the server.
		 */
		public var tenfos:ArrayCollection = new ArrayCollection();
		
		/**
		 * All of the TeNfos belonging to the current user.
		 */
		public var myTeNfos:ArrayCollection = new ArrayCollection();
		
		/**
		 * The number of empty SlideSPOTs the current user has left to use.
		 */
		public var availableSlideSPOTs:uint = 0;
		
		/**
		 * Whether or not a user is logged in.
		 */
		public var userLoggedIn:Boolean = false;
		
		/**
		 * The user currently logged in.
		 */
		public var currentUser:User = null;
		
		/**
		 * A status marker if the user login failed.
		 */
		public var userLoginFailed:Boolean = false;
		
		/**
		 * All of the users from the server.
		 */
		public var users:ArrayCollection = new ArrayCollection();
	}
}

class SingletonEnforcer {}