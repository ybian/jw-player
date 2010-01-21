package com.longtailvideo.jwplayer.model {
	
	public class PlaylistItemLevel {

		public var file:String		= "";
		public var bitrate:Number	= 0;
		public var width:Number		= 0;
		
		/**
		 * @param file - The location of the file to play
		 * @param bitrate - The bitrate of the file
		 * @param width - The width of the file
		 */
		public function PlaylistItemLevel(file:String, bitrate:Number, width:Number) {
			this.file = file;
			this.bitrate = bitrate;
			this.width = width;
		}
		
	}
}