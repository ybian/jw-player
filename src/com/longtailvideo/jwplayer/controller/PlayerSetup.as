package com.longtailvideo.jwplayer.controller {
	import com.jeroenwijering.events.PluginInterface;
	import com.longtailvideo.jwplayer.events.PlaylistEvent;
	import com.longtailvideo.jwplayer.model.Model;
	import com.longtailvideo.jwplayer.player.Player;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.plugins.V4Plugin;
	import com.longtailvideo.jwplayer.utils.Configger;
	import com.longtailvideo.jwplayer.view.DefaultSkin;
	import com.longtailvideo.jwplayer.view.ISkin;
	import com.longtailvideo.jwplayer.view.View;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * Sent when the all of the setup steps have successfully completed.
	 *
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type = "flash.events.Event")]

	/**
	 * Sent when an error occurred during player setup
	 *
	 * @eventType flash.events.ErrorEvent.ERROR
	 */
	[Event(name="error", type = "flash.events.ErrorEvent")]


	/**
	 * PlayerSetup is a helper class to Controller.  It manages the initial player startup process, firing an 
	 * Event.COMPLETE event when finished, or an ErrorEvent.ERROR if a problem occurred during setup.
	 * 
	 * @see Controller
 	 * @author Pablo Schklowsky
	 */
	public class PlayerSetup extends EventDispatcher {

		/** MVC references **/
		private var _player:Player;
		private var _model:Model;
		private var _view:View;
		
		/** TaskQueue **/
		private var tasker:TaskQueue;
		
		public function PlayerSetup(player:Player, model:Model, view:View) {
			_player = player;
			_model = model;
			_view = view;
		}
		
		public function setupPlayer():void {
			tasker = new TaskQueue();
			tasker.addEventListener(Event.COMPLETE, setupTasksComplete);
			tasker.addEventListener(ErrorEvent.ERROR, setupTasksFailed);
			
			tasker.queueTask(insertDelay);
			tasker.queueTask(loadConfig, loadConfigComplete);
			tasker.queueTask(loadSkin);
			tasker.queueTask(loadPlugins, loadPluginsComplete);
			tasker.queueTask(loadPlaylist);
			tasker.queueTask(loadMediaSources);
			tasker.queueTask(initPlugins);
			tasker.queueTask(setupJS);
			tasker.queueTask(beginAutostart);
			
			tasker.runTasks();
		}
		
		private function setupTasksComplete(evt:Event):void {
			complete();
		}
		
		private function setupTasksFailed(evt:ErrorEvent):void {
			error(evt.text);
		}

		private function complete():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function error(message:String):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		///////////////////////
		// Tasks
		///////////////////////
		
		private function insertDelay():void {
			var timer:Timer = new Timer(50, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, tasker.success);
			timer.start(); 
		}

		private function loadConfig():void {
			var configger:Configger = new Configger();
			configger.addEventListener(Event.COMPLETE, tasker.success);
			configger.addEventListener(ErrorEvent.ERROR, tasker.failure);

			try {
				configger.loadConfig();
			} catch (e:Error) {
				error(e.message);
			}
		}

		private function loadConfigComplete(evt:Event):void {
			var confHash:Object = (evt.target as Configger).config;
			_model.config.setConfig(confHash);
		}

		private function loadSkin():void {
			var skin:ISkin = new DefaultSkin();
			skin.addEventListener(Event.COMPLETE, tasker.success);
			skin.addEventListener(ErrorEvent.ERROR, tasker.failure);
			skin.load();
		}

		private function loadPlugins():void {
			if (_model.config.plugins) {
				var loader:PluginLoader = new PluginLoader();
				loader.addEventListener(Event.COMPLETE, tasker.success);
				loader.addEventListener(ErrorEvent.ERROR, tasker.failure);
				loader.loadPlugins(_model.config.plugins);
			} else {
				tasker.success();
			}
		}
		
		private function loadPluginsComplete(event:Event):void {
			var loader:PluginLoader = event.target as PluginLoader;

			for (var pluginName:String in loader.plugins) {
				var plugin:DisplayObject = loader.plugins[pluginName] as DisplayObject;
				if (plugin is IPlugin) {
					_view.addPlugin(pluginName, plugin as IPlugin);
				} else if (plugin is PluginInterface) {
					_view.addPlugin(pluginName, new V4Plugin(plugin as PluginInterface));
				}
			}
			
		}

		private function loadPlaylist():void {
			if (_model.config.playlist) {
				_model.playlist.addEventListener(PlaylistEvent.JWPLAYER_PLAYLIST_LOADED, tasker.success);
				_model.playlist.addEventListener(ErrorEvent.ERROR, tasker.failure);
				_model.playlist.load(_model.config.playlist);
			} else {
				tasker.success();
			}
		}

		private function loadMediaSources():void {
			tasker.success();
		}
		
		private function initPlugins():void {
			try {
				for each (var pluginName:String in _view.loadedPlugins().split(",")) {
					var plugin:IPlugin = _view.getPlugin(pluginName);
					plugin.initializePlugin(_player, _model.config.pluginConfig(pluginName));
				}
				tasker.success();
			} catch (e:Error) {
				tasker.failure(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}

		private function setupJS():void {
			tasker.success();
		}

		private function beginAutostart():void {
			tasker.success();
		}
		
		
	}
}