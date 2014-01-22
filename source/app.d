import std.stdio;

import three;
import std.typecons;

class Tester {
	Unique!(Window) _window;
	bool _keepRunning = true;
	
	this() {
		this._window = initThree();
		this._window.onKey.connect!"_onKey"(this);
		this._window.onClose.connect!"_onClose"(this);
	}
	
	~this() {
		//_window.destroy();
		deinitThree();
	}
	
	void run() {
		while(this._keepRunning) {
			updateWindows();
		}
	}
	
	void stop() {
		this._keepRunning = false;
	}
	
	void _onKey(Window window, Key key, ScanCode scanCode, KeyAction action, KeyMod keyMod) {
		if(window is this._window.opDot() && action == KeyAction.Pressed) {
			if(key == Key.Escape) {
				this.stop();
			}
		}
	}

	void _onClose(Window window) {
		this.stop();
	}
}


void main() {
	Unique!(Tester) tester = new Tester();	
	tester.run();
}