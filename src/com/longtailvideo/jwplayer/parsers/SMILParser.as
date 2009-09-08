package com.longtailvideo.jwplayer.parsers {

	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.utils.Strings;

	/**
	 * Parse an SMIL feed and translate it to a feedarray.
	 **/
	public class SMILParser implements IPlaylistParser {

		/** Parse an SMIL playlist for feeditems. **/
		public function parse(dat:XML):Array {
			var arr:Array = new Array();
			var elm:XML = dat.children()[1].children()[0];
			if (elm.localName().toLowerCase() == 'seq') {
				for each (var i:XML in elm.children()) {
					arr.push(new PlaylistItem(parseSeq(i)));
				}
			} else {
				arr.push(parseItem(elm));
			}
			return arr;
		}
		
		public function parseItem(obj:XML):PlaylistItem {
			return new PlaylistItem(parsePar(obj));
		}

		/** Translate SMIL sequence item to playlistitem. **/
		public function parseSeq(obj:XML):Object {
			var itm:Object = new Object();
			switch (obj.localName().toLowerCase()) {
				case 'par':
					itm = parsePar(obj);
					break;
				case 'img':
				case 'video':
				case 'audio':
					itm = parseAttributes(obj, itm);
					break;
				default:
					break;
			}
			return itm;
		}

		/** Translate a SMIL par group to playlistitem **/
		public function parsePar(obj:XML):Object {
			var itm:Object = new Object();
			for each (var i:XML in obj.children()) {
				switch (i.localName().toLowerCase()) {
					case 'anchor':
						itm['link'] = i.@href.toString();
						break;
					case 'img':
						if (itm['file']) {
							itm['image'] = i.@src.toString();
							break;
						} else {
							itm = parseAttributes(i, itm);
						}
						break;
					case 'video':
					case 'audio':
						itm = parseAttributes(i, itm);
						break;
					default:
						break;
				}
			}
			itm = JWParser.parseEntry(obj, itm);
			return itm;
		}

		/** Get attributes from a SMIL element. **/
		public function parseAttributes(obj:Object, itm:Object):Object {
			for (var i:Number = 0; i < obj.attributes().length(); i++) {
				var att:String = obj.attributes()[i].name().toString();
				switch (att) {
					case 'begin':
						itm['start'] = Strings.seconds(obj.@begin.toString());
						break;
					case 'src':
						itm['file'] = obj.@src.toString();
						break;
					case 'dur':
						itm['duration'] = Strings.seconds(obj.@dur.toString());
						break;
					case 'alt':
						itm['description'] = obj.@alt.toString();
						break;
					default:
						itm[att] = obj.attributes()[i].toString();
						break;
				}
			}
			return itm;
		}

	}

}