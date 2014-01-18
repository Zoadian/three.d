// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module aurora.gl.vbo;

import derelict.opengl3.gl3;
import aurora.gl.util;


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
final class VertexBufferObject {
private:
	uint _id;

public:		   
	///
	this() {
		check!glGenBuffers(1, &this._id);
	}

	///
	~this() {
		check!glDeleteBuffers(1, &this._id);
	}
	
public:		 
	///
	void bind(VertexBufferObjectTarget target) { 
		check!glBindBuffer(target, this._id);
	}

	///
	static unbind(VertexBufferObjectTarget target = VertexBufferObjectTarget.Array) { 
		check!glBindBuffer(target, 0);
	}  
	
public:			
	///
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
}
