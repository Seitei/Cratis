package entities
{
	import flash.utils.Dictionary;
	
	import starling.events.EventDispatcher;

	public class Turns extends EventDispatcher
	{
		
		private var _currentState:int;
		private var _state:String;
		private var _states:Dictionary;
		private var _stateNames:Array;
		private var _enemyTurnEnded:Boolean;
		private var _myTurnEnded:Boolean;
		private var _phaseChangeMessageShown:Boolean;

		public function Turns()
		{
       		_states = new Dictionary();
			_stateNames = new Array();
		}
		
		public function onEnemyTurnEnd(data:Object = null):void {
			
			_enemyTurnEnded = true;
			
			_states[_state]["receive"](data.data);
			
			if(_myTurnEnded)
				result();

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
			
			if(_states[_state]["life_span"] == 1){
				_phaseChangeMessageShown = false;
				advanceState();
			}
				
		}
		
		public function end():void {
			
			executeTurn("end");
			_myTurnEnded = true;
			
			dispatchEventWith("sendData", false, _states[_state]["send"]);
			
			if(_enemyTurnEnded)
				result();
			
		}
		
		
		private function executeTurn(phase:String):void {
		
			for (var type:String in _states[_state][phase]){
				
				var action:Object = _states[_state][phase];
				
				if(type.indexOf("var_property") != -1)
					action[type][0][action[type][1]] = action[type][2];

				if(type.indexOf("method") != -1 && type.indexOf("var_method") == -1){
					var meParams:Array = action[type].slice(1);				
					action[type][0].apply(null, meParams);
				}
				
				if(type.indexOf("var_method") != -1){
					var vmParams:Array = action[type].slice(2);
					action[type][0][action[type][1]].apply(null, vmParams);
				}
				
			}
			
			if(_states[_state]["phaseChangeMessage"] && phase == "start" && _phaseChangeMessageShown == false){
				_states[_state]["phaseChangeMessage"].showMessage(_states[_state]["phaseChangeMessage"].phrase);
				_phaseChangeMessageShown = true;				
			}
			
			
		}
		
			
		 
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}