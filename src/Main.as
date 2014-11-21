package {


    import entities.Player;
import entities.iGame;

import flash.external.ExternalInterface;

import flash.net.NetGroup;

import flash.ui.Keyboard;


import flash.utils.Dictionary;

import helpers.Multigame;

import netcode.NetConnect;

import starling.display.Sprite;
	import starling.events.Event;
    import starling.events.KeyboardEvent;
import starling.text.TextField;
import starling.utils.AssetManager;

    public class Main extends starling.display.Sprite
	{
		
        private static var USER_STUB:Boolean = true;
		private static var _instance:Main;
		private var _assetManager:AssetManager;
        private var _games:Dictionary;
        private var _currentGame:Sprite;
        private var _currentGameSlot:int;
        private static var defaultOptions:Object = {numberOfPlayers: 2};
        private var _userStub:UserStub;
        private var _nc:NetConnect;
        private var _userName:String;
        private var _player:Player;
        private var _auxArray:Array;

        public function Main()
		{
            _instance = this;

            ExternalInterface.addCallback("init", init);
            ExternalInterface.addCallback("loadGame", selectGame);
            ExternalInterface.addCallback("changeGame", changeGame);

            _assetManager = new AssetManager();
			addEventListener(starling.events.Event.ADDED_TO_STAGE, onAdded);

			//hardcoded for now, it has to come from the web

            if(USER_STUB){
                _userStub = new UserStub();
                addChild(_userStub);
            }

            _games = new Dictionary();
            _auxArray = new Array();

            //addEventListener("nameSelected", onNameSelected);
            addEventListener("gameConstructionComplete", onGameConstructionComplete);

		}

        private function init(userName:String):void {

            onNameSelected(null, userName);

        }

        private function onNameSelected(e:Event, selectedName:String):void {

            removeChild(_userStub);
            _userName = selectedName;

            _nc = new NetConnect(_userName);
            _nc.addEventListener("matchInfoReceived", onMatchInfoReceived);
            _nc.addEventListener("postingNotify", onPostingNotify);

            _player = new Player(selectedName);

        }


        private function onAdded(e:starling.events.Event):void {

            //addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            ExternalInterface.call("JSListener.cratisConstructionComplete();");

        }

        private function selectGame(gameName:String, gameID:String):void {


           var options:Object = new Object();
           options.numberOfPlayers = 2;

           addGame(gameName, gameID);


        }

        private function addGame(gameName:String, gameID:String, options:Object = null):void {

            if(!options){
                options = defaultOptions;
            }

            _nc.addGame(gameName, options, gameID);

        }

        private function onMatchInfoReceived(e:Event, matchData:Object):void {

            _games[matchData.netGroup] = matchData;

            Multigame.loadGame(matchData.gameName + "/Main.swf", onGameLoadComplete, matchData);

        }

        private function onGameLoadComplete(classInfo:Object, matchData):void {

           var game:Sprite = new classInfo["gameClass"](_player, _assetManager, matchData.matchID, matchData.gameID);
           addChild(game);

           game.addEventListener("sendData", onSendData);
           game.addEventListener("gameAssetsLoadingProgress", onGmeAssetsLoadingProgress);

           _games[matchData.netGroup] = game;

           //temporary solution for testing purposes
           _auxArray.push(game);

        }

        private function onGmeAssetsLoadingProgress(e:Event, ratio:Number):void {

            ExternalInterface.call("gameLoadProgress", Math.floor(ratio * 100));

        }


        private function onSendData(e:Event, data:Object):void {

            for( var netGroup:NetGroup in _games){

                if(_games[netGroup] == data.game){

                    _nc.sendMessage(netGroup, data.data, "action");

                }


            }
        }

        private function onGameConstructionComplete(e:Event, game:Sprite):void {

            game.visible = true;

        }

        public function getGameByNetGroup(netGroup:NetGroup):iGame {

            return _games[netGroup];

        }


        private function onPostingNotify(e:Event, data:Object):void {

            var message:Object = data.message;

            if(data.message.type == "neighbourConnected"){

                var player:Player = new Player(message.data.userName);
                var playerAlreadyAdded:Boolean = _games[data.netGroup].addPlayer(player);

                if(!playerAlreadyAdded){
                    //notify the web that a new player has connected
                }

            }

            if(data.message.type == "action"){

                _games[data.netGroup].onEnemyTurnEnd(data.message);

            }

        }

        public function changeGame(slotID:int):void {

            _currentGameSlot = slotID;

            showGame(slotID);

        }

        private function showGame(slotID:int):void {

            if(_currentGame){

                _currentGame.visible = false;

            }

            _currentGame = _auxArray[slotID];
            _currentGame.visible = true;

        }


        public static function getInstance():Main {

            if(!_instance)
                _instance = new Main();

            return _instance;

        }

    }
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}