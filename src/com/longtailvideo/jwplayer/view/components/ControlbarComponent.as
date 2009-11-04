package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	
	
	/**
	 * Sent when the user interface requests that the player play the currently loaded media
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_PLAY
	 */
	[Event(name="jwPlayerViewPlay", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 * Sent when the user interface requests that the player pause the currently playing media
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_PAUSE
	 */
	[Event(name="jwPlayerViewPause", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 * Sent when the user interface requests that the player stop the currently playing media
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_STOP
	 */
	[Event(name="jwPlayerViewStop", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 * Sent when the user interface requests that the player play the next item in its playlist
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_NEXT
	 */
	[Event(name="jwPlayerViewNext", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 * Sent when the user interface requests that the player play the previous item in its playlist
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_PREV
	 */
	[Event(name="jwPlayerViewPrev", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 * Sent when the user interface requests that the player navigate to the playlist item's <code>link</code> property
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_LINK
	 */
	[Event(name="jwPlayerViewLink", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_MUTE
	 */
	[Event(name="jwPlayerViewMute", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_FULLSCREEN
	 */
	[Event(name="jwPlayerViewFullscreen", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_VOLUME
	 */
	[Event(name="jwPlayerViewVolume", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	/**
	 *
	 *
	 * @eventType com.longtailvideo.jwplayer.events.ViewEvent.JWPLAYER_VIEW_SEEK
	 */
	[Event(name="jwPlayerViewSeek", type="com.longtailvideo.jwplayer.events.ViewEvent")]
	public class ControlbarComponent extends CoreComponent implements IControlbarComponent {
		protected var _buttons:Object = {};
		protected var _dividers:Array;
		protected var _defaultLayout:String = "[capLeft play|stop|prev|next|elapsed][time][duration|fullscreen|mute volume capRight]";
		protected var _currentLayout:String;
		protected var _layoutManager:ControlbarLayoutManager;
		protected var _width:Number;
		protected var _height:Number;
		
		
		public function ControlbarComponent(player:IPlayer) {
			super(player);
			_layoutManager = new ControlbarLayoutManager(this);
			_dividers = [];
			setupBackground();
			setupDefaultButtons();
			addEventListeners();
			updateControlbarState();
			setTime(0,0);
			updateVolumeSlider();
		}
		
		
		private function addEventListeners():void {
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, playlistHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistHandler);
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, stateHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, updateVolumeSlider);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, mediaHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, mediaHandler);
		}
		
		
		private function playlistHandler(evt:PlaylistEvent):void {
			resetSlider();
			updateControlbarState();
			redraw();
		}
		
		
		private function resetSlider():void {
			var scrubber:Slider = getButton('time') as Slider;
			if (scrubber) {
				scrubber.reset();
			}
		}
		
		
		private function stateHandler(evt:PlayerEvent):void {
			updateControlbarState();
			redraw();
		}
		
		
		private function updateControlbarState():void {
			var newLayout:String = _defaultLayout;
			if (player.state == PlayerState.PLAYING) {
				newLayout = newLayout.replace('play', 'pause');
				hideButton('play');
			} else if (player.state == PlayerState.IDLE) {
				resetSlider();
				if (_player.playlist.currentItem){
					setTime(0,_player.playlist.currentItem.duration);
				}
				hideButton('pause');
			} else {
				hideButton('pause');
			}
			if (player.playlist.length <= 1) {
				newLayout = newLayout.replace("|prev|next", "");
				hideButton('prev');
				hideButton('next');
			}
			if (player.mute) {
				newLayout = newLayout.replace("mute", "unmute");
				hideButton("mute");
			} else {
				hideButton("unmute");
			}
			if (player.fullscreen) {
				newLayout = newLayout.replace("fullscreen", "normalscreen");
				hideButton("fullscreen");
			} else {
				hideButton("normalscreen");
			}
			_currentLayout = removeInactive(newLayout);
		}
		
		
		private function removeInactive(layout:String):String {
			var buttons:Array = _defaultLayout.match(/\W*([A-Za-z0-9]+?)\W/g);
			for (var i:Number = 0; i < buttons.length; i++){
				var button:String = (buttons[i] as String).replace(/\W/g,"");
				if (!_buttons[button]) {
					layout = layout.replace(button,"");
					layout = layout.replace("||", "|");
				}
			}
			return layout;
		}
		
		private function mediaHandler(evt:MediaEvent):void {
			var scrubber:Slider = getButton('time') as Slider;
			switch (evt.type) {
				case MediaEvent.JWPLAYER_MEDIA_BUFFER:
					//setTime(evt.position, evt.duration);
					if (scrubber) {
						//scrubber.setProgress(evt.position / evt.duration *100);
						scrubber.setBuffer(evt.bufferPercent);
					}
					break;
				case MediaEvent.JWPLAYER_MEDIA_TIME:
					setTime(evt.position, evt.duration);
					if (scrubber) {
						scrubber.setProgress(evt.position / evt.duration * 100);
						scrubber.setBuffer(evt.bufferPercent);
					}
					break;
				default:
					scrubber.reset();
					break;
			}
		}
		
		private function updateVolumeSlider(evt:MediaEvent = null):void {
			var volume:Slider = getButton('volume') as Slider;
			if (volume){
				if (!_player.config.mute) {
					volume.setBuffer(100);
					volume.setProgress(_player.config.volume);
					volume.resize(getSkinElement("controlbar", "volumeSliderRail").width,volume.height);
				} else {
					volume.reset();
					volume.resize(getSkinElement("controlbar", "volumeSliderRail").width,volume.height);
				}
			}
		}
		
		
		private function setTime(position:Number, duration:Number):void {
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "_sans";
			textFormat.size = 10;
			textFormat.bold = true;
			textFormat.color = player.config.frontcolor.color;
			if (position < 0) {
				position = 0;				
			}
			if (duration < 0) {
				duration = 0;
			}
			var elapsedText:TextField = getButton('elapsed') as TextField;
			elapsedText.text = Strings.digits(position);
			elapsedText.setTextFormat(textFormat);
			var durationField:TextField = getButton('duration') as TextField;
			durationField.text = Strings.digits(duration);
			durationField.setTextFormat(textFormat);
			redraw();
		}
		
		
		private function setupBackground():void {
			var back:DisplayObject = getSkinElement("controlbar", "background");
			if (!back) {
				var newBackground:Sprite = new Sprite();
				newBackground.name = "background";
				newBackground.graphics.beginFill(0, 1);
				newBackground.graphics.drawRect(0, 0, 1, 1);
				newBackground.graphics.endFill();
				back = newBackground as DisplayObject;
			} else if (back is Bitmap) {
				var backContainer:Sprite = new Sprite();
				backContainer.addChild(back);
				back = backContainer as DisplayObject;
			}
			back.x = 0;
			back.y = 0;
			_buttons['background'] = back;
			addChildAt(back, 0);
			player.config.pluginConfig("controlbar")['size'] = back.height;
			_height = back.height;
			if (getSkinElement("controlbar", "shade")) {
				var shade:DisplayObject = getSkinElement("controlbar", "shade");
				if (shade is Bitmap) {
					var shadeContainer:Sprite = new Sprite();
					shadeContainer.addChild(shade);
					shade = shadeContainer as DisplayObject;
				}
				shade.x = 0;
				shade.y = 0;
				_buttons['shade'] = shade;
				addChildAt(shade, 1);
			}
		}
		
		
		private function setupDefaultButtons():void {
			addComponentButton('play', 'Play', ViewEvent.JWPLAYER_VIEW_PLAY);
			addComponentButton('pause', 'Pause', ViewEvent.JWPLAYER_VIEW_PAUSE);
			addComponentButton('prev', 'Previous', ViewEvent.JWPLAYER_VIEW_PREV);
			addComponentButton('next', 'Next', ViewEvent.JWPLAYER_VIEW_NEXT);
			addComponentButton('stop', 'Stop', ViewEvent.JWPLAYER_VIEW_STOP);
			addComponentButton('fullscreen', 'Fullscreen', ViewEvent.JWPLAYER_VIEW_FULLSCREEN, true);
			addComponentButton('normalscreen', 'Normalscreen', ViewEvent.JWPLAYER_VIEW_FULLSCREEN, false);
			addComponentButton('unmute', 'Mute', ViewEvent.JWPLAYER_VIEW_MUTE, false);
			addComponentButton('mute', 'Unmute', ViewEvent.JWPLAYER_VIEW_MUTE, true);
			addTextField('elapsed');
			addTextField('duration');
			addSlider('time', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, seekHandler);
			addSlider('volume', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, volumeHandler);
			_buttons['capLeft'] = getSkinElement("controlbar", "capLeft");
			_buttons['capRight'] = getSkinElement("controlbar", "capRight");
		}
		
		
		private function addComponentButton(name:String, text:String, event:String, eventData:* = null):void {
			var button:ComponentButton = new ComponentButton();
			button.setOutIcon(getSkinElement("controlbar", name + "Button"));
			button.setOverIcon(getSkinElement("controlbar", name + "ButtonOver"));
			button.setBackground(getSkinElement("controlbar", name + "ButtonBack"));
			button.outColor = player.config.lightcolor;
			button.overColor = player.config.backcolor;
			button.clickFunction = function():void {
				forward(new ViewEvent(event, eventData));
			}
			if (getSkinElement("controlbar", name + "Button")
				|| getSkinElement("controlbar", name + "ButtonOver") 
				|| getSkinElement("controlbar", name + "ButtonBack")) {
					button.init();
					addButtonDisplayObject(button, name);
			}
		}
		
		
		private function addSlider(name:String, orientation:String, event:String, callback:Function):void {
			var slider:Slider = new Slider(getSkinElement("controlbar", name + "SliderRail") as Sprite, getSkinElement("controlbar", name + "SliderBuffer") as Sprite, getSkinElement("controlbar", name + "SliderProgress") as Sprite, getSkinElement("controlbar", name + "SliderThumb") as Sprite, orientation);
			slider.addEventListener(event, callback);
			slider.name = name;
			_buttons[name] = slider;
		}
		
		
		private function addTextField(name:String):void {
			var textField:TextField = new TextField();
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.name = name;
			addChild(textField);
			_buttons[name] = textField;
		}
		
		
		private function forward(evt:ViewEvent):void {
			dispatchEvent(evt);
		}
		
		
		private function volumeHandler(evt:ViewEvent):void {
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_VOLUME, evt.data * 100));
		}
		
		
		private function seekHandler(evt:ViewEvent):void {
			var duration:Number = 0;
			try {
				duration = player.playlist.currentItem.duration;
			} catch (err:Error) {
			}
			var percent:Number = Math.round(duration * evt.data);
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_SEEK, percent));
		}
		
		
		public function addButton(icon:DisplayObject, name:String, handler:Function = null):MovieClip {
			_defaultLayout = _defaultLayout.replace("|fullscreen","|"+name+"|fullscreen");
			return addButtonDisplayObject(icon, name, handler);
		}
		
		private function addButtonDisplayObject(icon:DisplayObject, name:String, handler:Function = null):MovieClip{
			if (icon) {
				var clipMC:MovieClip = new MovieClip();
				if (handler != null) {
					clipMC.addEventListener(MouseEvent.CLICK, handler);
				}
				clipMC.name = name;
				clipMC.addChild(icon);
				_buttons[name] = clipMC;
				return clipMC;
			}
			return null;
		}
		
		public function removeButton(name:String):void {
			_buttons[name] = null;
			redraw();
		}
		
		
		private function hideButton(name:String):void {
			if (_buttons[name]) {
				_buttons[name].visible = false;
			}
		}
		
		
		public function getButton(buttonName:String):DisplayObject {
			if (buttonName == "divider") {
				var divider:DisplayObject = getSkinElement("controlbar", "divider");
				if (divider) {
					_dividers.push(divider);
				}
				return divider;
			}
			return _buttons[buttonName];
		}
		
		
		public function resize(width:Number, height:Number):void {
			_width = width;
			var wid:Number = width;
			if (getConfigParam('position') == 'over' || _player.fullscreen == true) {
				player.config.pluginConfig("controlbar")['x'] = getConfigParam('margin');
				player.config.pluginConfig("controlbar")['y'] = height - background.height - getConfigParam('margin');
				_width = width - 2 * getConfigParam('margin');
			}
			background.width = _width;
			shade.width = _width;
			updateControlbarState();
			redraw();
			Mouse.show();
		}
		
		
		private function redraw():void {
			clearDividers();
			_layoutManager.resize(_width, _height);
		}
		
		
		private function clearDividers():void {
			for (var i:Number = 0; i < _dividers.length; i++){
				_dividers[i].visible = false;
				_dividers[i] = null;
			}
			_dividers = [];
		}
		
		public function get layout():String {
			return _currentLayout;
		}
		
		
		private function getFont(textField:TextField):String {
			var result:String;
			if (textField) {
				textField.getTextFormat().font;
			}
			return result;
		}
		
		
		private function get background():Sprite {
			if (_buttons['background']) {
				return _buttons['background'];
			}
			return (new Sprite());
		}
		
		
		private function get shade():Sprite {
			if (_buttons['shade']) {
				return _buttons['shade'];
			}
			return (new Sprite());
		}
		
		
		private function getConfigParam(param:String):* {
			return player.config.pluginConfig("controlbar")[param];
		}
	}
}