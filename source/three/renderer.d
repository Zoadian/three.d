module three.renderer;

import three.common;
import three.scene;
import three.camera;
import three.renderTarget;
import three.viewport;
import three.mesh;

import std.string : toStringz;
import std.exception : collectException;

import std.experimental.logger;


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
}

void construct(GlBufferTarget Target, T)(out GlBuffer!(Target, T) buffer, GLuint length, GLbitfield createFlags, GLbitfield mapFlags) {
	glCheck!glGenBuffers(1, &buffer.handle);
	glCheck!glBindBuffer(Target, buffer.handle);
	glCheck!glBufferStorage(Target, length * T.sizeof, null, createFlags);
	buffer.data = cast(T*)glCheck!glMapBufferRange(Target, 0, length * T.sizeof, mapFlags);
	buffer.length = length;
	if (buffer.data is null) {
		throw new Exception("glMapBufferRange failed, probable bug.");
	}
}

void destruct(GlBufferTarget Target, T)(ref GlBuffer!(Target, T) buffer) {
	glCheck!glBindBuffer(Target, buffer.handle);
	glCheck!glUnmapBuffer(Target);
	glCheck!glDeleteBuffers(1, &buffer.handle);
	buffer = buffer.init;
}

void bind(GlBufferTarget Target, T)(ref GlBuffer!(Target, T) buffer) {
	glCheck!glBindBuffer(Target, buffer.handle);
}

void unbind(GlBufferTarget Target, T)(ref GlBuffer!(Target, T) buffer) {
	glCheck!glBindBuffer(Target, 0);
}

alias GlArrayBuffer(T) = GlBuffer!(GlBufferTarget.Array, T);
alias GlElementArrayBuffer(T) = GlBuffer!(GlBufferTarget.ElementArray, T);
alias GlShaderStorageBuffer(T) = GlBuffer!(GlBufferTarget.ShaderStorage, T);
alias GlDispatchIndirectBuffer(T) = GlBuffer!(GlBufferTarget.DispatchIndirect, T);
alias GlTextureBuffer(T) = GlBuffer!(GlBufferTarget.Texture, T);
alias GlUniformBuffer(T) = GlBuffer!(GlBufferTarget.Uniform, T);

struct DrawElementsIndirectCommand {
	GLuint count;
	GLuint instanceCount;
	GLuint firstIndex;
	GLuint baseVertex;
	GLuint baseInstance;
}




struct DrawParameter {
	Matrix4 transformationMatrix;
}




struct Renderer {
	uint width;
	uint height;
	GlArrayBuffer!VertexData vertexBuffer; // vertex data for all meshes
	GlElementArrayBuffer!IndexData indexBuffer; //index data for all meshes
	GlShaderStorageBuffer!DrawParameter perInstanceParamBuffer; // is filled with draw parameters for each instance each frame. shall be accessed as a ringbuffer
	GlDispatchIndirectBuffer!DrawElementsIndirectCommand dispatchIndirectCommandBuffer; // is filled with DrawElementsIndirectCommand for each mesh each frame. shall be accessed as a ringbuffer
}

void construct(out Renderer renderer, uint width, uint height) {
	GLbitfield createFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;//TODO: ?? | GL_MAP_DYNAMIC_STORAGE_BIT;
	GLbitfield mapFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;
	
	renderer.vertexBuffer.construct(1024, createFlags, mapFlags);
	renderer.indexBuffer.construct(1024, createFlags, mapFlags);
	renderer.perInstanceParamBuffer.construct(1024, createFlags, mapFlags);
	renderer.dispatchIndirectCommandBuffer.construct(1024, createFlags, mapFlags);
}

void destruct(ref Renderer renderer) {
	renderer.vertexBuffer.destruct();
	renderer.indexBuffer.destruct();
	renderer.perInstanceParamBuffer.destruct();
	renderer.dispatchIndirectCommandBuffer.destruct();
	renderer = renderer.init;
}

void uploadModelData(ref Renderer renderer, ModelData modelData) {
}

void renderOneFrame(ref Renderer renderer, ref Scene scene, ref Camera camera, ref RenderTarget renderTarget, ref Viewport viewport) {
	
	/*
		foreach(renderTarget) //framebuffer
		foreach(pass)
		foreach(material) //shaders
		foreach(materialInstance) //textures
		foreach(vertexFormat) //vertex buffers
		foreach(object) {
							write uniform data;
							glDrawElementsBaseVertex
						}
		*/	

	GLsizei meshCount = 0;

	glCheck!glViewport(0, 0, renderer.width, renderer.height);
	
	//enable depth mask _before_ glClear ing the depth buffer!
	glCheck!glDepthMask(GL_TRUE); scope(exit) glCheck!glDepthMask(GL_FALSE);
	glCheck!glEnable(GL_DEPTH_TEST); scope(exit) glCheck!glDisable(GL_DEPTH_TEST);
	glCheck!glDepthFunc(GL_LEQUAL);

	// write draw parameters
	
	// write draw commmands
	
	//draw //TODO: pass offset (cast to ptr) into command buffer instead of null


	renderer.vertexBuffer.bind();
	renderer.indexBuffer.bind();
	renderer.perInstanceParamBuffer.bind();
	renderer.dispatchIndirectCommandBuffer.bind();

	glCheck!glMultiDrawElementsIndirect(GL_TRIANGLES, toGlType!(renderer.indexBuffer.ValueType), null, meshCount, 0);


}

debug {
	void blitGBufferToScreen(ref Renderer renderer) {
	}
}