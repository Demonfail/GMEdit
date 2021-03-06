package ui;
import electron.Dialog;
import electron.Electron;
import gml.file.GmlFile;
import gml.Project;
import js.html.BeforeUnloadEvent;
import js.html.CustomEvent;
import js.html.Element;
import js.html.Event;
import Main.window;
import Main.document;
using tools.NativeString;

/**
 * ...
 * @author YellowAfterlife
 */
class ChromeTabs {
	public static var element:Element;
	public static var impl:ChromeTabsImpl;
	public static var pathHistory:Array<String> = [];
	public static var attrContext:String = "data-context";
	public static inline var pathHistorySize:Int = 32;
	public static inline function addTab(title:String) {
		impl.addTab({ title: title });
	}
	public static function init() {
		element = Main.document.querySelector("#tabs");
		impl = new ChromeTabsImpl();
		impl.init(element, {
			tabOverlapDistance: 14, minWidth: 45, maxWidth: 160
		});
		//
		ChromeTabMenu.init();
		//
		element.addEventListener("activeTabChange", function(e:CustomEvent) {
			var tabEl:ChromeTab = e.detail.tabEl;
			var gmlFile = tabEl.gmlFile;
			if (gmlFile == null) {
				gmlFile = GmlFile.next;
				if (gmlFile == null) return;
				GmlFile.next = null;
				gmlFile.tabEl = cast tabEl;
				tabEl.gmlFile = gmlFile;
				tabEl.title = gmlFile.path != null ? gmlFile.path : gmlFile.name;
				tabEl.setAttribute(attrContext, gmlFile.context);
				tabEl.addEventListener("contextmenu", function(e) {
					ChromeTabMenu.show(tabEl, e);
				});
			}
			var prev = GmlFile.current;
			if (prev != null) {
				pathHistory.unshift(prev.context);
				if (pathHistory.length > pathHistorySize) pathHistory.pop();
			}
			GmlFile.current = gmlFile;
			var ctr = Main.aceEditor.container;
			ctr.setAttribute("file-name", gmlFile.name);
			ctr.setAttribute("file-path", gmlFile.path);
			ctr.setAttribute("file-kind", gmlFile.kind.getName());
			gmlFile.focus();
			Main.aceEditor.setSession(gmlFile.session);
		});
		element.addEventListener("tabClose", function(e:CustomEvent) {
			var tabEl:ChromeTab = e.detail.tabEl;
			var gmlFile = tabEl.gmlFile;
			if (gmlFile == null) return;
			if (gmlFile.changed) {
				#if (!lwedit)
				if (gmlFile.path != null) {
					var bt = Dialog.showMessageBox({
						buttons: ["Yes", "No", "Cancel"],
						message: "Do you want to save the current changes?",
						title: "Unsaved changes in " + gmlFile.name,
						cancelId: 2,
					});
					switch (bt) {
						case 0: gmlFile.save();
						case 1: { };
						default: e.preventDefault();
					}
				} else {
					var bt = Dialog.showMessageBox({
						buttons: ["Yes", "No"],
						message: "Changes cannot be saved (not a file). Stay here?",
						title: "Unsaved changes in " + gmlFile.name,
						cancelId: 0,
					});
					switch (bt) {
						case 1: { };
						default: e.preventDefault();
					}
				}
				#else
				if (gmlFile.session.getValue().length > 0) {
					if (window.confirm(
				}
				#end
			}
		});
		element.addEventListener("tabRemove", function(e:CustomEvent) {
			//
			var closedTab:ChromeTab = e.detail.tabEl;
			var closedFile = closedTab.gmlFile;
			if (closedFile != null) closedFile.close();
			//
			if (impl.tabEls.length == 0) {
				GmlFile.current = null;
				Main.aceEditor.session = WelcomePage.session;
			} else {
				var tab:Element = null;
				while (tab == null && pathHistory.length > 0) {
					tab = document.querySelector('.chrome-tab[' + attrContext + '="'
						+ pathHistory.shift().escapeProp() + '"]'
					);
				}
				if (tab == null) tab = e.detail.prevTab;
				if (tab == null) tab = e.detail.nextTab;
				if (tab == null) {
					Main.aceEditor.session = WelcomePage.session;
				} else impl.setCurrentTab(tab);
			}
			if (Main.aceEditor.session == WelcomePage.session) {
				var ctr = Main.aceEditor.container;
				ctr.removeAttribute("file-name");
				ctr.removeAttribute("file-path");
				ctr.removeAttribute("file-kind");
			}
		});
		// https://github.com/electron/electron/issues/7977:
		if (Electron != null)
		window.addEventListener("beforeunload", function(e:BeforeUnloadEvent) {
			var changedTabs = document.querySelectorAll('.chrome-tab.chrome-tab-changed');
			if (changedTabs.length == 0) {
				for (tabNode in element.querySelectorAll('.chrome-tab')) {
					var tabEl:ChromeTab = cast tabNode;
					var file = tabEl.gmlFile;
					if (file != null) file.close();
				}
				if (Project.current != null) Project.current.close();
				return;
			}
			//
			e.returnValue = cast false;
			window.setTimeout(function() {
				for (tabNode in changedTabs) {
					var tabEl:Element = cast tabNode;
					tabEl.querySelector(".chrome-tab-close").click();
				}
				if (document.querySelectorAll('.chrome-tab.chrome-tab-changed').length == 0) {
					Electron.remote.getCurrentWindow().close();
				}
			});
		});
		//
		window.addEventListener("focus", function(_) {
			if (GmlFile.current != null) GmlFile.current.checkChanges();
		});
		//
		return impl;
	}
}
@:native("ChromeTabs") extern class ChromeTabsImpl {
	public function new():Void;
	public function init(el:Element, opt:Dynamic):Void;
	public function addTab(tab:Dynamic):Dynamic;
	public function setCurrentTab(tab:Element):Void;
	public var tabEls(default, never):Array<ChromeTab>;
}
extern class ChromeTab extends Element {
	public var gmlFile:GmlFile;
}
