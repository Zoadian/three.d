module three.common;

public import derelict.opengl3.gl3;
public import derelict.glfw3.glfw3;
public import derelict.anttweakbar.anttweakbar;
public import derelict.freeimage.freeimage;	
public import derelict.freetype.ft;
public import derelict.assimp3.assimp;

public import std.experimental.logger;

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


//==============================================================================
///
template toGlType(T) {
	static if(is(T == byte)) {
		enum toGlType = GL_BYTE;
	} else static if(is(T == ubyte)) {
		enum toGlType = GL_UNSIGNED_BYTE;
	} else static if(is(T == short)) {
		enum toGlType = GL_SHORT;
	} else static if(is(T == ushort)) {
		enum toGlType = GL_UNSIGNED_SHORT;
	} else static if(is(T == int)) {
		enum toGlType = GL_INT;
	} else static if(is(T == uint)) {
		enum toGlType = GL_UNSIGNED_INT;
	} else static if(is(T == float)) {
		enum toGlType = GL_FLOAT;
	} else static if(is(T == double)) {
		enum toGlType = GL_DOUBLE;
	} else {
		static assert(false, T.stringof ~ " cannot be represented as GLenum");
	}
}


//==============================================================================
///
template sizeofGlType(GLenum t) {
	static if(t == GL_BYTE) {
		enum sizeofGlType = byte.sizeof;
	} else static if(t == GL_UNSIGNED_BYTE) {
		enum sizeofGlType = ubyte.sizeof;
	} else static if(t == GL_SHORT) {
		enum sizeofGlType = short.sizeof;
	} else static if(t == GL_UNSIGNED_SHORT) {
		enum sizeofGlType = ushort.sizeof;
	} else static if(t == GL_INT) {
		enum sizeofGlType = int.sizeof;
	} else static if(t == GL_UNSIGNED_INT) {
		enum sizeofGlType = uint.sizeof;
	} else static if(t == GL_FLOAT) {
		enum sizeofGlType = float.sizeof;
	} else static if(t == GL_DOUBLE) {
		enum sizeofGlType = double.sizeof;
	} else {
		static assert(false, T.stringof ~ " cannot be represented as D-Type");
	}
}
