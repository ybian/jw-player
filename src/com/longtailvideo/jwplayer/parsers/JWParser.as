/**
 * Parse JWPlayer specific feed content into playlists.
 **/
package com.longtailvideo.jwplayer.parsers {
	import com.longtailvideo.jwplayer.utils.Strings;

	public class JWParser {

		/** Prefix for the JW Player namespace. **/
		private static const PREFIX:String = 'jwplayer';

		/** File extensions of all supported mediatypes. **/
		private static var extensions:Object = {
				'3g2':'video',
				'3gp':'video',
				'aac':'video',
				'f4b':'video',
				'f4p':'video',
				'f4v':'video',
				'flv':'video',
				'gif':'image',
				'jpg':'image',
				'jpeg':'image',
				'm4a':'video',
				'm4v':'video',
				'mov':'video',
				'mp3':'sound',
				'mp4':'video',
				'png':'image',
				'rbs':'sound',
				'sdp':'video',
				'swf':'image',
				'vp6':'video'
			};
			
		/**
		 * Parse a feedentry for JWPlayer content.
		 *
		 * @param obj	The XML object to parse.
		 * @param itm	The playlistentry to amend the object to.
		 * @return		The playlistentry, amended with the JWPlayer info.
		 * @see			ASXParser
		 * @see			ATOMParser
		 * @see			RSSParser
		 * @see			SMILParser
		 * @see			XSPFParser
		 **/
		public static function parseEntry(obj:XML, itm:Object):Object {
			for each (var i:XML in obj.children()) {
				if (i.namespace().prefix == JWParser.PREFIX) {
					itm[i.localName()] = Strings.serialize(i.text().toString());
				}
			}
			updateProvider(itm);
			return itm;
		}
		
		public static function updateProvider(item:Object):void {
			if (!item['provider'] && item['file']) {
				if (item['type']) {
					item['provider'] = item['type'];
				} else if (item['file'].indexOf('youtube.com/w') > -1) {
					item['provider'] = "youtube";
				} else if (item['streamer'] && item['streamer'].indexOf('rtmp') == 0) {
					item['provider'] = "rtmp";
				} else {
					var ext:String = Strings.extension(item['file']);
					if (extensions.hasOwnProperty(ext)) {
						item['provider'] = extensions[ext];
					}
				}
			}
		}

	}

}