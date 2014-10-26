module three.common;

public import derelict.opengl3.gl3;
public import derelict.glfw3.glfw3;
public import derelict.anttweakbar.anttweakbar;
public import derelict.freeimage.freeimage;	
public import derelict.freetype.ft;
public import derelict.assimp3.assimp;

alias SoA(T) = T[];



import std.traits : ReturnType;

ReturnType!func glCheck(alias func, string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string funcd = __FUNCTION__, string pretty = __PRETTY_FUNCTION__, Args...)(Args args) nothrow {
	import std.stdio;
	import std.stdio : stderr;
	import std.array : join;
	import std.range : repeat;
	import std.string : format;
	try{
		debug scope(exit) {
			GLenum err = glGetError();
			if(err != GL_NO_ERROR) {
				stderr.writeln("\n===============================");
				stderr.writeln("File: ", file, "\nLine: ", line, "\nModule: ",mod, "\nFunction: ",funcd, "\n",pretty);
				stderr.writeln("-------------------------------");
				stderr.writefln(`OpenGL function "%s(%s)" failed: "%s."`, func.stringof, format("%s".repeat(Args.length).join(", "), args), glErrorString(err));
				stderr.writeln("=============================== \n");
				assert(false);
			}
		}
	}
	catch(Exception e){
	}
	
	debug if(func is null) {
		try{
			stderr.writefln("%s is null! OpenGL loaded? Required OpenGL version not supported?".format(func.stringof));
		}
		catch(Exception e){
			assert(false);
		}
		assert(false);
	}	
	return func(args);
}

string glErrorString(GLenum error) pure @safe nothrow @nogc {
	final switch(error) {
		case GL_NO_ERROR: return "no error";
		case GL_INVALID_ENUM: return "invalid enum";
		case GL_INVALID_VALUE: return "invalid value";
		case GL_INVALID_OPERATION: return "invalid operation";
			//case GL_STACK_OVERFLOW: return "stack overflow";
			//case GL_STACK_UNDERFLOW: return "stack underflow";
		case GL_INVALID_FRAMEBUFFER_OPERATION: return "invalid framebuffer operation";
		case GL_OUT_OF_MEMORY: return "out of memory";
	}
	assert(false, "invalid enum");
}