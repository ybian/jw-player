package com.longtailvideo.jwplayer.media {
	
	
	/**
	 * Static typed list of all possible Model states
	 *
	 * @see com.longtailvideo.jwplayer.model.Model
	 */
	public class MediaState {
		/** Nothing happening. No playback and no file in memory. **/
		public static var IDLE:String = "IDLE";
		/** Buffering; will start to play when the buffer is full. **/
		public static var BUFFERING:String = "BUFFERING";
		/** The file is being played back. **/
		public static var PLAYING:String = "PLAYING";
		/** Playback is paused. **/
		public static var PAUSED:String = "PAUSED";
		/** End of mediafile has been reached. No playback but the file is in memory. **/
		public static var COMPLETED:String = "COMPLETED";
		/** The file being played back has caused an error. **/
		public static var ERROR:String = "ERROR";
	}
}