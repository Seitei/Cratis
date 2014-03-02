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
	import utils.Border;
	import utils.ExtendedButton;
	
	public class Game extends Sprite implements IGame
	{
		
		private static const TILES:int = 10;
		private static const TILE_SIZE:int = 28;
		private static const MINIMUM_SHIPS_TILES:int = 10; 
		private static const MAXIMUM_SHIPS_TILES:int = 15;
		private static const ALPHA_SPRITE_MODE:String = "write";
		
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
		private var _prevShipTilesPositionX:int;
		private var _prevShipTilesPositionY:int;
		private var _canPlaceShip:Boolean;
		private var _placedShips:Array;
		private var _usedTiles:int;
		private var _doneButton:ExtendedButton;
		private var _shipsToPlace:Array;
		private var _totalAttackPower:int;
		private var _myAttacks:Array;
		private var _tile:Sprite;
		private var _attackedTiles:Array;
		private var _player:Player;
		private var _assetManager:AssetManager;
		
		
		public function Game(player:Player, assetManager:AssetManager)
		{
			_player = player;
			_assetManager = assetManager;
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
	
		}
		
		private function onAdded(e:Event):void {
			
			//background
			var bgImage:Image = new Image(_assetManager.getTexture("background"));
			//bgImage.name = "main_background";
			addChild(bgImage);
			
			_myAttacks = new Array();
			
			_player.turn = new Turns();
			
			_attackedTiles = new Array();
			
			var testObject1:Sprite = new Sprite();
			
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
			
			return;
			
			
			buildGrids();
			initShips();
			
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
			
			_placedShips = new Array();
			
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
		
		private function updateTilesCounter(tiles:int):void {
			
			_usedTiles += tiles;
			
			if(_usedTiles >= MINIMUM_SHIPS_TILES){
				_doneButton.enabled = true;
			}
			
			//loop though ships to see which ones can't be placed because of their cost
			for each(var ship:Ship in _shipsToPlace){
				
				if(ship.size > MAXIMUM_SHIPS_TILES - _usedTiles){
					ship.disable();
				}
				
			}
			
		}
		
		private function initShips():void {
			
			_assetManager.getTexture("patrol_side");
			
			var carrierSideImage:Image = new Image(_assetManager.getTexture("carrier_side_black"));
			var carrierTopImage:Image = new Image(_assetManager.getTexture("carrier_top"));
			var carrierSpecial:Special = new Special();
			
			_carrier = new Ship("carrier", 4, 5, 2, carrierSpecial, carrierSideImage, carrierTopImage, "detailed");
			_carrier.x = 50 + _carrier.pivotX;
			_carrier.y = 400;
			_carrier.name = "carrier";
			addChild(_carrier);
			_carrier.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			/*var battleshipSideImage:Image = new Image(_assetManager.getTexture("battleship_side_black"));
			var battleshipTopImage:Image = new Image(_assetManager.getTexture("battleship_top"));
			var battleshipSpecial:Special = new Special();
			
			_battleship = new Ship("battleship", 4, 4, 3, battleshipSpecial, battleshipSideImage, battleshipTopImage, "detailed");
			_battleship.x = 50 + _battleship.pivotX;
			_battleship.y = _carrier.y + 50;
			addChild(_battleship);
			_battleship.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var destroyerSideImage:Image = new Image(_assetManager.getTexture("destroyer_side_black"));
			var destroyerTopImage:Image = new Image(_assetManager.getTexture("destroyer_top"));
			var destroyerSpecial:Special = new Special();
			
			_destroyer = new Ship("destroyer", 3, 3, 1, destroyerSpecial, destroyerSideImage, destroyerTopImage, "detailed");
			_destroyer.x = 50 + _destroyer.pivotX;
			_destroyer.y = _battleship.y + 50;
			addChild(_destroyer);
			_destroyer.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var patrolSideImage:Image = new Image(_assetManager.getTexture("patrol_side_black"));
			var patrolTopImage:Image = new Image(_assetManager.getTexture("patrol_top"));
			var patrolSpecial:Special = new Special();
			
			_patrol = new Ship("patrol", 2, 2, 0, patrolSpecial, patrolSideImage, patrolTopImage, "detailed");
			_patrol.x = 50 + _patrol.pivotX;
			_patrol.y = _destroyer.y + 50;
			addChild(_patrol);
			_patrol.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var submarineSideImage:Image = new Image(_assetManager.getTexture("submarine_side_black"));
			var submarineTopImage:Image = new Image(_assetManager.getTexture("submarine_top"));
			var submarineSpecial:Special = new Special();
			
			_submarine = new Ship("submarine", 2, 3, 1, submarineSpecial, submarineSideImage, submarineTopImage, "detailed");
			_submarine.x = 50 + _submarine.pivotX;
			_submarine.y = _destroyer.y + 50;
			addChild(_submarine);
			_submarine.addEventListener(TouchEvent.TOUCH, onShipTouch);
			
			var cruiserSideImage:Image = new Image(_assetManager.getTexture("cruiser_side_black"));
			var cruiserTopImage:Image = new Image(_assetManager.getTexture("cruiser_top"));
			var cruiserSpecial:Special = new Special();
			
			_cruiser = new Ship("cruiser", 2, 3, 1, cruiserSpecial, cruiserSideImage, cruiserTopImage, "detailed");
			_cruiser.x = 50 + _cruiser.pivotX;
			_cruiser.y = _destroyer.y + 50;
			addChild(_cruiser);
			_cruiser.addEventListener(TouchEvent.TOUCH, onShipTouch);*/
			
			_shipsToPlace = new Array();
			//_shipsToPlace.push(_carrier, _destroyer, _patrol, _battleship);
			_shipsToPlace.push(_carrier);
		}
		
		private function setTouchableShips(value:Boolean):void {
			
			_carrier.touchable = value;
			_battleship.touchable = value;
			_destroyer.touchable = value;
			_patrol.touchable = value;
			
			for each(var ship:Ship in _placedShips){
				ship.touchable = value;
			}
		}
		
		private function eraseShip(ship:Ship):void {
			
			for each(var point:Point in ship.position){
				_myMap[point.x][point.y] = 0;
			}
			
			_myGrid.removeChild(ship, true);
		}
		
		private function onShipTouch(e:TouchEvent):void {
			
			_touchedShip = Ship(e.currentTarget);
			e.stopImmediatePropagation();
			
			var endedTouch:Touch = e.getTouch(_touchedShip, TouchPhase.ENDED); 
			var hoverTouch:Touch = e.getTouch(_touchedShip, TouchPhase.HOVER);
			
			if(hoverTouch){
				_touchedShip.highlight(true);
			}
			else {
				_touchedShip.highlight(false);
			}
			
			if(endedTouch){
				
				setTouchableShips(false);
				this.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
				this.addEventListener(TouchEvent.TOUCH, movingShip);
				_myGrid.addEventListener(TouchEvent.TOUCH, positioningShip);
				_shipToPlace = _touchedShip.clone();
				_shipToPlace.showView("top");
				_shipToPlace.rotation = _touchedShip.rotation;
				_shipToPlace.touchable = false;
				_shipToPlace.alpha = 0.5;
				addChild(_shipToPlace);
				
				Mouse.hide();
				_shipTiles = Border.createBorder(_touchedShip.size * TILE_SIZE, TILE_SIZE, Color.AQUA);
				_shipTiles.x = -50;
				_shipTiles.y = -50;
				_shipTiles.pivotX = _shipTiles.width / 2;
				_shipTiles.pivotY = _shipTiles.height / 2;
				_shipTiles.rotation = _touchedShip.rotation;
				
				_myGrid.addChild(_shipTiles);
				
				if(_touchedShip.placed)
					eraseShip(_touchedShip);	
				
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			
			if(e.charCode == Keyboard.SPACE){
				
				_shipToPlace.rotation = _shipToPlace.rotation == 0 ? Math.PI / 180 * 90 : 0;
				_shipTiles.rotation = _shipToPlace.rotation;
				
			}
			
			
		}
		
		private function movingShip(e:TouchEvent):void {
			
			var hoverTouch:Touch = e.getTouch(this, TouchPhase.HOVER);
			
			if(hoverTouch){
				
				_shipToPlace.x = hoverTouch.globalX;
				_shipToPlace.y = hoverTouch.globalY;
				
			}
		}
		
		private function checkIfCanPlaceShip(xP:int, yP:int):void {
			
			_canPlaceShip = true;
			
			if(_shipToPlace.rotation == 0){
				
				if( xP >= 0 && yP >= 0 && (xP + _touchedShip.size <= TILES)){
					_canPlaceShip = true;
				}
				else {
					_canPlaceShip = false;
					return;
				}
			}
			else {
				
				if( yP >= 0 && (yP + _touchedShip.size <= TILES)){
					_canPlaceShip = true;
				}
				else {
					_canPlaceShip = false;
					return;
				}
			}
			
			if(_shipToPlace.rotation != 0 && _touchedShip.size % 2 == 0)
				xP --;	
			
			if(_shipToPlace.rotation == 0){
				
				for(var i:int = 0; i < _touchedShip.size; i ++){
					
					if(_myMap[xP + i][yP] != 0){
						_canPlaceShip = false;
						return;
					}
					
				}
			}
			else {
				
				for(var j:int = 0; j < _touchedShip.size; j ++){
					
					if(_myMap[xP][yP + j] != 0){
						_canPlaceShip = false;
						return;
					}
				}
			}
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
				
				_shipTiles.x = xP * TILE_SIZE;
				_shipTiles.x += TILE_SIZE / 2 * (_touchedShip.size % 2);
				
				_shipTiles.y = yP * TILE_SIZE + _shipTiles.pivotY;
				
				if((_touchedShip.size % 2) == 0 && _shipToPlace.rotation != 0){
					_shipTiles.x -= TILE_SIZE / 2;
					_shipTiles.y -= TILE_SIZE / 2;
				}
				
				_prevShipTilesPositionX = _shipTiles.x;
				_prevShipTilesPositionY = _shipTiles.y;
				
			}
			
			if(touch.phase == TouchPhase.BEGAN){
				
				if(_shipToPlace.rotation == 0) xP -= Math.floor(_touchedShip.size / 2);
				if(_shipToPlace.rotation != 0) yP -= Math.floor(_touchedShip.size / 2);
				
				checkIfCanPlaceShip(xP, yP);
				
				if(!_canPlaceShip) return;
				
				var position:Array = new Array();
				var point:Point;
				
				if(_shipToPlace.rotation == 0){
					
					_shipToPlace.x = _shipTiles.x; 
					_shipToPlace.y = _shipTiles.y;
					_myGrid.addChild(_shipToPlace);
					_shipToPlace.alpha = 1;
					
					this.removeEventListener(TouchEvent.TOUCH, movingShip);
					_myGrid.removeEventListener(TouchEvent.TOUCH, positioningShip);
					
					_shipTiles.x = -50;
					_shipTiles.y = -50;
					
					Mouse.show();
					
					for(var i:int = 0; i < _touchedShip.size; i ++){
						
						_myMap[xP + i][yP] = _touchedShip.size;
						point = new Point(xP + i, yP);
						position.push(point);
					}
					
					setTouchableShips(true);
					
				}
				
				if(_shipToPlace.rotation != 0){
					
					if(_touchedShip.size % 2 == 0)
						xP --;	
					
					_shipToPlace.x = _shipTiles.x; 
					_shipToPlace.y = _shipTiles.y;
					_myGrid.addChild(_shipToPlace);
					_shipToPlace.alpha = 1;
					
					this.removeEventListener(TouchEvent.TOUCH, movingShip);
					_myGrid.removeEventListener(TouchEvent.TOUCH, positioningShip);
					
					_shipTiles.x = -50;
					_shipTiles.y = -50;
					
					Mouse.show();
					
					for(var j:int = 0; j < _touchedShip.size; j ++){
						
						_myMap[xP][yP + j] = _touchedShip.size;
						point = new Point(xP, yP + j);
						position.push(point);
					}
					
					setTouchableShips(true);
				}
				
				//debug
				showMap(_myMap);
				
				_shipToPlace.touchable = true;
				_shipToPlace.addEventListener(TouchEvent.TOUCH, onShipTouch);
				_shipToPlace.position = position;
				_shipToPlace.placed = true;
				
				_placedShips.push(_shipToPlace);
				_totalAttackPower += _shipToPlace.attackPower;
				
				if(!_touchedShip.placed)
					updateTilesCounter(_shipToPlace.size);
				
				
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