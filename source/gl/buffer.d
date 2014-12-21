module three.gl.buffer;

public import derelict.opengl3.gl3;
import three.gl.util;

enum GlBufferTarget {
	Array = GL_ARRAY_BUFFER, 
	AtomicCounter = GL_ATOMIC_COUNTER_BUFFER, 
	CopyRead= GL_COPY_READ_BUFFER, 
	CopyWrite = GL_COPY_WRITE_BUFFER, 
	DrawIndirect = GL_DRAW_INDIRECT_BUFFER,
	DispatchIndirect = GL_DISPATCH_INDIRECT_BUFFER,
	ElementArray = GL_ELEMENT_ARRAY_BUFFER, 
	PixelPack = GL_PIXEL_PACK_BUFFER, 
	PixelUnpack = GL_PIXEL_UNPACK_BUFFER, 
	QueryBuffer = GL_QUERY_BUFFER,
	ShaderStorage = GL_SHADER_STORAGE_BUFFER,
	Texture = GL_TEXTURE_BUFFER, 
	TransformFeedback = GL_TRANSFORM_FEEDBACK_BUFFER,
	Uniform = GL_UNIFORM_BUFFER
}

struct GlBuffer(GlBufferTarget Target, T) {
	alias BufferTarget = Target;
	alias ValueType = T;
	GLuint handle;
	GLuint length;
	T* data;
	
	void construct(GLuint length, GLbitfield createFlags, GLbitfield mapFlags) {
		glCheck!glGenBuffers(1, &this.handle);
		bind();
		glCheck!glBufferStorage(Target, length * T.sizeof, null, createFlags);
		this.data = cast(T*)glCheck!glMapBufferRange(Target, 0, length * T.sizeof, mapFlags);
		this.length = length;
		if (this.data is null) {
			throw new Exception("glMapBufferRange failed, probable bug.");
		}
	}
	
	void destruct() {
		bind(); // bind!
		glCheck!glUnmapBuffer(Target);
		glCheck!glDeleteBuffers(1, &this.handle);
	}
	
	void bind() {
		glCheck!glBindBuffer(Target, this.handle);
	}
	
//	void unbind() {
//		glCheck!glBindBuffer(Target, 0);
//	}
}

alias GlArrayBuffer(T) = GlBuffer!(GlBufferTarget.Array, T);
alias GlElementArrayBuffer(T) = GlBuffer!(GlBufferTarget.ElementArray, T);
alias GlShaderStorageBuffer(T) = GlBuffer!(GlBufferTarget.ShaderStorage, T);
alias GlDrawIndirectBuffer(T) = GlBuffer!(GlBufferTarget.DrawIndirect, T);
alias GlDispatchIndirectBuffer(T) = GlBuffer!(GlBufferTarget.DispatchIndirect, T);
alias GlTextureBuffer(T) = GlBuffer!(GlBufferTarget.Texture, T);
alias GlUniformBuffer(T) = GlBuffer!(GlBufferTarget.Uniform, T);