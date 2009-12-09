package com.longtailvideo.jwplayer.view.components {
	import com.longtailvideo.jwplayer.events.PlayerStateEvent;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.IPlayer;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.utils.AssetLoader;
	import com.longtailvideo.jwplayer.utils.Draw;
	import com.longtailvideo.jwplayer.utils.Logger;
	import com.longtailvideo.jwplayer.utils.RootReference;
	import com.longtailvideo.jwplayer.utils.Stacker;
	import com.longtailvideo.jwplayer.utils.Stretcher;
	import com.longtailvideo.jwplayer.utils.Strings;
	import com.longtailvideo.jwplayer.view.PlayerLayoutManager;
	import com.longtailvideo.jwplayer.view.interfaces.IPlaylistComponent;
	import com.longtailvideo.jwplayer.view.interfaces.ISkin;
	import com.longtailvideo.jwplayer.view.skins.DefaultSkin;
	import com.longtailvideo.jwplayer.view.skins.SWFSkin;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	public class PlaylistComponent extends CoreComponent implements IPlaylistComponent {
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
		/** Visual representation of a the playlist **/
		private var list:Sprite;
		/** Visual representation of a playlist item **/
		private var button:Sprite;
		/** The playlist mask **/
		private var listmask:Sprite;
		/** The playlist slider **/
		private var slider:Sprite;
		/** The playlist background **/
		private var background:Sprite;
		/** Internal reference to the skin **/
		private var skin:ISkin;
		private var skinLoaded:Boolean = false;
		private var pendingResize:Rectangle;
		private var pendingBuild:Boolean = false;
		/** Map of images and loaders **/
		private var imageLoaderMap:Dictionary = new Dictionary();
		
		public function PlaylistComponent(player:IPlayer) {
			super(player, "playlist");
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_ITEM, itemHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, playlistHandler);
			player.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_UPDATED, playlistHandler);
			player.addEventListener(PlayerStateEvent.JWPLAYER_PLAYER_STATE, stateHandler);
			
			if (_player.skin is SWFSkin && !_player.skin.hasComponent('playlist')) {
				var defaultSkin:DefaultSkin = new DefaultSkin();
				defaultSkin.addEventListener(Event.COMPLETE, continueSetup);
				skin = defaultSkin;
				defaultSkin.load();
			} else {
				skinLoaded = true;
				skin = _player.skin;
				continueSetup();
			}
		}
		
		protected function continueSetup(evt:Event=null):void {
			skinLoaded = true;
			
			background = getSkinElement("background") as Sprite;
			if (!background) {
				background = new Sprite();
				background.name = "background";
				background.graphics.beginFill(0, 1);
				background.graphics.drawRect(0, 0, 1, 1);
				background.graphics.endFill();
			}
			addElement(background);
			slider = getSkinElement("slider") as Sprite;
			if (!slider) {
				slider = new Sprite();
				
				var sliderBack:Sprite = getSkinElement("sliderBackground") as Sprite;
				if (!sliderBack) {
					sliderBack = new Sprite();
					sliderBack.graphics.beginFill(0, 1);
					sliderBack.graphics.drawRect(0, 0, 1, 1);
					sliderBack.graphics.endFill();
				}
				sliderBack.name = "back";
				addElement(sliderBack,slider);
				
				var sliderRail:Sprite = getSkinElement("sliderRail") as Sprite;
				if (!sliderRail){
					sliderRail = new Sprite();
					sliderRail.graphics.beginFill(0, 1);
					sliderRail.graphics.drawRect(0, 0, 7, 22);
					sliderRail.graphics.endFill();
				}
				sliderRail.name = "rail";
				addElement(sliderRail,slider);
				
				var sliderThumb:Sprite = getSkinElement("sliderThumb") as Sprite;
				if (!sliderThumb) {
					sliderThumb = new Sprite();
					sliderThumb.graphics.beginFill(0, 1);
					sliderThumb.graphics.drawRect(0, 0, 5, 54);
					sliderThumb.graphics.endFill();
				}
				sliderThumb.name = "icon";
				addElement(sliderThumb,slider,(sliderRail.width - sliderThumb.width)/2);
			}
			addElement(slider);
			slider.buttonMode = true;
			slider.mouseChildren = false;
			slider.addEventListener(MouseEvent.MOUSE_DOWN, sdownHandler);
			slider.addEventListener(MouseEvent.MOUSE_OVER, soverHandler);
			slider.addEventListener(MouseEvent.MOUSE_OUT, soutHandler);
			slider.visible = false;
			listmask = getSkinElement("masker") as Sprite;
			if (!listmask) {
				listmask = new Sprite();
				listmask.graphics.beginFill(0xff0000, 1);
				listmask.graphics.drawRect(0, 0, 1, 1);
				listmask.graphics.endFill();
			}
			addElement(listmask);
			list = getSkinElement("list") as Sprite;
			if (!list) {
				list = new Sprite();
				button = buildButton() as Sprite;
				addElement(button, list);
			} else {
				button = list.getChildByName("button") as Sprite;
			}
			buttonheight = button.height;
			button.visible = false;
			list.mask = listmask;
			list.addEventListener(MouseEvent.CLICK, clickHandler);
			list.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			list.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addElement(list);
			buttons = new Array();
			this.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			try {
				image = new Array(button.getChildByName("image").width, button.getChildByName("image").height);
			} catch (err:Error) {
			}
			if (button.getChildByName("back")) {
				setColors();
			}
			if (pendingBuild) {
				buildPlaylist(true);
			}
			if (pendingResize) {
				resize(pendingResize.width, pendingResize.height);
			}
		}
		
		
		private function buildButton():MovieClip {
			var btn:MovieClip = new MovieClip();
			
			var backOver:Sprite = getSkinElement("itemOver") as Sprite;
			if (!backOver) {
				backOver = new Sprite();
				backOver.graphics.beginFill(0, 1);
				backOver.graphics.drawRect(0, 0, 1, 1);
				backOver.graphics.endFill();
			}
			backOver.name = "backOver";
			addElement(backOver, btn, 0, 0);
			
			var back:Sprite = getSkinElement("item") as Sprite;
			if (!back) {
				back = new Sprite();
				back.graphics.beginFill(0, 1);
				back.graphics.drawRect(0, 0, 100, 100);
				back.graphics.endFill();
			}
			back.name = "back";
			addElement(back, btn, 0, 0);
			
			var img:Sprite = new Sprite();
			img.name = "image";
			img.graphics.beginFill(0, 1);
			img.graphics.drawRect(0, 0, 80, back.height);
			img.graphics.endFill();
			addElement(img, btn, 1, 1);
			
			var titleTextFormat:TextFormat = new TextFormat();
			titleTextFormat.size = 13;
			titleTextFormat.font = "_sans";
			titleTextFormat.bold = true;
			var title:TextField = new TextField();
			title.name = "title";
			//title.autoSize = TextFieldAutoSize.LEFT;
			title.defaultTextFormat = titleTextFormat;
			title.wordWrap = true;
			title.multiline = true;
			title.width = 250;
			title.height = 20;
			addElement(title, btn, 85, 2);
			
			var descriptionTextFormat:TextFormat = new TextFormat();
			descriptionTextFormat.size = 11;
			descriptionTextFormat.font = "_sans";
			var description:TextField = new TextField();
			description.name = "description";
			//description.autoSize = TextFieldAutoSize.LEFT;
			description.wordWrap = true;
			description.multiline = true;
			description.width= 290;
			description.height = back.height - 20;
			description.defaultTextFormat = descriptionTextFormat;
			addElement(description, btn, 86, 20);
			
			var duration:TextField = new TextField();
			duration.name = "duration";
			duration.width = 40;
			duration.height = 20;
			addElement(duration, btn, 335, 4);
			
			backOver.width = btn.width;			
			back.width = btn.width;
			
			return btn;
		}
		
		private function addElement(doc:DisplayObject, parent:DisplayObjectContainer = null, x:Number = 0, y:Number = 0):void {
			if (!parent) {
				parent = this;
			}
			parent.addChild(doc);
			doc.x = x;
			doc.y = y;
		}
		
		
		/** Handle a button rollover. **/
		private function overHandler(evt:MouseEvent):void {
			var idx:Number = Number(evt.target.name);
			if (front && back) {
				for (var itm:String in _player.playlist.getItemAt(idx)) {
					if (getButton(idx).getChildByName(itm) && getButton(idx).getChildByName(itm) is TextField) {
						(getButton(idx).getChildByName(itm) as TextField).textColor = back.color;
					}
				}
				if (swfSkinned) {
					getButton(idx).getChildByName("back").transform.colorTransform = light;
				} else {
					getButton(idx).setChildIndex(getButton(idx).getChildByName("back"), 0);
					getButton(idx).setChildIndex(getButton(idx).getChildByName("backOver"), 1);
				}
			}
		}
		
		
		/** Handle a button rollover. **/
		private function outHandler(evt:MouseEvent):void {
			var idx:Number = Number(evt.target.name);
			if (front && back) {
				for (var itm:String in _player.playlist.getItemAt(idx)) {
					if (getButton(idx).getChildByName(itm) && getButton(idx).getChildByName(itm) is TextField) {
						if (idx == active) {
							(getButton(idx).getChildByName(itm) as TextField).textColor = light.color;
						} else {
							(getButton(idx).getChildByName(itm) as TextField).textColor = front.color;
						}
					}
				}
				if (swfSkinned) {
					getButton(idx).getChildByName("back").transform.colorTransform = back;
				} else {
					getButton(idx).setChildIndex(getButton(idx).getChildByName("backOver"), 0);
					getButton(idx).setChildIndex(getButton(idx).getChildByName("back"), 1);
				}
			}
		}
		
		
		/** Setup all buttons in the playlist **/
		private function buildPlaylist(clr:Boolean):void {
			if (!_player.playlist || player.playlist.length < 1) {
				return;
			}
			if (!skinLoaded) {
				pendingBuild = true;
				return
			}

			var wid:Number = getConfigParam("width");
			var hei:Number = getConfigParam("height");
			listmask.height = hei;
			listmask.width = wid;
			proportion = _player.playlist.length * buttonheight / hei;
			if (proportion > 1.01) {
				wid -= slider.width;
				buildSlider();
			} else {
				slider.visible = false;
			}
			if (clr) {
				list.y = listmask.y;
				for (var j:Number = 0; j < buttons.length; j++) {
					list.removeChild(getButton(j));
				}
				buttons = new Array();
			} else {
				if (proportion > 1) {
					scrollEase();
				}
			}
			for (var i:Number = 0; i < _player.playlist.length; i++) {
				if (clr) {
					var btn:MovieClip;
					if (swfSkinned) {
						btn = Draw.clone(button, true) as MovieClip;
					} else {
						btn = buildButton();
						list.addChild(btn);
					}
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
			slider.visible = true;
			slider.x = getConfigParam("width") - slider.width;
			var dif:Number = getConfigParam("height") - slider.height - slider.y;
			slider.getChildByName("back").height += dif;
			slider.getChildByName("rail").height += dif;
			slider.getChildByName("icon").height = Math.round(slider.getChildByName("rail").height / proportion);
		}
		
		
		/** Make sure the playlist is not out of range. **/
		private function scrollEase(ips:Number = -1, cps:Number = -1):void {
			if (ips != -1) {
				slider.getChildByName("icon").y = Math.round(ips - (ips - slider.getChildByName("icon").y) / 1.5);
				list.y = Math.round((cps - (cps - list.y) / 1.5));
			}
			if (list.y > 0 || slider.getChildByName("icon").y < slider.getChildByName("rail").y) {
				list.y = listmask.y;
				slider.getChildByName("icon").y = slider.getChildByName("rail").y;
			} else if (list.y < listmask.height - list.height || slider.getChildByName("icon").y > slider.getChildByName("rail").y + slider.getChildByName("rail").height - slider.getChildByName("icon").height) {
				slider.getChildByName("icon").y = slider.getChildByName("rail").y + slider.getChildByName("rail").height - slider.getChildByName("icon").height;
				list.y = listmask.y + listmask.height - list.height;
			}
		}
		
		
		/** Scrolling handler. **/
		private function scrollHandler():void {
			var yps:Number = slider.mouseY - slider.getChildByName("rail").y;
			var ips:Number = yps - slider.getChildByName("icon").height / 2;
			var cps:Number = listmask.y + listmask.height / 2 - proportion * yps;
			scrollEase(ips, cps);
		}
		
		
		/** Init the colors. **/
		private function setColors():void {
			if (_player.config.backcolor) {
				back = new ColorTransform();
				back.color = _player.config.backcolor.color;
				if (swfSkinned) {
					background.transform.colorTransform = back;
					slider.getChildByName("back").transform.colorTransform = back;
				} 
			}
			if (_player.config.frontcolor) {
				front = new ColorTransform();
				front.color = _player.config.frontcolor.color;
				try {
					if (swfSkinned) {
						slider.getChildByName("icon").transform.colorTransform = front;
						slider.getChildByName("rail").transform.colorTransform = front;
					}
				} catch (err:Error) {
				}
				if (_player.config.lightcolor) {
					light = new ColorTransform();
					light.color = _player.config.lightcolor.color;
				} else {
					light = front;
				}
			}
		}
		
		
		/** Setup button elements **/
		private function setContents(idx:Number):void {
			var playlistItem:PlaylistItem = _player.playlist.getItemAt(idx);
			var title:TextField = getButton(idx).getChildByName("title") as TextField;
			var description:TextField = getButton(idx).getChildByName("description") as TextField;
			var duration:TextField = getButton(idx).getChildByName("duration") as TextField;
			var author:TextField = getButton(idx).getChildByName("author") as TextField;
			var tags:TextField = getButton(idx).getChildByName("tags") as TextField;
			if (playlistItem.image) {
				if (getConfigParam('thumbs') != false && _player.config.playlist != 'none' && playlistItem.image) {
					var img:Sprite = getButton(idx).getChildByName("image") as Sprite;
					img.alpha = 0;
					if (img && playlistItem.image) {
						var ldr:AssetLoader = new AssetLoader();
						imageLoaderMap[ldr] = idx;
						ldr.addEventListener(Event.COMPLETE, loaderHandler);
						ldr.addEventListener(ErrorEvent.ERROR, errorHandler);
						ldr.load(playlistItem.image);
					}
				}
			}
			if (duration && playlistItem.duration) {
				if (playlistItem.duration > 0) {
					duration.text = Strings.digits(playlistItem.duration);
					if (front) {
						duration.textColor = front.color;
					}
				}
			}
			try {
				if (description) { 
					description.htmlText = playlistItem.description; 
				}
				if (title) { 
					title.htmlText = "<b>" + playlistItem.title + "</b>"; 
				}
				if (author) { 
					author.htmlText = playlistItem.author; 
				}
				if (tags) { 
					tags.htmlText = playlistItem.tags; 
				}
				if (front) {
					description.textColor = front.color;
					title.textColor = front.color;
				}
			} catch (e:Error) {
			}
			if (getButton(idx).getChildByName("image") && (!playlistItem.image || getConfigParam('thumbs') == false)) {
				getButton(idx).getChildByName("image").visible = false;
			}
			if (back && swfSkinned) {
				getButton(idx).getChildByName("back").transform.colorTransform = back;
			}
		}
		
		
		/** Loading of image completed; resume loading **/
		private function loaderHandler(evt:Event):void {
			try {
				var ldr:AssetLoader = evt.target as AssetLoader;
				var button:Sprite = getButton(imageLoaderMap[ldr]);
				var img:Sprite = button.getChildByName("image") as Sprite;
				img.alpha = 1;
				var msk:Sprite = Draw.rect(button, '0xFF0000', img.width, img.height, img.x, img.y);
				img.mask = msk;
				img.addChild(ldr.loadedObject);
				Draw.smooth(ldr.loadedObject);
				Stretcher.stretch(ldr.loadedObject, image[0], image[1], Stretcher.FILL);
			} catch (err:Error) {
				Logger.log('Error loading playlist image: '+err.message);
			}
		}
		
		
		/** Loading of image failed; hide image **/
		private function errorHandler(evt:Event):void {
			try {
				var ldr:AssetLoader = evt.target as AssetLoader;
				var button:Sprite = getButton(imageLoaderMap[ldr]);
				var img:Sprite = button.getChildByName("image") as Sprite;
				img.visible = false;
				(buttons[imageLoaderMap[ldr]].s as Stacker).rearrange(getConfigParam("width"));
			} catch (err:Error) {
				Logger.log('Error loading playlist image '+(ldr.loadedObject as Loader).loaderInfo.url+': '+err.message);
			}
		}
		
		
		private function wheelHandler(evt:MouseEvent):void {
			//scrollEase(evt.delta * -1, getConfigParam("height"));
		}
		
		
		/** Start scrolling the playlist on mousedown. **/
		private function sdownHandler(evt:MouseEvent):void {
			clearInterval(scrollInterval);
			RootReference.stage.addEventListener(MouseEvent.MOUSE_UP, supHandler);
			scrollHandler();
			scrollInterval = setInterval(scrollHandler, 50);
		}
		
		
		/** Revert the highlight on mouseout. **/
		private function soutHandler(evt:MouseEvent):void {
			if (front && swfSkinned) {
				slider.getChildByName("icon").transform.colorTransform = front;
			} else {
				//slider.getChildByName("icon").gotoAndStop('out');
			}
		}
		
		
		/** Highlight the icon on rollover. **/
		private function soverHandler(evt:MouseEvent):void {
			if (front && swfSkinned) {
				slider.getChildByName("icon").transform.colorTransform = light;
			} else {
				//slider.getChildByName("icon").gotoAndStop('over');
			}
		}
		
		
		/** Stop scrolling the playlist on mouseout. **/
		private function supHandler(evt:MouseEvent):void {
			clearInterval(scrollInterval);
			RootReference.stage.removeEventListener(MouseEvent.MOUSE_UP, supHandler);
		}
		
		
		/** Handle a click on a button. **/
		private function clickHandler(evt:MouseEvent):void {
			_player.playlistItem(Number(evt.target.name));
		}
		
		
		/** Process resizing requests **/
		public function resize(width:Number, height:Number):void {
			if (skinLoaded) {
				setConfigParam("width", width);
				setConfigParam("height", height);
				background.width = width;
				background.height = height;
				buildPlaylist(false);
				if (PlayerLayoutManager.testPosition(getConfigParam('position'))) {
					visible = true;
				} else if (getConfigParam('position') == "over") {
					stateHandler();
				} else {
					visible = false;
				}
				if (visible && getConfigParam('visible') === false) {
					visible = false;
				}
			} else {
				pendingResize = new Rectangle(0,0,width,height);
			}
		}
		
		
		/** Switch the currently active item */
		protected function itemHandler(evt:PlaylistEvent = null):void {
			var idx:Number = _player.playlist.currentIndex;
			clearInterval(scrollInterval);
			if (proportion > 1.01) {
				scrollInterval = setInterval(scrollEase, 50, idx * buttonheight / proportion, -idx * buttonheight + listmask.y);
			}
			if (light) {
				for (var itm:String in _player.playlist.getItemAt(idx)) {
					if (getButton(idx).getChildByName(itm)) {
						try {
							(getButton(idx).getChildByName(itm) as TextField).textColor = light.color;
						} catch (err:Error) {
						}
					}
				}
			}
			if (back && swfSkinned) {
				getButton(idx).getChildByName("back").transform.colorTransform = back;
			}
			if (!isNaN(active)) {
				if (front) {
					for (var act:String in _player.playlist.getItemAt(active)) {
						if (getButton(active).getChildByName(act)) {
							try {
								(getButton(active).getChildByName(act) as TextField).textColor = front.color;
							} catch (err:Error) {
							}
						}
					}
				}
			}
			active = idx;
		}
		
		
		/** New playlist loaded: rebuild the playclip. **/
		protected function playlistHandler(evt:PlaylistEvent = null):void {
			clearInterval(scrollInterval);
			active = undefined;
			buildPlaylist(true);
			resize(background.width, background.height);
		}
		
		
		/** Process state changes **/
		protected function stateHandler(evt:PlayerStateEvent = null):void {
			if (getConfigParam('position') == "over") {
				if (player.state == PlayerState.PLAYING || player.state == PlayerState.PAUSED || player.state == PlayerState.BUFFERING) {
					visible = false;
				} else {
					visible = true;
				}
			}
		}
		
		
		private function getButton(id:Number):Sprite {
			return buttons[id].c as Sprite;
		}
		
		private function get swfSkinned():Boolean {
			if (skin is SWFSkin) {
				return (skin.hasComponent('playlist'));
			}
			return false;
		}
		
		protected override function getSkinElement(element:String):DisplayObject {
			return skin.getSkinElement(_name,element);
		}
		
	}
}

