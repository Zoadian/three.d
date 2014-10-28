module three.renderer;

import three.common;
import three.scene;
import three.camera;
import three.renderTarget;
import three.viewport;

enum forwardRendererVertexShaderSource = "
	#version 420 core

	layout(location = 0) in vec3 in_position;
	layout(location = 1) in vec3 in_normal;
	layout(location = 2) in vec2 in_texcoord;
	layout(location = 3) in vec4 in_color;


	out vec4 v_color;	

	out gl_PerVertex 
	{
    	vec4 gl_Position;
 	};

	void main()
	{
		gl_Position = vec4(0.005 * in_position.x, 0.005 * in_position.y, 0.005* in_position.z, 1.0);
    	v_color = in_color;
	}
";

enum forwardRendererFragmentShaderSource = "
	#version 420 core
	in vec4 v_color;

	out vec4 FragColor;

	void main()
	{
		FragColor = v_color;
	}
";

struct GBuffer {
	uint width;
	uint height;
	GLuint textureDepth;
	GLuint textureNormal;
	GLuint textureColor;
	GLuint textureDepthStencil;
	GLuint fbo;
}

void construct(out GBuffer gBuffer, uint width, uint height) nothrow {
	gBuffer.width = width;
	gBuffer.height = height;
	
	glCheck!glGenTextures(1, &gBuffer.textureDepth);		
	glCheck!glBindTexture(GL_TEXTURE_2D, gBuffer.textureDepth);
	glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	//	glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	//	glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	//	glCheck!glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE, GL_INTENSITY);
	glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH_COMPONENT32F, width, height);
	glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_DEPTH_COMPONENT, GL_FLOAT, null);	
	glCheck!glBindTexture(GL_TEXTURE_2D, 0);
	
	glCheck!glGenTextures(1, &gBuffer.textureNormal);
	glCheck!glBindTexture(GL_TEXTURE_2D, gBuffer.textureNormal);
	glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glCheck!glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);	
	//	glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	//	glCheck!glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGB10_A2, width, height);
	glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
	glCheck!glBindTexture(GL_TEXTURE_2D, 0);
	
	glCheck!glGenTextures(1, &gBuffer.textureColor);
	glCheck!glBindTexture(GL_TEXTURE_2D, gBuffer.textureColor);
	glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA8, width, height);
	glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
	glCheck!glBindTexture(GL_TEXTURE_2D, 0);
	
	glCheck!glGenTextures(1, &gBuffer.textureDepthStencil);
	glCheck!glBindTexture(GL_TEXTURE_2D, gBuffer.textureDepthStencil);
	glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH24_STENCIL8, width, height);
	glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, null);	
	glCheck!glBindTexture(GL_TEXTURE_2D, 0);
	
	glCheck!glGenFramebuffers(1, &gBuffer.fbo);
	glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, gBuffer.fbo);
	
	glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 0, GL_TEXTURE_2D, gBuffer.textureDepth, 0);
	glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 1, GL_TEXTURE_2D, gBuffer.textureNormal, 0);
	glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 2, GL_TEXTURE_2D, gBuffer.textureColor, 0);
	glCheck!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, gBuffer.textureDepthStencil, 0);
	
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
}

void destruct(ref GBuffer gBuffer) nothrow {
	glCheck!glDeleteFramebuffers(1, &gBuffer.fbo);
	glCheck!glDeleteTextures(1, &gBuffer.textureDepthStencil);
	glCheck!glDeleteTextures(1, &gBuffer.textureColor);
	glCheck!glDeleteTextures(1, &gBuffer.textureNormal);
	glCheck!glDeleteTextures(1, &gBuffer.textureDepth);
	gBuffer = GBuffer.init;
}

struct Pipeline {
	GLuint pipeline;
	GLuint vertexShaderGeometryPass;
	GLuint fragmentShaderGeometryPass;
}

void construct(out Pipeline pipeline) nothrow {
	glCheck!glGenProgramPipelines(1, &pipeline.pipeline); 

	import std.string : toStringz;
	auto szVertexSource = [forwardRendererVertexShaderSource.toStringz()];
	pipeline.vertexShaderGeometryPass = glCheck!glCreateShaderProgramv(GL_VERTEX_SHADER, 1, szVertexSource.ptr);

	auto szFragmentSource = [forwardRendererFragmentShaderSource.toStringz()];
	pipeline.fragmentShaderGeometryPass = glCheck!glCreateShaderProgramv(GL_FRAGMENT_SHADER, 1, szFragmentSource.ptr);

	glCheck!glUseProgramStages(pipeline.pipeline, GL_VERTEX_SHADER_BIT, pipeline.vertexShaderGeometryPass);
	glCheck!glUseProgramStages(pipeline.pipeline, GL_FRAGMENT_SHADER_BIT, pipeline.fragmentShaderGeometryPass);

	glCheck!glActiveShaderProgram(pipeline.pipeline, pipeline.vertexShaderGeometryPass);
	glCheck!glActiveShaderProgram(pipeline.pipeline, pipeline.fragmentShaderGeometryPass);

	glCheck!glValidateProgramPipeline(pipeline.pipeline); 
	GLint status;
	glCheck!glGetProgramPipelineiv(pipeline.pipeline, GL_VALIDATE_STATUS, &status);
	//TODO: add error handling
	assert(status != 0);
}

void destruct(ref Pipeline pipeline) nothrow {
	glDeleteProgramPipelines(1, &pipeline.pipeline);
	pipeline = Pipeline.init;
}


struct OpenGlTiledDeferredRenderer {
	GBuffer gBuffer;
	Pipeline pipeline;
}

void construct(out OpenGlTiledDeferredRenderer deferredRenderer, uint width, uint height) nothrow {
	deferredRenderer.gBuffer.construct(width, height);
	deferredRenderer.pipeline.construct();
}

void destruct(ref OpenGlTiledDeferredRenderer deferredRenderer) nothrow {
	deferredRenderer.pipeline.destruct();
	deferredRenderer.gBuffer.destruct();
	deferredRenderer = OpenGlTiledDeferredRenderer.init;
}

// draw the scene supersampled with renderer's with+height onto renderTarget at position+size of viewport
void renderOneFrame(ref OpenGlTiledDeferredRenderer renderer, ref Scene scene, ref Camera camera, ref RenderTarget renderTarget, ref Viewport viewport) {
	// 1. Render the (opaque) geometry into the G-Buffers.	
	// 2. Construct a screen space grid, covering the frame buffer, with some fixed tile
	//    size, t = (x, y), e.g. 32 × 32 pixels.	
	// 3. For each light: find the screen space extents of the light volume and append the
	//    light ID to each affected grid cell.	
	// 4. For each fragment in the frame buffer, with location f = (x, y).
	//    (a) sample the G-Buffers at f.
	//    (b) accumulate light contributions from all lights in tile at ⌊f /t⌋
	//    (c) output total light contributions to frame buffer at f

	with(renderer.gBuffer) glCheck!glViewport(0, 0, width, height);
	
	//enable depth mask _before_ glClear ing the depth buffer!
	glCheck!glDepthMask(GL_TRUE); scope(exit) glCheck!glDepthMask(GL_FALSE);
	glCheck!glEnable(GL_DEPTH_TEST); scope(exit) glCheck!glDisable(GL_DEPTH_TEST);
	glCheck!glDepthFunc(GL_LEQUAL);
	
	//bind gBuffer
//	glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, renderer.gBuffer.fbo); scope(exit) glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0); 
//	glCheck!glDrawBuffer(GL_COLOR_ATTACHMENT0 + 0);
//	glCheck!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
//	GLenum[] drawBuffers = [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2];
//	glCheck!glDrawBuffers(drawBuffers.length, drawBuffers.ptr);
//	glCheck!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	
	//bind pipeline
	glCheck!glBindProgramPipeline(renderer.pipeline.pipeline); scope(exit) glCheck!glBindProgramPipeline(0);
	
	{// Draw Geometry
		scope(exit) glCheck!glBindVertexArray(0);
		scope(exit) glCheck!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); // TODO: GL_ELEMENT_ARRAY_BUFFER should be vao state, but bugs might make this necessary
		
		for(size_t meshIdx = 0; meshIdx < scene.mesh.cnt; ++meshIdx) {
			glCheck!glBindVertexArray(scene.mesh.vao[meshIdx]); 
			
			glCheck!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, scene.mesh.vboIndices[meshIdx]); // TODO: GL_ELEMENT_ARRAY_BUFFER should be vao state, but bugs might make this necessary

			glCheck!glDrawElements(GL_TRIANGLES, scene.mesh.cntIndices[meshIdx], GL_UNSIGNED_INT, null);
		}
	}
}