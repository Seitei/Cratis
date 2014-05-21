package utils
{
	import flash.display3D.IndexBuffer3D;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Color;

	public class AlphaSprite
	{
		private static var _instance:AlphaSprite;
		private static var THRESHOLD:int = 3;
		private var _displayObjectsDic:Dictionary;
		private var _UIBoxesDic:Dictionary;
		private var _data:XML;
		private var _sharedObject:SharedObject;
		private var _doContainer:DisplayObjectContainer;
		private var _displayObjectsArray:Array;
		private var _verticalGuide:Quad;
		private var _horizontalGuide:Quad;
		private var _thresholdCounterX:int;
		private var _thresholdCounterY:int;
		private var _snappedX:Boolean;
		private var _snappedY:Boolean;
		private var _deltaX:int;
		private var _deltaY:int;
		private var _snapObject:Object;
		private var _shiftTouch:Point;
		private var _selectedDo:DisplayObject;
		private var _displacement:int;
		private var _mode:String;
		private var _movingWithKeyboard:Boolean;
		private var _alphaMode:Boolean = false;
		private var _childrenListeners:Dictionary;
		
		public function AlphaSprite()
		{
			_displayObjectsDic = new Dictionary();
			_displayObjectsArray = new Array();
			_childrenListeners = new Dictionary();
			_data = new XML();
			_sharedObject = SharedObject.getLocal("data");
			_UIBoxesDic = new Dictionary();
		}
		
		private function recurseStage(doc:DisplayObjectContainer):void
		{
			var children:int = doc.numChildren;
			
			for(var i:int = 0; i < children; i++)
			{
				var child:* = doc.getChildAt(i);  
				
				if(child.name){
				
					_displayObjectsDic[child.name] = child;
					_displayObjectsArray.push(child);
					
					//if the object exists in the shared objects, assign properties
					if(_sharedObject.data[child.name]) {
						
						for ( var property:String in _sharedObject.data[child.name]) {
							
							_displayObjectsDic[child.name][property] = _sharedObject.data[child.name][property];
							
						}
					}
				
					if(_mode == "write"){
						
						//removing the listeners so they don't interfere and add AlphaSprite ones.
						_childrenListeners[child.name] = DisplayObject(child).removeEventListeners();
						
						child.addEventListener(TouchEvent.TOUCH, onTouch);
						
					}
				}
				
				if(child is DisplayObjectContainer && child.numChildren > 0){
						
					recurseStage(child);
						
				}
				
			}
		}
		
		private function onTouch(e:TouchEvent):void {
			
			var endedTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.ENDED); 
			var hoverTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.HOVER);
			var beganTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.BEGAN);
			var movedTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.MOVED);
		
			var displayObject:DisplayObject = DisplayObject(e.currentTarget);
			
			if(!_alphaMode && displayObject.name.indexOf("_alpha") != -1)
				return;
			
			if(!_alphaMode)	e.stopImmediatePropagation();
			
			if(_alphaMode && displayObject.name.indexOf("_alpha") == -1) return;
			
			//highlight
			if(hoverTouch){
				
				_UIBoxesDic[displayObject.name].highlight(true);
				
			}
			else if(!hoverTouch) {
				
				_UIBoxesDic[displayObject.name].highlight(false);
				
			}
			
			if(movedTouch){
				
				_deltaX = movedTouch.getMovement(displayObject).x;
				_deltaY = movedTouch.getMovement(displayObject).y;
				
				if(!_snappedX){
					displayObject.x = movedTouch.getLocation(displayObject.parent).x - _shiftTouch.x;
					//_UIBoxesDic[displayObject.name].x = movedTouch.globalX - _shiftTouch.x;
					_UIBoxesDic[displayObject.name].updateUI();
				}
				
				if(!_snappedY){
					displayObject.y = movedTouch.getLocation(displayObject.parent).y - _shiftTouch.y;
					//_UIBoxesDic[displayObject.name].y = movedTouch.globalY - _shiftTouch.y;
					_UIBoxesDic[displayObject.name].updateUI();
				}
				
				snap(checkSnap(displayObject), _deltaX, _deltaY);
				
			}
			
			//select
			if(beganTouch){
				
				_selectedDo = displayObject;
				_shiftTouch = beganTouch.getLocation(displayObject);
				deselectAll();
				e.stopPropagation();
				_UIBoxesDic[_selectedDo.name].select(true);
				
			}
			
			//save new position
			if(endedTouch) {
				
				saveData();
				
			}
		}
		
		private function saveData():void {
			
			_sharedObject.close();	
			_sharedObject.data[_selectedDo.name] = {"x": _selectedDo.x, "y": _selectedDo.y};
			_sharedObject.flush();
		}
		
		private function onFinishedMovingObject(e:KeyboardEvent):void {
		
			if(_movingWithKeyboard){
				
				_selectedDo.x = Math.floor(_selectedDo.x);
				_selectedDo.y = Math.floor(_selectedDo.y);
				
				saveData();
				
			}
			
			_movingWithKeyboard = false;
			
		}
		
		private function showAlpha(e:KeyboardEvent):void {
		
			if(e.keyCode == Keyboard.CONTROL){
				
				_alphaMode = !_alphaMode;
				
				deselectAll();
				
			}
		}
		
		private function onMoveObject(e:KeyboardEvent):void {
			
			_displacement = e.shiftKey ? 5 : 1; 
			//right
			if(e.keyCode == Keyboard.RIGHT){
				
				_selectedDo.x += _displacement;
				_UIBoxesDic[_selectedDo.name].x += _displacement;
				_movingWithKeyboard = true;
			}
			
			//left
			if(e.keyCode == Keyboard.LEFT){
				
				_selectedDo.x -= _displacement;
				_UIBoxesDic[_selectedDo.name].x -= _displacement;
				_movingWithKeyboard = true;
			}
			
			//up
			if(e.keyCode == Keyboard.UP){
				
				_selectedDo.y -= _displacement;
				_UIBoxesDic[_selectedDo.name].y -= _displacement;
				_movingWithKeyboard = true;
			}
			
			//down
			if(e.keyCode == Keyboard.DOWN){
				
				_selectedDo.y += _displacement;
				_UIBoxesDic[_selectedDo.name].y += _displacement;
				_movingWithKeyboard = true;
			}
			
		}
		
		private function drawGuide(data:Object):void {
			
			//vertical axis
			if(data.axisX && _snappedX){
				
				_verticalGuide.x = data.axisX.axisValue;
				_verticalGuide.visible = true;
				
				if(data.selectedDO.y - data.axisX.dObject.y > 0){
					
					_verticalGuide.y = data.axisX.dObject.localToGlobal(new Point()).y;
					_verticalGuide.height = data.selectedDO.y - data.axisX.dObject.y + data.selectedDO.height;    	
						
				}
				else {
					
					_verticalGuide.y = data.selectedDO.localToGlobal(new Point()).y;
					_verticalGuide.height = -(data.selectedDO.y - data.axisX.dObject.y) + data.axisX.dObject.height;
					
				}
			}
			else {
				_verticalGuide.visible = false;
			}
				
			
			//horitonzal axis
			if(data.axisY && _snappedY){
				
				_horizontalGuide.y = data.axisY.axisValue;
				_horizontalGuide.visible = true;
				
				if(data.selectedDO.x - data.axisY.dObject.x > 0){
					
					_horizontalGuide.x = data.axisY.dObject.localToGlobal(new Point()).x;
					_horizontalGuide.width = data.selectedDO.x - data.axisY.dObject.x + data.selectedDO.width;    	
					
				}
				else {
					
					_horizontalGuide.x = data.selectedDO.localToGlobal(new Point()).x;
					_horizontalGuide.width = -(data.selectedDO.x - data.axisY.dObject.x) + data.axisY.dObject.width;
					
				}
			}
			else {
				_horizontalGuide.visible = false;
			}
			
			
		}
		
		private function snap(data:Object, deltaX:int, deltaY:int):void {
			
			if(!data) return;
			
			//left/right/midx
			if(data.axisX){
							
				if(!_snappedX){
					data.selectedDO.x -= data.axisX.deltaValue;
					_snappedX = true;		
				}
				else {
					_thresholdCounterX += deltaX;
				}
				
				if(Math.abs(_thresholdCounterX) >= THRESHOLD * 2){
					
					data.selectedDO.x += _thresholdCounterX / 2;
					
					_thresholdCounterX = 0;					
					_snappedX = false;
					
				}
			}
			
			//top/bottom/midy
			if(data.axisY){
				
				if(!_snappedY){
					data.selectedDO.y -= data.axisY.deltaValue;
					_snappedY = true;					
				}
				else {
					_thresholdCounterY += deltaY;
				}
				
				if(Math.abs(_thresholdCounterY) >= THRESHOLD * 2){
					data.selectedDO.y += _thresholdCounterY / 2;
					_thresholdCounterY = 0;					
					_snappedY = false;
				}
			}
		
			_UIBoxesDic[_selectedDo.name].updateUI();
			
			
			drawGuide(data);
			
		}
		
		
		private function checkSnap(selectedDO:DisplayObject):Object {
			
			var sDORect:Rectangle = selectedDO.getBounds(_doContainer);
			var sDOSides:Array = [[sDORect.left, sDORect.right, sDORect.left + selectedDO.width / 2], 
								  [sDORect.top, sDORect.bottom, sDORect.top + selectedDO.height / 2]];
				
			_snapObject = {"selectedDO": selectedDO};
			
			for(var i:int = 0; i < _displayObjectsArray.length; i++){
				
				var dO:DisplayObject = _displayObjectsArray[i];
				
				if(dO.name == selectedDO.name || selectedDO.parent == dO)
					continue;
				
				//in alpha mode, the container shouldn't check with his own chilren
				if(_alphaMode && DisplayObjectContainer(_selectedDo).contains(dO))
					continue;
				
				var dORect:Rectangle = dO.getBounds(_doContainer);
				var dOSides:Array = [[dORect.left, dORect.right, dORect.left + dO.width / 2],
									 [dORect.top, dORect.bottom, dORect.top + dO.height / 2]];
								
				
				//check x axis
				for(var sDOSidesI:int = 0; sDOSidesI < sDOSides[0].length; sDOSidesI ++){
					
					for(var dOSideI:int = 0; dOSideI < dOSides[0].length; dOSideI ++){
							
						if(Math.abs(sDOSides[0][sDOSidesI] - dOSides[0][dOSideI]) <= THRESHOLD){
							
							_snapObject.axisX = {"dObject": dO, "axis": 0, "deltaValue": sDOSides[0][sDOSidesI] - dOSides[0][dOSideI], "axisValue": dOSides[0][dOSideI]};
							continue;
							
						}
					}	
				}
				
				//check y axis
				for(var sDOSidesJ:int = 0; sDOSidesJ < sDOSides[1].length; sDOSidesJ ++){
						
					for(var dOSideJ:int = 0; dOSideJ < dOSides[1].length; dOSideJ ++){
						
						if(Math.abs(sDOSides[1][sDOSidesJ] - dOSides[1][dOSideJ]) <= THRESHOLD){
							
							_snapObject.axisY = {"dObject": dO, "axis": 1, "deltaValue": sDOSides[1][sDOSidesJ] - dOSides[1][dOSideJ], "axisValue": dOSides[1][dOSideJ]};
							continue;
							
						}
					}	
				}
				
			}	
			
			if(!_snapObject.axisX && !_snapObject.axisY)
				return null;
			else
				return _snapObject;
			
		}
		
		private function onContainerTouch(e:TouchEvent):void {
			
			var beganTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.BEGAN);
			
			if(beganTouch){
				
				deselectAll();
				
			}
			
		}
		
		private function deselectAll(dO:DisplayObject = null):void {
			
			for each(var box:UIBox in _UIBoxesDic){
					
				if(dO && dO.name == box.selectedDo.name) return;
					
				box.select(false);
				_verticalGuide.visible = false;
				_horizontalGuide.visible = false;
				
				_snappedX = false;
				_snappedY = false;
					
			}
			
		}
			
		
		public function init(object:DisplayObjectContainer, mode:String):void {
			
			_mode = mode;
			_doContainer = object;
			
			recurseStage(object);
			
			if(_mode == "write"){
				
				_doContainer.addEventListener(KeyboardEvent.KEY_DOWN, onMoveObject);
				_doContainer.addEventListener(KeyboardEvent.KEY_UP, onFinishedMovingObject);
				_doContainer.addEventListener(KeyboardEvent.KEY_DOWN, showAlpha);
				
				_doContainer.addEventListener(TouchEvent.TOUCH, onContainerTouch);
				
				_horizontalGuide = new Quad(1, 1, Color.AQUA);
				_horizontalGuide.visible = false;
				_doContainer.addChild(_horizontalGuide);
				
				_verticalGuide = new Quad(1, 1, Color.AQUA);
				_verticalGuide.visible = false;
				_doContainer.addChild(_verticalGuide);	
				
				for(var i:int; i < _displayObjectsArray.length; i ++){
					
					_UIBoxesDic[_displayObjectsArray[i].name] = new UIBox(_displayObjectsArray[i]);
					_doContainer.addChild(_UIBoxesDic[_displayObjectsArray[i].name]);
					
				}
			}
			
			
			
		}
		
		public function activate():void {
		
			
		}
		
		
		
		public function deactivate():void {
			
			for each(var dO:DisplayObject in _displayObjectsArray){
				
				dO.addEventListener(_childrenListeners[dO.name]["touch"], _childrenListeners[dO.name]["touch"]); 
				
			}
			
		}
		
		
		
		public static function getInstance():AlphaSprite {
			
			if(!_instance)
				_instance = new AlphaSprite();
			
			return _instance;
			
		}
		
	}
	
	
	
	
	
	
	
	
}