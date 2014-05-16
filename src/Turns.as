package
{
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;
	import starling.utils.AssetManager;
	
	import utils.Utils;

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
				result();
			
			//Utils.showMap(data.data.map);
				
		}
		
		//TODO
		//for the moment we only need 0 and 1 lifespan types, more complex games could require more options
		public function createState(stateName:String, start:Object, end:Object, result:Object, send:Object, receive:Object, lifeSpan:int, phaseChangeMessage:Object = null):void {
			
			_states[stateName] = new Dictionary();
			
			_states[stateName]["start"] = start;
			_states[stateName]["end"] = end;
			_states[stateName]["result"] = result;
			_states[stateName]["life_span"] = lifeSpan;
			_states[stateName]["send"] = send;
			_states[stateName]["receive"] = receive;
			_states[stateName]["phaseChangeMessage"] = phaseChangeMessage;
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
		
		public function result():void {
			
			_myTurnEnded = false;
			_enemyTurnEnded = false;
			executeTurn("result");
			
			
		}
		
		public function end():void {
			
			executeTurn("end");
			
			dispatchEventWith("sendData", false, _states[_state]["send"]);
			
			if(_enemyTurnEnded)
				result();
			
			if(_states[_state]["life_span"] == 1)
				advanceState();
			
			_myTurnEnded = true;
			
			
			
		}
		
		
		private function executeTurn(phase:String):void {
		
			for (var type:String in _states[_state][phase]){
				
				var action:Object = _states[_state][phase];
				
				if(type.indexOf("var_property") != -1)
					action[type][0][action[type][1]] = action[type][2];

				if(type.indexOf("method") != -1 && type.indexOf("var_method") == -1){
					var meParams:Array = action[type].slice(1);				
					action.method[0].apply(null, meParams);
				}
				
				if(type.indexOf("var_method") != -1){
					var vmParams:Array = action[type].slice(2);
					action.var_method[0][action.var_method[1]].apply(null, vmParams);
				}
				
			}
			
			if(_states[_state]["phaseChangeMessage"] && phase == "start")
				_states[_state]["phaseChangeMessage"].showMessage(_states[_state]["phaseChangeMessage"].phrase);
			
		}
		
			
		 
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}