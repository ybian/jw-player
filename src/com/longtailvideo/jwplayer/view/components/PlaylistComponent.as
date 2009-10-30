package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.plugins.PluginConfig;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Stacker;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.PlayerLayoutManager;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	public class PlaylistComponent extends CoreComponent implements IPlaylistComponent {
		/** Reference to the playlist MC. **/
		public var clip:MovieClip;
		/** Array with all button instances **/
		private var buttons:Array;
		/** Height of a button (to calculate scrolling) **/
		private var buttonheight:Number;
		/** Currently active button. **/
		private var active:Number;
		/** Proportion between clip and mask. **/
		private var proportion:Number;
		/** Interval ID for scrolling **/
		private var scrollInterval:Number;
		/** Image dimensions. **/
		private var image:Array;
		/** Color object for backcolor. **/
		private var back:ColorTransform;
		/** Color object for frontcolor. **/
		private var front:ColorTransform;
		/** Color object for lightcolor. **/
		private var light:ColorTransform;
		
		
		public function PlaylistComponent(player:IPlayer) {
			super(player);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, playlistHandler);
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			clip = _player.skin.getSWFSkin().getChildByName("playlist") as MovieClip;
			addChild(clip);
			buttonheight = clip.list.button.height;
			clip.list.button.visible = false;
			clip.list.mask = clip.masker;
			clip.list.addEventListener(MouseEvent.CLICK, clickHandler);
			clip.list.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			clip.list.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			clip.slider.buttonMode = true;
			clip.slider.mouseChildren = false;
			clip.slider.addEventListener(MouseEvent.MOUSE_DOWN, sdownHandler);
			clip.slider.addEventListener(MouseEvent.MOUSE_OVER, soverHandler);
			clip.slider.addEventListener(MouseEvent.MOUSE_OUT, soutHandler);
			clip.slider.visible = false;
			buttons = new Array();
			try {
				image = new Array(clip.list.button.image.width, clip.list.button.image.height);
			} catch (err:Error) {
			}
			if (clip.list.button['back']) {
				setColors();
			}
		}
		
		
		/** Handle a button rollover. **/
		private function overHandler(evt:MouseEvent):void {
			var idx:Number = Number(evt.target.name);
			if (front && back) {
				for (var itm:String in _player.playlist.getItemAt(idx)) {
					if (buttons[idx].c[itm] && typeof(buttons[idx].c[itm]) == "object") {
						buttons[idx].c[itm].textColor = back.color;
					}
				}
				buttons[idx].c['back'].transform.colorTransform = light;
			}
			buttons[idx].c.gotoAndStop('over');
		};
		
		
		/** Handle a button rollover. **/
		private function outHandler(evt:MouseEvent):void {
			var idx:Number = Number(evt.target.name);
			if (front && back) {
				for (var itm:String in _player.playlist.getItemAt(idx)) {
					if (buttons[idx].c[itm] && typeof(buttons[idx].c[itm]) == "object") {
						if (idx == active) {
							buttons[idx].c[itm].textColor = light.color;
						} else {
							buttons[idx].c[itm].textColor = front.color;
						}
					}
				}
				buttons[idx].c['back'].transform.colorTransform = back;
			}
			if (idx == active) {
				buttons[idx].c.gotoAndStop('active');
			} else {
				buttons[idx].c.gotoAndStop('out');
			}
		};
		
		
		/** Setup all buttons in the playlist **/
		private function buildPlaylist(clr:Boolean):void {
			if (!_player.playlist) {
				return;
			}
			var wid:Number = clip.back.width;
			var hei:Number = clip.back.height;
			clip.masker.height = hei;
			clip.masker.width = wid;
			proportion = _player.playlist.length * buttonheight / hei;
			if (proportion > 1.01) {
				wid -= clip.slider.width;
				buildSlider();
			} else {
				clip.slider.visible = false;
			}
			if (clr) {
				clip.list.y = clip.masker.y;
				for (var j:Number = 0; j < buttons.length; j++) {
					clip.list.removeChild(buttons[j].c);
				}
				buttons = new Array();
			} else {
				if (proportion > 1) {
					scrollEase();
				}
			}
			for (var i:Number = 0; i < _player.playlist.length; i++) {
				if (clr) {
					var btn:MovieClip = Draw.clone(clip.list.button, true) as MovieClip;
					var stc:Stacker = new Stacker(btn);
					btn.y = i * buttonheight;
					btn.buttonMode = true;
					btn.mouseChildren = false;
					btn.name = i.toString();
					buttons.push({c: btn, s: stc});
					setContents(i);
				}
				if (buttons[i]) {
					(buttons[i].s as Stacker).rearrange(wid);
				}
			}
		}
		
		
		/** Setup the scrollbar component **/
		private function buildSlider():void {
			var scr:MovieClip = clip.slider;
			scr.visible = true;
			scr.x = clip.back.width - scr.width;
			var dif:Number = clip.back.height - scr.height - scr.y;
			scr.back.height += dif;
			scr.rail.height += dif;
			scr.icon.height = Math.round(scr.rail.height / proportion);
		}
		
		
		/** Make sure the playlist is not out of range. **/
		private function scrollEase(ips:Number = -1, cps:Number = -1):void {
			var scr:MovieClip = clip.slider;
			if (ips != -1) {
				scr.icon.y = Math.round(ips - (ips - scr.icon.y) / 1.5);
				clip.list.y = Math.round((cps - (cps - clip.list.y) / 1.5));
			}
			if (clip.list.y > 0 || scr.icon.y < scr.rail.y) {
				clip.list.y = clip.masker.y;
				scr.icon.y = scr.rail.y;
			} else if (clip.list.y < clip.masker.height - clip.list.height || scr.icon.y > scr.rail.y + scr.rail.height - scr.icon.height) {
				scr.icon.y = scr.rail.y + scr.rail.height - scr.icon.height;
				clip.list.y = clip.masker.y + clip.masker.height - clip.list.height;
			}
		};
		
		
		/** Scrolling handler. **/
		private function scrollHandler():void {
			var scr:MovieClip = clip.slider;
			var yps:Number = scr.mouseY - scr.rail.y;
			var ips:Number = yps - scr.icon.height / 2;
			var cps:Number = clip.masker.y + clip.masker.height / 2 - proportion * yps;
			scrollEase(ips, cps);
		};
		
		
		/** Init the colors. **/
		private function setColors():void {
			if (_player.config.backcolor) {
				back = new ColorTransform();
				back.color = _player.config.backcolor.color;
				clip.back.transform.colorTransform = back;
				clip.slider.back.transform.colorTransform = back;
			}
			if (_player.config.frontcolor) {
				front = new ColorTransform();
				front.color = _player.config.frontcolor.color;
				try {
					clip.slider.icon.transform.colorTransform = front;
					clip.slider.rail.transform.colorTransform = front;
				} catch (err:Error) {
				}
				if (_player.config.lightcolor) {
					light = new ColorTransform();
					light.color = _player.config.lightcolor.color;
				} else {
					light = front;
				}
			}
		};
		
		
		/** Setup button elements **/
		private function setContents(idx:Number):void {
			var playlistItem:PlaylistItem = _player.playlist.getItemAt(idx);
			buttons[idx].c.gotoAndStop(0);
			if (playlistItem.image) {
				if (config['thumbs'] != false && _player.config.playlist != 'none' && playlistItem.image) {
					var img:MovieClip = buttons[idx].c.image;
					var msk:Sprite = Draw.rect(buttons[idx].c, '0xFF0000', img.width, img.height, img.x, img.y);
					var ldr:Loader = new Loader();
					img.mask = msk;
					img.addChild(ldr);
					ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderHandler);
					if (playlistItem.image) {
						ldr.load(new URLRequest(playlistItem.image));
					}
				}
			}
			if (playlistItem.duration) {
				if (playlistItem.duration > 0) {
					buttons[idx].c['duration'].text = Strings.digits(playlistItem.duration);
					if (front) {
						buttons[idx].c['duration'].textColor = front.color;
					}
				}
			}
			try {
				buttons[idx].c['description'].htmlText = playlistItem.description;
				buttons[idx].c['title'].htmlText = "<b>" + playlistItem.title + "</b>";
				if (front) {
					buttons[idx].c['description'].textColor = front.color;
					buttons[idx].c['title'].textColor = front.color;
				}
			} catch (e:Error) {
			}
			if (buttons[idx].c['image'] && (!playlistItem.image || config['thumbs'] == false)) {
				buttons[idx].c['image'].visible = false;
			}
			if (back) {
				buttons[idx].c['back'].transform.colorTransform = back;
			}
		}
		
		
		/** Loading of image completed; resume loading **/
		private function loaderHandler(evt:Event):void {
			var ldr:Loader = Loader(evt.target.loader);
			Stretcher.stretch(ldr, image[0], image[1], Stretcher.FILL);
		};
		
		
		/** Start scrolling the playlist on mousedown. **/
		private function sdownHandler(evt:MouseEvent):void {
			clearInterval(scrollInterval);
			clip.stage.addEventListener(MouseEvent.MOUSE_UP, supHandler);
			scrollHandler();
			scrollInterval = setInterval(scrollHandler, 50);
		};
		
		
		/** Revert the highlight on mouseout. **/
		private function soutHandler(evt:MouseEvent):void {
			if (front) {
				clip.slider.icon.transform.colorTransform = front;
			} else {
				clip.slider.icon.gotoAndStop('out');
			}
		};
		
		
		/** Highlight the icon on rollover. **/
		private function soverHandler(evt:MouseEvent):void {
			if (front) {
				clip.slider.icon.transform.colorTransform = light;
			} else {
				clip.slider.icon.gotoAndStop('over');
			}
		};
		
		
		/** Stop scrolling the playlist on mouseout. **/
		private function supHandler(evt:MouseEvent):void {
			clearInterval(scrollInterval);
			clip.stage.removeEventListener(MouseEvent.MOUSE_UP, supHandler);
		};
		
		
		/** Handle a click on a button. **/
		private function clickHandler(evt:MouseEvent):void {
			_player.playlistItem(Number(evt.target.name));
		}
		
		
		/** Process resizing requests **/
		public function resize(width:Number, height:Number):void {
			clip.x = 0;
			clip.y = 0;
			clip.back.width = width;
			clip.back.height =  height;
			buildPlaylist(false);
			if ( PlayerLayoutManager.testPosition(config['position'])) {
				clip.visible = true;
			} else if (config['position'] == "over") {
				stateHandler();
			} else {
				clip.visible = false;
			}

			if (clip.visible && config['visible'] === false) {
				clip.visible = false;
			}
		}
		
		
		/** Switch the currently active item */
		protected function itemHandler(evt:PlaylistEvent = null):void {
			var idx:Number = _player.playlist.currentIndex;
			clearInterval(scrollInterval);
			if (proportion > 1.01) {
				scrollInterval = setInterval(scrollEase, 50, idx * buttonheight / proportion, -idx * buttonheight + clip.masker.y);
			}
			if (light) {
				for (var itm:String in _player.playlist.getItemAt(idx)) {
					if (buttons[idx].c[itm]) {
						try {
							buttons[idx].c[itm].textColor = light.color;
						} catch (err:Error) {
						}
					}
				}
			}
			if (back) {
				buttons[idx].c['back'].transform.colorTransform = back;
			}
			buttons[idx].c.gotoAndStop('active');
			if (!isNaN(active)) {
				if (front) {
					for (var act:String in _player.playlist.getItemAt(active)) {
						if (buttons[active].c[act]) {
							try {
								buttons[active].c[act].textColor = front.color;
							} catch (err:Error) {
							}
						}
					}
				}
				buttons[active].c.gotoAndStop('out');
			}
			active = idx;
		}
		
		
		/** New playlist loaded: rebuild the playclip. **/
		protected function playlistHandler(evt:PlaylistEvent = null):void {
			clearInterval(scrollInterval);
			active = undefined;
			buildPlaylist(true);
			resize(width, height);
		}
		
		
		/** Process state changes **/
		protected function stateHandler(evt:PlayerStateEvent = null):void {
			if (config['position'] == "over") {
				if (player.state == PlayerState.PLAYING || player.state == PlayerState.PAUSED || player.state == PlayerState.BUFFERING) {
					clip.visible = false;
				} else {
					clip.visible = true;
				}
			}
		}
		
		
		protected function get config():PluginConfig {
			return player.config.pluginConfig('playlist');
		}
		
		
		protected function getSkinElement(component:String, element:String):DisplayObject {
			return _player.skin.getSkinElement(component, element);
		}
	}
}