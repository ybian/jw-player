package com.longtailvideo.jwplayer.model {
	
	public class PlaylistItemLevel {

		public var file:String		= "";
		public var bitrate:Number	= 0;
		public var width:Number		= 0;
		public var streamer:String	= "";
		
		/**
		 * @param file - The location of the file to play
		 * @param bitrate - The bitrate of the file
		 * @param width - The width of the file
		 */
		public function PlaylistItemLevel(file:String, bitrate:Number, width:Number, streamer:String="") {
			this.file = file;
			this.streamer = streamer;
			this.bitrate = bitrate;
			this.width = width;
		}
		
	}
}