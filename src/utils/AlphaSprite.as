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
		private static var THRESHOLD:int = 3;
		private var _verticalGuide:Quad;
		private var _horizontalGuide:Quad;
		private var _thresholdCounterX:int;
		private var _thresholdCounterY:int;
		private var _snappedX:Boolean;
		private var _snappedY:Boolean;
		private var _deltaX:int;
		private var _deltaY:int;
		
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
					displayObject.x += _deltaX;
				}
				
				if(!_snappedY){
					displayObject.y += _deltaY;
				}
				
				snap(checkSnap(displayObject), _deltaX, _deltaY);
				
			}
			
			//select
			if(beganTouch){
				
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
			if(data.axis == 0 && _snappedX){
				
				_verticalGuide.x = data.axisValue;
				_verticalGuide.visible = true;
				
				if(data.selectedDO.y - data.dObject.y > 0){
					
					_verticalGuide.y = data.dObject.y;
					_verticalGuide.height = data.selectedDO.y - data.dObject.y + data.selectedDO.width;    	
						
				}
				else {
					_verticalGuide.y = data.selectedDO.y;
					_verticalGuide.height = -(data.selectedDO.y - data.dObject.y) + data.dObject.width;  
				}
			}
			else {
				_verticalGuide.visible = false;
			}
				
			
			//horitonzal axis
			if(data.axis == 1 && _snappedY){
				
				_horizontalGuide.y = data.axisValue;
				_horizontalGuide.visible = true;
				
				if(data.selectedDO.x - data.dObject.x > 0){
					
					_horizontalGuide.x = data.dObject.x;
					_horizontalGuide.width = data.selectedDO.x - data.dObject.x + data.selectedDO.height;    	
					
				}
				else {
					_horizontalGuide.x = data.selectedDO.x;
					_horizontalGuide.width = -(data.selectedDO.x - data.dObject.x) + data.dObject.height;  
				}
			}
			else {
				_horizontalGuide.visible = false;
			}
			
			
		}
		
		private function snap(data:Object, deltaX:int, deltaY:int):void {
			
			if(!data) return;
			
			//left/right
			if(data.axis == 0){
							
				if(!_snappedX){
					data.selectedDO.x -= data.deltaValue;
					_snappedX = true;		
				}
				else {
					_thresholdCounterX += deltaX;
				}
				
				if(Math.abs(_thresholdCounterX) >= THRESHOLD){
					data.selectedDO.x += _thresholdCounterX;
					_thresholdCounterX = 0;					
					_snappedX = false;
					
				}
			}
			
			//top/bottom
			if(data.axis == 1){
				
				if(!_snappedY){
					data.selectedDO.y -= data.deltaValue;
					_snappedY = true;					
				}
				else {
					_thresholdCounterY += deltaY;
				}
				
				if(Math.abs(_thresholdCounterY) >= THRESHOLD){
					data.selectedDO.y += _thresholdCounterY;
					_thresholdCounterY = 0;					
					_snappedY = false;
				}
			}
			
			drawGuide(data);
			
		}
		
		
		private function checkSnap(selectedDO:DisplayObject):Object {
			
			var sideNames:Array = [["left", "right"], ["top", "bottom"]];
			var sDORect:Rectangle = selectedDO.getBounds(selectedDO.parent);
			var sDOSides:Array = [[sDORect.left, sDORect.right], [sDORect.top, sDORect.bottom]];
			
			for(var i:int = 0; i < _displayObjectsArray.length; i++){
				
				var dO:DisplayObject = _displayObjectsArray[i];
				
				if(dO.name == selectedDO.name)
					continue;
				
				var dORect:Rectangle = dO.getBounds(dO.parent);
				var dOSides:Array = [[dORect.left, dORect.right], [dORect.top, dORect.bottom]]
				
				for(var axisI:int = 0; axisI < sDOSides.length; axisI ++){
					
					for(var sDOSidesI:int = 0; sDOSidesI < sDOSides[axisI].length; sDOSidesI ++){
						
						for(var dOSideI:int = 0; dOSideI < dOSides[axisI].length; dOSideI ++){
								
							if(Math.abs(sDOSides[axisI][sDOSidesI] - dOSides[axisI][dOSideI]) <= THRESHOLD){
								
								return {"selectedDO": selectedDO, "dObject": dO, "axis": axisI, "deltaValue": sDOSides[axisI][sDOSidesI] - dOSides[axisI][dOSideI], "axisValue": dOSides[axisI][dOSideI]};
								
							}
						}	
					}
				}
			}	
			
			return null;
			
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