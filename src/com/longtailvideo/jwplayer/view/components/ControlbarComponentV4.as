package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Stacker;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.components.CoreComponent;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.effects.Fade;
	import com.longtailvideo.jwplayer.view.interfaces.IControlbarComponent;
	
	
	public class ControlbarComponentV4 extends CoreComponent implements IControlbarComponent {
		/** Reference to the original skin **/
		private var skin:Sprite;
		/** A list with all controls. **/
		private var stacker:Stacker;
		/** Timeout for hiding the  **/
		private var hiding:Number;
		/** When scrubbing, icon shouldn't be set. **/
		private var scrubber:MovieClip;
		/** Color object for frontcolor. **/
		private var front:ColorTransform;
		/** Color object for lightcolor. **/
		private var light:ColorTransform;
		/** The actions for all controlbar buttons. **/
		private var BUTTONS:Object;
		/** The actions for all sliders **/
		private var SLIDERS:Object = {
			timeSlider: ViewEvent.JWPLAYER_VIEW_SEEK, 
			volumeSlider: ViewEvent.JWPLAYER_VIEW_VOLUME
		};
		/** The button to clone for all custom buttons. **/
		private var clonee:MovieClip;
		/** Saving the block state of the controlbar. **/
		private var blocking:Boolean;
		
		
		public function ControlbarComponentV4(player:Player) {
			super(player);
			// TODO: Remove Link button
 			BUTTONS = {
 				playButton: ViewEvent.JWPLAYER_VIEW_PLAY, 
 				pauseButton: ViewEvent.JWPLAYER_VIEW_PAUSE, 
 				stopButton: ViewEvent.JWPLAYER_VIEW_STOP, 
 				prevButton: ViewEvent.JWPLAYER_VIEW_PREV, 
 				nextButton: ViewEvent.JWPLAYER_VIEW_NEXT, 
 				linkButton: 'LINK', 
 				fullscreenButton: ViewEvent.JWPLAYER_VIEW_FULLSCREEN, 
 				normalscreenButton: ViewEvent.JWPLAYER_VIEW_FULLSCREEN, 
 				muteButton: ViewEvent.JWPLAYER_VIEW_MUTE, 
 				unmuteButton: ViewEvent.JWPLAYER_VIEW_MUTE
 			};
			var temp:Sprite = player.skin.getSWFSkin();
			skin = player.skin.getSWFSkin().getChildByName('controlbar') as Sprite;
			skin.x = 0;
			skin.y = 0;
			addChild(skin);
			player.addEventListener(PlayerEvent.JWPLAYER_STATE, stateHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, muteHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, volumeHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_LOADED, loadedHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, itemHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, itemHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			stacker = new Stacker(skin as MovieClip);
			setButtons();
			setColors();
			itemHandler();
			loadedHandler();
			muteHandler();
			stateHandler();
			timeHandler();
			volumeHandler();
		}
		
		
		/**
		 * Add a new button to the control
		 *
		 * @param icn	A graphic to show as icon
		 * @param nam	Name of the button
		   getSkinElement("controlbar", '* @param hdl	The function to call when clicking the Button').
		 **/
		public function addButton(name:String, icon:DisplayObject, handler:Function = null):void {
			if (getSkinElement("controlbar", 'linkButton') && getSkinElement("controlbar", 'linkButton').getChildByName('back')) {
				var btn:* = Draw.clone(getSkinElement("controlbar", 'linkButton') as Sprite);
				btn.name = name + 'Button';
				btn.visible = true;
				btn.tabEnabled = true;
				btn.tabIndex = 6;
				var acs:AccessibilityProperties = new AccessibilityProperties();
				acs.name = name + 'Button';
				btn.accessibilityProperties = acs;
				addChild(btn);
				var off:Number = Math.round((btn.height - icon.height) / 2);
				Draw.clear(btn.icon);
				btn.icon.addChild(icon);
				icon.x = icon.y = 0;
				btn.icon.x = btn.icon.y = off;
				btn.back.width = icon.width + 2 * off;
				btn.buttonMode = true;
				btn.mouseChildren = false;
				btn.addEventListener(MouseEvent.CLICK, handler);
				if (front) {
					btn.icon.transform.colorTransform = front;
					btn.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
					btn.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				}
				stacker.insert(btn, getSkinElement("controlbar", 'linkButton') as MovieClip);
			}
		}
		
		
		public function removeButton(name:String):void {
		}
		
		
		public function resize(width:Number, height:Number):void {
			var wid:Number = width;
			if (player.config.position == 'over' || player.config.fullscreen == true) {
				x = player.config.x + player.config.margin;
				y = player.config.y + player.config.height - player.config.margin - player.config.size;
				wid = width - 2 * player.config.margin;
			}
			try {
				getSkinElement("controlbar", 'fullscreenButton').visible = false;
				getSkinElement("controlbar", 'normalscreenButton').visible = false;
				if (stage['displayState'] && player.config.height > 40) {
					if (player.config.fullscreen) {
						getSkinElement("controlbar", 'fullscreenButton').visible = false;
						getSkinElement("controlbar", 'normalscreenButton').visible = true;
					} else {
						getSkinElement("controlbar", 'fullscreenButton').visible = true;
						getSkinElement("controlbar", 'normalscreenButton').visible = false;
					}
				}
			} catch (err:Error) {
			}
			stacker.rearrange(width);
			stateHandler();
			fixTime();
			Mouse.show();
		}
		
		
		public function getButton(buttonName:String):DisplayObject {
			return null;
		}
		
		
		/** Hide the controlbar **/
		public function block(stt:Boolean):void {
			blocking = stt;
			timeHandler();
		}
		
		
		/** Handle clicks from all buttons. **/
		private function clickHandler(evt:MouseEvent):void {
			var act:String = BUTTONS[evt.target.name];
			var data:Object = null;
			if (blocking != true || act == "FULLSCREEN" || act == "MUTE") {
				switch (act) {
					case ViewEvent.JWPLAYER_VIEW_PLAY:
					case ViewEvent.JWPLAYER_VIEW_PAUSE:
						data = Boolean(_player.state == PlayerState.IDLE || _player.state == PlayerState.PAUSED);
						break;
					case ViewEvent.JWPLAYER_VIEW_MUTE:
						data = Boolean(!_player.config.mute);
						break;
				}
				dispatchEvent(new ViewEvent(act, data));
			}
		}
		
		
		/** Handle mouse presses on sliders. **/
		private function downHandler(evt:MouseEvent):void {
			scrubber = MovieClip(evt.target);
			if (blocking != true || scrubber.name == 'volumeSlider') {
				var rct:Rectangle = new Rectangle(scrubber.rail.x, scrubber.icon.y, scrubber.rail.width - scrubber.icon.width, 0);
				scrubber.icon.startDrag(true, rct);
				stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			} else {
				scrubber = undefined;
			}
		}
		
		
		/** Fix the timeline display. **/
		private function fixTime():void {
			try {
				var scp:Number = getSkinElement("controlbar", 'timeSlider').scaleX;
				getSkinElement("controlbar", 'timeSlider').scaleX = 1;
				getSkinElement("controlbar", 'timeSlider').getChildByName('icon').x = scp * getSkinElement("controlbar", 'timeSlider').getChildByName('icon').x;
				getSkinElement("controlbar", 'timeSlider').getChildByName('mark').x = scp * getSkinElement("controlbar", 'timeSlider').getChildByName('mark').x;
				getSkinElement("controlbar", 'timeSlider').getChildByName('mark').width = scp * getSkinElement("controlbar", 'timeSlider').getChildByName('mark').width;
				getSkinElement("controlbar", 'timeSlider').getChildByName('rail').width = scp * getSkinElement("controlbar", 'timeSlider').getChildByName('rail').width;
				getSkinElement("controlbar", 'timeSlider').getChildByName('done').x = scp * getSkinElement("controlbar", 'timeSlider').getChildByName('done').x;
				getSkinElement("controlbar", 'timeSlider').getChildByName('done').width = scp * getSkinElement("controlbar", 'timeSlider').getChildByName('done').width;
			} catch (err:Error) {
			}
		}
		
		
		/** Handle a change in the current item **/
		private function itemHandler(evt:PlaylistEvent = null):void {
			try {
				if (player.playlist && player.playlist.length > 1) {
					getSkinElement("controlbar", 'prevButton').visible = getSkinElement("controlbar", 'nextButton').visible = true;
				} else {
					getSkinElement("controlbar", 'prevButton').visible = getSkinElement("controlbar", 'nextButton').visible = false;
				}
			} catch (err:Error) {
			}
			try {
				if (player.playlist && player.playlist.currentItem.link) {
					getSkinElement("controlbar", 'linkButton').visible = true;
				} else {
					getSkinElement("controlbar", 'linkButton').visible = false;
				}
			} catch (err:Error) {
			}
			timeHandler();
			stacker.rearrange();
			fixTime();
			loadedHandler();
		}
		
		
		/** Process bytesloaded updates given by the model. **/
		private function loadedHandler(evt:MediaEvent = null):void {
			try {
				var wid:Number = getSkinElement("controlbar", 'timeSlider').getChildByName('rail').width;
				getSkinElement("controlbar", 'timeSlider').getChildByName('mark').x = evt.position * wid;
				getSkinElement("controlbar", 'timeSlider').getChildByName('mark').width = evt.bufferPercent * wid;
				var icw:Number = getSkinElement("controlbar", 'timeSlider').getChildByName('icon').x + getSkinElement("controlbar", 'timeSlider').getChildByName('icon').width;
			} catch (err:Error) {
			}
		}
		
		
		/** Show above controlbar on mousemove. **/
		private function moveHandler(evt:MouseEvent = null):void {
			if (alpha == 0) {
				var fade:Fade = new Fade(this);
				fade.alphaTo = 1;
				fade.play();
			}
			clearTimeout(hiding);
			hiding = setTimeout(moveTimeout, 2000);
			Mouse.show();
		}
		
		
		/** Hide above controlbar again when move has timed out. **/
		private function moveTimeout():void {
			var fade:Fade = new Fade(this);
			fade.alphaTo = 0;
			fade.play();
		}
		
		
		/** Show a mute icon if playing. **/
		private function muteHandler(evt:MediaEvent = null):void {
			if (player.config.mute == true) {
				try {
					getSkinElement("controlbar", 'muteButton').visible = false;
					getSkinElement("controlbar", 'unmuteButton').visible = true;
				} catch (err:Error) {
				}
				try {
					getSkinElement("controlbar", 'volumeSlider').getChildByName('mark').visible = false;
					getSkinElement("controlbar", 'volumeSlider').getChildByName('icon').x = getSkinElement("controlbar", 'volumeSlider').getChildByName('rail').x;
				} catch (err:Error) {
				}
			} else {
				try {
					getSkinElement("controlbar", 'muteButton').visible = true;
					getSkinElement("controlbar", 'unmuteButton').visible = false;
				} catch (err:Error) {
				}
				try {
					getSkinElement("controlbar", 'volumeSlider').getChildByName('mark').visible = true;
					volumeHandler();
				} catch (err:Error) {
				}
			}
		}
		
		
		/** Handle mouseouts from all buttons **/
		private function outHandler(evt:MouseEvent):void {
			if (front && evt.target['icon']) {
				evt.target['icon'].transform.colorTransform = front;
			} else {
				evt.target.gotoAndPlay('out');
			}
		}
		
		
		/** Handle clicks from all buttons **/
		private function overHandler(evt:MouseEvent):void {
			if (front && evt.target['icon']) {
				evt.target['icon'].transform.colorTransform = light;
			} else {
				evt.target.gotoAndPlay('over');
			}
		}
		
		
		/** Clickhandler for all buttons. **/
		private function setButtons():void {
 			for (var btn:String in BUTTONS) {
				if (getSkinElement("controlbar", btn)) {
					getSkinElement("controlbar", btn).mouseChildren = false;
					getSkinElement("controlbar", btn).buttonMode = true;
					getSkinElement("controlbar", btn).addEventListener(MouseEvent.CLICK, clickHandler);
					getSkinElement("controlbar", btn).addEventListener(MouseEvent.MOUSE_OVER, overHandler);
					getSkinElement("controlbar", btn).addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				}
			}
			for (var sld:String in SLIDERS) {
				if (getSkinElement("controlbar", sld)) {
					getSkinElement("controlbar", sld).mouseChildren = false;
					getSkinElement("controlbar", sld).buttonMode = true;
					getSkinElement("controlbar", sld).addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
					getSkinElement("controlbar", sld).addEventListener(MouseEvent.MOUSE_OVER, overHandler);
					getSkinElement("controlbar", sld).addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				}
			}
		}
		
		
		/** Init the colors. **/
		private function setColors():void {
			if (player.config.backcolor && getSkinElement("controlbar", 'playButton').getChildByName('icon')) {
				var clr:ColorTransform = new ColorTransform();
				clr.color = player.config.backcolor;
				getSkinElement("controlbar", 'back').transform.colorTransform = clr;
			}
			if (player.config.frontcolor) {
				try {
					front = new ColorTransform();
					front.color = player.config.frontcolor;
					for (var btn:String in BUTTONS) {
						if (getSkinElement("controlbar", btn)) {
							getSkinElement("controlbar", btn).getChildByName('icon').transform.colorTransform = front;
						}
					}
					for (var sld:String in SLIDERS) {
						if (getSkinElement("controlbar", sld)) {
							getSkinElement("controlbar", sld).getChildByName('icon').transform.colorTransform = front;
							getSkinElement("controlbar", sld).getChildByName('mark').transform.colorTransform = front;
							getSkinElement("controlbar", sld).getChildByName('rail').transform.colorTransform = front;
						}
					}
					(getSkinElement("controlbar", 'elapsedText') as TextField).textColor = front.color;
					(getSkinElement("controlbar", 'totalText') as TextField).textColor = front.color;
				} catch (err:Error) {
				}
			}
			if (player.config.lightcolor) {
				light = new ColorTransform();
				light.color = player.config.lightcolor;
			} else {
				light = front;
			}
			if (light) {
				try {
					getSkinElement("controlbar", 'timeSlider').getChildByName('done').transform.colorTransform = light;
					getSkinElement("controlbar", 'volumeSlider').getChildByName('mark').transform.colorTransform = light;
				} catch (err:Error) {
				}
			}
		}
		
		
		/** Process state changes **/
		private function stateHandler(evt:PlayerEvent = undefined):void {
			clearTimeout(hiding);
			player.skin.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			try {
				var dps:String = stage['displayState'];
			} catch (err:Error) {
			}
			switch (player.config.state) {
				case PlayerState.PLAYING:
				case PlayerState.BUFFERING:
					try {
						getSkinElement("controlbar", 'playButton').visible = false;
						getSkinElement("controlbar", 'pauseButton').visible = true;
					} catch (err:Error) {
					}
					if (player.config.position == 'over' || (dps == 'fullScreen' && player.config.position != 'none')) {
						hiding = setTimeout(moveTimeout, 2000);
						player.skin.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
					} else {
						var fade1:Fade = new Fade(this);
						fade1.alphaTo = 1;
						fade1.play();
					}
					break;
				default:
					try {
						getSkinElement("controlbar", 'playButton').visible = true;
						getSkinElement("controlbar", 'pauseButton').visible = false;
					} catch (err:Error) {
					}
					if (player.config.position == 'over' || dps == 'fullScreen') {
						Mouse.show();
						var fade2:Fade = new Fade(this);
						fade2.alphaTo = 1;
						fade2.play();
					}
			}
		}
		
		
		/** Process time updates given by the model. **/
		private function timeHandler(evt:MediaEvent = null):void {
			var dur:Number = 0;
			var pos:Number = 0;
			if (evt) {
				dur = evt.duration;
				pos = evt.position;
			} else if (player.playlist.length > 0 && player.playlist.currentItem) {
				dur = player.playlist.currentItem.duration;
				pos = 0;
			}
			var pct:Number = pos / dur;
			if (isNaN(pct)) {
				pct = 1;
			}
			try {
				(getSkinElement("controlbar", 'elapsedText') as TextField).text = Strings.digits(pos);
				(getSkinElement("controlbar", 'totalText') as TextField).text = Strings.digits(dur);
			} catch (err:Error) {
			}
			try {
				var tsl:MovieClip = getSkinElement("controlbar", 'timeSlider') as MovieClip;
				var xps:Number = Math.round(pct * (tsl.rail.width - tsl.icon.width));
				if (dur > 0) {
					getSkinElement("controlbar", 'timeSlider').getChildByName('icon').visible = true;
					getSkinElement("controlbar", 'timeSlider').getChildByName('mark').visible = true;
					if (!scrubber) {
						getSkinElement("controlbar", 'timeSlider').getChildByName('icon').x = xps;
						getSkinElement("controlbar", 'timeSlider').getChildByName('done').width = xps;
					}
					getSkinElement("controlbar", 'timeSlider').getChildByName('done').visible = true;
				} else {
					getSkinElement("controlbar", 'timeSlider').getChildByName('icon').visible = false;
					getSkinElement("controlbar", 'timeSlider').getChildByName('mark').visible = false;
					getSkinElement("controlbar", 'timeSlider').getChildByName('done').visible = false;
				}
			} catch (err:Error) {
			}
		}
		
		
		/** Handle mouse releases on sliders. **/
		private function upHandler(evt:MouseEvent):void {
			var mpl:Number = 0;
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			scrubber.icon.stopDrag();
			if (scrubber.name == 'timeSlider' && player.playlist) {
				mpl = player.playlist.currentItem.duration;
			} else if (scrubber.name == 'volumeSlider') {
				mpl = 100;
			}
			var pct:Number = (scrubber.icon.x - scrubber.rail.x) / (scrubber.rail.width - scrubber.icon.width) * mpl;
			dispatchEvent(new ViewEvent(SLIDERS[scrubber.name], Math.round(pct)));
			scrubber = undefined;
		}
		
		
		/** Reflect the new volume in the controlbar **/
		private function volumeHandler(evt:MediaEvent = null):void {
			try {
				var vsl:MovieClip = getSkinElement("controlbar", 'volumeSlider') as MovieClip;
				vsl.mark.width = player.config.volume * (vsl.rail.width - vsl.icon.width / 2) / 100;
				vsl.icon.x = vsl.mark.x + player.config.volume * (vsl.rail.width - vsl.icon.width) / 100;
			} catch (err:Error) {
			}
		}
		
		private function getSkinElement(component:String, element:String):MovieClip {
			return skin.getChildByName(element) as MovieClip;
		}
	}
}