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
	import starling.utils.Color;
	import starling.utils.HAlign;
	
	import utils.Border;
import utils.ExtendedButton;

public class Ship extends Sprite
	{
		private static const UNIT_WIDTH:int = 22;
		private static const TILE_SIZE:int = 27;
        private var _shipName:String;
		private var _size:int;
		private var _sunk:Boolean;
		private var _damage:int;
		private var _placed:Boolean;
		private var _position:Array;
		private var _disable:Quad;
		private var _attackPower:int;
		private var _cost:int;
		private var _shipNameTxt:TextField;
		private var _state:String;
		private var _id:String;
		private var _shipFactory:ShipFactory;
		private var _visual:Image;
        private var _visualRoster:Image;
        private var _highlight:Image;
        private var _deleteShipButton:ExtendedButton;

        [Embed(source="../assets/fonts/consola.ttf", fontName = "Consolas", mimeType = "application/x-font", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true")]
        private var myEmbeddedFont:Class;

		public function Ship(shipName:String, cost:int, size:int, attackPower:int, visual:Image, visualRoster:Image, highlight:Image, state:String)
		{
		    _state = state;
			_cost = cost;
			_damage = 0;
			_shipName = shipName;
			_size = size;
            _visual = visual;
            _visualRoster = visualRoster;
            _highlight = highlight;
            _sunk = false;
			
			_attackPower = attackPower;

			_placed = false;
			_position = new Array();
			
			_disable = new Quad(this.width, this.height, Color.BLACK);
			_disable.alpha = 0.4;
			_disable.visible = false;
			addChild(_disable);

            createState(_state);

			this.pivotX = this.width / 2;
			this.pivotY = this.height / 2;
			
			if(state != "fleet")
				addEventListener(TouchEvent.TOUCH, onTouch);
			
		}
		
		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
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

                    case "toDelete":

                        shipToPlace = null;
                        action = "delete";
                        break;
					
				}
				
				dispatchEventWith("onShipTouch", true, {"touchedShip": this, "shipToPlace": shipToPlace, "action": action});
				
			}
		}
		
		public function receiveDamage(value:int):void {
			
			_damage += value;
			
			if(_damage == _size){
				_sunk = true;
				dispatchEventWith("onShipSunk", true, this);
			}
			
			
		}
		
		private function createUI(size:int):void {
		
			//cost
            for(var i:int = 0; i < _cost; i++){

                var costBar:Quad = new Quad(UNIT_WIDTH, 3, 0x138EE2);
                costBar.alpha = 0.8;
                costBar.x = i * TILE_SIZE;
                costBar.y = TILE_SIZE + 15;
                addChild(costBar);

            }

            for(var i:int = 0; i < _size; i++){

                var grayBox:Sprite = Border.createBorder(22, 7, 0xA7A9AC, 2);
                grayBox.x = i * TILE_SIZE;
                grayBox.y = TILE_SIZE + 5;
                addChild(grayBox);


            }

            for(var i:int = 0; i < _attackPower; i++){

                var redQuad:Quad = new Quad(18, 4, 0xEF414E);
                redQuad.x = i * TILE_SIZE + 2;
                redQuad.y = TILE_SIZE + 6;
                addChild(redQuad);

            }


		}

		private function createState(state:String):void {
			
            switch(state) {

				//(picking phase)
				case "detailed":

                    addChild(_visual);
                    _highlight.visible = false;
                    addChild(_highlight);

                    createUI(size);

					_shipNameTxt = new TextField(75, 20, this.shipName.toUpperCase(), "Consolas", 11, 0xA7A9AC);
					_shipNameTxt.hAlign = HAlign.LEFT;
					_shipNameTxt.y = - _shipNameTxt.height;

					addChild(_shipNameTxt);
						
					break;
				
				case "placed":

                    addChild(_visual);
                    _highlight.visible = false;
                    addChild(_highlight);

                    //delete button
                    var upState:Image = new Image(Main.getInstance().assetManager.getTexture("delete_ship_button_up"));
                    upState.name = "up0000";
                    var hoverState:Image = new Image(Main.getInstance().assetManager.getTexture("delete_ship_button_hover"));
                    hoverState.name = "hover0000";
                    var downState:Image = new Image(Main.getInstance().assetManager.getTexture("delete_ship_button_hover"));
                    downState.name = "down0000";

                    var buttonsStates:Array = new Array();
                    buttonsStates.push(upState, downState, hoverState);

                    _deleteShipButton = new ExtendedButton(buttonsStates);
                    _deleteShipButton.addEventListener("buttonTriggeredEvent", onShipDeleted);
                    addChild(_deleteShipButton);

                    break;

				case "fleet":

                    addChild(_visualRoster);
        			break;
				
				
			}
			
			
			
		}

        public function showDeleteButton(value:Boolean):void {

            _deleteShipButton.visible = false;

        }

        private function onShipDeleted(e:Event){

            _state = "toDelete";

        }
		
		public function get state():String
		{
			return _state;
		}

		public function set state(value:String):void
		{
			_state = value;
		}

		public function get cost():int
		{
			return _cost;
		}

		public function get attackPower():int
		{
			return _attackPower;
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
			
			_shipFactory = ShipFactory.getInstance();
			
			var clonedShip:Ship = _shipFactory.buildShip(this.shipName, state, null);
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

            switch(state) {

                case "detailed":

                    _shipNameTxt.color = value ? Color.BLACK : 0xA7A9AC;
                    _highlight.visible = value;
                     break;

                case "placed":

                    _highlight.visible = value;
                    break;

            }

		}

		public function get size():int
		{
			return _size;
		}


		public function get shipName():String
		{
			return _shipName;
		}

	}
}