package ships
{
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.Color;
	
	import utils.Border;
	
	public class Ship extends Sprite
	{
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
		
		public function Ship(shipName:String, size:int, attackPower:int, sideView:Image, topView:Image)
		{
			super();
			
			_damage = 0;
			_shipName = shipName;
			_size = size;
			_sunk = false;
			
			_attackPower = attackPower;
				
			_sideView = sideView;
			addChild(_sideView);
			
			_topView = topView;
			_topView.visible = false;
			addChild(_topView);
			
			_border = Border.createBorder(this.width, this.height, Color.AQUA, 1);
			_border.alpha = 0.75;
			addChild(_border);
			_border.visible = false;
			
			this.pivotX = this.width / 2;
			this.pivotY = this.height / 2;
			
			_placed = false;
			
			_disable = new Quad(this.width, this.height, Color.BLACK);
			_disable.alpha = 0.4;
			_disable.visible = false;
			addChild(_disable);
			
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
			
			var clonedShip:Ship = new Ship(this.shipName, this.size, this.attackPower, sideView, topView); 
			
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