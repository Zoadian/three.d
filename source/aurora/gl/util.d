// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB boost.org/LICENSE_1_0.txt, Boost License 1.0).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module aurora.gl.util;

import std.algorithm;
import std.stdio;
import std.stdio : stderr;
import std.array : join;
import std.range : repeat;
import std.string : format;
import std.traits : ReturnType;
import derelict.opengl3.gl3;


//==============================================================================
///
enum BlendMode {
	Replace,
	Blend,
	Add,
	AddBlended,
	Mult
}


//==============================================================================
///
enum DepthTestMode {
	None,
	Always,
	Equal,
	Less,
	Greater,
	LessEqual,
	GreaterEqual
}		 


//==============================================================================
///
enum CullMode {
	None,
	Back,
	Front
}


//==============================================================================
///
void setCullMode(CullMode cm) {
	final switch(cm) {
		case CullMode.Back:
			check!glEnable(GL_CULL_FACE);
			check!glCullFace(GL_BACK);
			break;
		case CullMode.Front:
			check!glEnable(GL_CULL_FACE);
			check!glCullFace(GL_FRONT);
			break;
		case CullMode.None:
			check!glDisable(GL_CULL_FACE);
			break;
	}
}


//==============================================================================
///
void setBlendMode(BlendMode bm) {
	final switch(bm) {
		case BlendMode.Replace:
			glDisable(GL_BLEND);
			break;
		case BlendMode.Blend:
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BlendMode.Add:
			glEnable(GL_BLEND);
			glBlendFunc(GL_ONE, GL_ONE);
			break;
		case BlendMode.AddBlended:
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE);
			break;
		case BlendMode.Mult:
			glEnable(GL_BLEND);
			glBlendFunc(GL_DST_COLOR, GL_ZERO);
			break;
	}
}			 


//==============================================================================
///
void setDepthTestMode(DepthTestMode dt) {	
	glDepthMask(dt == DepthTestMode.None ? GL_FALSE : GL_TRUE);
	final switch(dt) {
		case DepthTestMode.None:
			glDisable(GL_DEPTH_TEST);
			break;
		case DepthTestMode.Always:
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_ALWAYS);
			break;
		case DepthTestMode.Equal:
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_EQUAL);
			break;
		case DepthTestMode.Less:
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_LESS);
			break;
		case DepthTestMode.Greater:
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_GREATER);
			break;
		case DepthTestMode.LessEqual:
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_LEQUAL);
			break;
		case DepthTestMode.GreaterEqual:
			glEnable(GL_DEPTH_TEST);
			glDepthFunc(GL_GEQUAL);
			break;
	}
}

		  
//==============================================================================
///
int maxDrawBuffers() {
	int maxDrawBuffers;
	glGetIntegerv(GL_MAX_DRAW_BUFFERS, &maxDrawBuffers);
	return maxDrawBuffers;
}


//==============================================================================
///
int maxColorBuffers() {
	int maxColorBuffers;
	glGetIntegerv(GL_MAX_COLOR_ATTACHMENTS, &maxColorBuffers);
	return maxColorBuffers;
}


//==============================================================================
///
int maxTextureImageUnits() {
	int maxTextureImageUnits;
	glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &maxTextureImageUnits);
	return maxTextureImageUnits;
}


//==============================================================================
///
ReturnType!func check(alias func, Args...)(Args args) {
	try{
		debug scope(exit) {
			GLenum err = glGetError();
			if(err != GL_NO_ERROR) {
				stderr.writefln(`OpenGL function "%s(%s)" failed: "%s."`,
				func.stringof, format("%s".repeat(Args.length).join(", "), args), gl_error_string(err));
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


//==============================================================================
///
string gl_error_string(GLenum error) {
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




//~ bool glCheck(string file = __FILE__, int line = __LINE__) @trusted  
//~ {
//~ debug{
	//~ try{
		//~ int error = glGetError();
		//~ if (error == GL_NO_ERROR) return true;
		
		//~ "[[ %s:%s ]]".writef(file, line);
		
		//~ while(error != GL_NO_ERROR) {
			//~ switch (error) {
				//~ case GL_INVALID_ENUM:
					//~ writeln("GL_INVALID_ENUM: an unacceptable value has been specified for an enumerated argument");
					//~ break;
				//~ case GL_INVALID_VALUE:
					//~ writeln("GL_INVALID_VALUE: a numeric argument is out of range");
					//~ break;
				//~ case GL_INVALID_OPERATION:
					//~ writeln("GL_INVALID_OPERATION: the specified operation is not allowed in the current state");
					//~ break;
				//~ case GL_OUT_OF_MEMORY:
					//~ writeln("GL_OUT_OF_MEMORY: there is not enough memory left to execute the command");
					//~ break;
				//~ case GL_INVALID_FRAMEBUFFER_OPERATION:
					//~ writeln("GL_INVALID_FRAMEBUFFER_OPERATION_EXT: the object bound to FRAMEBUFFER_BINDING_EXT is not \"framebuffer complete\"");
					//~ break;
				//~ default:
					//~ writeln("Error not listed. Value: ", error);
					//~ break;
			//~ }
			//~ error = glGetError();
		//~ }
	//~ }catch(Exception e)
	//~ {}
	//~ return false;
	//~ }
	//~ return true;
//~ }


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
