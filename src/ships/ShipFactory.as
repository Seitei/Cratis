package ships
{
	import flash.utils.Dictionary;
	
	import ships.Ship;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.AssetManager;
	
	public class ShipFactory
	{
		private static var _instance:ShipFactory;
		
		private var _assetManager:AssetManager;
		private var _playerName:String;
		private var _stats:Dictionary;
		private var _shipCounter:int;
		
		public function ShipFactory():void
		{
			_stats = new Dictionary();
			
			_stats["carrier"]    = [6, 5, 3];
			_stats["battleship"] = [4, 4, 2];
			_stats["destroyer"]  = [4, 3, 3];
			_stats["patrol"]     = [1, 2, 0];
			_stats["submarine"]  = [2, 3, 1];
			_stats["cruiser"]    = [3, 3, 2];
				
		}
		
		public function set assetManager(assetManager:AssetManager):void {
			
			_assetManager = assetManager;
		}
		
		public function get playerName():String
		{
			return _playerName;
		}
		
		public function set playerName(value:String):void
		{
			_playerName = value;
		}
		
		public function buildShip(shipName:String, state:String, position:Array = null):Ship {
			
			var ship:Ship;
			
			ship = new Ship(shipName, _stats[shipName][0], _stats[shipName][1], _stats[shipName][2],
                            new Image(_assetManager.getTexture(shipName)),
                            new Image(_assetManager.getTexture(shipName + "_roster")),
                            new Image(_assetManager.getTexture(shipName + "_highlight")),  state);
				
			if(position) ship.position = position;
			
			//auto id
			ship.id = shipName + _shipCounter.toString();
			
			_shipCounter ++;
			return ship;	
		}
		
		public static function getInstance():ShipFactory {
			if(!_instance)
				_instance = new ShipFactory();
			return _instance;
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}