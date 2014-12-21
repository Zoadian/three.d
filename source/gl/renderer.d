module three.gl.renderer;

import three.scene;
import three.camera;
import three.viewport;
import three.mesh;

import std.string : toStringz;
import std.exception : collectException;

import std.experimental.logger;

import three.gl.buffer;
import three.gl.draw;
import three.gl.sync;
import three.gl.util;
public import three.gl.renderTarget;

enum maxVertices = 1 * 1024 * 1024;
enum maxIndices = 1 * 1024 * 1024;
enum maxPerInstanceParams = 1 * 1024 * 1024;
enum maxIndirectCommands = 1 * 1024 * 1024;
enum bufferCount = 3; //tripple buffering




//======================================================================================================================
// 
//======================================================================================================================
struct GBuffer {
	uint width;
	uint height;
	GLuint texturePosition;
	GLuint textureNormal;
	GLuint textureColor;
	GLuint textureDepthStencil;
	GLuint fbo;
	
	void construct(uint width, uint height) nothrow {
		this.width = width;
		this.height = height;
		glCheck!glGenTextures(1, &this.texturePosition);
		glCheck!glBindTexture(GL_TEXTURE_2D, this.texturePosition);
		glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//		glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
//		glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
//		glCheck!glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE, GL_INTENSITY);
		glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_R32F, width, height);
		glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RED, GL_FLOAT, null);	
		glCheck!glBindTexture(GL_TEXTURE_2D, 0);
		
		glCheck!glGenTextures(1, &this.textureNormal);	
		glCheck!glBindTexture(GL_TEXTURE_2D, this.textureNormal);
		glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);	
//		glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
//		glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
		glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGB10_A2, width, height);
		glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);
		glCheck!glBindTexture(GL_TEXTURE_2D, 0);
		
		glCheck!glGenTextures(1, &this.textureColor);	
		glCheck!glBindTexture(GL_TEXTURE_2D, this.textureColor);
		glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA8, width, height);
		glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
		glCheck!glBindTexture(GL_TEXTURE_2D, 0);
		
		glCheck!glGenTextures(1, &this.textureDepthStencil);	
		glCheck!glBindTexture(GL_TEXTURE_2D, this.textureDepthStencil);
		glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH24_STENCIL8, width, height);
		glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, null);
		glCheck!glBindTexture(GL_TEXTURE_2D, 0);	
		
		glCheck!glGenFramebuffers(1, &this.fbo);
		glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, this.fbo);
		glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 0, GL_TEXTURE_2D, this.texturePosition, 0);
		glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 1, GL_TEXTURE_2D, this.textureNormal, 0);
		glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 2, GL_TEXTURE_2D, this.textureColor, 0);
		glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, this.textureDepthStencil, 0);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	}
	
	void destruct() nothrow {
		glCheck!glDeleteFramebuffers(1, &this.fbo);
		glCheck!glDeleteTextures(1, &this.textureColor);
		glCheck!glDeleteTextures(1, &this.textureNormal);
		glCheck!glDeleteTextures(1, &this.texturePosition);
	}
}




//======================================================================================================================
// 
//======================================================================================================================

struct ShaderPipeline {
	GLuint pipeline;
	GLuint vertexShaderGeometryPass;
	GLuint fragmentShaderGeometryPass;
	
	void construct(string vertexShaderSource, string fragmentShaderSource) nothrow {
		glCheck!glGenProgramPipelines(1, &this.pipeline); 
		
		auto szVertexSource = [vertexShaderSource.toStringz()];
		this.vertexShaderGeometryPass = glCheck!glCreateShaderProgramv(GL_VERTEX_SHADER, 1, szVertexSource.ptr);
		int len;
		glCheck!glGetProgramiv(this.vertexShaderGeometryPass, GL_INFO_LOG_LENGTH , &len);
		if (len > 1) {
			char[] msg = new char[len];
			glCheck!glGetProgramInfoLog(this.vertexShaderGeometryPass, len, null, cast(char*) msg);
			log(cast(string)msg).collectException;
		}
		
		auto szFragmentSource = [fragmentShaderSource.toStringz()];
		this.fragmentShaderGeometryPass = glCheck!glCreateShaderProgramv(GL_FRAGMENT_SHADER, 1, szFragmentSource.ptr);
		//	int len;
		glCheck!glGetProgramiv(this.fragmentShaderGeometryPass, GL_INFO_LOG_LENGTH , &len);
		if (len > 1) {
			char[] msg = new char[len];
			glCheck!glGetProgramInfoLog(this.fragmentShaderGeometryPass, len, null, cast(char*) msg);
			log(cast(string)msg).collectException;
		}
		
		glCheck!glUseProgramStages(this.pipeline, GL_VERTEX_SHADER_BIT, this.vertexShaderGeometryPass);
		glCheck!glUseProgramStages(this.pipeline, GL_FRAGMENT_SHADER_BIT, this.fragmentShaderGeometryPass);
		
		glCheck!glValidateProgramPipeline(this.pipeline);
		GLint status;
		glCheck!glGetProgramPipelineiv(this.pipeline, GL_VALIDATE_STATUS, &status);
		//TODO: add error handling
		assert(status != 0);
	}
	
	void destruct() nothrow {
		glDeleteProgramPipelines(1, &this.pipeline);
	}
}



enum vertexShaderSource = "
	#version 420 core

	layout(location = 0) in vec3 in_position;
	layout(location = 1) in vec3 in_normal;
	layout(location = 2) in vec4 in_color;
	layout(location = 3) in vec2 in_texcoord;

	//==============
	out vec2 _normal;
	out vec2 _texture;
	out vec3 _color;
	//==============

	out gl_PerVertex 
	{
    	vec4 gl_Position;
 	};

	vec2 encode(vec3 n)
	{
	    float f = sqrt(8*n.z+8);
	    return n.xy / f + 0.5;
	}
	
	void main() 
	{        				
		gl_Position = vec4(0.005 * in_position.x, 0.005 * in_position.y, 0.005* in_position.z, 1.0);
		_normal = encode(in_normal);
		_texture = in_texcoord;
		_color = in_color.xyz;
	};
";

enum fragmentShaderSource = "
	#version 420 core

	//==============
	in vec2 _normal;
	in vec2 _texture;
	in vec3 _color;
	//==============

	layout(location = 0) out float depth;
	layout(location = 1) out vec4 normal;
	layout(location = 2) out vec4 color;

	void main()
	{
		depth = gl_FragCoord.z;
		normal.xy = _normal.xy;
		color.xyz = _color;
	}
";


struct RingbufferManager {
	size_t offset;

};


//======================================================================================================================
// 
//======================================================================================================================
struct Renderer {
	GBuffer gbuffer;
	ShaderPipeline shaderPipeline;
	GlArrayBuffer!VertexData vertexBuffer; // vertex data for all meshes
	GlElementArrayBuffer!IndexData indexBuffer; //index data for all meshes
	GlShaderStorageBuffer!GlDrawParameter perInstanceParamBuffer; // is filled with draw parameters for each instance each frame. shall be accessed as a ringbuffer
	GlDrawIndirectBuffer!GlDrawElementsIndirectCommand drawIndirectCommandBuffer; // is filled with DrawElementsIndirectCommand for each mesh each frame. shall be accessed as a ringbuffer
	GlSyncManager vertexSyncManager;
	GlSyncManager indexSyncManager;
	GlSyncManager perInstanceParamSyncManager;
	GlSyncManager drawIndirectCommandSyncManager;
	size_t vertexRingbufferIndex = 0;
	size_t indexRingbufferIndex = 0;
	size_t perInstanceParamRingbufferIndex = 0;
	size_t drawIndirectCommandRingbufferIndex = 0;
	
	void construct(uint width, uint height) {
		GLbitfield createFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;//TODO: ?? | GL_MAP_DYNAMIC_STORAGE_BIT;
		GLbitfield mapFlags = GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT;
		
		this.gbuffer.construct(width, height);
		this.shaderPipeline.construct(vertexShaderSource, fragmentShaderSource);
		this.vertexBuffer.construct(bufferCount * maxVertices, createFlags, mapFlags);
		this.indexBuffer.construct(bufferCount * maxIndices, createFlags, mapFlags);
		this.perInstanceParamBuffer.construct(bufferCount * maxPerInstanceParams, createFlags, mapFlags);
		this.drawIndirectCommandBuffer.construct(bufferCount * maxIndirectCommands, createFlags, mapFlags);
		this.vertexSyncManager.construct();
		this.indexSyncManager.construct();
		this.perInstanceParamSyncManager.construct();
		this.drawIndirectCommandSyncManager.construct();
		
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
		this.drawIndirectCommandSyncManager.destruct();
		this.perInstanceParamSyncManager.destruct();
		this.indexSyncManager.destruct();
		this.vertexSyncManager.destruct();
		this.drawIndirectCommandBuffer.destruct();
		this.perInstanceParamBuffer.destruct();
		this.indexBuffer.destruct();
		this.vertexBuffer.destruct();
		this.shaderPipeline.destruct();
		this.gbuffer.destruct();
	}

	void renderOneFrame(ref Scene scene, ref Camera camera, ref GlRenderTarget renderTarget, ref Viewport viewport)  {
		"-----------begin renderOneFrame---------".log;

		// calc if we have to wrap our buffer
		if(vertexRingbufferIndex + scene.modelData.vertexCount >= this.vertexBuffer.length) {
			vertexRingbufferIndex = 0;
		}
		
		if(indexRingbufferIndex + scene.modelData.indexCount >= this.indexBuffer.length) {
			indexRingbufferIndex = 0;
		}
		
		if(drawIndirectCommandRingbufferIndex + scene.modelData.meshCount >= this.drawIndirectCommandBuffer.length) {
			drawIndirectCommandRingbufferIndex = 0;
		}

		// wait until GPU has finished rendereing from our desired buffer destination
		log("vertexSyncManager.waitForLockedRange ", vertexRingbufferIndex, ", ", scene.modelData.vertexCount); 
		this.vertexSyncManager.waitForLockedRange(vertexRingbufferIndex, scene.modelData.vertexCount);
		log("indexSyncManager.waitForLockedRange ", indexRingbufferIndex, ", ", scene.modelData.indexCount); 
		this.indexSyncManager.waitForLockedRange(indexRingbufferIndex, scene.modelData.indexCount);
		log("drawIndirectCommandSyncManager.waitForLockedRange ", drawIndirectCommandRingbufferIndex, ", ", scene.modelData.meshCount); 
		this.drawIndirectCommandSyncManager.waitForLockedRange(drawIndirectCommandRingbufferIndex, scene.modelData.meshCount);

		// bind buffers
		this.vertexBuffer.bind();
		this.indexBuffer.bind();
		this.perInstanceParamBuffer.bind();
		this.drawIndirectCommandBuffer.bind();

		//bind gbuffer
		glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, gbuffer.fbo); scope(exit) glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0); 
		GLenum[] drawBuffers = [GL_COLOR_ATTACHMENT0 + 0, GL_COLOR_ATTACHMENT0 + 1, GL_COLOR_ATTACHMENT0 + 2];
		glCheck!glDrawBuffers(drawBuffers.length, drawBuffers.ptr); scope(exit) glCheck!glDrawBuffer(GL_NONE);
		
		// enable depth mask _before_ glClear ing the depth buffer!
		glCheck!glDepthMask(GL_TRUE); scope(exit) glCheck!glDepthMask(GL_FALSE);
		glCheck!glEnable(GL_DEPTH_TEST); scope(exit) glCheck!glDisable(GL_DEPTH_TEST);
		glCheck!glDepthFunc(GL_LEQUAL);
		
		// clear scene
		glCheck!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		glCheck!glClearDepth(1.0f);
		glCheck!glClearColor(0, 0.3, 0, 1);
		
		glCheck!glViewport(0, 0, this.gbuffer.width, this.gbuffer.height);

		// backup the indices, we'll need it for our draw command and locking
		auto vertexRingbufferIndexForThisFrame = vertexRingbufferIndex;
		auto indexRingbufferIndexForThisFrame = indexRingbufferIndex;
		auto drawIndirectCommandRingbufferIndexForThisFrame = drawIndirectCommandRingbufferIndex;

		// upload data to our buffers
		foreach(meshData; scene.modelData.meshData) {
			// upload vertex data
			this.vertexBuffer.data[vertexRingbufferIndex .. vertexRingbufferIndex + meshData.vertexData.length] = meshData.vertexData[0 .. meshData.vertexData.length];

			// upload index data
			this.indexBuffer.data[indexRingbufferIndex .. indexRingbufferIndex + meshData.indexData.length] = meshData.indexData[0 .. meshData.indexData.length];

			// draw command data
			this.drawIndirectCommandBuffer.data[drawIndirectCommandRingbufferIndex] = GlDrawElementsIndirectCommand(
				meshData.vertexData.length, 
				1,
				indexRingbufferIndex,
				vertexRingbufferIndex,
				0
				);

			// advance ringbuffers
			vertexRingbufferIndex += meshData.vertexData.length;
			indexRingbufferIndex += meshData.indexData.length;
			++drawIndirectCommandRingbufferIndex;
		}
			
		//bind pipeline
		glCheck!glBindProgramPipeline(shaderPipeline.pipeline); scope(exit) glCheck!glBindProgramPipeline(0);

		//draw
		log("glMultiDrawElementsIndirect ", drawIndirectCommandRingbufferIndexForThisFrame, ", ", scene.modelData.meshCount, ", ", 0); 
		glCheck!glMultiDrawElementsIndirect(GL_TRIANGLES, toGlType!(this.indexBuffer.ValueType), cast(const void*)drawIndirectCommandRingbufferIndexForThisFrame, scene.modelData.meshCount, 0);

		// lock ranges
		log("vertexSyncManager.lockRange ", vertexRingbufferIndexForThisFrame, ", ", scene.modelData.vertexCount); 
		this.vertexSyncManager.lockRange(vertexRingbufferIndexForThisFrame, scene.modelData.vertexCount);
		log("indexSyncManager.lockRange ", indexRingbufferIndexForThisFrame, ", ", scene.modelData.indexCount); 
		this.indexSyncManager.lockRange(indexRingbufferIndexForThisFrame, scene.modelData.indexCount);
		log("drawIndirectCommandSyncManager.lockRange ", drawIndirectCommandRingbufferIndexForThisFrame, ", ", scene.modelData.meshCount); 
		this.drawIndirectCommandSyncManager.lockRange(drawIndirectCommandRingbufferIndexForThisFrame, scene.modelData.meshCount);
		"-----------end renderOneFrame---------\n".log;
	}
	
	debug {
		void blitGBufferToScreen() {
			glCheck!glBindFramebuffer(GL_READ_FRAMEBUFFER, this.gbuffer.fbo); scope(exit) glCheck!glBindFramebuffer(GL_READ_FRAMEBUFFER, 0); 
			
			GLsizei width = this.gbuffer.width;
			GLsizei height = this.gbuffer.height;
			
			scope(exit) glCheck!glReadBuffer(GL_NONE);
			
			glCheck!glReadBuffer(GL_COLOR_ATTACHMENT0 + 0);
			glCheck!glBlitFramebuffer(0, 0, width, height, 0, height-300, 400, height, GL_COLOR_BUFFER_BIT, GL_LINEAR);
			
			glCheck!glReadBuffer(GL_COLOR_ATTACHMENT0 + 1);
			glCheck!glBlitFramebuffer(0, 0, width, height, 0, 0, 400, 300, GL_COLOR_BUFFER_BIT, GL_LINEAR);
			
			glCheck!glReadBuffer(GL_COLOR_ATTACHMENT0 + 2);
			glCheck!glBlitFramebuffer(0, 0, width, height, width-400, height-300, width, height, GL_COLOR_BUFFER_BIT, GL_LINEAR);
		}
	}
}



