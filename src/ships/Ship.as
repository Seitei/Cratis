package ships
{
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Color;
	
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
			_topView.visible = false;
			
			_border = Border.createBorder(this.width, this.height, Color.AQUA, 1);
			_border.alpha = 0.70;
			addChild(_border);
			_border.visible = false;
			
			this.pivotX = this.width / 2;
			this.pivotY = this.height / 2;
			
			_placed = false;
			
			_disable = new Quad(this.width, this.height, Color.BLACK);
			_disable.alpha = 0.4;
			_disable.visible = false;
			addChild(_disable);
			
			createState(_state);
			
		}
		
		private function createSizeBoxes(size:int):void {
		
			//horizontals
			var top:Quad = new Quad(_tileSize * size, 1, Color.WHITE);
			var bot:Quad = new Quad(_tileSize * size, 1, Color.WHITE);
			bot.alpha = top.alpha = 0.7;
			
			bot.y = _tileSize;
			addChildAt(top, 0);
			addChildAt(bot, 0);
			
			//verticals
			for(var i:int = 0; i <= size; i++){
				
				var vertical:Quad = new Quad(1, _tileSize, Color.WHITE);
				vertical.alpha = 0.7;
				vertical.x = i * _tileSize;
				addChildAt(vertical, 0);
				
			}
			
		}
		
		private function createState(state:String):void {
			
			switch(state) {
				
				case "detailed":
					
					addChild(_sideView);
					createSizeBoxes(size);
					
					_shipNameTxt = new TextField(150, 50, this.shipName, "Consolas", 12, Color.BLACK);
					_shipNameTxt.name = this.shipName + "Txt";
					addChild(_shipNameTxt);
					
					
					
					
					
					
					
					break;
				
				case "placed":
					
					break;
				
				case "fleet":
					
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

		public function clone():Ship {
			
			var sideView:Image = new Image(Texture.fromTexture(this._sideView.texture));
			var topView:Image = new Image(Texture.fromTexture(this._topView.texture));
			
			var clonedShip:Ship = new Ship(this.shipName, this.cost, this.size, this.attackPower, this.special, sideView, topView, this.state); 
			
			return clonedShip;
		}
		
		public function showView(view:String):void {
		
			if(view == "top"){
				_sideView.visible = false;
				_topView.visible = true;
			}
			else {
				_sideView.visible = true;
				_topView.visible = false;
			}
		}
		
		public function get sunk():Boolean
		{
			return _sunk;
		}

		public function set sunk(value:Boolean):void
		{
			_sunk = value;
		}

		

		public function highlight(value:Boolean):void {
			
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