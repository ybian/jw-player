package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.Animations;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;


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
		protected var _defaultLayout:String = "[play|stop|prev|next|elapsed][time][duration|blank|fullscreen|mute volume]";
		protected var _currentLayout:String;
		protected var _layoutManager:ControlbarLayoutManager;
		protected var _width:Number;
		protected var _height:Number;

		protected var controlbarConfig:PluginConfig;
		protected var animations:Animations;
		protected var hiding:Number;
		
		public function ControlbarComponent(player:IPlayer) {
			super(player, "controlbar");
			_layoutManager = new ControlbarLayoutManager(this);
			_dividers = [];
			setupBackground();
			setupDefaultButtons();
			addEventListeners();
			updateControlbarState();
			setTime(0, 0);
			updateVolumeSlider();
			controlbarConfig = _player.config.pluginConfig(_name);
			animations = new Animations(this);
		}

		private function addEventListeners():void {
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, playlistHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, playlistHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, stateHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, updateVolumeSlider);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, mediaHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, mediaHandler);
			player.addEventListener(PlayerEvent.JWPLAYER_LOCKED, lockHandler);
			player.addEventListener(PlayerEvent.JWPLAYER_UNLOCKED, lockHandler);
		}


		private function lockHandler(evt:PlayerEvent):void {
			if (_player.locked) {
				getSlider('time').lock();
				getSlider('volume').lock();
			} else {
				getSlider('time').unlock();
				getSlider('volume').unlock();
			}
		}


		private function playlistHandler(evt:PlaylistEvent):void {
			getSlider('time').reset();
			updateControlbarState();
			redraw();
		}

		
		private function startFader():void {
			if (controlbarConfig['position'] == 'over' || (_player.fullscreen && controlbarConfig['position'] != 'none')) {
				if (!isNaN(hiding)) {
					clearTimeout(hiding);
				}
				hiding = setTimeout(moveTimeout, 2000);
				_player.controls.display.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			}
		}
		
		private function stopFader():void {
			if (!isNaN(hiding)) {
				clearTimeout(hiding);
				try {
					_player.controls.display.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
				} catch (e:Error) {}
			}
			Mouse.show();
			animations.fade(1, 0.5);
		}
		
		/** Show above controlbar on mousemove. **/
		private function moveHandler(evt:MouseEvent=null):void {
			if (alpha == 0) {
				animations.fade(1, 0.5);
			}
			clearTimeout(hiding);
			hiding = setTimeout(moveTimeout, 2000);
			Mouse.show();
		}
		
		
		/** Hide above controlbar again when move has timed out. **/
		private function moveTimeout():void {
			animations.fade(0, 0.5);
			Mouse.hide();
		}
		
		private function stateHandler(evt:PlayerEvent=null):void {
			switch(_player.state) {
				case PlayerState.BUFFERING:
				case PlayerState.PLAYING:
					startFader();
					break;
				case PlayerState.PAUSED:
				case PlayerState.IDLE:
					stopFader();
					break;
			}
			updateControlbarState();
			redraw();
		}


		private function updateControlbarState():void {
			var newLayout:String = _defaultLayout;
			newLayout = removeButtonFromLayout("blank", newLayout);
			if (player.state == PlayerState.PLAYING) {
				newLayout = newLayout.replace('play', 'pause');
				hideButton('play');
			} else if (player.state == PlayerState.IDLE) {
				getSlider('time').reset();
				if (_player.playlist.currentItem) {
					setTime(0, _player.playlist.currentItem.duration);
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
			for (var i:Number = 0; i < buttons.length; i++) {
				var button:String = (buttons[i] as String).replace(/\W/g, "");
				if (!_buttons[button]) {
					layout = removeButtonFromLayout(button, layout);
				}
			}
			return layout;
		}


		private function removeButtonFromLayout(button:String, layout:String):String {
			layout = layout.replace(button, "");
			layout = layout.replace("||", "|");
			return layout;
		}


		private function mediaHandler(evt:MediaEvent):void {
			var scrubber:Slider = getSlider('time');
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
						if (evt.bufferPercent >= 0) {
							scrubber.setBuffer(evt.bufferPercent);
						}
					}
					break;
				default:
					scrubber.reset();
					break;
			}
		}


		private function updateVolumeSlider(evt:MediaEvent=null):void {
			var volume:Slider = getSlider('volume');
			if (volume) {
				if (!_player.config.mute) {
					volume.setBuffer(100);
					volume.setProgress(_player.config.volume);
					volume.resize(getSkinElement("volumeSliderRail").width, volume.height);
				} else {
					volume.reset();
					volume.resize(getSkinElement("volumeSliderRail").width, volume.height);
				}
			}
		}


		private function setTime(position:Number, duration:Number):void {
			if (position < 0) {
				position = 0;
			}
			if (duration < 0) {
				duration = 0;
			}
			var elapsedText:TextField = getButton('elapsed') as TextField;
			elapsedText.text = Strings.digits(position);
			var durationField:TextField = getButton('duration') as TextField;
			durationField.text = Strings.digits(duration);
			redraw();
		}


		private function setupBackground():void {
			var back:DisplayObject = getSkinElement("background");
			var capLeft:DisplayObject = getSkinElement("capLeft");
			var capRight:DisplayObject = getSkinElement("capRight");
			//var shade:DisplayObject = getSkinElement("shade");

			if (!back) {
				var newBackground:Sprite = new Sprite();
				newBackground.name = "background";
				newBackground.graphics.beginFill(0, 1);
				newBackground.graphics.drawRect(0, 0, 1, 1);
				newBackground.graphics.endFill();
				back = newBackground as DisplayObject;
			}

			_buttons['background'] = back;
			addChild(back);
			_height = back.height;
			player.config.pluginConfig("controlbar")['size'] = back.height;

			if (capLeft) {
				_buttons['capLeft'] = capLeft;
				addChild(capLeft);
			}

			if (capRight) {
				_buttons['capRight'] = capRight;
				addChild(capRight);
			}

		/*if (shade) {
		   _buttons['shade'] = shade;
		   addChild(shade);
		 }*/
		}


		private function setupDefaultButtons():void {
			addComponentButton('play', ViewEvent.JWPLAYER_VIEW_PLAY);
			addComponentButton('pause', ViewEvent.JWPLAYER_VIEW_PAUSE);
			addComponentButton('prev', ViewEvent.JWPLAYER_VIEW_PREV);
			addComponentButton('next', ViewEvent.JWPLAYER_VIEW_NEXT);
			addComponentButton('stop', ViewEvent.JWPLAYER_VIEW_STOP);
			addComponentButton('fullscreen', ViewEvent.JWPLAYER_VIEW_FULLSCREEN, true);
			addComponentButton('normalscreen', ViewEvent.JWPLAYER_VIEW_FULLSCREEN, false);
			addComponentButton('unmute', ViewEvent.JWPLAYER_VIEW_MUTE, false);
			addComponentButton('mute', ViewEvent.JWPLAYER_VIEW_MUTE, true);
			addTextField('elapsed');
			addTextField('duration');
			addSlider('time', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, seekHandler);
			addSlider('volume', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, volumeHandler);
		}


		private function addComponentButton(name:String, event:String, eventData:*=null):void {
			var button:ComponentButton = new ComponentButton();
			button.name = name;
			button.setOutIcon(getSkinElement(name + "Button"));
			button.setOverIcon(getSkinElement(name + "ButtonOver"));
			button.setBackground(getSkinElement(name + "ButtonBack"));
			button.outColor = player.config.lightcolor;
			button.overColor = player.config.backcolor;
			button.clickFunction = function():void {
				forward(new ViewEvent(event, eventData));
			}
			if (getSkinElement(name + "Button") || getSkinElement(name + "ButtonOver") || getSkinElement(name + "ButtonBack")) {
				button.init();
				addButtonDisplayObject(button, name);
			}
		}


		private function addSlider(name:String, orientation:String, event:String, callback:Function):void {
			var slider:Slider = new Slider(getSkinElement(name + "SliderRail"), getSkinElement(name + "SliderBuffer"), getSkinElement(name + "SliderProgress"), getSkinElement(name + "SliderThumb"), orientation);
			slider.addEventListener(event, callback);
			slider.name = name;
			_buttons[name] = slider;
		}


		private function addTextField(name:String):void {
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = "_sans";
			textFormat.size = 10;
			textFormat.bold = true;
			textFormat.color = player.config.frontcolor.color;
			var textField:TextField = new TextField();
			textField.defaultTextFormat = textFormat;
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
			if (!_player.mute) {
				var volume:Number = Math.round(evt.data * 100);
				if (!_player.locked) {
					var volumeEvent:MediaEvent = new MediaEvent(MediaEvent.JWPLAYER_MEDIA_VOLUME);
					volumeEvent.volume = volume;
					updateVolumeSlider(volumeEvent);
				}
				dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_VOLUME, volume));
			}
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


		private function addButtonDisplayObject(icon:DisplayObject, name:String, handler:Function=null):MovieClip {
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


		public function addButton(icon:DisplayObject, name:String, handler:Function=null):MovieClip {
			_defaultLayout = _defaultLayout.replace("|blank","|blank|"+name);
			icon.x = icon.y = 0;
			var button:ComponentButton = new ComponentButton();
			button.name = name;
			var outBackground:DisplayObject = getSkinElement("blankButton");
			if (outBackground) {
				var outImage:Sprite = new Sprite();
				var outIcon:DisplayObject = icon;
				if (_player.config.frontcolor){
					var outTransform:ColorTransform = new ColorTransform();
					outTransform.color = _player.config.frontcolor.color;
					outIcon.transform.colorTransform = outTransform;
				}
				var outOffset:Number = Math.round((outBackground.height - outIcon.height) / 2);
				outBackground.width = outIcon.width + 2 * outOffset;
				outImage.addChild(outBackground);
				outImage.addChild(outIcon);
				outIcon.x = outIcon.y = outOffset;
				button.setOutIcon(outImage);

				button.init();
				return addButtonDisplayObject(button, name, handler);
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
				var divider:DisplayObject = getSkinElement("divider");
				if (divider) {
					_dividers.push(divider);
				}
				return divider;
			}
			return _buttons[buttonName];
		}


		public function getSlider(sliderName:String):Slider {
			return getButton(sliderName) as Slider;
		}


		public function resize(width:Number, height:Number):void {
			if (getConfigParam('position') == "none") {
				visible = false;
				return;
			}
			
			_width = width;

			if (getConfigParam('position') == 'over' || _player.fullscreen == true) {
				x = getConfigParam('margin');
				y = height - background.height - getConfigParam('margin');
				_width = width - 2 * getConfigParam('margin');
			}

			//shade.width = _width;

			var backgroundWidth:Number = _width;

			backgroundWidth -= capLeft.width;
			capLeft.x = 0;

			backgroundWidth -= capRight.width;
			capRight.x = _width - capRight.width;

			background.width = backgroundWidth;
			background.x = capLeft.width;
			setChildIndex(capLeft, numChildren - 1);
			setChildIndex(capRight, numChildren - 1);

			stopFader();
			stateHandler();
			redraw();
		}


		private function redraw():void {
			clearDividers();
			_layoutManager.resize(_width, _height);
		}


		private function clearDividers():void {
			for (var i:Number = 0; i < _dividers.length; i++) {
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


		private function get background():DisplayObject {
			if (_buttons['background']) {
				return _buttons['background'];
			}
			return (new Sprite());
		}


		/*private function get shade():DisplayObject {
		   if (_buttons['shade']) {
		   return _buttons['shade'];
		   }
		   return (new Sprite());
		 }*/

		private function get capLeft():DisplayObject {
			if (_buttons['capLeft']) {
				return _buttons['capLeft'];
			}
			return (new Sprite());
		}


		private function get capRight():DisplayObject {
			if (_buttons['capRight']) {
				return _buttons['capRight'];
			}
			return (new Sprite());
		}
	}
}
