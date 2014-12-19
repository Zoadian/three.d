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

import three.gl.buffer;
import three.gl.draw;
import three.gl.sync;
import three.gl.util;

enum maxVertices = 1024;
enum maxIndices = 1024;
enum maxPerInstanceParams = 1024;
enum maxIndirectCommands = 1024;
enum bufferCount = 3; //tripple buffering
enum kOneSecondInNanoSeconds = GLuint64(1000000000);



//======================================================================================================================
// 
//======================================================================================================================
struct Renderer {
	uint width;
	uint height;
	GlArrayBuffer!VertexData vertexBuffer; // vertex data for all meshes
	GlElementArrayBuffer!IndexData indexBuffer; //index data for all meshes
	GlShaderStorageBuffer!GlDrawParameter perInstanceParamBuffer; // is filled with draw parameters for each instance each frame. shall be accessed as a ringbuffer
	GlDispatchIndirectBuffer!GlDrawElementsIndirectCommand dispatchIndirectCommandBuffer; // is filled with DrawElementsIndirectCommand for each mesh each frame. shall be accessed as a ringbuffer
	GlSyncManager syncManager;

	void construct(uint width, uint height) {
		GLbitfield createFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;//TODO: ?? | GL_MAP_DYNAMIC_STORAGE_BIT;
		GLbitfield mapFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;
		
		this.vertexBuffer.construct(bufferCount * maxVertices, createFlags, mapFlags);
		this.indexBuffer.construct(bufferCount * maxIndices, createFlags, mapFlags);
		this.perInstanceParamBuffer.construct(bufferCount * maxPerInstanceParams, createFlags, mapFlags);
		this.dispatchIndirectCommandBuffer.construct(bufferCount * maxIndirectCommands, createFlags, mapFlags);
		this.syncManager.construct();

		glCheck!glEnableVertexAttribArray(0);
		glCheck!glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)0 );
		glCheck!glEnableVertexAttribArray(1);
		glCheck!glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)3 );
		glCheck!glEnableVertexAttribArray(2);
		glCheck!glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)6 );
		glCheck!glEnableVertexAttribArray(3);
		glCheck!glVertexAttribPointer(3, 2, GL_FLOAT, GL_FALSE, VertexData.sizeof, cast(GLvoid*)10 );
	}

	void destruct() {
		this.syncManager.destruct();
		this.dispatchIndirectCommandBuffer.destruct();
		this.perInstanceParamBuffer.destruct();
		this.indexBuffer.destruct();
		this.vertexBuffer.destruct();
	}

//	void uploadModelData(GlArrayBuffer!VertexData vertexBuffer, GlElementArrayBuffer!IndexData indexBuffer, ModelData modelData) {
//		//TODO: wait for buffer range
//		//mBufferLockManager.WaitForLockedRange(mStartDestOffset, _vertices.size() * sizeof(Vec2));
//
//		// TODO: check if buffers are bound. they should always be bound here!
//
//		// we need to store all models in one giant vbo to use glMultiDrawElementsIndirect. 
//		// TODO: implement triple buffering. -> use vertexBuffer and indexBuffer as giant ring buffers
//		GLuint vertexBufferOffset = 0;
//		GLuint indexBufferOffset = 0;
//		
//		foreach(meshData; modelData.meshData) {
//			import std.c.string: memcpy;
//			//upload vertex data
//			assert(this.vertexBuffer.length >= meshData.vertexData.length);
//			memcpy(this.vertexBuffer.data + vertexBufferOffset, meshData.vertexData.ptr, meshData.vertexData.length * VertexData.sizeof);
//			vertexBufferOffset += meshData.vertexData.length * VertexData.sizeof;
//			//upload index data
//			assert(this.indexBuffer.length >= meshData.indexData.length);
//			memcpy(this.indexBuffer.data + indexBufferOffset, meshData.indexData.ptr, meshData.indexData.length * IndexData.sizeof);
//			indexBufferOffset += meshData.indexData.length * IndexData.sizeof;
//		}
//	}

	void renderOneFrame(ref Scene scene, ref Camera camera, ref RenderTarget renderTarget, ref Viewport viewport) {

		// wait until GPU has finished rendereing from our desired buffer destination
		//TODO: this.syncManager.WaitForLockedRange(mStartDestOffset, _vertices.size() * sizeof(Vec2));


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
		
		glCheck!glViewport(0, 0, this.width, this.height);
		
		// enable depth mask _before_ glClear ing the depth buffer!
		glCheck!glDepthMask(GL_TRUE); scope(exit) glCheck!glDepthMask(GL_FALSE);
		glCheck!glEnable(GL_DEPTH_TEST); scope(exit) glCheck!glDisable(GL_DEPTH_TEST);
		glCheck!glDepthFunc(GL_LEQUAL);
		
		// write draw parameters
		
		// write draw commmands
		
		// draw //TODO: pass offset (cast to ptr) into command buffer instead of null

		
		this.vertexBuffer.bind();
		this.indexBuffer.bind();
		this.perInstanceParamBuffer.bind();
		this.dispatchIndirectCommandBuffer.bind();
		
		glCheck!glMultiDrawElementsIndirect(GL_TRIANGLES, toGlType!(this.indexBuffer.ValueType), null, meshCount, 0);

		//TODO: this.syncManager.LockRange(mStartDestOffset, _vertices.size() * sizeof(Vec2));
	}
	
	debug {
		void blitGBufferToScreen() {
		}
	}
}



