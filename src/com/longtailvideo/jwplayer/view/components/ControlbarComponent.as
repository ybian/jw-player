package com.longtailvideo.jwplayer.view.components {
	import com.jeroenwijering.events.ControllerEvent;
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
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
		protected var _defaultLayout:String = "[play|stop|prev|next|elapsed][time][duration|fullscreen|mute volume]";
		protected var _currentLayout:String;
		protected var _layoutManager:ControlbarLayoutManager;
		
		
		public function ControlbarComponent(player:Player) {
			super(player);
			_layoutManager = new ControlbarLayoutManager(this);
			setupBackground();
			setupDefaultButtons();
			temp();
			addEventListeners();
			updateControlbarState()
		}
		
		private function temp():void {
			(_buttons['volume'] as Slider).setProgress(player.config.volume);
			(_buttons['time'] as Slider).setProgress(25);
		}
		
		private function addEventListeners():void {
			player.addEventListener(ControllerEvent.PLAY, controllerHandler);
			player.addEventListener(ControllerEvent.ITEM, controllerHandler);
			player.addEventListener(ControllerEvent.STOP, controllerHandler);
			player.addEventListener(ControllerEvent.MUTE, controllerHandler);
			player.addEventListener(ControllerEvent.VOLUME, controllerHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, mediaHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, mediaHandler);
		}
		
		
		private function controllerHandler(evt:ControllerEvent):void {
			switch (evt.type) {
				case ViewEvent.JWPLAYER_VIEW_VOLUME:
					var volume:Slider = getButton('volume') as Slider;
					volume.setProgress(evt.data as Number);
					break;
				case ControllerEvent.ITEM:
					resetSlider();
					break;
				case ControllerEvent.STOP:
					resetSlider();
					break;
				default:
					updateControlbarState();
					break;
			}
		}
		
		private function resetSlider():void {
			var scrubber:Slider = getButton('time') as Slider;
			scrubber.reset();
		}
		
		private function updateControlbarState():void {
			var newLayout:String = _defaultLayout;
			if (player.state == PlayerState.PAUSED){
				newLayout = newLayout.replace('play', 'pause');
			}
			
			if (player.playlist.length <= 1){
				newLayout = newLayout.replace("|prev|next", "");
			}
			
			if (player.config.mute) {
				newLayout = newLayout.replace("mute", "unmute");
			}
			
			if (player.config.fullscreen){
				newLayout = newLayout.replace("fullscreen", "normalscreen");
			}
			_currentLayout = newLayout;
			resize(width, height);
		}
		
		
		private function swapButtons(button1:String, button2:String):void {
			var tempButton:DisplayObject = getButton(button1);
			addButton(button1, getButton(button2));
			addButton(button2, tempButton);
			tempButton = null;
			resize(width, height);
		}
		
		
		private function mediaHandler(evt:MediaEvent):void {
			var scrubber:Slider = getButton('time') as Slider;
			switch (evt.type) {
				case MediaEvent.JWPLAYER_MEDIA_BUFFER:
					scrubber.setProgress(evt.position);
					scrubber.setBuffer(evt.bufferPercent);
					break;
				case MediaEvent.JWPLAYER_MEDIA_TIME:
					scrubber.setProgress(evt.position);
					scrubber.setBuffer(evt.bufferPercent);
					break;
				default:
					scrubber.reset();
					break;
			}
		}
		
		
		private function setupBackground():void {
			var background:MovieClip;
			if (getSkinElement("controlbar", "back")) {
				background = getSkinElement("controlbar", "back") as MovieClip;
			} else {
				background = new MovieClip();
				background.name = "background";
				background.graphics.beginFill(0, 1);
				background.graphics.drawRect(0, 0, 1, 1);
				background.graphics.endFill();
			}

			if (player.config.backcolor) {
				var colorTransform:ColorTransform = new ColorTransform();
				colorTransform.color = player.config.backcolor;
				background.transform.colorTransform = colorTransform;
			}
			background.x = 0;
			background.y = 0;
			addChildAt(background, 0);
			if (getSkinElement("controlbar", "shade")) {
				var shade:DisplayObject = getSkinElement("controlbar", "shade");
				shade.x = 0;
				shade.y = 0;
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
			addComponentButton('unmute', 'Mute', ViewEvent.JWPLAYER_VIEW_MUTE, true);
			addComponentButton('mute', 'Unmute', ViewEvent.JWPLAYER_VIEW_MUTE, false);
			addSlider('time', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, seekHandler);
			addSlider('volume', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, seekHandler);
			addTextField('elapsed', (getSkinElement("controlbar","elapsedText") as TextField).getTextFormat().font);
			addTextField('duration', (getSkinElement("controlbar","totalText") as TextField).getTextFormat().font);
			addButton('divider', getSkinElement("controlbar", "divider"));
		}
		
		
		private function addComponentButton(name:String, text:String, event:String, eventData:* = null):void {
			var outIcon:DisplayObject = getSkinElement("controlbar", name + "Button");
			if (outIcon) {
				var button:ComponentButton = new ComponentButton(outIcon, event, eventData, player.config.lightcolor, player.config.backcolor, getSkinElement("controlbar", name + "ButtonBack"), getSkinElement("controlbar", name + "ButtonOver"), text);
				button.addEventListener(event, forward);
				addButton(name, button);
			}
		}
		
		
		private function addSlider(name:String, orientation:String, event:String, callback:Function):void {
			var slider:Slider = new Slider(getSkinElement("controlbar", name + "SliderRail"), getSkinElement("controlbar", name + "SliderBuffer"), getSkinElement("controlbar", name + "SliderProgress"), getSkinElement("controlbar", name + "SliderThumb"), orientation);
			slider.addEventListener(event, callback);
			addButton(name, slider);
		}
		
		private function addTextField(name:String, font:String):void {
			var textField:TextField =  new TextField();
			textField.text = '00:00';
			var textFormat:TextFormat = new TextFormat();
			textFormat.font = font;
			textFormat.size = 8;
			textField.setTextFormat(textFormat);
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.LEFT;
			addButton(name, textField);
		}
		
		
		private function forward(evt:ViewEvent):void {
			dispatchEvent(evt);
		}
		
		
		private function volumeHandler(evt:ViewEvent):void {
			dispatchEvent(new ViewEvent(ViewEvent.JWPLAYER_VIEW_VOLUME, evt.data));
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
		
		
		public function addButton(name:String, icon:DisplayObject, handler:Function = null):void {
			//TODO: Add button + handler
			if (icon) {
				icon.name = name;
				_buttons[name] = icon;
			}
		}
		
		
		public function removeButton(name:String):void {
			_buttons[name] = null;
			_layoutManager.resize(width, height);
		}
		
		
		public function getButton(buttonName:String):DisplayObject {
			return _buttons[buttonName];
		}
		
		
		public function resize(width:Number, height:Number):void {
			getChildAt(0).width = width;
			getChildAt(1).width = width;
			_layoutManager.resize(width, height);
		}
		
		
		public function get layout():String {
			return _currentLayout;
		}
		
		private function getSkinElement(component:String, element:String):DisplayObject {
			return player.skin.getSkinElement(component,element);
		}
	}
}