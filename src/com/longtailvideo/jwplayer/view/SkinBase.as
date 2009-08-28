package com.longtailvideo.jwplayer.view
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Send when the skin is ready
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "flash.events.Event")]

	/**
	 * Send when an error occurred loading the skin
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]


	public class SkinBase extends EventDispatcher implements ISkin
	{
		protected var _skin:Sprite;

		public function load(url:String=null):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function hasComponent(component:String):Boolean
		{
			return _skin.getChildByName(component) is DisplayObjectContainer;
		}
		
		public function getSkinElement(component:String, element:String):DisplayObject
		{
			var comp:DisplayObjectContainer = _skin.getChildByName(component) as DisplayObjectContainer;
			return comp.getChildByName(element);
		}
		
		public function addSkinElement(component:String, element:DisplayObject, name:String=null):void
		{
			if (name) element.name = name;
						
			var comp:DisplayObjectContainer =  _skin.getChildByName(component) as DisplayObjectContainer;
						
			if (!comp) {
				comp = new Sprite();
				comp.name = component;
				_skin.addChild(comp);
			}
						
			if(comp.getChildByName(element.name)) {
				delete comp[element.name];
				comp.removeChild(comp.getChildByName(element.name));
			}
			comp.addChild(element);
			comp[element.name] = element;
		}
		
		public function getSkinProperties():SkinProperties
		{
			return new SkinProperties();
		}
		
		protected function sendError(message:String):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}


		
	}
}