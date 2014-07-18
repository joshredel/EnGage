package org.ten {
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class PulseSpace {
		/**
		 * The name of this space.
		 */
		public var spaceName:String;
		
		/**
		 * The unique ID Pulse uses to identify this space on their servers.
		 */
		private var spaceId:uint;
		
		/**
		 * The weekly energy data for this location.
		 */
		public var weeklyEnergyData:ArrayCollection;
		
		/**
		 * The energy point for this space.
		 */
		public var energyPoint:EnergyPoint = new EnergyPoint();
		
		/**
		 * Generates a request for the actual average power for the past hour.
		 */
		public function get actualCurrentPowerRequest():URLRequest {
			var requestString:String = "https://api.pulseenergy.com/pulse/1/spaces/" + spaceId + "/data.json?key=" + DataShop.instance.apiKey + "&resource=Electricity&interval=hour&quantity=AveragePower&qualifier=Actual";
			return new URLRequest(requestString);
		}
		
		/**
		 * Geneates a request for the typical average power for the past hour.
		 */
		public function get typicalCurrentPowerRequest():URLRequest {
			var requestString:String = "https://api.pulseenergy.com/pulse/1/spaces/" + spaceId + "/data.json?key=" + DataShop.instance.apiKey + "&resource=Electricity&interval=hour&quantity=AveragePower&qualifier=Typical";
			return new URLRequest(requestString);
		}
		
		/**
		 * Generates a request for the actual average power for the past week.
		 */
		public function get actualWeekPowerRequest():URLRequest {
			var requestString:String = "https://api.pulseenergy.com/pulse/1/spaces/" + spaceId + "/data.json?key=" + DataShop.instance.apiKey + "&resource=Electricity&interval=week&quantity=AveragePower&qualifier=Actual";
			return new URLRequest(requestString);
		}
		
		/**
		 * Generates a request for teh typical average power for the past week.
		 */
		public function get typicalWeekPowerRequest():URLRequest {
			var requestString:String = "https://api.pulseenergy.com/pulse/1/spaces/" + spaceId + "/data.json?key=" + DataShop.instance.apiKey + "&resource=Electricity&interval=week&quantity=AveragePower&qualifier=Typical";
			return new URLRequest(requestString);
		}
		
		public function PulseSpace(name:String, id:uint){
			spaceName = name;
			spaceId = id;
		}
	}
}