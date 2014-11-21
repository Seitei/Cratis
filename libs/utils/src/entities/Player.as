package entities {


import flash.utils.Dictionary;

import netcode.NetConnect;

import starling.events.Event;
	import starling.events.EventDispatcher;

	public class Player extends EventDispatcher
	{
		private var _userName:String;
        private var _avatarUrl:String;

		public function Player(userName:String)
		{
            _userName = userName;
            _avatarUrl = "http://localhost/avatars/avatar_" + _userName + ".png";
		}
		
        public function get avatarUrl():String {

            return _avatarUrl;

        }

        public function get userName():String {

            return _userName;

        }

	}































}