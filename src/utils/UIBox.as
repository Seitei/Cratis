package utils
{
	import flash.geom.Point;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.utils.Color;
	
	public class UIBox extends Sprite
	{
		private var _highlightBox:Sprite;
		private var _selectionBox:Sprite;
		private var _anchorsArray:Array;
		static private var anchorSize:int = 6;
		private var _topLeftAnchor:Quad;
		private var _topMidAnchor:Quad;
		private var _topRightAnchor:Quad;
		private var _midLeftAnchor:Quad;
		private var _midRightAnchor:Quad;
		private var _botLeftAnchor:Quad;
		private var _botMidAnchor:Quad;
		private var _botRightAnchor:Quad;
		private var _rotationAnchor:Quad;
		private var _selectedDo:DisplayObject;
		
		public function UIBox(displayObject:DisplayObject)
		{
			
			_highlightBox = new Sprite();
			_selectionBox = new Sprite();
			_selectedDo = displayObject;
			
			addChild(_highlightBox);
			addChild(_selectionBox);
			
			_highlightBox.visible = false;
			_selectionBox.visible = false;
			
		}
		
		public function updateUI():void {
			
			Border.createBorder(_selectedDo.width, _selectedDo.height, Color.AQUA, 1, _highlightBox);
			Border.createBorder(_selectedDo.width, _selectedDo.height, Color.AQUA, 1, _selectionBox);
			
			this.x = _selectedDo.localToGlobal(new Point()).x;
			this.y = _selectedDo.localToGlobal(new Point()).y;
			
			createAnchors();
		}
		
		public function highlight(value:Boolean):void {
			
			updateUI();
			
			_highlightBox.visible = value;
			
		}
		
		
		public function select(value:Boolean):void {
			
			_selectionBox.visible = value;
			
		}
		
		private function createAnchors():void {
			
			_anchorsArray = new Array();
			
			_anchorsArray[1] = _topLeftAnchor = new Quad(anchorSize, anchorSize, Color.AQUA);  _topLeftAnchor.name = "topLeft";
			_anchorsArray[2] = _topMidAnchor = new Quad(anchorSize, anchorSize, Color.AQUA);   _topMidAnchor.name = "topMid";
			_anchorsArray[3] = _topRightAnchor = new Quad(anchorSize, anchorSize, Color.AQUA); _topRightAnchor.name = "topRight";
			_anchorsArray[4] = _midLeftAnchor = new Quad(anchorSize, anchorSize, Color.AQUA);  _midLeftAnchor.name = "midLeft";
			_anchorsArray[6] = _midRightAnchor = new Quad(anchorSize, anchorSize, Color.AQUA); _midRightAnchor.name = "midRight";
			_anchorsArray[7] = _botLeftAnchor = new Quad(anchorSize, anchorSize, Color.AQUA);  _botLeftAnchor.name = "botLeft";
			_anchorsArray[8] = _botMidAnchor = new Quad(anchorSize, anchorSize, Color.AQUA);   _botMidAnchor.name = "botMid";
			_anchorsArray[9] = _botRightAnchor = new Quad(anchorSize, anchorSize, Color.AQUA); _botRightAnchor.name = "botRight";
			_rotationAnchor = new Quad(6, 6, Color.AQUA);
			
			var xCounter:Number = 0;
			var yCounter:Number = 0;
			
			for(var i:int = 1; i <= 9; i++){
			
				if(i != 5){
				
					_anchorsArray[i].pivotX = _anchorsArray[i].width / 2;
					_anchorsArray[i].pivotY = _anchorsArray[i].height / 2;
					_anchorsArray[i].x = xCounter * _selectedDo.width; 
					_anchorsArray[i].y = yCounter * _selectedDo.height;
					
					_selectionBox.addChild(_anchorsArray[i]);
					
				}
			
				xCounter += 0.5;
				
				if(i % 3 == 0){
					xCounter = 0;
					yCounter += 0.5;
				}
			}
			
			_rotationAnchor.pivotX = _rotationAnchor.width / 2;
			_rotationAnchor.pivotY = _rotationAnchor.height / 2;
			
			_rotationAnchor.x = _topMidAnchor.x;
			_rotationAnchor.y = _topMidAnchor.y - 15;
			
			_selectionBox.addChild(_rotationAnchor);
			
			/*_topLeftAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			_topMidAnchor.addEventListener(TouchEvent.TOUCH, verticalResize);
			_topRightAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			_midLeftAnchor.addEventListener(TouchEvent.TOUCH, horizontalResize);
			_midRightAnchor.addEventListener(TouchEvent.TOUCH, horizontalResize);
			_botLeftAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			_botMidAnchor.addEventListener(TouchEvent.TOUCH, verticalResize);
			_botRightAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			
			_rotationAnchor.addEventListener(TouchEvent.TOUCH, rotate);
			
			//we need to recalculate the pivot since we are altering the image.
			this.pivotX = this.width / 2;
			this.pivotY = this.height / 2;*/
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}