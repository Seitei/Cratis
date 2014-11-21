package helpers {
import entities.Player;

import flash.display.Bitmap;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import starling.display.DisplayObject;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.Color;

public class Portrait extends Sprite{


    private var _userName:String;
    private var _nameTxT:TextField;
    private var _avatarContainer:Sprite;
    private var _avatarDummy:Quad;

    public function Portrait() {

        //user name
        _nameTxT = new TextField(100, 30, "PLAYER");
        _nameTxT.color = Color.BLACK;
        _nameTxT.fontSize = 20;
        _nameTxT.y = 50;
        addChild(_nameTxT);

        //user avatar
        _avatarContainer = new Sprite();
        _avatarDummy = new Quad(50, 50, Color.GRAY);
        _avatarContainer.addChild(_avatarDummy);
        addChild(_avatarContainer)

    }

    public function setPlayer(player:Player):void {

        _avatarContainer.removeChild(_avatarDummy, true);
        loadAvatar(player.avatarUrl);

        _userName = player.userName;
        _nameTxT.text = _userName;
        addChild(_nameTxT);

    }


    private function loadAvatar(url:String):void {

        var urlRequest:URLRequest = new URLRequest(url);
        var loaderContext:LoaderContext = new LoaderContext();
        var gameLoader:Loader = new Loader();
        gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
        gameLoader.load(urlRequest, loaderContext);

    }

    private function onCompleteHandler(e:Event):void {

        var loaderInfo:LoaderInfo = e.target as LoaderInfo;
        var bitmap:Bitmap = Bitmap(loaderInfo.content);

        var texture:Texture = Texture.fromBitmap(bitmap);

        var avatar:Image = new Image(texture);

        _avatarContainer.addChild(avatar);


    }


}








}
