module three.init;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.anttweakbar.anttweakbar;
import derelict.freeimage.freeimage;	
import derelict.freetype.ft;
import derelict.assimp3.assimp;

import three.glfw.window;

import std.stdio;
import std.conv;


private static FT_Library _s_freeTypeLibrary;

Window initThree() {
	"Starting Three.d".writeln();

	"Loading OpenGL".writeln();
	DerelictGL3.load();

	"Loading GLFW".writeln();
	DerelictGLFW3.load();

	"Loading FreeImage".writeln();
	DerelictFI.load();	  

//	"Loading FreeType".writeln();
//	DerelictFT.load();

	"Loading Assimp".writeln();
	DerelictASSIMP3.load();

	"Loading AntTweakBar".writeln();
	DerelictAntTweakBar.load();

	"Initialising GLFW".writeln();
	if(!glfwInit()) throw new Exception("Initialising GLFW failed");

	"Creating Window".writeln();
	auto window = new Window("Fray", 1600, 900);
	
	"ReLoading OpenGL".writeln();
	try {
		GLVersion glVersion = DerelictGL3.reload();
		writeln("Loaded OpenGL Version", to!string(glVersion));
	} catch(Exception e) {
		writeln("exception: "~ e.msg);
	}

//	"Initialising FreeType".writeln();
//	if(!FT_Init_FreeType(&_s_freeTypeLibrary)) throw new Exception("Initialising FreeType failed");

	"Initialising AntTweakBar".writeln();
	if(TwInit(TW_OPENGL_CORE, null) == 0) throw new Exception("Initialising AntTweakBar failed");

	return window;
}

void deinitThree() { 

	"Terminating AntTweakBar".writeln();
	TwTerminate();

//	"Terminating FreeType".writeln();
//	FT_Done_FreeType(_s_freeTypeLibrary);

	"Terminating GLFW".writeln();
	glfwTerminate();	
}