package com.longtailvideo.jwplayer.utils {
	import flash.display.DisplayObject;
	import flash.display.Stage;

	/**
	 * Maintains a static reference to the stage and root of the application.
	 *
	 * @author Pablo Schklowsky
	 */
	public class RootReference {

		/** The root DisplayObject of the application.  **/ 
		public static var root:DisplayObject;

		/** A reference to the stage. **/ 
		public static var stage:Stage;

		public function RootReference(displayObj:DisplayObject) {
			RootReference.root = displayObj.root;
			RootReference.stage = displayObj.stage;
		}
	}
}