package
{
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;
	import starling.utils.AssetManager;

	public class Turns extends EventDispatcher
	{
		
		private var _currentState:int;
		private var _state:String;
		private var _states:Dictionary;
		private var _stateName:String;
		private var _stateNames:Array;
		private var _enemyTurnEnded:Boolean;
		private var _myTurnEnded:Boolean;
		
		public function Turns() 
		{
			_states = new Dictionary();
			_stateNames = new Array();
		}
		
		public function onEnemyTurnEnd(data:Object = null):void {
			
			_enemyTurnEnded = true;
			
			for (var key:String in data.data){
			
				_states[_state]["receive"][key] = data.data[key];

			}
			
			if(_myTurnEnded)
				start();
				
				
		}
		
		//TODO
		//for the moment we only need 0 and 1 lifespan types, more complex games could require more options
		public function createState(stateName:String, start:Object, end:Object, send:Object, receive:Object, lifeSpan:int):void {
			
			_states[stateName] = new Dictionary();
			
			_states[stateName]["start"] = start;
			_states[stateName]["end"] = end;
			_states[stateName]["life_span"] = lifeSpan;
			_states[stateName]["send"] = send;
			_states[stateName]["receive"] = receive;
			
			_stateNames.push(stateName);

			if(!_state) _state = stateName;
			
		}
									
		private function advanceState():void {
			
			_currentState ++;
			_state = _stateNames[_currentState]; 
			
		}
		
		
		public function start():void {
			
			_myTurnEnded = false;
			_enemyTurnEnded = false;
			executeTurn("start");
		}
		
		public function end():void {
			
			executeTurn("end");
			
			dispatchEventWith("sendData", false, _states[_state]["send"]);
			
			if(_states[_state]["life_span"] == 1)
				advanceState();
			
			if(_enemyTurnEnded)
				start();
			
			_myTurnEnded = true;
			
			
			
		}
		
		
		private function executeTurn(phase:String):void {
		
			for (var type:String in _states[_state][phase]){
				
				var action:Object = _states[_state][phase];
				
				if(type == "var_property")
					action.var_property[0][action.var_property[1]] = action.var_property[2];

				if(type == "method"){
					var meParams:Array = action[type].slice(1);				
					action.method[0].apply(null, meParams);
				}
				
				if(type == "var_method"){
					var vmParams:Array = action[type].slice(2);
					action.var_method[0][action.var_method[1]].apply(null, vmParams);
				}
			}
			
		}
		
			
		 
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}