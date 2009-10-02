package com.longtailvideo.jwplayer.view {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
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
	public class ControlBarComponent extends CoreComponent implements IControlbarComponent {
		protected var _buttons:Object = {};
		protected var _layout:String = "[play|stop|prev|next|elapsed][time][duration|fullscreen|mute volume]";
		protected var _layoutManager:ControlbarLayoutManager;
		
		
		public function ControlBarComponent(player:Player) {
			super(player);
			_layoutManager = new ControlbarLayoutManager(this);
			setupBackground();
			setupDefaultButtons();
			addEventListeners();
		}
		
		
		private function addEventListeners():void {
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_PLAY, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_PAUSE, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_NEXT, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_PREV, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_STOP, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_FULLSCREEN, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_MUTE, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_VOLUME, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_ITEM, viewHandler);
			player.addEventListener(ViewEvent.JWPLAYER_VIEW_LOAD, viewHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, mediaHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, mediaHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_ERROR, mediaHandler);
		}
		
		
		private function viewHandler(evt:ViewEvent):void {
			switch (evt.type) {
				case ViewEvent.JWPLAYER_VIEW_PLAY:
					swapButtons('play', 'pause');
					break;
				case ViewEvent.JWPLAYER_VIEW_PAUSE:
					swapButtons('play', 'pause');
					break;
				case ViewEvent.JWPLAYER_VIEW_FULLSCREEN:
					swapButtons('fullscreen', 'normalscreen');
					break;
				case ViewEvent.JWPLAYER_VIEW_MUTE:
					swapButtons('mute', 'unmute');
					break;
				case ViewEvent.JWPLAYER_VIEW_VOLUME:
					var volume:Slider = getButton('volume') as Slider;
					volume.setProgress(evt.data);
					break;
				default:
					var scrubber:Slider = getButton('scrubber') as Slider;
					scrubber.reset();
					break;
			}
		}
		
		
		private function swapButtons(button1:String, button2:String):void {
			var tempButton:DisplayObject = getButton(button1);
			addButton(button1, getButton(button2));
			addButton(button2, tempButton);
			tempButton = null;
			resize(width, height);
		}
		
		
		private function mediaHandler(evt:MediaEvent):void {
			var scrubber:Slider = getButton('scrubber') as Slider;
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
			if (player.skin.getSkinElement("controlbar", "back")) {
				background = player.skin.getSkinElement("controlbar", "back") as MovieClip;
					//background.name = "background";
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
			if (player.skin.getSkinElement("controlbar", "shade")) {
				var shade:DisplayObject = player.skin.getSkinElement("controlbar", "shade");
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
			(_buttons['time'] as Slider).setProgress(25);
			addSlider('volume', Slider.HORIZONTAL, ViewEvent.JWPLAYER_VIEW_CLICK, seekHandler);
			(_buttons['volume'] as Slider).setProgress(player.config.volume);
			addButton('elapsed', new TextField());
			(_buttons['elapsed'] as TextField).selectable = false;
			(_buttons['elapsed'] as TextField).autoSize = TextFieldAutoSize.LEFT;
			(_buttons['elapsed'] as TextField).text = '00:00';
			addButton('duration', new TextField());
			(_buttons['duration'] as TextField).selectable = false;
			(_buttons['duration'] as TextField).autoSize = TextFieldAutoSize.LEFT;
			(_buttons['duration'] as TextField).text = '00:00';
			addButton('divider', player.skin.getSkinElement("controlbar", "divider"));
		}
		
		
		private function addComponentButton(name:String, text:String, event:String, eventData:* = null):void {
			var button:ComponentButton = new ComponentButton(player.skin.getSkinElement("controlbar", name + "ButtonBack"), player.skin.getSkinElement("controlbar", name + "Button"), player.config.lightcolor, player.config.backcolor, player.skin.getSkinElement("controlbar", name + "ButtonOver"), text, event, eventData);
			button.addEventListener(event, forward);
			addButton(name, button);
		}
		
		
		private function addSlider(name:String, orientation:String, event:String, callback:Function):void {
			var slider:Slider = new Slider(player.skin.getSkinElement("controlbar", name + "SliderRail"), player.skin.getSkinElement("controlbar", name + "SliderBuffer"), player.skin.getSkinElement("controlbar", name + "SliderProgress"), player.skin.getSkinElement("controlbar", name + "SliderThumb"), orientation);
			slider.addEventListener(event, callback);
			addButton(name, slider);
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
		
		
		public function addButton(name:String, icon:DisplayObject):void {
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
			return _layout;
		}
	}
}