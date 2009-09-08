package com.longtailvideo.jwplayer.parsers {

	public class ParserFactory {
		
		public static function getParser(list:XML):IPlaylistParser {
			
			switch(list.localName().toString().toLowerCase()) {
				case 'asx':
					return new ASXParser();
					break;
				case 'feed':
					return new ATOMParser();
					break;
				case 'playlist':
					return new XSPFParser();
					break;
				case 'rss':
					return new RSSParser();
					break;
				case 'smil':
					return new SMILParser();
					break;
			}
			
			return null;
		}
		
	}
}