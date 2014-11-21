package netcode
{


import flash.net.GroupSpecifier;
import flash.net.NetGroup;
import flash.net.NetGroup;
import flash.net.NetGroup;
import flash.net.Responder;
import flash.utils.setTimeout;

import starling.display.DisplayObject;

import starling.events.EventDispatcher;
	
	public class NetConnect extends starling.events.EventDispatcher
	{

		import flash.events.NetStatusEvent;
		import flash.geom.Point;
		import flash.net.NetConnection;
		import flash.net.registerClassAlias;
		import flash.utils.Dictionary;

		
		registerClassAlias("Point", Point);
		registerClassAlias("Vector", Vector);
		registerClassAlias("Point", Point);
		registerClassAlias("Dictionary", Dictionary);
		registerClassAlias("Array", Array);
		registerClassAlias("Boolean", Boolean);
		
		private const SERVER:String = "rtmfp://p2p.rtmfp.net/"; 
		private const DEVKEY:String = "cde41fe05bb01817e82e5398-2ab5d983d09f"; 

		private const HOST_NAME:String = "http://localhost";
		//private const HOST_NAME:String = "http://www.konkugames.com";
		
		private var _cirrusNc:NetConnection;

		private var _amfphpNc:NetConnection;
		
	    private var _seq:int;
		
		private var _status:String;
		private var _log:String;

		private var _matchResponder:Responder;
        private var _updateStatusResponder:Responder;
	    private var _userName:String;
        private var _users:Array;
        private var _avatarUrl:String;
        private var _sentMessages:Array;

		public function NetConnect(userName:String):void {

            _userName = userName;
            _users = new Array();
            _avatarUrl = "http://localhost/avatars/avatar_" + _userName + ".png";
            _sentMessages = new Array();

            _amfphpNc = new NetConnection();
            _amfphpNc.connect(HOST_NAME + "/Amfphp/");
            _matchResponder = new Responder(onResultMatchResponder, onFault);
            _updateStatusResponder = new Responder(onResultUpdateStatusResponder, onFault);


			_status = "waiting";
			_cirrusNc = new NetConnection();
			_cirrusNc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_cirrusNc.connect( SERVER + DEVKEY );

		}

		private function onNetStatus(event:NetStatusEvent):void {

            _log = "NET CONNECTION  : " + event.info.code;
            trace(_log);

			switch(event.info.code) {

                case "NetConnection.Connect.Success":
					onCirrusConnect();
					break;

                case "NetGroup.Connect.Success":
                    break;

				default:
					break;
			}
			

			sendStatus(_log);
			
		}

        private function onCirrusConnect():void {

        }

        private function onNetGroupStatus(e:NetStatusEvent):void {

            trace("NETGROUP INFO: ", e.info.code);

            switch(e.info.code) {

                case "NetGroup.Neighbor.Connect":
                    evaluateNeighbourConnect(e);
                    break;

                case "NetGroup.Posting.Notify":
                    evaluatePostingNotify(e);

                    break;

                default:
                    break;
            }

        }

        private function evaluateNeighbourConnect(e:NetStatusEvent):void {

           var netGroup:NetGroup = e.currentTarget as NetGroup;

           var data:Object = {userName: _userName};

           sendMessage(netGroup, data, "neighbourConnected");

        }

        //here I receive messages from neighbours
        private function evaluatePostingNotify(e:NetStatusEvent):void {

            var netGroup:NetGroup = e.currentTarget as NetGroup;
            var message:Object = e.info.message;

            trace("EVALUATE: ", message.id);

            if(_sentMessages.indexOf(message.id) == -1){

                sendMessage(netGroup, message.data, message.type, message.id);
                dispatchEventWith("postingNotify", false, {netGroup: netGroup, message: message});

                if(message.type == "neighbourConnected"){

                    _amfphpNc.call("Rendezvous.updateStatus", _updateStatusResponder, _userName, Main.getInstance().getGameByNetGroup(netGroup).matchID );

                }
            }

        }

       	public function sendStatus(status:String):void {
			dispatchEventWith("notifyStatusEvent", true, status);
		}
		
		public function sendMessage(netGroup:NetGroup, data:Object, type:String, messageID:String = null):void {

			var message:Object = new Object();
			message.data = data;
            message.type = type;
			message.sequence = _seq ++;

            if(messageID){
               message.id = messageID;
            }
            else{
                message.id = _userName + "_" + String(_seq);
            }

            netGroup.post(message);
            _sentMessages.push(message.id);

            trace("SEND: ", message.id);

		}

        //options is an object, but for now we will only use numberOfPlayers
        public function addGame(gameName:String, options:Object, gameID:String):void {

            _amfphpNc.call("Rendezvous.match", _matchResponder, _userName, gameName, options.numberOfPlayers, gameID );

        }

        public function onResultMatchResponder(response:*):void {

            for each(var user:Object in response.usersData){

                _users.push(user);

            }

            createGroup(response.match_id, response.gameName, response.gameID);

        }

        public function onResultUpdateStatusResponder(response:*):void {
        }

        private function createGroup(matchID:int, gameName:String, gameID:String):void {

            var groupSpecString:String = "com.konkugames.games/" + gameName + matchID;
            var groupSpecifier:GroupSpecifier = new GroupSpecifier(groupSpecString);

            groupSpecifier.multicastEnabled = true;
            groupSpecifier.postingEnabled = true;
            groupSpecifier.objectReplicationEnabled = true;
            groupSpecifier.routingEnabled = true;
            groupSpecifier.serverChannelEnabled = true;

            var netGroup:NetGroup = new NetGroup(_cirrusNc, groupSpecifier.groupspecWithoutAuthorizations());
            netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );

            //distribute the groupSpec string to use it as ID for organization purposes
            dispatchEventWith("matchInfoReceived", false, {netGroup: netGroup, usersData: _users, gameName: gameName, matchID: matchID, gameID: gameID});

        }

        public function onFault(response:*):void {

            trace(" ******************* ON_FAULT **********************");

            for (var key:* in response){
                trace("KEY: ", key, " VALUE: ", response[key]);
            }

            trace(" ******************* ON_FAULT **********************");

        }


    }







































}