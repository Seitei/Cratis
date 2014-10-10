package game
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
    import flash.utils.setTimeout;

    import interfaces.IGame;
	
	import ships.Ship;
	import ships.ShipFactory;

	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
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
	import starling.utils.AssetManager;
	import starling.utils.Color;
	import starling.utils.HAlign;
	
	import utils.AlphaSprite;
	import utils.Border;
	import utils.ExtendedButton;
    import utils.SimpleBar;
    import utils.Utils;
	
	public class BattleShip extends Sprite implements IGame
	{
		
		private static const TILES:int = 10;
		private static const TILE_SIZE:int = 27;
		private static const MINIMUM_COST_TO_SPEND:int = 12; 
		private static const AVAILABLE_COST:int = 15;
		
		//WRITE //READ //PRODUCTION
		//private static const ALPHA_SPRITE_MODE:String = "production";
		private static const ALPHA_SPRITE_MODE:String = "read";
		
		private var _myGrid:Sprite;
		private var _enemyGrid:Sprite;
		private var _myMap:Array;
		private var _enemyFleet:Array;
		
		private var _carrier:Ship;
		private var _patrol:Ship;
		private var _submarine:Ship;
		private var _cruiser:Ship;
		private var _destroyer:Ship;
		private var _battleship:Ship;
		private var _shipToPlace:Ship;
		private var _shipTiles:Sprite;
		private var _touchedShip:Ship;
		private var _myFleet:Array;
		private var _myRoster:Array;
		private var _enemyRoster:Array;
		private var _spent:int;
		private var _doneButton:ExtendedButton;
		private var _fleetRoster:Array;
		private var _totalAttackPower:int;
		private var _myAttacks:Array;
		private var _enemyAttacks:Array;
		private var _tile:Sprite;
		private var _attackedTiles:Array;
		private var _player:Player;
		private var _assetManager:AssetManager;
		private var _costBar:SimpleBar;
		private var _myAttackBar:SimpleBar;
		private var _phaseMessageContent:Sprite;
		private var _myFleetCondensed:Array;
		private var _shipFactory:ShipFactory;
		private var _enemyHp:int;
		private var _enemyAttackPower:int;
		private var _myHitTiles:Array;
		private var _enemyHitTiles:Array;
		private var _myWaterTiles:Array; 
		private var _enemyWaterTiles:Array;
		
		public function BattleShip(player:Player, assetManager:AssetManager)
		{
			_player = player;
			_assetManager = assetManager;
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			_myFleetCondensed = new Array();
			
			this.addEventListener("onShipTouch", onShipTouch);
			this.addEventListener("onShipSunk", onShipSunk);
			this.addEventListener(Event.ADDED, onChildAdded);
			this.addEventListener(Event.REMOVED, onChildRemoved);
			
			_myRoster = new Array();
			_enemyRoster = new Array();
			_myHitTiles = new Array();
			_myWaterTiles = new Array();
			_enemyHitTiles = new Array();
			_enemyWaterTiles = new Array();

		}
		
		private function onAdded(e:Event):void {
			
			this.addEventListener(KeyboardEvent.KEY_DOWN, onDeactivateAlphaSprite);
			//background
			var bgImage:Image = new Image(_assetManager.getTexture("background"));
			addChild(bgImage);
			_phaseMessageContent = new Sprite();
			_myAttacks = new Array();
			_enemyAttacks = new Array();
			
			_player.turn = new Turns();
			
			_attackedTiles = new Array();
			
			buildGrids();
			initShips();
			createCostBar();
			createAttackBar();
			
			//visual aid used to select where to attack
			_tile = Border.createBorder(TILE_SIZE, TILE_SIZE, Color.GRAY, 2);
			_tile.x = -50;
            _tile.alpha = 0.75;
			_enemyGrid.addChild(_tile);
			
			//done button
			var upState:Image = new Image(_assetManager.getTexture("done_button_up"));
			upState.name = "up0000";
			var hoverState:Image = new Image(_assetManager.getTexture("done_button_hover"));
			hoverState.name = "hover0000";
			var downState:Image = new Image(_assetManager.getTexture("done_button_hover"));
			downState.name = "down0000";
			var disabledState:Image = new Image(_assetManager.getTexture("done_button_disabled"));
			disabledState.name = "disabled0000";
			
			var buttonsStates:Array = new Array;
			buttonsStates.push(upState, downState, hoverState, disabledState);
			
			_doneButton = new ExtendedButton(buttonsStates);
			_doneButton.enabled = false;
			_doneButton.name = "done_button";
			
			_doneButton.addEventListener("buttonTriggeredEvent", onMyTurnEnd);
			addChild(_doneButton);
			
			_myFleet = new Array();
			_enemyFleet = new Array();
			
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
				 "var_property": [_doneButton, "enabled", false],
                 "var_method": [_myAttackBar, "writeTotalUnits"]
				},
				//result
				{
					"method": [displayShips] 
				},
				//send
				 _myFleetCondensed, 
				//receive
				 processEnemyFleetCondensed,
				//lifespan
				1,
				{"showMessage": showMessage, "phrase": "PLACE YOUR SHIPS"}	
			); 
			
			
			//the attack/action phase
			_player.turn.createState(
				//state name
				"ATTACKING",
				//start
				{
				 "var_property1": [_enemyGrid, "touchable", true],
				 "var_method": [_enemyGrid, "addEventListener", TouchEvent.TOUCH, onEnemyGridTouched],
				 "var_property2": [_doneButton, "enabled", false],
				 "method": [resetAttackTurn]
				},
				//end
				{
				 "var_property1": [_enemyGrid, "touchable", false], 
				 "var_method": [_enemyGrid, "removeEventListener", TouchEvent.TOUCH, onEnemyGridTouched],
				 "var_property2": [_doneButton, "enabled", false]
				},
				//result
				{
					"method": [displayAttacks] 
				},
				//send
				 _myAttacks,
				//receive
				 processEnemyAttacks,
				 0,
				{"showMessage": showMessage, "phrase": "ATTACK!"}	
			);
			
		}
	
	   private function processEnemyAttacks(attacks:Array):void {
		   
		   _enemyAttacks = attacks;
		   
	   }
		
	   private function resetAttackTurn():void {
		   
		   _myAttacks.splice(0);
		   _myAttackBar.setValue("full"); 

	   }
	   
	   private function processEnemyFleetCondensed(fleet:Array):void {
			
			//reconstruct enemy fleet
			
			for each(var obj:Object in fleet){
				
				var ship:Ship = _shipFactory.buildShip(obj.shipName, "placed", obj.position);
				_enemyFleet.push(ship);
				
				ship.rotation = obj.position[0].x == obj.position[1].x ? Math.PI/2 : 0;  
				ship.alpha = 0;
				ship.touchable = false;
				
				ship.x = obj.position[0].x * TILE_SIZE;
				ship.y = obj.position[0].y * TILE_SIZE;
				
				ship.x += ship.rotation ? ship.pivotY : ship.pivotX;
				ship.y += ship.rotation ? ship.pivotX : ship.pivotY;
				
				_enemyGrid.addChild(ship);
					
				_enemyHp += ship.size;
				_enemyAttackPower += ship.attackPower;
			}
			
			_enemyFleet.sortOn("size", [Array.DESCENDING]);
			
		}
		
		private function displayShips():void {
			
			fadeUI();

            _enemyGrid.addEventListener( TouchEvent.TOUCH, onEnemyGridTouched);

			_myFleet.sortOn("size", [Array.DESCENDING]);

            for each(var ship:Ship in _myFleet){
                ship.showDeleteButton(false);
            }

			for (var i:int = 0; i < _myFleet.length; i++){
				
				var clonedShip:Ship = _myFleet[i].clone("fleet", 0);
				clonedShip.pivotX = clonedShip.pivotY = 0;
                addChild(clonedShip);
              	clonedShip.x = -90;
				clonedShip.y = 370 + i * 32;

				var tween:Tween = new Tween(clonedShip, 2, Transitions.EASE_IN_OUT);
				tween.animate("x", 45);
				Starling.juggler.add(tween);
				
				clonedShip.id = _myFleet[i].id;
				_myRoster.push(clonedShip);
				
			}
			
			for (var j:int = 0; j < _enemyFleet.length; j++){
				
				var clonedShip2:Ship = _enemyFleet[j].clone("fleet", 0);
                clonedShip2.pivotX = clonedShip2.pivotY = 0;
                addChild(clonedShip2);
                clonedShip2.scaleX = -1;
				clonedShip2.x = stage.stageWidth + 80;
				clonedShip2.y = 370 + j * 32;
				
				var tween2:Tween = new Tween(clonedShip2, 2, Transitions.EASE_IN_OUT);
				tween2.animate("x", stage.stageWidth - 45);
				Starling.juggler.add(tween2);
				
				clonedShip2.id = _enemyFleet[j].id;
				_enemyRoster.push(clonedShip2);
				
			}

            setTimeout(onTweensComplete, 2);

		}
		
		private function onTweensComplete():void {
			
			_player.turn.start();
			
		}
		
		private function fadeUI():void {
			
			for each(var ship:Ship in _fleetRoster){
				Utils.fadeTo(ship, 1, Transitions.LINEAR);
			}
			
			Utils.fadeTo(_costBar, 1, Transitions.LINEAR);

            Utils.moveTo(_myAttackBar, _myAttackBar.x, _costBar.y, 1, Transitions.EASE_IN_OUT);

		}
		
		private function displayAttacks():void {
			
			//remove attacked tiles
			var deleteArray:Array = new Array();
			
			for each(var image:Image in _attackedTiles){
				Utils.fadeTo(image, 1, Transitions.LINEAR);
				deleteArray.push(image);
			}
			
			for each(var attackedTile:Image in deleteArray) 
				_attackedTiles.splice(_attackedTiles.indexOf(attackedTile), 1);
			
			//display your attacks
			checkIfHit(_myAttacks, _enemyFleet, _enemyGrid, _myHitTiles, _myWaterTiles, true);
			
			//display enemy attacks
			checkIfHit(_enemyAttacks, _myFleet, _myGrid, _enemyHitTiles, _enemyWaterTiles, false);
			
			
			_player.turn.start();
			
		}
		
		private function checkIfHit(attacks:Array, fleet:Array, grid:DisplayObjectContainer, hitTiles:Array, waterTiles:Array, itsMe:Boolean):void {
			
			var hit:Boolean = false;
			
			for each(var point:Point in attacks){
				
				hit = false;
				
				for each(var ship:Ship in fleet){
					
					for each(var posPoint:Point in ship.position){
						
						if(point.equals(posPoint)){
							
							var hitI:Image = itsMe ? new Image(_assetManager.getTexture("my_hit")) : new Image(_assetManager.getTexture("his_hit"));
							hitI.x = point.x * TILE_SIZE + 1;
							hitI.y = point.y * TILE_SIZE + 1;
							grid.addChild(hitI);
							hitI.alpha = 0;
							hitTiles.push(hitI);
								
							var tween:Tween = new Tween(hitI, 1, Transitions.LINEAR);
							tween.animate("alpha", 1);
							Starling.juggler.add(tween);
							
							hit = true;

							ship.receiveDamage(1);
							
							break;
						}
					}
				}
				
				if(!hit){
					
					var water:Image = new Image(_assetManager.getTexture("water"));
					water.x = point.x * TILE_SIZE + 1;
					water.y = point.y * TILE_SIZE + 1;
					grid.addChild(water);
					water.alpha = 0;
					waterTiles.push(water);
					
					var tween2:Tween = new Tween(water, 1, Transitions.LINEAR);
					tween2.animate("alpha", 1);
					Starling.juggler.add(tween2);
					
				}
			}
		}
		
		private function onShipSunk(e:Event, ship:Ship):void {
			
			var myShip:Boolean = false;
			var deleteArray:Array = new Array();
			
			if(_myFleet.indexOf(ship) != -1)
				myShip = true;
				
			for each(var posPoint:Point in ship.position){
				
				for each(var hitT:Image in myShip ? _enemyHitTiles : _myHitTiles){
					
					if(new Point(Math.round(hitT.x / TILE_SIZE), Math.round(hitT.y / TILE_SIZE)).equals(posPoint)){
						
						Utils.fadeTo(hitT, 1, Transitions.LINEAR);
						deleteArray.push(hitT);	
						continue;
						
					}
				}
			}
			
			for each(var tileI:Image in deleteArray){
				_enemyHitTiles.splice(_enemyHitTiles.indexOf(tileI), 1);
			}
				
			for each(var shipSunk:Ship in myShip ? _myRoster : _enemyRoster){
				
				if(shipSunk.id == ship.id){
					Utils.fadeTo(shipSunk, 1, Transitions.LINEAR, 0.2);
					eraseShip(ship, myShip, true);
					break;
				}
			}
			
			if(myShip)
				_myAttackBar.totalUnits = _myAttackBar.totalUnits - ship.attackPower;

			
		}
		
		private function eraseShip(ship:Ship, myShip:Boolean, fade:Boolean = false):void {
			
			//var map:Array = myShip ? _myMap : _enemyMap; 
			var fleet:Array = myShip ? _myFleet : _enemyFleet;
			var roster:Array = myShip ? _myRoster : _enemyRoster;
			var grid:DisplayObjectContainer = myShip ? _myGrid : _enemyGrid;
			
			/*for each(var point:Point in ship.position){
				map[point.x][point.y] = 0;
			}*/
			
			fleet.splice(fleet.indexOf(ship), 1);
			
			if(myShip){
				
				for each(var obj:Object in _myFleetCondensed) {
					
					if(obj.shipName == ship.shipName){
						
						for each(var point2:Point in ship.position){
							
							if(point2.equals(obj.position[0])){
								_myFleetCondensed.splice(_myFleetCondensed.indexOf(obj), 1);
								break;
								
							}
						}
					}
				}
			}
			
			if(fade)
				Utils.fadeTo(ship, 1, Transitions.LINEAR, 0.2);
			else
				grid.removeChild(ship, true);
			
			if(roster.length)
				roster.splice(roster.indexOf(ship), 1);
			
		}
		
		
		private function showMessage(message:String):void {
			
			//content
			var messageTxt:TextField = new TextField(stage.stageWidth, stage.stageHeight, message, "Consolas", 50, Color.BLACK);
			messageTxt.hAlign = HAlign.CENTER;
			//messageTxt.y = stage.stageHeight / 2;
			_phaseMessageContent.addChild(messageTxt);
			addChild(_phaseMessageContent);
			
			//transition effect
			Utils.fadeTo(messageTxt, 0.5, Transitions.EASE_IN);
			
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
				
				var point:Point = new Point(xP, yP);
				
				if(checkIfDuplicatedAttack(point))
					return;		
				
				_myAttacks.push(point);	
				var attackedTile:Image = new Image(_assetManager.getTexture("attacked_tile"));
				attackedTile.x = _tile.x + 1;
				attackedTile.y = _tile.y + 1;
				_enemyGrid.addChild(attackedTile);
				_attackedTiles.push(attackedTile);
				
				_myAttackBar.update(-1);
				
				if(_myAttackBar.currentUnits == 0){
					_enemyGrid.removeEventListener(TouchEvent.TOUCH, onEnemyGridTouched);
					_doneButton.enabled = true;
				}
			}
		}
		
		private function checkIfDuplicatedAttack(point:Point):Boolean {
			
			for each(var p:Point in _myAttacks){
				
				if(p.x == point.x && p.y == point.y)
					return true;
				
			}
			
			return false;
			
		}
		
		private function onMyTurnEnd(e:Event):void {
			
			_player.turn.end();
			
		}
		
		private function initShips():void {
			
			_shipFactory = ShipFactory.getInstance();
			_shipFactory.assetManager = _assetManager;
			
			_carrier = _shipFactory.buildShip("carrier", "detailed", null);
			_carrier.name = "carrier" + "_alpha";
			addChild(_carrier);
			
			_battleship = _shipFactory.buildShip("battleship", "detailed", null);
			_battleship.name = "battleship" + "_alpha";
			addChild(_battleship);
			
			_destroyer = _shipFactory.buildShip("destroyer", "detailed", null);
			_destroyer.name = "destroyer" + "_alpha";
			addChild(_destroyer);
			
			_submarine = _shipFactory.buildShip("submarine", "detailed", null);
			_submarine.name = "submarine" + "_alpha";
			addChild(_submarine);
			
			_patrol = _shipFactory.buildShip("patrol", "detailed", null);
			_patrol.name = "patrol" + "_alpha";
			addChild(_patrol);
			
			_cruiser = _shipFactory.buildShip("cruiser", "detailed", null);
			_cruiser.name = "cruiser" + "_alpha";
			addChild(_cruiser);
			
			_fleetRoster = new Array();
			_fleetRoster.push(_carrier, _destroyer, _patrol, _battleship, _submarine, _cruiser);
			//_shipsToPlace.push(_carrier);
		}
		
		private function setTouchableShips(value:Boolean):void {
			
			_patrol.touchable = value;
			_battleship.touchable = value;
            _carrier.touchable = value;
            _submarine.touchable = value;
            _cruiser.touchable = value;
            _destroyer.touchable = value;

			for each(var ship:Ship in _myFleet){
				ship.touchable = value;
			}
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

					var border:Sprite = Border.createBorder(_touchedShip.size * TILE_SIZE - 1, TILE_SIZE - 1, Color.BLACK, 3);
                    border.y ++;
                    _shipTiles = new Sprite();
                    _shipTiles.addChild(border);
                    _shipTiles.alpha = 0.15;
                    _shipTiles.x = -50;
					_shipTiles.y = -50;
					_shipTiles.pivotX = Math.floor(_shipTiles.width / 2);
					_shipTiles.pivotY = Math.floor(_shipTiles.height / 2);
					_shipTiles.rotation = _touchedShip.rotation;

					_myGrid.addChild(_shipTiles);

					break;

                case "delete":

                    _costBar.update(_touchedShip.cost);
                    _myAttackBar.update(-_touchedShip.attackPower)
                    _spent -= _touchedShip.cost;
                    eraseShip(_touchedShip, true);
                    checkShipStates();

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
			
			_myAttackBar.update(_shipToPlace.attackPower);
			
			updateCost(_shipToPlace.cost);
			
			//Utils.showMap(_myMap);
		}


        private function checkIfCanPlaceShip(shipToPlace:Ship, rectangle:Rectangle = null, touchedShip:Ship = null):Boolean {

            var canPlace:Boolean = true;
            var rec:Rectangle;

            if(rectangle)
                rec = rectangle;
            else
                rec = shipToPlace.getBounds(this);

            //the ship must be contained inside the grid

            var gridRec = _myGrid.getBounds(this);


            if(_myGrid.getBounds(this).containsRect(rec)){

                //check overlaping between ships
                for each(var ship:Ship in _myFleet) {

                    if(!touchedShip){

                        if(ship != shipToPlace){

                            if(rec.intersects(ship.getBounds(this))){

                                canPlace = false;
                                break;

                            }
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


		private function writeShip(ship:Ship, xTile:int, yTile:int):void {
			
			for(var i:int = 0; i < ship.size; i ++){
				
				var point:Point = new Point(ship.rotation ? xTile : xTile + i, ship.rotation ? yTile + i: yTile) 
				_myMap[point.x][point.y] = ship.size;
				ship.position.push(point);
				
			}
			
			_myFleet.push(ship);
			_myFleetCondensed.push({"shipName": ship.shipName, "position": ship.position});
			
		}
		
		private function onRotatingShip(e:KeyboardEvent):void {
			
			if(e.charCode == Keyboard.SPACE){
				
				_shipToPlace.rotation = _shipToPlace.rotation == 0 ? Math.PI / 180 * 90 : 0;
				_shipTiles.rotation = _shipToPlace.rotation;
				
			}
		}
		
		private function onDeactivateAlphaSprite(e:KeyboardEvent):void {
			
			if(e.keyCode == Keyboard.CONTROL){
				
				AlphaSprite.getInstance().changeMode();
				
			}
		}
		
		private function createCostBar():void {
		
			_costBar = new SimpleBar(_assetManager.getTexture("cost_icon"), AVAILABLE_COST, 1);
			addChild(_costBar);
			_costBar.name = "costBar";

		}
		
		private function onChildAdded(e:Event):void {
			
			if(DisplayObject(e.target).name)
				AlphaSprite.getInstance().addNew(e.target);
		}
		
		private function onChildRemoved(e:Event):void {
			
			if(DisplayObject(e.target).name)
				AlphaSprite.getInstance().remove(e.target);
		}
		
		private function updateCost(cost:int):void {
			
			_spent += cost;
			_costBar.update(-cost);
			
			if(!_doneButton.enabled && _spent >= MINIMUM_COST_TO_SPEND){
				_doneButton.enabled = true;
			}
			
			checkShipStates();

		}

        private function checkShipStates():void {

            //loop though ships to see which ones can't be placed because of their cost
            for each(var ship:Ship in _fleetRoster){

                if(ship.cost > AVAILABLE_COST - _spent){
                    ship.disable();
                }
                else {
                    ship.enable();
                }
            }

        }

        private function createAttackBar():void {
			
			_myAttackBar = new SimpleBar(_assetManager.getTexture("attack_icon"), 0, 1);
			_myAttackBar.name = "my_attack_bar";
			addChild(_myAttackBar);

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
				_shipTiles.x += Math.ceil(TILE_SIZE / 2) * (_touchedShip.size % 2);
				
				_shipTiles.y = yP * TILE_SIZE + _shipTiles.pivotY;
				
				if((_touchedShip.size % 2) == 0 && _shipToPlace.rotation != 0){
					_shipTiles.x -= Math.floor(TILE_SIZE / 2) - 1;
					_shipTiles.y -= Math.floor(TILE_SIZE / 2);
				}

                if((_touchedShip.size % 2) == 1 && _shipToPlace.rotation != 0){
                    _shipTiles.x += 1;
                    _shipTiles.y += 1;
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
				
				eraseShip(_touchedShip, true);
				
				writeShip(_shipToPlace, xP, yP);
				
				//debug
				//showMap(_myMap);
				
			}
		}
		
		private function buildGrids():void {
			
			_myGrid = new Sprite();
			_myGrid.x = 46;
			_myGrid.y = 39;
            var dummy:Quad = new Quad(270, 270);
            dummy.alpha = 0;
            _myGrid.addChild(dummy);
			addChild(_myGrid);
			
			_enemyGrid = new Sprite();
			_enemyGrid.x = 354;
			_enemyGrid.y = 39;
            var dummy2:Quad = new Quad(270, 270);
            dummy2.alpha = 0;
            _enemyGrid.addChild(dummy2);
			addChild(_enemyGrid);

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
		
		
		
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
