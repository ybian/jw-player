package com.longtailvideo.jwplayer.view {
	import flash.display.DisplayObject;

	public interface ISkin {
		
		/**
		 * Instructs the skin to load its assets from a URL 
		 * @param url The URL from which to load the assets
		 * @return <code>true</code> when the URL passed is valid 
		 */
		function load(url:String):Boolean;
		
		/**
		 * Returns the availability of skin elements for a given component.
		 * 
		 * <p>e.g. "controlbar"</p>
		 * 
		 * @param component
		 * @return 
		 * 
		 */		
		function hasComponent(component:String):Boolean;

		/**
		 * 
		 * @param component
		 * @param element
		 * @return 
		 * 
		 */
		function getSkinElement(component:String, element:String):DisplayObject;
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		function getSkinProperties():SkinProperties;
	}
}