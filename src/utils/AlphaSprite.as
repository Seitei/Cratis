package utils
{
	import flash.display3D.IndexBuffer3D;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Color;

	public class AlphaSprite
	{
		private var _displayObjectsDic:Dictionary;
		private var _data:XML;
		private static var _instance:AlphaSprite;
		private var _sharedObject:SharedObject;
		private var _selectionQuad:Sprite;
		private var _doContainer:DisplayObjectContainer;
		private var _displayObjectsArray:Array;
		private static var THRESHOLD:int = 5;
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
		
		public function AlphaSprite()
		{
			_displayObjectsDic = new Dictionary();
			_displayObjectsArray = new Array();
			_data = new XML();
			_sharedObject = SharedObject.getLocal("data");
			
		}
		
		private function recurseStage(doc:DisplayObjectContainer):void
		{
			var children:int = doc.numChildren;
			
			for(var i:int = 0; i < children; i++)
			{
				var child:* = doc.getChildAt(i);  
				
				if(child.name){
				
					child.addEventListener(TouchEvent.TOUCH, onTouch);
						
					_displayObjectsDic[child.name] = child;
					_displayObjectsArray.push(child);
					
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
			
			//highlight
			if(hoverTouch && _selectionQuad.visible == false){
				
				_selectionQuad.x = displayObject.x;
				_selectionQuad.y = displayObject.y;
				_selectionQuad = Border.createBorder(displayObject.width, displayObject.height, Color.AQUA, 1, _selectionQuad);
				_selectionQuad.visible = true;
				
			}
			else if(!hoverTouch) {
				_selectionQuad.visible = false;
			}
			
			if(movedTouch){
				
				_deltaX = movedTouch.getMovement(displayObject).x;
				_deltaY = movedTouch.getMovement(displayObject).y;
				
				if(!_snappedX){
					displayObject.x = movedTouch.getLocation(displayObject.parent).x - _shiftTouch.x; 
				}
				
				if(!_snappedY){
					displayObject.y = movedTouch.getLocation(displayObject.parent).y - _shiftTouch.y;
				}
				
				snap(checkSnap(displayObject), _deltaX, _deltaY);
				
			}
			
			//select
			if(beganTouch){
				
				_shiftTouch = beganTouch.getLocation(displayObject);
				
			}
			
			//save new position
			if(endedTouch) {
				
				_sharedObject.data[displayObject.name] = {"x": displayObject.x, "y": displayObject.y};
				_sharedObject.flush();
				_sharedObject.close();
				
			}
		}
		
		private function drawGuide(data:Object):void {
			
			//vertical axis
			if(data.axisX && _snappedX){
				
				_verticalGuide.x = data.axisX.axisValue;
				_verticalGuide.visible = true;
				
				if(data.selectedDO.y - data.axisX.dObject.y > 0){
					
					_verticalGuide.y = data.axisX.dObject.y;
					_verticalGuide.height = data.selectedDO.y - data.axisX.dObject.y + data.selectedDO.height;    	
						
				}
				else {
					_verticalGuide.y = data.selectedDO.y;
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
					
					_horizontalGuide.x = data.axisY.dObject.x;
					_horizontalGuide.width = data.selectedDO.x - data.axisY.dObject.x + data.selectedDO.width;    	
					
				}
				else {
					_horizontalGuide.x = data.selectedDO.x;
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
					trace(_thresholdCounterX / 2);
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
		
			drawGuide(data);
			
		}
		
		
		private function checkSnap(selectedDO:DisplayObject):Object {
			
			var sDORect:Rectangle = selectedDO.getBounds(selectedDO.parent);
			var sDOSides:Array = [[sDORect.left, sDORect.right, sDORect.left + selectedDO.width / 2], 
								  [sDORect.top, sDORect.bottom, sDORect.top + selectedDO.height / 2]];
				
			_snapObject = {"selectedDO": selectedDO};
			
			for(var i:int = 0; i < _displayObjectsArray.length; i++){
				
				var dO:DisplayObject = _displayObjectsArray[i];
				
				if(dO.name == selectedDO.name)
					continue;
				
				var dORect:Rectangle = dO.getBounds(dO.parent);
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
			
		
		public function init(object:DisplayObjectContainer):void {
			
			_doContainer = object;
			
			_selectionQuad = Border.createBorder(10, 10, Color.AQUA);
			_selectionQuad.x = -99;
			_selectionQuad.y = -99;
			_doContainer.addChild(_selectionQuad);
			
			_horizontalGuide = new Quad(1, 1, Color.AQUA);
			_horizontalGuide.visible = false;
			_doContainer.addChild(_horizontalGuide);
			
			_verticalGuide = new Quad(1, 1, Color.AQUA);
			_verticalGuide.visible = false;
			_doContainer.addChild(_verticalGuide);
			
			recurseStage(object);
			
			for ( var doName:String in _sharedObject.data) {
				
				for ( var property:String in _sharedObject.data[doName]) {
					
					_displayObjectsDic[doName][property] = _sharedObject.data[doName][property];
					
				}
				
				
				
				
			}
			
		}
		
		
		
		
		
		public static function getInstance():AlphaSprite {
			
			if(!_instance)
				_instance = new AlphaSprite();
			
			return _instance;
			
		}
		
	}
	
	
	
	
	
	
	
	
}