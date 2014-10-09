package {
import game.*;

	import game.Turns;
	import netcode.NetConnect;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;

	public class Player extends EventDispatcher
	{
		private var _net:NetConnect;
		private var _turn:Turns;
		
		public function Player()
		{
			_net = new NetConnect();
			_net.addEventListener("notifyEvent", onNotify);
		}
		
		public function get turn():Turns
		{
			return _turn;
		}

		public function set turn(value:Turns):void
		{
			_turn = value;
			_turn.addEventListener("sendData", onSendData);
		}

		private function onSendData(e:Event):void {
			
			_net.sendMessage(e.data);
			
		}
		
		private function onNotify(e:Event):void {
			
			_turn.onEnemyTurnEnd(e.data);
			
		}
		
		
		
			
		
	}
}