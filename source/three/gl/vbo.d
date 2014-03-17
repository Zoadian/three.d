// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.gl.vbo;

import derelict.opengl3.gl3;
import three.gl.util;


//==============================================================================
///
enum VertexBufferObjectTarget {
	Array = GL_ARRAY_BUFFER, 
	AtomicCounter = GL_ATOMIC_COUNTER_BUFFER, 
	CopyRead= GL_COPY_READ_BUFFER, 
	CopyWrite = GL_COPY_WRITE_BUFFER, 
	DrawIndirect = GL_DRAW_INDIRECT_BUFFER, 
	DispatchIndirect = GL_DISPATCH_INDIRECT_BUFFER,
	ElementArray = GL_ELEMENT_ARRAY_BUFFER, 
	PixelPack = GL_PIXEL_PACK_BUFFER, 
	PixelUnpack = GL_PIXEL_UNPACK_BUFFER, 
	ShaderStorage = GL_SHADER_STORAGE_BUFFER,
	Texture = GL_TEXTURE_BUFFER, 
	TransformFeedback = GL_TRANSFORM_FEEDBACK_BUFFER,
	Uniform = GL_UNIFORM_BUFFER
}


//==============================================================================
///
enum BufferUsageHint {
	StreamDraw = GL_STREAM_DRAW, 
	StreamRead = GL_STREAM_READ, 
	StreamCopy = GL_STREAM_COPY, 
	StaticDraw = GL_STATIC_DRAW, 
	StaticRead = GL_STATIC_READ, 
	StaticCopy = GL_STATIC_COPY, 
	DynamicDraw = GL_DYNAMIC_DRAW, 
	DynamicRead = GL_DYNAMIC_READ, 
	DynamicCopy = GL_DYNAMIC_COPY
}

import std.stdio;
//==============================================================================
///
final class VertexBufferObject(VertexBufferObjectTarget target) {
private:
	uint _id;

public:		   
	///
	this() {
		check!glGenBuffers(1, &this._id);
		writeln("vbo created: ", this._id);
	}

	///
	~this() {
		check!glDeleteBuffers(1, &this._id);
		writeln("vbo destroyed: ", this._id);
	}
	
public:		 
	///
	void bind() { 
		assert(this.isValid);
		check!glBindBuffer(target, this._id);
	}

	///
	static unbind() { 
		check!glBindBuffer(target, 0);
	}  
	
public:			
	///
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
}


private void _isVertexBufferObject(T...)(VertexBufferObject!(T) t) {}
enum isVertexBufferObject(T) = is(typeof(_isVertexBufferObject(T.init)));
