module three.window;

import three.common;

struct Window {
private:
	GLFWwindow* _glfwWindow = null;
	uint _x, _y, _width, _height;
	KeyAction[int] _keyStates;
	ButtonAction[int] _buttonStates;

public:
	void construct(string title, uint width, uint height) nothrow {
		this._x = 0;
		this._y = 0;
		this._width = width;
		this._height = height;
		
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 4);

		glfwDefaultWindowHints();
		glfwWindowHint(GLFW_RED_BITS, 8);
		glfwWindowHint(GLFW_GREEN_BITS, 8);
		glfwWindowHint(GLFW_BLUE_BITS, 8);
		glfwWindowHint(GLFW_ALPHA_BITS, 0);
		glfwWindowHint(GLFW_DEPTH_BITS, 24);
		glfwWindowHint(GLFW_STENCIL_BITS, 8);
		import std.string : toStringz;
		this._glfwWindow = glfwCreateWindow(width, height, title.toStringz(), null, null);
		assert(this._glfwWindow !is null);
		
		glfwSetWindowUserPointer(this._glfwWindow, cast(void*)&this);
		glfwSetWindowPosCallback(this._glfwWindow, cast(GLFWwindowposfun)&_GLFWwindowposfun);
		glfwSetWindowSizeCallback(this._glfwWindow, cast(GLFWwindowsizefun)&_GLFWwindowsizefun);
		glfwSetWindowCloseCallback(this._glfwWindow, cast(GLFWwindowclosefun)&_GLFWwindowclosefun);
		glfwSetWindowRefreshCallback(this._glfwWindow, cast(GLFWwindowrefreshfun)&_GLFWwindowrefreshfun);
		glfwSetWindowIconifyCallback(this._glfwWindow, cast(GLFWwindowiconifyfun)&_GLFWwindowiconifyfun);
		glfwSetMouseButtonCallback(this._glfwWindow, cast(GLFWmousebuttonfun)&_GLFWmousebuttonfun);
		glfwSetCursorPosCallback(this._glfwWindow, cast(GLFWcursorposfun)&_GLFWcursorposfun);
		//glfwSetCursorEnterCallback(this._glfwWindow, cast(GLFWcursorenterfunfun)&_GLFWcursorenterfunfun);
		glfwSetScrollCallback(this._glfwWindow, cast(GLFWscrollfun)&_GLFWscrollfun);
		glfwSetKeyCallback(this._glfwWindow, cast(GLFWkeyfun)&_GLFWkeyfun);
		glfwSetCharCallback(this._glfwWindow, cast(GLFWcharfun)&_GLFWcharfun);
		
		glfwMakeContextCurrent(this._glfwWindow);
	}
	
	void destruct() {
		//	glfwSetWindowPosCallback(this._glfwWindow, null);
		//	glfwSetWindowSizeCallback(this._glfwWindow, null);
		//	glfwSetWindowCloseCallback(this._glfwWindow, null);
		//	glfwSetWindowRefreshCallback(this._glfwWindow, null);
		//	glfwSetWindowIconifyCallback(this._glfwWindow, null);
		//	glfwSetMouseButtonCallback(this._glfwWindow, null);
		//	glfwSetCursorPosCallback(this._glfwWindow, null);
		//	//glfwSetCursorEnterCallback(this._glfwWindow, null);
		//	glfwSetScrollCallback(this._glfwWindow, null);
		//	glfwSetKeyCallback(this._glfwWindow, null);
		//	glfwSetCharCallback(this._glfwWindow, null);
		
		glfwDestroyWindow(this._glfwWindow);
	}
	
	void makeAktiveRenderWindow() nothrow @nogc {
		glfwMakeContextCurrent(this._glfwWindow);
	}
	
	void swapBuffers() nothrow @nogc {
		glfwSwapBuffers(this._glfwWindow);
	}
	
	void pollEvents() nothrow @nogc {
		glfwPollEvents();
	}
	
	@property void setTitle(string title) nothrow {
		import std.string : toStringz;
		glfwSetWindowTitle(this._glfwWindow, title.toStringz());
	}
	
	KeyAction keyState(int key) pure @safe nothrow {
		try {
			return this._keyStates.get(key, KeyAction.Released);
		}
		catch(Exception) {
			return KeyAction.Released;
		}
	}
	
	ButtonAction buttonState(int button) pure @safe nothrow {
		try {
			return this._buttonStates.get(button, ButtonAction.Released);
		}
		catch(Exception) {
			return ButtonAction.Released;
		}
	}
	
	uint x() {
		return this._x;
	}
	uint y() {
		return this._y;
	}
	uint width() {
		return this._width;
	}
	uint height() {
		return this._height;
	}

public:							
	void delegate(ref Window, int, int) onPosition;	 
	void delegate(ref Window, int, int) onSize;	 
	void delegate(ref Window) onClose;		
	void delegate(ref Window) onRefresh;			
	void delegate(ref Window, FocusAction) onFocus;	  
	void delegate(ref Window, IconifyAction) onIconify;	
	void delegate(ref Window, bool) onCursorEnter;		
	void delegate(ref Window, int, ButtonAction) onButton;	
	void delegate(ref Window, double, double) onCursorPos; 
	void delegate(ref Window, double, double) onScroll;	
	void delegate(ref Window, Key, ScanCode, KeyAction, KeyMod) onKey;   
	void delegate(ref Window, int) onChar;
}

alias ScanCode = int;

enum IconifyAction {
	Iconified,
	Restored
}

enum FocusAction {
	Focused,
	Defocused
}

enum CursorAction {
	Entered,
	Leaved
}

enum ButtonAction {
	Pressed,
	Released
}

enum KeyAction {
	Pressed,
	Released,
	Repeated
}

enum KeyMod {
	Shift = 0x0001,
	Control = 0x0002,
	Alt = 0x0004,
	Super = 0x0008,
}

enum Key {
	Unknown = -1,
	Space = 32,
	Apostrophe = 39,
	Comma = 44,
	Minus = 45,
	Period = 46,
	Slash = 47,
	Key0 = 48,
	Key1 = 49,
	Key2 = 50,
	Key3 = 51,
	Key4 = 52,
	Key5 = 53,
	Key6 = 54,
	Key7 = 55,
	Key8 = 56,
	Key9 = 57,
	Semicolon = 59,
	Equal = 61,
	KeyA = 65,
	KeyB = 66,
	KeyC = 67,
	KeyD = 68,
	KeyE = 69,
	KeyF = 70,
	KeyG = 71,
	KeyH = 72,
	KeyI = 73,
	KeyJ = 74,
	KeyK = 75,
	Keyl = 76,
	KeyM = 77,
	KeyN = 78,
	KeyO = 79,
	KeyP = 80,
	KeyQ = 81,
	KeyR = 82,
	KeyS = 83,
	KeyT = 84,
	KeyU = 85,
	KeyV = 86,
	KeyW = 87,
	KeyX = 88,
	KeyY = 89,
	KeyZ = 90,
	LeftBracket = 91,
	Backslash = 92,
	RightBracket = 93,
	GraveAccent = 96,
	World1 = 161,
	World2 = 162,
	Escape = 256,
	Enter = 257,
	Tab = 258,
	Backspace = 259,
	Insert = 260,
	Delete = 261,
	Right = 262,
	Left = 263,
	Down = 264,
	Up = 265,
	PageUp = 266,
	PageDown = 267,
	Home = 268,
	End = 269,
	CapsLock = 280,
	ScrollLock = 281,
	NumLock = 282,
	PrintScreen = 283,
	Pause = 284,
	F1 = 290,
	F2 = 291,
	F3 = 292,
	F4 = 293,
	F5 = 294,
	F6 = 295,
	F7 = 296,
	F8 = 297,
	F9 = 298,
	F10 = 299,
	F11 = 300,
	F12 = 301,
	F13 = 302,
	F14 = 303,
	F15 = 304,
	F16 = 305,
	F17 = 306,
	F18 = 307,
	F19 = 308,
	F20 = 309,
	F21 = 310,
	F22 = 311,
	F23 = 312,
	F24 = 313,
	F25 = 314,
	NumBlock0 = 320,
	NumBlock1 = 321,
	NumBlock2 = 322,
	NumBlock3 = 323,
	NumBlock4 = 324,
	NumBlock5 = 325,
	NumBlock6 = 326,
	NumBlock7 = 327,
	NumBlock8 = 328,
	NumBlock9 = 329,
	KpDecimal = 330,
	KpDivide = 331,
	KpMultiply = 332,
	KpSubtract = 333,
	KpAdd = 334,
	KpEnter = 335,
	KpEqual = 336,
	LeftShift = 340,
	LeftControl = 341,
	LeftAlt = 342,
	LeftSuper = 343,
	RightShift = 344,
	RightControl = 345,
	RightAlt = 346,
	RightSuper = 347,
	Menu = 348
}




private Window* _castWindow(GLFWwindow* window)
out (result) { assert(result !is null, "glfwGetWindowUserPointer returned null"); }
body {
	void* user_ptr = glfwGetWindowUserPointer(window);
	return cast(Window*)user_ptr;
}


private extern(C) void _GLFWwindowposfun(GLFWwindow* glfwWindow, int x, int y) {							  
	Window* window = _castWindow(glfwWindow);
	auto monitor = glfwGetPrimaryMonitor();
	if(monitor is null) return;
	auto videoMode = glfwGetVideoMode(monitor);
	y = videoMode.height - y;
	int w,h;
	glfwGetWindowSize(glfwWindow, &w, &h);
	window._x = x;
	window._y = y;
	window._width = w;
	window._height = h;
	if(window.onPosition) window.onPosition(*window, x, y);
}

private extern(C) void _GLFWwindowsizefun(GLFWwindow* glfwWindow, int width, int height) {												 
	Window* window = _castWindow(glfwWindow);
	window._width = width;
	window._height = height;
	if(window.onSize) window.onSize(*window, width, height);
}

private extern(C) void _GLFWwindowclosefun(GLFWwindow* glfwWindow) {				  
	Window* window = _castWindow(glfwWindow);
	if(window.onClose) window.onClose(*window);
}

private extern(C) void _GLFWwindowrefreshfun(GLFWwindow* glfwWindow) {													 
	Window* window = _castWindow(glfwWindow);
	if(window.onRefresh) window.onRefresh(*window);
}

private extern(C) void _GLFWwindowfocusfun(GLFWwindow* glfwWindow, int focused) {													 
	Window* window = _castWindow(glfwWindow);
	if(window.onFocus) window.onFocus(*window, (focused == GL_TRUE) ? FocusAction.Focused : FocusAction.Defocused);
}

private extern(C) void _GLFWwindowiconifyfun(GLFWwindow* glfwWindow, int iconified) {												 
	Window* window = _castWindow(glfwWindow);
	if(window.onIconify) window.onIconify(*window, (iconified == GL_TRUE) ? IconifyAction.Iconified : IconifyAction.Restored);
}

private extern(C) void _GLFWcursorenterfun(GLFWwindow* glfwWindow, int entered) {
	Window* window = _castWindow(glfwWindow);
	if(window.onCursorEnter) window.onCursorEnter(*window, (entered == GL_TRUE) ? CursorAction.Entered : CursorAction.Leaved);
}

private extern(C) void _GLFWmousebuttonfun(GLFWwindow* glfwWindow, int button, int action) { 
	Window* window = _castWindow(glfwWindow);
	window._buttonStates[button] = (action == GLFW_PRESS) ? ButtonAction.Pressed : ButtonAction.Released;
	if(window.onButton) window.onButton(*window, button, (action == GLFW_PRESS) ? ButtonAction.Pressed : ButtonAction.Released);
}

private extern(C) void _GLFWcursorposfun(GLFWwindow* glfwWindow, double x, double y) {
	Window* window = _castWindow(glfwWindow);
	if(window.onCursorPos) window.onCursorPos(*window, x, window._height - y);
}

private extern(C) void _GLFWscrollfun(GLFWwindow* glfwWindow, double x, double y) {	
	Window* window = _castWindow(glfwWindow);
	if(window.onScroll) window.onScroll(*window, x, y);
}

private extern(C) void _GLFWkeyfun(GLFWwindow* glfwWindow, int key, int scancode, int action, int mods) {  
	Window* window = _castWindow(glfwWindow);
	window._keyStates[key] = (action == GLFW_PRESS || action == GLFW_REPEAT) ? KeyAction.Pressed : KeyAction.Released;
	if(window.onKey) window.onKey(*window, cast(Key)key, cast(ScanCode)scancode, cast(KeyAction)action, cast(KeyMod)mods);
}

private extern(C) void _GLFWcharfun(GLFWwindow* glfwWindow, uint character) { 
	Window* window = _castWindow(glfwWindow);
	if(window.onChar) window.onChar(*window, character);
}
