package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.events.PlayerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.events.ViewEvent;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Stacker;
	import com.longtailvideo.jwplayer.utils.Strings;
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
	import com.jeroenwijering.events.ControllerEvent;
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.Logger;
	
	
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
		private var SLIDERS:Object = {timeSlider: ViewEvent.JWPLAYER_VIEW_SEEK, volumeSlider: ViewEvent.JWPLAYER_VIEW_VOLUME};
		/** The button to clone for all custom buttons. **/
		private var clonee:MovieClip;
		/** Saving the block state of the controlbar. **/
		private var blocking:Boolean;
		/** Controlbar config **/
		private var controlbarConfig:PluginConfig;
		
		
		public function ControlbarComponentV4(player:Player) {
			super(player);
			controlbarConfig = player.config.pluginConfig("controlbar");
			// TODO: Remove Link button
			BUTTONS = {
				playButton: ViewEvent.JWPLAYER_VIEW_PLAY, 
				pauseButton: ViewEvent.JWPLAYER_VIEW_PAUSE, 
				stopButton: ViewEvent.JWPLAYER_VIEW_STOP, 
				prevButton: ViewEvent.JWPLAYER_VIEW_PREV, 
				nextButton: ViewEvent.JWPLAYER_VIEW_NEXT, 
				fullscreenButton: ViewEvent.JWPLAYER_VIEW_FULLSCREEN, 
				normalscreenButton: ViewEvent.JWPLAYER_VIEW_FULLSCREEN, 
				muteButton: ViewEvent.JWPLAYER_VIEW_MUTE, 
				unmuteButton: ViewEvent.JWPLAYER_VIEW_MUTE};
			var temp:Sprite = player.skin.getSWFSkin();
			skin = player.skin.getSWFSkin().getChildByName('controlbar') as Sprite;
			skin.x = 0;
			skin.y = 0;
			addChild(skin);
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_TIME, timeHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_MUTE, muteHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_VOLUME, volumeHandler);
			player.addEventListener(MediaEvent.JWPLAYER_MEDIA_BUFFER, loadedHandler);
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
		   getSkinElement('* @param hdl	The function to call when clicking the Button').
		 **/
		public function addButton(name:String, icon:DisplayObject, handler:Function = null):void {
			if (getSkinElement('linkButton') && getSkinElementChild('linkButton', 'back')) {
				var btn:* = Draw.clone(getSkinElement('linkButton') as Sprite);
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
				stacker.insert(btn, getSkinElement('linkButton') as MovieClip);
			}
		}
		
		
		public function removeButton(name:String):void {
			skin.removeChild(getSkinElement(name));
		}
		
		public function resize(width:Number, height:Number):void {
			var wid:Number = width;
			if (controlbarConfig['position'] == 'over' || player.config.fullscreen == true) {
				//x = player.config.x + player.config.margin;
				//y = player.config.y + player.config.height - player.config.margin - player.config.size;
				wid = width - 2 * controlbarConfig['margin'];
			}
			try {
				getSkinElement('fullscreenButton').visible = false;
				getSkinElement('normalscreenButton').visible = false;
				if (stage['displayState'] && player.config.height > 40) {
					if (player.config.fullscreen) {
						getSkinElement('fullscreenButton').visible = false;
						getSkinElement('normalscreenButton').visible = true;
					} else {
						getSkinElement('fullscreenButton').visible = true;
						getSkinElement('normalscreenButton').visible = false;
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
			if (blocking != true || act == ViewEvent.JWPLAYER_VIEW_FULLSCREEN || act == ViewEvent.JWPLAYER_VIEW_MUTE) {
				switch (act) {
					case ViewEvent.JWPLAYER_VIEW_FULLSCREEN:
						data = Boolean(!player.config.fullscreen);
						break;
					case ViewEvent.JWPLAYER_VIEW_PAUSE:
						data = Boolean(_player.state == PlayerState.IDLE || _player.state == PlayerState.PAUSED);
						break;
					case ViewEvent.JWPLAYER_VIEW_MUTE:
						data = Boolean(!player.mute);
						break;
				}
				var event:ViewEvent = new ViewEvent(act, data);
				dispatchEvent(event);
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
				var scp:Number = getSkinElement('timeSlider').scaleX;
				getSkinElement('timeSlider').scaleX = 1;
				getSkinElementChild('timeSlider', 'icon').x = scp * getSkinElementChild('timeSlider', 'icon').x;
				getSkinElementChild('timeSlider', 'mark').x = scp * getSkinElementChild('timeSlider', 'mark').x;
				getSkinElementChild('timeSlider', 'mark').width = scp * getSkinElementChild('timeSlider', 'mark').width;
				getSkinElementChild('timeSlider', 'rail').width = scp * getSkinElementChild('timeSlider', 'rail').width;
				getSkinElementChild('timeSlider', 'done').x = scp * getSkinElementChild('timeSlider', 'done').x;
				getSkinElementChild('timeSlider', 'done').width = scp * getSkinElementChild('timeSlider', 'done').width;
			} catch (err:Error) {
			}
		}
		
		
		/** Handle a change in the current item **/
		private function itemHandler(evt:PlaylistEvent = null):void {
			try {
				if (player.playlist && player.playlist.length > 1) {
					getSkinElement('prevButton').visible = getSkinElement('nextButton').visible = true;
				} else {
					getSkinElement('prevButton').visible = getSkinElement('nextButton').visible = false;
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
				var wid:Number = getSkinElementChild('timeSlider', 'rail').width;
				//getSkinElement('timeSlider').getChildByName('mark').x = evt.position / evt.duration * wid;
				var icw:Number = getSkinElementChild('timeSlider', 'icon').x + getSkinElementChild('timeSlider', 'icon').width;
				var markWidth:Number = ((evt.bufferPercent / 100) * player.config.bufferlength) / evt.duration * wid + icw;
				getSkinElementChild('timeSlider', 'mark').width = Math.abs(markWidth);
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
			if (player.mute == true) {
				try {
					getSkinElement('muteButton').visible = false;
					getSkinElement('unmuteButton').visible = true;
				} catch (err:Error) {
				}
				try {
					getSkinElementChild('volumeSlider', 'mark').visible = false;
					getSkinElementChild('volumeSlider', 'icon').x = getSkinElementChild('volumeSlider', 'rail').x;
				} catch (err:Error) {
				}
			} else {
				try {
					getSkinElement('muteButton').visible = true;
					getSkinElement('unmuteButton').visible = false;
				} catch (err:Error) {
				}
				try {
					getSkinElementChild('volumeSlider', 'mark').visible = true;
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
				if (getSkinElement(btn)) {
					(getSkinElement(btn) as MovieClip).mouseChildren = false;
					(getSkinElement(btn) as MovieClip).buttonMode = true;
					getSkinElement(btn).addEventListener(MouseEvent.CLICK, clickHandler);
					getSkinElement(btn).addEventListener(MouseEvent.MOUSE_OVER, overHandler);
					getSkinElement(btn).addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				}
			}
			for (var sld:String in SLIDERS) {
				if (getSkinElement(sld)) {
					(getSkinElement(sld) as MovieClip).mouseChildren = false;
					(getSkinElement(sld) as MovieClip).buttonMode = true;
					getSkinElement(sld).addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
					getSkinElement(sld).addEventListener(MouseEvent.MOUSE_OVER, overHandler);
					getSkinElement(sld).addEventListener(MouseEvent.MOUSE_OUT, outHandler);
				}
			}
		}
		
		
		/** Init the colors. **/
		private function setColors():void {
			if (player.config.backcolor && getSkinElementChild('playButton', 'icon')) {
				var clr:ColorTransform = new ColorTransform();
				clr.color = player.config.backcolor;
				getSkinElement('back').transform.colorTransform = clr;
			}
			if (player.config.frontcolor) {
				try {
					front = new ColorTransform();
					front.color = player.config.frontcolor;
					for (var btn:String in BUTTONS) {
						if (getSkinElement(btn)) {
							getSkinElementChild(btn, 'icon').transform.colorTransform = front;
						}
					}
					for (var sld:String in SLIDERS) {
						if (getSkinElement(sld)) {
							getSkinElementChild(sld, 'icon').transform.colorTransform = front;
							getSkinElementChild(sld, 'mark').transform.colorTransform = front;
							getSkinElementChild(sld, 'rail').transform.colorTransform = front;
						}
					}
					(getSkinElement('elapsedText') as TextField).textColor = front.color;
					(getSkinElement('totalText') as TextField).textColor = front.color;
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
					getSkinElementChild('timeSlider', 'done').transform.colorTransform = light;
					getSkinElementChild('volumeSlider', 'mark').transform.colorTransform = light;
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
			switch (player.state) {
				case PlayerState.PLAYING:
					try {
						getSkinElement('playButton').visible = false;
						getSkinElement('pauseButton').visible = true;
					} catch (err:Error) {
					}
					if (controlbarConfig['position'] == 'over' || dps == 'fullScreen') {
						Mouse.show();
						/*var fade2:Fade = new Fade(this);
						   fade2.alphaTo = 1;
						 fade2.play();*/
					}
					break;
				case PlayerState.PAUSED:
					try {
						getSkinElement('playButton').visible = true;
						getSkinElement('pauseButton').visible = false;
					} catch (err:Error) {
					}
					if (controlbarConfig['position'] == 'over' || dps == 'fullScreen') {
						Mouse.show();
						/*var fade2:Fade = new Fade(this);
						   fade2.alphaTo = 1;
						 fade2.play();*/
					}
					break;
				case PlayerState.BUFFERING:
					try {
						getSkinElement('playButton').visible = false;
						getSkinElement('pauseButton').visible = true;
					} catch (err:Error) {
					}
					if (controlbarConfig['position'] == 'over' || (dps == 'fullScreen' && controlbarConfig['position'] != 'none')) {
						hiding = setTimeout(moveTimeout, 2000);
						player.skin.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
					} else {
						/*var fade1:Fade = new Fade(this);
						   fade1.alphaTo = 1;
						 fade1.play();*/
					}
					break;
				case PlayerState.IDLE:
					try {
						getSkinElement('playButton').visible = true;
						getSkinElement('pauseButton').visible = false;
						timeHandler();
					} catch (err:Error) {
					}
					if (controlbarConfig['position'] == 'over' || dps == 'fullScreen') {
						Mouse.show();
						/*var fade2:Fade = new Fade(this);
						   fade2.alphaTo = 1;
						 fade2.play();*/
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
				var temp:DisplayObject = skin.getChildByName('elapsedText');
				(getSkinElement('elapsedText') as TextField).text = Strings.digits(pos);
				(getSkinElement('totalText') as TextField).text = Strings.digits(dur);
			} catch (err:Error) {
				Logger.log(err);
			}
			try {
				var tsl:MovieClip = getSkinElement('timeSlider') as MovieClip;
				var xps:Number = Math.round(pct * (tsl.rail.width - tsl.icon.width));
				if (dur > 0) {
					getSkinElementChild('timeSlider', 'icon').visible = true;
					getSkinElementChild('timeSlider', 'mark').visible = true;
					if (!scrubber) {
						getSkinElementChild('timeSlider', 'icon').x = xps;
						getSkinElementChild('timeSlider', 'done').width = xps;
					}
					getSkinElementChild('timeSlider', 'done').visible = true;
				} else {
					getSkinElementChild('timeSlider', 'icon').visible = false;
					getSkinElementChild('timeSlider', 'mark').visible = false;
					getSkinElementChild('timeSlider', 'done').visible = false;
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
				var vsl:MovieClip = getSkinElement('volumeSlider') as MovieClip;
				vsl.mark.width = player.config.volume * (vsl.rail.width - vsl.icon.width / 2) / 100;
				vsl.icon.x = vsl.mark.x + player.config.volume * (vsl.rail.width - vsl.icon.width) / 100;
			} catch (err:Error) {
			}
		}
		
		
		private function getSkinElement(element:String):DisplayObject {
			return skin.getChildByName(element) as DisplayObject;
		}
		
		
		private function getSkinElementChild(element:String, child:String):DisplayObject {
			return (skin.getChildByName(element) as MovieClip).getChildByName(child);
		}
	}
}