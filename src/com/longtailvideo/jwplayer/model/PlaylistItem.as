package com.longtailvideo.jwplayer.model {

	/**
	 * Playlist item data.  The class is dynamic; any items parsed from the jwplayer XML namespace are added to the item.
	 *  
	 * @author Pablo Schklowsky
	 */
	public dynamic class PlaylistItem {
		public var author:String		= "";
		public var date:String			= "";
		public var description:String	= "";
		public var duration:Number		= -1;
		public var file:String			= "";
		public var image:String			= "";
		public var link:String			= "";
		public var mediaid:String		= "";
		public var start:Number			= 0;
		public var streamer:String		= "";
		public var tags:String			= "";
		public var title:String			= "";
		public var provider:String		= "";
		
		public function PlaylistItem(obj:Object = null) {
			for (var itm:String in obj) {
				if (this[itm] && typeof(this[itm]) == typeof(0)) {
					this[itm] = Number(obj[itm]);
				} else {
					this[itm] = obj[itm];
				}
			}
		}
		
		// For backwards compatibility
		public function get type():String { return provider; }
		public function set type(t:String):void { provider = t; }
		
	}
}