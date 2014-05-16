package ships
{
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	import starling.utils.HAlign;
	
	import utils.Border;
	
	public class Ship extends Sprite
	{
		private static var _tileSize:int = 41;
		private var _shipName:String;
		private var _size:int;
		private var _sideView:Image;
		private var _topView:Image;
		private var _border:Sprite;
		private var _sunk:Boolean;
		private var _damage:int;
		private var _placed:Boolean;
		private var _position:Array;
		private var _disable:Quad;
		private var _attackPower:int;
		private var _cost:int;
		private var _special:Special;
		private var _shipNameTxt:TextField;
		private var _state:String;
		private var _sizeBoxesContainer:Sprite;
		private var _costSquaresContainer:Sprite;
		private var _attackSquaresContainer:Sprite;
		
		public function Ship(shipName:String, cost:int, size:int, attackPower:int, special:Special, sideView:Image, topView:Image, state:String)
		{
			
			_state = state;
			_special = special;
			_cost = cost;
			_damage = 0;
			_shipName = shipName;
			_size = size;
			_sunk = false;
			
			_attackPower = attackPower;
			_sideView = sideView;
			_topView = topView;
			
			_placed = false;
			_position = new Array();
			
			_disable = new Quad(this.width, this.height, Color.BLACK);
			_disable.alpha = 0.4;
			_disable.visible = false;
			addChild(_disable);
			
			createState(_state);
			
			_border = Border.createBorder(this.width, this.height, Color.WHITE, 1.5);
			_border.alpha = 1;
			addChild(_border);
			_border.visible = false;
			
			this.pivotX = this.width / 2;
			this.pivotY = this.height / 2;
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
		}
		
		private function onTouch(e:TouchEvent):void {
			
			var endedTouch:Touch = e.getTouch(this, TouchPhase.ENDED); 
			var hoverTouch:Touch = e.getTouch(this, TouchPhase.HOVER);
			
			if(hoverTouch)
				highlight(true);
			else 
				highlight(false);
			
			var shipToPlace:Ship;
			var action:String;
			
			if(endedTouch){
				
				switch(state) {
					
					case "detailed":
						
						shipToPlace = this.clone("placed");
						action = "placeShip";
						break;
					
					case "placed":
						
						shipToPlace = this.clone("placed");
						action = "positionShip"; 
						break;
					
					//unused for now
					case "fleet":
						
						shipToPlace = this.clone("placed");
						action = "showDetails";
						break;
					
				}
				
				dispatchEventWith("onShipTouch", true, {"touchedShip": this, "shipToPlace": shipToPlace, "action": action});
				
			}
		}
		
		private function createSizeBoxes(size:int):void {
		
			_sizeBoxesContainer = new Sprite();
			//_sizeBoxesContainer.name = this.shipName + "_sizeBoxesContainer";
			addChild(_sizeBoxesContainer);
			
			//horizontals
			var top:Quad = new Quad(_tileSize * size, 1, Color.WHITE);
			var bot:Quad = new Quad(_tileSize * size, 1, Color.WHITE);
			bot.alpha = top.alpha = 0.7;
			
			bot.y = _tileSize;
			
			_sizeBoxesContainer.addChild(top);
			_sizeBoxesContainer.addChild(bot);
			
			//verticals
			for(var i:int = 0; i <= size; i++){
				
				var vertical:Quad = new Quad(1, _tileSize, Color.WHITE);
				vertical.alpha = 0.7;
				vertical.x = i * _tileSize;
				_sizeBoxesContainer.addChild(vertical);
				
			}
			
		}
		
		private function createCostSquares():void {
			
			_costSquaresContainer = new Sprite();
			addChild(_costSquaresContainer);
			
			for(var i:int = 0; i < _cost; i++){
				
				var costQuadContainer:Sprite = new Sprite();
				var costQuad:Quad = new Quad(8, 8, 0x00AEEF);
				costQuadContainer.x = i * 10;
				costQuadContainer.addChild(costQuad);
				Border.createBorder(Number.NaN, Number.NaN, Color.BLACK, 1, costQuadContainer);
				_costSquaresContainer.addChild(costQuadContainer);
				
			}
			
			_costSquaresContainer.x = _sizeBoxesContainer.width - _costSquaresContainer.width; 
			_costSquaresContainer.y = -_costSquaresContainer.height - 3;
		}
		
		private function createAttackSquares():void {
			
			_attackSquaresContainer = new Sprite();
			addChild(_attackSquaresContainer);
			
			for(var i:int = 0; i <= _attackPower; i++){
				
				var attackQuadContainer:Sprite = new Sprite();
				var attackQuad:Quad = new Quad(8, 8, 0xEA5639);
				attackQuadContainer.x = i * 10;
				attackQuadContainer.addChild(attackQuad);
				Border.createBorder(Number.NaN, Number.NaN, Color.BLACK, 1, attackQuadContainer);
				_attackSquaresContainer.addChild(attackQuadContainer);
				
			}
			
			_attackSquaresContainer.y = _sizeBoxesContainer.height + 3;
				
		}
		
		private function createState(state:String):void {
			
			switch(state) {
				
				//(picking phase)
				case "detailed":
					
					createSizeBoxes(size);
					createCostSquares();
					createAttackSquares();
					addChild(_sideView);
					
					_shipNameTxt = new TextField(75, 20, this.shipName.toUpperCase(), "Consolas", 12, Color.BLACK);
					_shipNameTxt.hAlign = HAlign.LEFT;
					_shipNameTxt.y = - _shipNameTxt.height;
					
					addChild(_shipNameTxt);
						
					break;
				
				//(top view)
				case "placed":
					
					addChild(_topView);
					break;
				
				//(your current ships)
				case "fleet":
					
					addChild(_sideView);
					
					
					break;
				
				
			}
			
			
			
		}
		
		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
		}

		public function get special():Special
		{
			return _special;
		}

		public function set special(value:Special):void
		{
			_special = value;
		}

		public function get cost():int
		{
			return _cost;
		}

		public function set cost(value:int):void
		{
			_cost = value;
		}

		public function get attackPower():int
		{
			return _attackPower;
		}

		public function set attackPower(value:int):void
		{
			_attackPower = value;
		}

		public function disable():void {
			this.touchable = false;
			_disable.visible = true;
			this.alpha = 0.5;
		}
		
		public function enable():void {
			this.touchable = true;
			_disable.visible = false;
			this.alpha = 1;
		}
		
		public function get position():Array
		{
			return _position;
		}

		public function set position(value:Array):void
		{
			_position = value;
		}

		public function get placed():Boolean
		{
			return _placed;
		}

		public function set placed(value:Boolean):void
		{
			_placed = value;
		}

		public function clone(state:String, preferredRotation:Number = NaN):Ship {
			
			var sideView:Image = new Image(Texture.fromTexture(this._sideView.texture));
			var topView:Image = new Image(Texture.fromTexture(this._topView.texture));
			
			var clonedShip:Ship = new Ship(this.shipName, this.cost, this.size, this.attackPower, this.special, sideView, topView, state); 
			clonedShip.rotation = isNaN(preferredRotation) ? this.rotation : preferredRotation; 
			
			return clonedShip;
		}
		
		public function get sunk():Boolean
		{
			return _sunk;
		}

		public function set sunk(value:Boolean):void
		{
			_sunk = value;
		}

		

		private function highlight(value:Boolean):void {
			
			_border.visible = value;
			
		}
		
		
		public function get size():int
		{
			return _size;
		}

		public function set size(value:int):void
		{
			_size = value;
		}

		public function get shipName():String
		{
			return _shipName;
		}

		public function set shipName(value:String):void
		{
			_shipName = value;
		}

	}
}