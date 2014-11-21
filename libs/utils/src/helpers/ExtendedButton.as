package helpers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/** Dispatched when the user triggers the button. Bubbles. */
	//[Event(name="triggered", type="starling.events.Event")]
	
	/**
	 *  A custom button that extends the Button class that comes with Starling 
	 */ 
	
	public class ExtendedButton extends Sprite
	{
		private static const MAX_DRAG_DIST:Number = 50;
		
		private var _data:Object;
		private var _buttonImage:Image;
		
		private var _enabled:Boolean;
		private var _isDown:Boolean;
		private var _isHovered:Boolean;
		private var _isSelected:Boolean;
		private var _useHandCursor:Boolean;
		private var _texturesArray:Vector.<Texture>;
		private var _texturesDic:Dictionary;
		private var _isMobile:Boolean;
		private var _isCheckBox:Boolean;
		private var _textField:TextField;
        private var _textBounds:Rectangle;

		/** Creates a button with a vector of textures or an array of display objects that represent the different states*/
		public function ExtendedButton(buttonStates:*, data:Object = null, isMobile:Boolean = true, isCheckBox:Boolean = false)
		{
			if (buttonStates.length == 0) throw new ArgumentError("Textures vector needs to have at least one texture state (up)");
			
			_data = data ? data : new Object();
			_isMobile = isMobile;
			_isCheckBox = isCheckBox;
			_enabled = true;
			_isDown = false;
			_useHandCursor = true;
			
			setTextureStates(buttonStates);
			
			_buttonImage = new Image(_texturesDic["up"]);
			_buttonImage.readjustSize();
			addChild(_buttonImage);
			
			addEventListener(TouchEvent.TOUCH, onTouch);

            _textBounds = new Rectangle(0, 0, _buttonImage.width, _buttonImage.height);

        }
		
		public function clone():ExtendedButton{
			
			var clonedButton:ExtendedButton = new ExtendedButton(this._texturesArray);
			return clonedButton;
			
		}
		
		
		private function setTextureStates(buttonStates:*):void {
			
			if (buttonStates.length == 0) throw new ArgumentError("Textures vector needs to have at least one texture state (up)");
			
			_texturesDic = new Dictionary();
			
			if(buttonStates[0] is DisplayObject){
				_texturesArray = new Vector.<Texture>;
				var count:int = 0;
				for each(var state:DisplayObject in buttonStates){
					var rt:RenderTexture = new RenderTexture(state.width, state.height);
					rt.draw(state);
					_texturesArray[count] = rt;
					rt.id = state.name;
					count ++;
				}
			}
			else {
				_texturesArray = buttonStates;
			}
			
			for (var i:int = 0; i < buttonStates.length; i ++){
				
				var id:String = _texturesArray[i].id;
				id = id.substr(0, id.indexOf("00"));
				
				_texturesDic[id] = _texturesArray[i];
			}
		}
		
		public function get data():Object
		{
			return _data;
		}

		public function set data(data:Object):void
		{
			_data = data;
		}
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}

		private function resetContents():void {
			_isDown = false;
			_buttonImage.texture = _isHovered && !_isMobile ? _texturesDic["hover"] : _texturesDic["up"];
			_buttonImage.readjustSize();
		}
		
		private function onTouch(event:TouchEvent):void
		{
			if (!_enabled)
				return;
			
			var touch:Touch = event.getTouch(this);
			var buttonRect:Rectangle = getBounds(stage);

			if(_useHandCursor && _enabled && event.interactsWith(this)){
				Mouse.cursor = MouseCursor.BUTTON;
			}
			else {
				if (touch){
					if(touch.globalX < buttonRect.x || touch.globalY < buttonRect.y || touch.globalX > buttonRect.x + buttonRect.width || touch.globalY > buttonRect.y + buttonRect.height) {
						Mouse.cursor = MouseCursor.AUTO;
					}
					else {
						Mouse.cursor = MouseCursor.BUTTON;
					}
				}
			}
			
			//added a hover touch detection
			var hoverTouch:Touch = event.getTouch(DisplayObject(event.currentTarget), TouchPhase.HOVER);
			
			if(!_isSelected){
				if(hoverTouch) {
					
					_buttonImage.texture = _texturesDic["hover"];
					_buttonImage.readjustSize();
				}
				else {
					
					_buttonImage.texture = _texturesDic["up"];
					_buttonImage.readjustSize();
				}
			}
			
			
			if (!_enabled || touch == null){
				Mouse.cursor = MouseCursor.AUTO;
				return;
			}
			
			if (touch.phase == TouchPhase.BEGAN && !_isDown)
			{
				if(_isCheckBox){
					selectDownState(!_isSelected);
				}
				else {
					_buttonImage.texture = _texturesDic["down"];
					_buttonImage.readjustSize();
					_isDown = true;
				}
			}
			else if (touch.phase == TouchPhase.MOVED && _isDown)
			{
				// reset button when user dragged too far away after pushing
				
				if (touch.globalX < buttonRect.x - MAX_DRAG_DIST ||
					touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
					touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
					touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
				{
					resetContents();
				}
			}
			else if (touch.phase == TouchPhase.ENDED && _isDown)
			{
				if (touch.globalX < buttonRect.x ||
					touch.globalY < buttonRect.y ||
					touch.globalX > buttonRect.x + buttonRect.width ||
					touch.globalY > buttonRect.y + buttonRect.height) {
				
					_isHovered = false;	
				}
				else {
					_isHovered = true;
				}
				
				resetContents();
				
				/*var position:Point = this.localToGlobal(new Point(0, 0));
				_data.position = position;*/
				dispatchEventWith("buttonTriggeredEvent", true, _data);
			}
		}
		
		public function selectDownState(value:Boolean):void {
			_isSelected = value;
			_buttonImage.texture = value ? _texturesDic["down"] : _texturesDic["up"];
			_buttonImage.readjustSize();
			
			if(_isCheckBox){
				_data.selected = _isSelected;				
				dispatchEventWith("buttonTriggeredEvent", true, _data);
			}
		}
		
		public function selectEnabledState(value:Boolean):void {
			_buttonImage.texture = value ? _texturesDic["up"] : _texturesDic["disabled"];
			_buttonImage.readjustSize();
		}
		
		/** Indicates if the button can be triggered. */
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void
		{
			if (_enabled != value)
			{
				_enabled = value;
				resetContents();
				if(_texturesDic["disabled"])
					selectEnabledState(value);
					
			}
		}

        private function createTextField():void
        {
            if (_textField == null)
            {
                _textField = new TextField(_textBounds.width, _textBounds.height, "");
                _textField.vAlign = VAlign.CENTER;
                _textField.hAlign = HAlign.CENTER;
                _textField.touchable = false;
                _textField.autoScale = true;
            }

            _textField.width  = _textBounds.width;
            _textField.height = _textBounds.height;
            _textField.x = _textBounds.x;
            _textField.y = _textBounds.y;
        }

        public function set text(value:String):void
        {
            if (value.length == 0)
            {
                if (_textField)
                {
                    _textField.text = value;
                    _textField.removeFromParent();
                }
            }
            else
            {
                createTextField();
                _textField.text = value;

                if (_textField.parent == null)
                    addChild(_textField);
            }
        }
		
	}



































}