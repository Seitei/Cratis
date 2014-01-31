package
{
	
	import flash.utils.getTimer;
	
	import game.Assets;
	import game.Game;
	
	import netcode.NetConnect;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.Color;
	
	public class Main extends Sprite
	{
		
		private var _game:Game
		private var _player:Player;
		private static var _instance:Main;
		private var _assetManager:AssetManager;
		
		public function Main()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			_player = new Player();
			
			_instance = this;
		}
		
		private function onAdded(e:Event):void {
			
			//teh game assets
			_assetManager = new AssetManager();
			_assetManager.enqueue(Assets.stringAssets);
			_assetManager.loadQueue(onProgress);
	
		}
		
		private function onProgress(ratio:Number):void {
			
			if(ratio == 1)
				initGame();
			
		}
		
		private function initGame():void {
		
			//teh game
			_game = new Game(_player, _assetManager);
			addChild(_game);
			
		}
		
		
		public static function getInstance():Main {
			return _instance;
		}
		
		
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}