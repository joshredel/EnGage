package org.ten {
	import com.adobe.serialization.json.JSON;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	[Bindable]
	/**
	 * DataShop provides singleton access to all data
	 * and services used throughout the system.
	 */
	public final class DataShop {
		/**************************
		 * Singleton enforcement
		 **************************/
		/**
		 * The reference to the single instance of this class.
		 */
		private static const _instance:DataShop = new DataShop(SingletonEnforcer);
		
		/**
		 * The single instance of this class.
		 * 
		 * @internal
		 * Returns the instance if it has been created, otherwise 
		 * it creates the instance.
		 */
		public static function get instance():DataShop {
			// return the single instance
			return _instance;
		}
		
		/**
		 * Constructor.
		 * Loads all of the classes so they are typeable via AMF.
		 * Prepares all of the services.
		 */
		public function DataShop(access:Class) {
			// require the passing of a SingletonEnforcer
			// because no outside class can use it, so only here 
			// can an instance be created and we can manage it
			if(access != SingletonEnforcer) {
				throw new Error("Singleton enforcement failed.  Use DataShop.instance");
			}
			
			// setup our pulse spaces
			_mcConnellSpace = new PulseSpace("McConnell", 1411);
			_gardnerSpace = new PulseSpace("Gardner", 635);
			_molsonSpace = new PulseSpace("Molson", 633);
		}
		
		/***************
		 * Properties
		 ***************/
		private var actualEnergyData:Object;
		
		private var typicalEnergyData:Object;
		
		private var energyTimer:Timer;
		
		public var clientId:int;
		
		/**
		 * All of the TeNfos from the server.
		 */
		public var tenfos:ArrayCollection = new ArrayCollection();
		
		/**
		* All of the TeNfos belonging to the current user.
		*/
		public var myTeNfos:ArrayCollection = new ArrayCollection();
		
		/**
		 * The different spaces in this residence cluster.
		 */
		private var _mcConnellSpace:PulseSpace;
		private var _gardnerSpace:PulseSpace;
		private var _molsonSpace:PulseSpace;
		
		public function get mcConnellSpace():PulseSpace {
			return _mcConnellSpace;
		}
		
		public function get gardnerSpace():PulseSpace {
			return _gardnerSpace;
		}
		
		public function get molsonSpace():PulseSpace {
			return _molsonSpace;
		}
		
		/**
		 * The main space for this display.
		 */
		private var _mainSpace:PulseSpace;
		
		public function set mainSpace(space:PulseSpace):void {
			// store the main space
			_mainSpace = space;
			
			// set the two competitor spaces
			if (space == _mcConnellSpace) {
				_competitorSpace1 = _gardnerSpace;
				_competitorSpace2 = _molsonSpace;
			} else if (space == _gardnerSpace) {
				_competitorSpace1 = _mcConnellSpace;
				_competitorSpace2 = _molsonSpace;
			} else if (space == _molsonSpace) {
				_competitorSpace1 = _mcConnellSpace;
				_competitorSpace2 = _gardnerSpace;
			}
			
			// set the energy timer in motion
			resetEnergyTimer();
		}
		
		public function get mainSpace():PulseSpace {
			return _mainSpace;
		}
		
		/**
		 * The competitor spaces.
		 */
		private var _competitorSpace1:PulseSpace;
		private var _competitorSpace2:PulseSpace;
		
		public function get competitorSpace1():PulseSpace {
			return _competitorSpace1;
		}
		
		public function get competitorSpace2():PulseSpace {
			return _competitorSpace2;
		}
		
		/**
		 * The Pulse API key for this client.
		 */
		public var apiKey:String;
		
		public var configLoaded:Boolean = false;
		
		/*********************
		 * Helper functions
		 *********************/
		private function resetEnergyTimer(event:Event = null):void {
			if(!configLoaded) {
				trace("[CONFIG] Racing to start energy timer; waiting one second for config to load.");
				var waitTimer:Timer = new Timer(1000, 1);
				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
				waitTimer.start();
				return;
			}
			
			// set the energy time in motion
			if(energyTimer) {
				energyTimer.stop();
			}
			energyTimer = new Timer(600000);
			energyTimer.addEventListener(TimerEvent.TIMER, refreshEnergy);
			energyTimer.start();
			refreshEnergy();
		}
		
		private function refreshEnergy(event:Event = null):void {
			// start the call chain
			getPulseData(_mainSpace.actualCurrentPowerRequest, populateActualMainData);
		}
		
		/**
		 * Call the Pulse API with the requested command and setup a callback handler to load the data.
		 */
		private function getPulseData(request:URLRequest, callbackFunction:Function):void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, callbackFunction);
			loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, handleStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleNoConnection);
			loader.load(request);
		}
		
		private function populateActualMainData(event:Event):void {
			try {
				// get the data from the API call
				var jsonContent:URLLoader = URLLoader(event.target);
				var temp:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data); 
				_mainSpace.energyPoint.actual = temp.average;
				
				// call the next request in the chain
				getPulseData(_mainSpace.typicalCurrentPowerRequest, populateTypicalMainData);
			} catch(error:Error) {
				trace("[ERROR] Most likely ran over the API max call count... trying again in 10 minutes");
//				var waitTimer:Timer = new Timer(1000, 1);
//				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
//				waitTimer.start();
			}
		}
		
		private function populateTypicalMainData(event:Event):void {
			try {
				// get the data from the API call
				var jsonContent:URLLoader = URLLoader(event.target);
				var temp:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data); 
				_mainSpace.energyPoint.typical = temp.average;
				
				// call the next request in the chain
				getPulseData(_competitorSpace1.actualCurrentPowerRequest, populateActualCompetitor1Data);
			} catch(error:Error) {
				trace("[ERROR] Most likely ran over the API max call count... trying again in 10 minutes");
//				var waitTimer:Timer = new Timer(1000, 1);
//				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
//				waitTimer.start();
			}
		}
		
		private function populateActualCompetitor1Data(event:Event):void {
			try {
				// get the data from the API call
				var jsonContent:URLLoader = URLLoader(event.target);
				var temp:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data);
				_competitorSpace1.energyPoint.actual = temp.average;
				
				// call the next request in the chain
				getPulseData(_competitorSpace1.typicalCurrentPowerRequest, populateTypicalCompetitor1Data);
			} catch(error:Error) {
				trace("[ERROR] Most likely ran over the API max call count... trying again in 10 minutes");
//				var waitTimer:Timer = new Timer(1000, 1);
//				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
//				waitTimer.start();
			}
		}
		
		private function populateTypicalCompetitor1Data(event:Event):void {
			try {
				// get the data from the API call
				var jsonContent:URLLoader = URLLoader(event.target);
				var temp:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data); 
				_competitorSpace1.energyPoint.typical = temp.average;
				
				// call the next request in the chain
				getPulseData(_competitorSpace2.actualCurrentPowerRequest, populateActualCompetitor2Data);
			} catch(error:Error) {
				trace("[ERROR] Most likely ran over the API max call count... trying again in 10 minutes");
//				var waitTimer:Timer = new Timer(1000, 1);
//				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
//				waitTimer.start();
			}
		}
		
		private function populateActualCompetitor2Data(event:Event):void {
			try {
				// get the data from the API call
				var jsonContent:URLLoader = URLLoader(event.target);
				var temp:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data); 
				_competitorSpace2.energyPoint.actual = temp.average;
				
				// call the next request in the chain
				getPulseData(_competitorSpace2.typicalCurrentPowerRequest, populateTypicalCompetitor2Data);
			} catch(error:Error) {
				trace("[ERROR] Most likely ran over the API max call count... trying again in 10 minutes");
//				var waitTimer:Timer = new Timer(1000, 1);
//				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
//				waitTimer.start();
			}
		}
		
		private function populateTypicalCompetitor2Data(event:Event):void {
			try {
				// get the data from the API call
				var jsonContent:URLLoader = URLLoader(event.target);
				var temp:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data); 
				_competitorSpace2.energyPoint.typical = temp.average;
				
				// call the next request in the chain
				getPulseData(_mainSpace.actualWeekPowerRequest, prepareWeeklyActualData);
			} catch(error:Error) {
				trace("[ERROR] Most likely ran over the API max call count... trying again in 10 minutes");
//				var waitTimer:Timer = new Timer(1000, 1);
//				waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
//				waitTimer.start();
			}
		}
		
		/**
		 * Collect the actual energy data from the past week and prepare it for view in the chart.
		 */
		private function prepareWeeklyActualData(event:Event):void {
			// get the raw data
			var jsonContent:URLLoader = URLLoader(event.target);
			var rawData:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data);
			
			// start the data fresh
			_mainSpace.weeklyEnergyData = new ArrayCollection();
			
			// loop through and create everything for the first time
			for each(var newPoint:Array in rawData.data) {
				_mainSpace.weeklyEnergyData.addItem({Time: newPoint[0], Actual: newPoint[1]});
			}
			
			// request the typical data
			getPulseData(_mainSpace.typicalWeekPowerRequest, prepareWeeklyTypicalData);
		}
		
		/**
		 * Collect the typical energy data from the past week, and prepare it for view in the chart.
		 */
		private function prepareWeeklyTypicalData(event:Event):void {
			// get the raw data
			var jsonContent:URLLoader = URLLoader(event.target);
			var rawData:Object = com.adobe.serialization.json.JSON.decode(jsonContent.data);
			
			// loop through the existing content and update
			var tempData:ArrayCollection = new ArrayCollection();
			for each(var editPoint:Object in _mainSpace.weeklyEnergyData) {
				// update with the Typical data
				editPoint["Typical"] = rawData.data[_mainSpace.weeklyEnergyData.getItemIndex(editPoint)][1];
				
				// only re-add the point if our data is valid
				if(editPoint["Actual"] != null && editPoint["Actual"] != "" && editPoint["Typical"] != null && editPoint["Typical"] != "") {
					tempData.addItem(editPoint);
				}
			}
			
			// restore the data
			_mainSpace.weeklyEnergyData = tempData;
		}
		
		/**
		 * Handle an HTTP status response from one of the API calls.
		 */
		private function handleStatus(event:Event):void {
			trace("RESPONSE: " + event.toString());	
		}
		
		/**
		 * Handle a no connection/loss of connection error.
		 * Tries a few times to reconnect and then retries every 10 minutes
		 */
		private function handleNoConnection(event:IOErrorEvent):void {
			trace("[NETWORK] Connection lost.  Retrying in 1 minute.");
			
			// stop the energy timer
			if(energyTimer) {
				energyTimer.stop();
			}
			
			// set a timer to try again in 1 minute
			var retryTimer:Timer = new Timer(60000, 1);
			retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE, resetEnergyTimer);
			retryTimer.start();
		}
	}
}

// by using a class here, no outide class can create
// a new DataShop because it is required in the constructor
class SingletonEnforcer {}