package
{
	
	import game.Assets;
	import game.BattleShip;

    import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;

	public class Main extends Sprite
	{
		
		private var _player:Player;
		private static var _instance:Main;
		private var _assetManager:AssetManager;
        private var _game:BattleShip;

        private function onAdded(e:Event):void {

            //the game assets
            _assetManager = new AssetManager();
            _assetManager.enqueue(Assets.stringAssets);
            _assetManager.loadQueue(onProgress);


        }
        public function Main()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);

			_player = new Player();
			_instance = this;

		}

		private function onProgress(ratio:Number):void {

            if(ratio == 1){

                initGame();

            }

        }

		private function initGame():void {

            //teh game
           _game = new BattleShip(_player, _assetManager);

            addChild(_game);
        }

		public static function getInstance():Main {

            if(!_instance)
                _instance = new Main();

            return _instance;

        }

        public function get assetManager():AssetManager {
            return _assetManager;
        }
    }
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}