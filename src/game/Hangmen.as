package game
{
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.utils.AssetManager;
	
	public class Hangmen extends Sprite
	{
		private var _player:Player;
		private var _assetManager:AssetManager;
		
		public function Hangmen(player:Player, assetManager:AssetManager)
		{
			
			_player = player;
			_assetManager = assetManager;
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			
			
		}
		
		private function onAdded(e:Event):void {
			
			
			
			
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}