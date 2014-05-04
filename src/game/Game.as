package game
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import game.Assets;
	
	import interfaces.IGame;
	
	import ships.Ship;
	import ships.Special;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	import starling.utils.Color;
	
	import utils.AlphaSprite;
	import utils.Bar;
	import utils.Border;
	import utils.ExtendedButton;
	
	public class Game extends Sprite implements IGame
	{
		
		private static const TILES:int = 10;
		private static const TILE_SIZE:int = 28;
		private static const MINIMUM_COST_TO_SPEND:int = 10; 
		private static const AVAILABLE_COST:int = 15;
		private static const ALPHA_SPRITE_MODE:String = "read";
		
		private var _myGrid:Sprite;
		private var _enemyGrid:Sprite;
		private var _myMap:Array;
		private var _enemyMap:Array;
		
		private var _carrier:Ship;
		private var _patrol:Ship;
		private var _submarine:Ship;
		private var _cruiser:Ship;
		private var _destroyer:Ship;
		private var _battleship:Ship;
		private var _shipToPlace:Ship;
		private var _shipTiles:Sprite;
		private var _touchedShip:Ship;
		private var _prevShipTilesPositionY:int;
		private var _canPlaceShip:Boolean;
		private var _myFleet:Array;
		private var _spent:int;
		private var _doneButton:ExtendedButton;
		private var _fleetRoster:Array;
		private var _totalAttackPower:int;
		private var _myAttacks:Array;
		private var _tile:Sprite;
		private var _attackedTiles:Array;
		private var _player:Player;
		private var _assetManager:AssetManager;
		private var _costBar:Quad;
		private var _hpBar:Bar;
		private var _attackBar:Bar;
		
		public function Game(player:Player, assetManager:AssetManager)
		{
			_player = player;
			_assetManager = assetManager;
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			this.addEventListener("onShipTouch", onShipTouch);
		}
		
		private function onAdded(e:Event):void {
			
			//background
			var bgImage:Image = new Image(_assetManager.getTexture("background"));
			//bgImage.name = "main_background";
			addChild(bgImage);
			
			_myAttacks = new Array();
			
			_player.turn = new Turns();
			
			_attackedTiles = new Array();
			
			/*var testObject1:Sprite = new Sprite();
			
			var quad1:Quad = new Quad(TILE_SIZE * 2, TILE_SIZE * 2, Color.GRAY);
			quad1.name = "quad1";
			testObject1.addChild(quad1); 
			
			var quad2:Quad = new Quad(30, 30, Color.BLACK);
			quad2.name = "quad2";
			testObject1.addChild(quad2);
			
			addChild(testObject1);
			
			var testObject2:Sprite = new Sprite();
			testObject2.addChild( new Quad(TILE_SIZE * 5, TILE_SIZE * 3, Color.RED));
			testObject2.name = "to2";
			addChild(testObject2);
			
			AlphaSprite.getInstance().init(this, ALPHA_SPRITE_MODE);
			
			return;*/
			
			
			buildGrids();
			initShips();
			createCostBar(AVAILABLE_COST);
			createHpBar();
			createAttackBar();
			
			//visual aid used to select where to attack
			_tile = Border.createBorder(TILE_SIZE, TILE_SIZE, Color.AQUA);
			_tile.x = -50;
			_enemyGrid.addChild(_tile);
			
			//done placing button
			var upState:Quad = new Quad(20, 20, Color.AQUA);
			upState.name = "up0000";
			var downState:Quad = new Quad(20, 20, Color.AQUA);
			downState.name = "down0000";
			var hoverState:Quad = new Quad(20, 20, Color.AQUA);
			hoverState.name = "hover0000";
			
			var buttonsStates:Array = new Array;
			buttonsStates.push(upState, downState, hoverState);
			_doneButton = new ExtendedButton(buttonsStates);
			_doneButton.enabled = false;
			
			_doneButton.x = 310;
			_doneButton.y = 335;
			_doneButton.addEventListener("buttonTriggeredEvent", onMyTurnEnd);
			addChild(_doneButton);
			
			_myFleet = new Array();
			
			createTurns();
			
			_player.turn.start();
			
			AlphaSprite.getInstance().init(this, ALPHA_SPRITE_MODE);
			
		}
		
		private function createTurns():void {
			
			//initial turn, the selection and positioning of the ships
			_player.turn.createState(
				//state name
				"PLACING_SHIPS",
				//start
				{
				 "var_property": [_enemyGrid, "touchable", false] 
				},
				//end
				{
				 "method": [setTouchableShips, false], 
				 "var_property": [_doneButton, "enabled", false]
				},
				//send
				{"map": _myMap}, 
				//receive
				{"map": _enemyMap},
				//lifespan
				1); 
			
			
			//the attack/action phase
			_player.turn.createState(
				//state name
				"ATTACKING",
				//start
				{
				 "var_property": [_enemyGrid, "touchable", true],
				 "var_method": [_enemyGrid, "addEventListener", TouchEvent.TOUCH, onEnemyGridTouched]
				},
				//end
				{
				 "var_property": [_enemyGrid, "touchable", false], 
				 "var_method": [_enemyGrid, "removeEventListener", TouchEvent.TOUCH, onEnemyGridTouched]
				},
				//send
				{"attacks": _myAttacks},
				//receive
				{"attacks": receiveEnemyAttacks},
				0);
			
		}
		
		private function receiveEnemyAttacks(attacks:Array):void {
			
			
			
		}
		
		private function onEnemyGridTouched(e:TouchEvent):void {
			
			var touch:Touch = e.getTouches(this)[0];
			var mousePos:Point = touch.getLocation(_enemyGrid);
			
			var xP:int = Math.floor(mousePos.x / TILE_SIZE);
			var yP:int = Math.floor(mousePos.y / TILE_SIZE);
			
			
			if(touch.phase == TouchPhase.HOVER){
				
				_tile.x = xP * TILE_SIZE;
				_tile.y = yP * TILE_SIZE;
				
			}
			
			if(touch.phase == TouchPhase.BEGAN){
				
				_myAttacks.push(xP, yP);	
				var attackedTile:Image = new Image(_assetManager.getTexture("attacked_tile"));
				attackedTile.x = _tile.x;
				attackedTile.y = _tile.y;
				_enemyGrid.addChild(attackedTile);
				_attackedTiles.push(attackedTile);
				
			}
		}
		
		private function onMyTurnEnd(e:Event):void {
			
			_player.turn.end();
			
		}
		
		private function initShips():void {
			
			_assetManager.getTexture("patrol_side");
			
			var carrierSideImage:Image = new Image(_assetManager.getTexture("carrier_side_black"));
			var carrierTopImage:Image = new Image(_assetManager.getTexture("carrier_top"));
			var carrierSpecial:Special = new Special();
			
			
			_carrier = new Ship("carrier", 4, 5, 2, carrierSpecial, carrierSideImage, carrierTopImage, "detailed");
			_carrier.x = 50 + _carrier.pivotX;
			_carrier.y = 400;
			_carrier.name = "carrier" + "_alpha";
			addChild(_carrier);
			//_carrier.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var battleshipSideImage:Image = new Image(_assetManager.getTexture("battleship_side_black"));
			var battleshipTopImage:Image = new Image(_assetManager.getTexture("battleship_top"));
			var battleshipSpecial:Special = new Special();
			
			_battleship = new Ship("battleship", 4, 4, 3, battleshipSpecial, battleshipSideImage, battleshipTopImage, "detailed");
			_battleship.x = 50 + _battleship.pivotX;
			_battleship.y = _carrier.y + 50;
			_battleship.name = _battleship.shipName + "_alpha";
			addChild(_battleship);
			//_battleship.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var destroyerSideImage:Image = new Image(_assetManager.getTexture("destroyer_side_black"));
			var destroyerTopImage:Image = new Image(_assetManager.getTexture("destroyer_top"));
			var destroyerSpecial:Special = new Special();
			
			_destroyer = new Ship("destroyer", 3, 3, 1, destroyerSpecial, destroyerSideImage, destroyerTopImage, "detailed");
			_destroyer.x = 50 + _destroyer.pivotX;
			_destroyer.y = _battleship.y + 50;
			_destroyer.name = _destroyer.shipName + "_alpha";
			addChild(_destroyer);
			//_destroyer.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var patrolSideImage:Image = new Image(_assetManager.getTexture("patrol_side_black"));
			var patrolTopImage:Image = new Image(_assetManager.getTexture("patrol_top"));
			var patrolSpecial:Special = new Special();
			
			_patrol = new Ship("patrol", 2, 2, 0, patrolSpecial, patrolSideImage, patrolTopImage, "detailed");
			_patrol.x = 50 + _patrol.pivotX;
			_patrol.y = _destroyer.y + 50;
			_patrol.name = _patrol.shipName + "_alpha";
			addChild(_patrol);
			//_patrol.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var submarineSideImage:Image = new Image(_assetManager.getTexture("submarine_side_black"));
			var submarineTopImage:Image = new Image(_assetManager.getTexture("submarine_top"));
			var submarineSpecial:Special = new Special();
			
			_submarine = new Ship("submarine", 2, 3, 1, submarineSpecial, submarineSideImage, submarineTopImage, "detailed");
			_submarine.x = 50 + _submarine.pivotX;
			_submarine.y = _destroyer.y + 50;
			_submarine.name = _submarine.shipName + "_alpha";
			addChild(_submarine);
			//_submarine.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var cruiserSideImage:Image = new Image(_assetManager.getTexture("cruiser_side_black"));
			var cruiserTopImage:Image = new Image(_assetManager.getTexture("cruiser_top"));
			var cruiserSpecial:Special = new Special();
			
			_cruiser = new Ship("cruiser", 2, 3, 1, cruiserSpecial, cruiserSideImage, cruiserTopImage, "detailed");
			_cruiser.x = 50 + _cruiser.pivotX;
			_cruiser.y = _destroyer.y + 50;
			_cruiser.name = _cruiser.shipName + "_alpha";
			addChild(_cruiser);
			//_cruiser.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			_fleetRoster = new Array();
			_fleetRoster.push(_carrier, _destroyer, _patrol, _battleship, _submarine, _cruiser);
			//_shipsToPlace.push(_carrier);
		}
		
		private function setTouchableShips(value:Boolean):void {
			
			_carrier.touchable = value;
			_battleship.touchable = value;
			_destroyer.touchable = value;
			_patrol.touchable = value;
			
			for each(var ship:Ship in _myFleet){
				ship.touchable = value;
			}
		}
		
		private function eraseShip(ship:Ship):void {
			
			for each(var point:Point in ship.position){
				_myMap[point.x][point.y] = 0;
			}
			
			_myFleet.splice(_myFleet.indexOf(ship), 1);
			_myGrid.removeChild(ship, true);
		}
		
		private function onShipTouch(e:Event, data:Object):void {
			
			e.stopImmediatePropagation();
			
			_shipToPlace = data.shipToPlace;
			_touchedShip = data.touchedShip;
			
			switch(data.action) {
				
				case "placeShip":
					
					placeShip(_shipToPlace);
					break;
				
				case "positionShip":
					
					//Mouse.hide();
					setTouchableShips(false);
					_shipToPlace.touchable = false;
					_shipToPlace.alpha = 0.5;
					addChild(_shipToPlace);
					
					this.addEventListener(KeyboardEvent.KEY_UP, onRotatingShip);
					_myGrid.addEventListener(TouchEvent.TOUCH, positioningShip);
					
					_shipTiles = Border.createBorder(_touchedShip.size * TILE_SIZE, TILE_SIZE, Color.AQUA);
					_shipTiles.x = -50;
					_shipTiles.y = -50;
					_shipTiles.pivotX = _shipTiles.width / 2;
					_shipTiles.pivotY = _shipTiles.height / 2;
					_shipTiles.rotation = _touchedShip.rotation;
					
					_myGrid.addChild(_shipTiles);
					
					break;
				
			}
			
		}
		
		//TODO could be improved adding some logic
		//place ship in a random position
		private function placeShip(shipToPlace:Ship):void {
			
			var canPlace:Boolean = false;
			
			var xTile:int; 
			var yTile:int;
			
			_myGrid.addChild(shipToPlace);
			
			while(canPlace == false) {
				
				xTile = Math.random() * TILES;
				yTile = Math.random() * TILES;
				
				shipToPlace.rotation = Math.round(Math.random()) * Math.PI/2;
				
				shipToPlace.x = xTile * TILE_SIZE;
				shipToPlace.y = yTile * TILE_SIZE;
				
				shipToPlace.x += shipToPlace.rotation ? shipToPlace.pivotY : shipToPlace.pivotX;
				shipToPlace.y += shipToPlace.rotation ? shipToPlace.pivotX : shipToPlace.pivotY;
				
				canPlace = checkIfCanPlaceShip(shipToPlace);
				
			}
			
			writeShip(shipToPlace, xTile, yTile);
			
			_hpBar.increaseUnits(_shipToPlace.size);
			
			_attackBar.increaseUnits(_shipToPlace.attackPower);
			
			updateCost(_shipToPlace.cost);
			
			showMap(_myMap);
		}
		
		private function writeShip(ship:Ship, xTile:int, yTile:int):void {
			
			for(var i:int = 0; i < ship.size; i ++){
				
				var point:Point = new Point(ship.rotation ? xTile : xTile + i, ship.rotation ? yTile + i: yTile) 
				_myMap[point.x][point.y] = _shipToPlace.size;
				_shipToPlace.position.push(point);
				
			}
			
			_myFleet.push(ship);
			
		}
		
		private function onRotatingShip(e:KeyboardEvent):void {
			
			if(e.charCode == Keyboard.SPACE){
				
				_shipToPlace.rotation = _shipToPlace.rotation == 0 ? Math.PI / 180 * 90 : 0;
				_shipTiles.rotation = _shipToPlace.rotation;
				
			}
		}
		
		private function createCostBar(maxCost:int):void {
		
			var container:Sprite = new Sprite();
			_costBar = new Quad(8 * AVAILABLE_COST, 8, 0x00AEEF);
			container.addChild(_costBar);
			container.name = "costBar";
			
			for(var i:int = 1; i < AVAILABLE_COST; i ++){
				
				var bQuad:Quad = new Quad(1, 8, Color.BLACK);
				bQuad.alpha = 0.2;
				bQuad.x = i * 8;
				container.addChild(bQuad);
				
				var wQuad:Quad = new Quad(1, 8, Color.WHITE);
				wQuad.alpha = 0.25;
				wQuad.x = i * 8 + 1;
				container.addChild(wQuad);
				
			}
			
			Border.createBorder(8 * AVAILABLE_COST, 8, Color.BLACK, 1, container);
			addChild(container);
			
		}
		
		
		
		private function updateCost(cost:int):void {
			
			_spent += cost;
			_costBar.width = (AVAILABLE_COST - _spent) * 8; 
			
			if(!_doneButton.enabled && _spent >= MINIMUM_COST_TO_SPEND){
				_doneButton.enabled = true;
			}
			
			//loop though ships to see which ones can't be placed because of their cost
			for each(var ship:Ship in _fleetRoster){
				
				if(ship.cost > AVAILABLE_COST - _spent){
					ship.disable();
				}
			}
			
			
		}
		
		private function createHpBar():void {
			
			_hpBar = new Bar(new Image(_assetManager.getTexture("hp_bar_bg")), new Image(_assetManager.getTexture("hp_bar_border")));
			_hpBar.name = "hp_bar";
			addChild(_hpBar);
				
		}
		
		private function createAttackBar():void {
			
			_attackBar = new Bar(new Image(_assetManager.getTexture("attack_bar_bg")), new Image(_assetManager.getTexture("attack_bar_border")));
			_attackBar.name = "attack_bar";
			addChild(_attackBar);
			
		}
		
		private function checkIfCanPlaceShip(shipToPlace:Ship, rectangle:Rectangle = null, touchedShip:Ship = null):Boolean {
			
			var canPlace:Boolean = true;
			var rec:Rectangle;
			
			if(rectangle) 
				rec = rectangle;
			else
				rec = shipToPlace.getBounds(this);	
			
			//the ship must be contained inside the grid
			if(_myGrid.getBounds(this).containsRect(rec)){
				
				//check overlaping between ships
				for each(var ship:Ship in _myFleet) {
					
					if(!touchedShip){
						if(ship != shipToPlace && rec.intersects(ship.getBounds(this))){
							canPlace = false;
							break;
						}
					}
					else {
						
						if(rec.intersects(ship.getBounds(this))){
							canPlace = false;
							break;
						}
					}
				}	
			}
			else {
				canPlace = false;
			}
			
			return canPlace;
		}
		
		private function positioningShip(e:TouchEvent):void {
			
			var touch:Touch = e.getTouches(this)[0];
			var mousePos:Point = touch.getLocation(_myGrid);
			
			mousePos.x += _touchedShip.size % 2 == 0 ? TILE_SIZE / 2 : 0;  
			
			if(_touchedShip.size % 2 == 0 && _shipToPlace.rotation != 0){
				mousePos.x += TILE_SIZE / 2;
				mousePos.y += TILE_SIZE / 2;
			}
			
			var xP:int = Math.floor(mousePos.x / TILE_SIZE);
			var yP:int = Math.floor(mousePos.y / TILE_SIZE);
			
			if(touch.phase == TouchPhase.HOVER){
				
				_shipToPlace.x = touch.globalX;
				_shipToPlace.y = touch.globalY;
				
				_shipTiles.x = xP * TILE_SIZE;
				_shipTiles.x += TILE_SIZE / 2 * (_touchedShip.size % 2);
				
				_shipTiles.y = yP * TILE_SIZE + _shipTiles.pivotY;
				
				if((_touchedShip.size % 2) == 0 && _shipToPlace.rotation != 0){
					_shipTiles.x -= TILE_SIZE / 2;
					_shipTiles.y -= TILE_SIZE / 2;
				}
			}
			
			if(touch.phase == TouchPhase.BEGAN){
				
				xP = _shipToPlace.rotation ? (_shipTiles.x - _shipTiles.pivotY) / TILE_SIZE : Math.floor(_shipTiles.x - _shipTiles.pivotX) / TILE_SIZE;
				yP = _shipToPlace.rotation ? (_shipTiles.y - _shipTiles.pivotX) / TILE_SIZE : Math.floor(_shipTiles.y - _shipTiles.pivotY) / TILE_SIZE;
				
				if(!checkIfCanPlaceShip(_shipToPlace, _shipTiles.getBounds(this), _touchedShip)) return;
				
				_shipToPlace.alpha = 1;
				
				_shipToPlace.x = _shipTiles.x;
				_shipToPlace.y = _shipTiles.y;
				
				_myGrid.removeChild(_shipTiles);
				
				_myGrid.addChild(_shipToPlace);
				_myGrid.removeEventListener(TouchEvent.TOUCH, positioningShip);
				Mouse.show();
				
				setTouchableShips(true);
				
				_shipToPlace.touchable = true;
				
				_shipToPlace.placed = true;
				
				_totalAttackPower += _shipToPlace.attackPower;
				
				eraseShip(_touchedShip);
				
				writeShip(_shipToPlace, xP, yP);
				
				//debug
				showMap(_myMap);
				
			}
		}
		
		private function buildGrids():void {
			
			_myGrid = new Sprite();
			_myGrid.x = 50;
			_myGrid.y = 50;
			addChild(_myGrid);
			
			_enemyGrid = new Sprite();
			_enemyGrid.x = 370;
			_enemyGrid.y = 50;
			addChild(_enemyGrid);
			
			//grid
			
			var canvas:RenderTexture = new RenderTexture(TILE_SIZE * 10, TILE_SIZE * 10); 
			var myCanvasContainer:Image = new Image(canvas);
			_myGrid.addChild(myCanvasContainer);
			
			var enemyCanvasContainer:Image = new Image(canvas);
			_enemyGrid.addChild(enemyCanvasContainer);
			
			var horizontalLine:Quad = new Quad(TILE_SIZE * 10, 1, Color.AQUA);
			horizontalLine.alpha = 0.5;
			
			var verticalLine:Quad = new Quad(1, TILE_SIZE * 10, Color.AQUA);
			verticalLine.alpha = 0.5;
			
			
			//horizontal line
			for (var i:int = 0; i < TILES; i++) {
				
				horizontalLine.y = i * TILE_SIZE;
				canvas.draw(horizontalLine);	
			}
			
			//vertical line
			for (var j:int = 0; j < TILES; j++) {
				
				verticalLine.x = j * TILE_SIZE;
				canvas.draw(verticalLine);
				
			}
			
			var myBorder:Sprite = Border.createBorder(TILE_SIZE * 10, TILE_SIZE * 10, Color.WHITE, 2);
			myBorder.alpha = 0.7;
			_myGrid.addChild(myBorder);
			
			var enemyBorder:Sprite = Border.createBorder(TILE_SIZE * 10, TILE_SIZE * 10, Color.WHITE, 2);
			enemyBorder.alpha = 0.7;
			_enemyGrid.addChild(enemyBorder);
			
			_myMap = new Array();
			
			for( var k:int = 0; k < TILES; k ++){
				_myMap[k] = new Array();
				for( var l:int = 0; l < TILES; l ++){
					_myMap[k][l] = 0;	
				}
			}
			
			_myGrid.clipRect = new Rectangle(0, 0, _myGrid.width, _myGrid.height);
			_enemyGrid.clipRect = new Rectangle(0, 0, _enemyGrid.width, _enemyGrid.height);
			
		}
		
		
		
		//debugging purposes
		private function showMap(map:Array):void {
			
			var output:String = "";
			
			for( var i:int = 0; i < TILES; i ++){
				for( var j:int = 0; j < TILES; j ++){
					output += map[j][i] + " ";	
				}
				output += "\n";
			}
			
			trace(output);
		}
		
		
		
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}