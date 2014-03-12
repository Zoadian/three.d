module three.init;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
//import derelict.freetype.ft;
import derelict.anttweakbar.anttweakbar;

import three.glfw.window;

import std.stdio;
import std.conv;
import std.typecons;

Unique!(Window) initThree() {
	DerelictGL3.load();
	DerelictGLFW3.load();
	//DerelictFT.load();
	
	//~ if(!freeTypeInit()) throw new Exception("FreeType init failed");
	if(!glfwInit()) throw new Exception("GLFW init failed");
	
	Unique!(Window) window = new Window("Fray", 1024, 768);
	
	try {
		GLVersion glVersion = DerelictGL3.reload();
		writeln("Loaded OpenGL Version", to!string(glVersion));
	} catch(Exception e) {
		writeln("exception: "~ e.msg);
	}

	DerelictAntTweakBar.load();
	TwInit(TW_OPENGL_CORE, null);

	return window.release();


}

void deinitThree() {
	glfwTerminate();	 
	TwTerminate();
	//freeTypeDeinit();
}