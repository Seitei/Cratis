package ships
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import ships.Ship;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.AssetManager;
	
	public class ShipFactory
	{
		private static var _instance:ShipFactory;
		
		private var _assetManager:AssetManager;
		private var _counter:int = 0;
		private var _playerName:String;
		private var _stats:Dictionary;
		
		public function ShipFactory():void
		{
			_stats = new Dictionary();
			
			_stats["carrier"]    = [4, 5, 2];
			_stats["battleship"] = [4, 4, 3];
			_stats["destroyer"]  = [3, 3, 1];
			_stats["patrol"]     = [2, 2, 0];
			_stats["submarine"]  = [2, 3, 1];
			_stats["cruiser"]    = [2, 3, 1];
				
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
			
			ship = new Ship(shipName, _stats[shipName][0], _stats[shipName][1], _stats[shipName][2], null, 
				new Image(_assetManager.getTexture(shipName + "_side_black")),
				new Image(_assetManager.getTexture(shipName + "_top")),
				new Image(_assetManager.getTexture(shipName + "_fleet")),
				state);
				
			ship.position = position;
			
			return ship;	
		}
		
		public static function getInstance():ShipFactory {
			if(!_instance)
				_instance = new ShipFactory();
			return _instance;
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}