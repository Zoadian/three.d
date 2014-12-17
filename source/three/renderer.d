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


enum maxVertices = 1024;
enum maxIndices = 1024;
enum maxPerInstanceParams = 1024;
enum maxIndirectCommands = 1024;
enum bufferCount = 3; //tripple buffering
enum kOneSecondInNanoSeconds = GLuint64(1000000000);



//======================================================================================================================
// 
//======================================================================================================================
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
	glCheck!glUnmapBuffer(Target);
	glCheck!glBindBuffer(Target, 0);
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



//======================================================================================================================
// 
//======================================================================================================================
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




//======================================================================================================================
// 
//======================================================================================================================
struct Renderer {
	uint width;
	uint height;
	GLsync sync;
	GlArrayBuffer!VertexData vertexBuffer; // vertex data for all meshes
	GlElementArrayBuffer!IndexData indexBuffer; //index data for all meshes
	GlShaderStorageBuffer!DrawParameter perInstanceParamBuffer; // is filled with draw parameters for each instance each frame. shall be accessed as a ringbuffer
	GlDispatchIndirectBuffer!DrawElementsIndirectCommand dispatchIndirectCommandBuffer; // is filled with DrawElementsIndirectCommand for each mesh each frame. shall be accessed as a ringbuffer
}

void construct(out Renderer renderer, uint width, uint height) {
	GLbitfield createFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;//TODO: ?? | GL_MAP_DYNAMIC_STORAGE_BIT;
	GLbitfield mapFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;
	
	renderer.vertexBuffer.construct(bufferCount * maxVertices, createFlags, mapFlags);
	renderer.indexBuffer.construct(bufferCount * maxIndices, createFlags, mapFlags);
	renderer.perInstanceParamBuffer.construct(bufferCount * maxPerInstanceParams, createFlags, mapFlags);
	renderer.dispatchIndirectCommandBuffer.construct(bufferCount * maxIndirectCommands, createFlags, mapFlags);

	glCheck!glEnableVertexAttribArray(0);
	glCheck!glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)0 );
	glCheck!glEnableVertexAttribArray(1);
	glCheck!glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)3 );
	glCheck!glEnableVertexAttribArray(2);
	glCheck!glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)6 );
	glCheck!glEnableVertexAttribArray(3);
	glCheck!glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)10 );
}

void destruct(ref Renderer renderer) {
	renderer.vertexBuffer.destruct();
	renderer.indexBuffer.destruct();
	renderer.perInstanceParamBuffer.destruct();
	renderer.dispatchIndirectCommandBuffer.destruct();
	renderer = renderer.init;
}




struct BufferLockManager(bool UseBusyCpu) {
	struct BufferRange
	{
		size_t startOffset;
		size_t length;

		bool overlaps(BufferRange rhs) const {
			return startOffset < (rhs.startOffset + rhs.length) && rhs.startOffset < (startOffset + length);
		}
	}
	
	struct BufferLock
	{
		BufferRange range;
		GLsync syncObj;
	}

	BufferLock[] bufferLocks;
}

void waitForLockedRange(bool UseBusyCpu)(ref BufferLockManager!UseBusyCpu bufferLockManager, size_t lockBeginOffset, size_t lockLength) { 
	BufferRange testRange = BufferRange(lockBeginOffset, lockLength);
	BufferLock[] swapLocks;

	foreach(ref bl; bufferLockManager.bufferLocks) {
		if (testRange.overlaps(bl.range)) {
			static if(UseBusyCpu) {
				GLbitfield waitFlags = 0;
				GLuint64 waitDuration = 0;
				while(true) {
					GLenum waitRet = glCheck!glClientWaitSync(syncObj, waitFlags, waitDuration);
					if (waitRet == GL_ALREADY_SIGNALED || waitRet == GL_CONDITION_SATISFIED) {
						return;
					}
					
					if (waitRet == GL_WAIT_FAILED) {
						assert(!"Not sure what to do here. Probably raise an exception or something.");
						return;
					}
					
					// After the first time, need to start flushing, and wait for a looong time.
					waitFlags = GL_SYNC_FLUSH_COMMANDS_BIT;
					waitDuration = kOneSecondInNanoSeconds;
				}
			} 
			else {
				glCheck!glWaitSync(syncObj, 0, GL_TIMEOUT_IGNORED);
			}

			glCheck!glDeleteSync(bl.syncObj);
		} 
		else {
			swapLocks ~= bl;
		}
	}

	import std.algorithm : swap;
	swap(bufferLockManager.bufferLocks, swapLocks);
}

void lockRange(bool UseBusyCpu)(ref BufferLockManager!UseBusyCpu bufferLockManager, size_t lockBeginOffset, size_t lockLength) {
	BufferRange newRange = BufferRange(lockBeginOffset, lockLength);
	GLsync syncName = glCheck!glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
	BufferLock newLock = BufferLock(newRange, syncName);	
	bufferLockManager.bufferLocks ~= newLock;
}


//void lockBuffer(ref Renderer renderer) {
//	if(renderer.sync) {
//		glDeleteSync(renderer.sync);	
//	}
//	renderer.sync = glCheck!glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
//}
//
//void waitBuffer(ref Renderer renderer) {
//	if(renderer.sync) {
//		while(true) {
//			GLenum waitReturn = glClientWaitSync(renderer.sync, GL_SYNC_FLUSH_COMMANDS_BIT, 1);
//			if (waitReturn == GL_ALREADY_SIGNALED || waitReturn == GL_CONDITION_SATISFIED) {
//				return;
//			}
//		}
//	}
//}

void uploadModelData(ref Renderer renderer, ModelData modelData) {
	//TODO: wait for buffer range
	//mBufferLockManager.WaitForLockedRange(mStartDestOffset, _vertices.size() * sizeof(Vec2));
	
	renderer.vertexBuffer.bind();
	renderer.indexBuffer.bind();
	// we need to store all models in one giant vbo to use glMultiDrawElementsIndirect. 
	// TODO: implement triple buffering. -> use vertexBuffer and indexBuffer as giant ring buffers
	GLuint vertexBufferOffset = 0;
	GLuint indexBufferOffset = 0;

	foreach(meshData; modelData.meshData) {
		import std.c.string: memcpy;
		//upload vertex data
		assert(renderer.vertexBuffer.length >= meshData.vertexData.length);
		memcpy(renderer.vertexBuffer.data + vertexBufferOffset, meshData.vertexData.ptr, meshData.vertexData.length * VertexData.sizeof);
		vertexBufferOffset += meshData.vertexData.length * VertexData.sizeof;
		//upload index data
		assert(renderer.indexBuffer.length >= meshData.indexData.length);
		memcpy(renderer.indexBuffer.data + indexBufferOffset, meshData.indexData.ptr, meshData.indexData.length * IndexData.sizeof);
		indexBufferOffset += meshData.indexData.length * IndexData.sizeof;
	}
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
	
	// enable depth mask _before_ glClear ing the depth buffer!
	glCheck!glDepthMask(GL_TRUE); scope(exit) glCheck!glDepthMask(GL_FALSE);
	glCheck!glEnable(GL_DEPTH_TEST); scope(exit) glCheck!glDisable(GL_DEPTH_TEST);
	glCheck!glDepthFunc(GL_LEQUAL);

	// write draw parameters
	
	// write draw commmands
	
	// draw //TODO: pass offset (cast to ptr) into command buffer instead of null


	renderer.vertexBuffer.bind();
	renderer.indexBuffer.bind();
	renderer.perInstanceParamBuffer.bind();
	renderer.dispatchIndirectCommandBuffer.bind();

	glCheck!glMultiDrawElementsIndirect(GL_TRIANGLES, toGlType!(renderer.indexBuffer.ValueType), null, meshCount, 0);

	//TODO: lock buffer range
}

debug {
	void blitGBufferToScreen(ref Renderer renderer) {
	}
}