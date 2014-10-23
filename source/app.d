import std.stdio;

import three;
import std.typecons;

import derelict.opengl3.gl3;
import three.gl.util;

import derelict.anttweakbar.anttweakbar;
import derelict.glfw3.glfw3;
import derelict.assimp3.assimp;

import std.string;
import std.experimental.logger;

//======================================================================================================================
// GBuffer
//======================================================================================================================
struct GBuffer {
	GLuint hDepth;
	GLuint hNormal;
	GLuint hColor;
	GLuint hFin;
	GLuint hStencil;
};

GBuffer createGBuffer() {
	GBuffer gBuffer;

	check!glGenTextures(1, &gBuffer.hDepth);		
	check!glBindTexture(GL_TEXTURE_2D, gBuffer.hDepth);
	with(_window) check!glTexStorage2D(GL_TEXTURE_2D, 1, GL_R32F, width, height);
	with(_window) check!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RED, GL_FLOAT, null);	
	check!glBindTexture(GL_TEXTURE_2D, 0);
	
	check!glGenTextures(1, &gBuffer.hNormal);
	check!glBindTexture(GL_TEXTURE_2D, gBuffer.hNormal);
	with(_window) check!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGB10_A2, width, height);
	with(_window) check!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
	check!glBindTexture(GL_TEXTURE_2D, 0);
	
	check!glGenTextures(1, &gBuffer.hColor);
	check!glBindTexture(GL_TEXTURE_2D, gBuffer.hColor);
	with(_window) check!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA8, width, height);
	with(_window) check!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
	check!glBindTexture(GL_TEXTURE_2D, 0);
	
	check!glGenTextures(1, &gBuffer.hFin);
	check!glBindTexture(GL_TEXTURE_2D, gBuffer.hFin);
	with(_window) check!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGB32F, width, height);
	with(_window) check!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGB, GL_FLOAT, null);	
	check!glBindTexture(GL_TEXTURE_2D, 0);
	
	check!glGenTextures(1, &gBuffer.hStencil);
	check!glBindTexture(GL_TEXTURE_2D, gBuffer.hStencil);
	with(_window) check!glTexStorage2D(GL_TEXTURE_2D, 1, GL_DEPTH24_STENCIL8, width, height);
	with(_window) check!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8, null);	
	check!glBindTexture(GL_TEXTURE_2D, 0);

	return gBuffer;
}

void destroyGBuffer(ref GBuffer gBuffer) {
	check!glDeleteTextures(1, &gBuffer.hStencil);
	check!glDeleteTextures(1, &gBuffer.hFin);
	check!glDeleteTextures(1, &gBuffer.hColor);
	check!glDeleteTextures(1, &gBuffer.hNormal);
	check!glDeleteTextures(1, &gBuffer.hDepth);
}


//======================================================================================================================
// FrameBuffer
//======================================================================================================================
struct FrameBuffer {
	GLuint hFrameBuffer;
};

FrameBuffer createFrameBuffer() {
	FrameBuffer frameBuffer;

	check!glGenFramebuffers(1, &frameBuffer.hFrameBuffer); 
	check!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, frameBuffer.hFrameBuffer);
	check!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 0, GL_TEXTURE_2D, gBuffer.hDepth, 0);
	check!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 1, GL_TEXTURE_2D, gBuffer.hNormal, 0);
	check!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 2, GL_TEXTURE_2D, gBuffer.hColor, 0);
	check!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + 3, GL_TEXTURE_2D, gBuffer.hFin, 0);
	check!glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_TEXTURE_2D, gBuffer.hStencil, 0);
	check!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);

	return frameBuffer;
}

void destroyFrameBuffer(ref FrameBuffer frameBuffer) {
	check!glDeleteFramebuffers(1, &frameBuffer.hFrameBuffer);
}


//======================================================================================================================
// ShaderPipeline
//======================================================================================================================
struct ShaderPipeline {
	GLuint hShaderPipeline;
};

ShaderPipeline createShaderPipeline() {
	ShaderPipeline shaderPipeline;

	glGenProgramPipelines(1, &shaderPipeline.hShaderPipeline); 

	return shaderPipeline;
}

void destroyShaderPipeline(ref ShaderPipeline shaderPipeline) {
	glDeleteProgramPipelines(1, &shaderPipeline.hShaderPipeline);
}


//======================================================================================================================
// ShaderProgram
//======================================================================================================================
struct ShaderProgram {
	GLuint hShaderProgram;
};

ShaderProgram createShaderProgram(string source) {
	ShaderProgram shaderProgram;

	auto szSource = [source.toStringz()];
	shaderProgram.hShaderProgram = check!glCreateShaderProgramv(GL_VERTEX_SHADER, 1, szSource.ptr);

	debug {
		int len;
		check!glGetProgramiv(this._id, GL_INFO_LOG_LENGTH , &len);
		if (len > 1) {
			char[] msg = new char[len];
			check!glGetProgramInfoLog(this._id, len, null, cast(char*) msg);
			error(cast(string)msg);
		}
	}

	return shaderProgram;
}

void destroyShaderProgram(ref ShaderProgram shaderProgram) {
	check!glDeleteProgram(shaderProgram.hShaderProgram);
}


//======================================================================================================================
// VertexArrayObject
//======================================================================================================================
struct VertexArrayObject {
	GLuint hVertexArrayObject;
}

VertexArrayObject createVertexArrayObject() {
	VertexArrayObject vertexArrayObject;
	check!glGenVertexArrays(1, &vertexArrayObject.hVertexArrayObject);	
	return vertexArrayObject;
}

void destroyVertexArrayObject(ref VertexArrayObject vertexArrayObject) {
	check!glDeleteVertexArrays(1, &vertexArrayObject.hVertexArrayObject);
}


//======================================================================================================================
// VertexBufferObject
//======================================================================================================================
struct VertexBufferObject {
	GLuint hVertexBufferObject;
}

VertexBufferObject createVertexBufferObject() {
	VertexBufferObject vertexBufferObject;
	check!glGenBuffers(1, &vertexBufferObject.hVertexBufferObject);
	return vertexBufferObject;
}

void destroyVertexArrayObject(ref VertexBufferObject vertexBufferObject) {
	check!glDeleteVertexArrays(1, &vertexBufferObject.hVertexBufferObject);
}

	

//======================================================================================================================
// 
//======================================================================================================================		
final class Camera {
}

final class Viewport {
	int x;
	int y;
	int width;
	int height;
}

final class Scene {
	VertexBufferObject[] vertexBufferObjects;
	VertexArrayObject[] vertexArrayObjects;
}


struct RenderGroup {
	Scene scene;
	Camera camera;
	Viewport viewport;
}



class OpenGlRenderer {
private:
	Window _window;

	GBuffer _gBuffer;
	GBuffer _frameBuffer;

	ShaderProgram _geometryPassVertexShader;
	ShaderProgram _geometryPassFragmentShader;

	ShaderProgram _stencilPassVertexShader;
	ShaderProgram _stencilPassFragmentShader;

	ShaderProgram _pointLightPassVertexShader;
	ShaderProgram _pointLightPassFragmentShader;

	ShaderPipeline _shaderPipeline;

	Camera[] _cameras;
	Viewport[] _viewports;
	Scene[] _scenes;

	RenderGroup[] _renderGroups;

public:
	this(Window window) {
		_window = window;

		_gBuffer = createGBuffer();

		_frameBuffer = createFrameBuffer();

		_geometryPassVertexShader = createShaderProgram("TODO: load and pass source code");
		_geometryPassFragmentShader = createShaderProgram("TODO: load and pass source code");

		_stencilPassVertexShader = createShaderProgram("TODO: load and pass source code");
		_stencilPassFragmentShader = createShaderProgram("TODO: load and pass source code");

		_pointLightPassVertexShader = createShaderProgram("TODO: load and pass source code");
		_pointLightPassFragmentShader = createShaderProgram("TODO: load and pass source code");

		_shaderPipeline = createShaderPipeline();
	}

	~this() {
		destroyShaderPipeline(_shaderPipeline);

		destroyShaderProgram(_pointLightPassFragmentShader);
		destroyShaderProgram(_pointLightPassVertexShader);

		destroyShaderProgram(_stencilPassFragmentShader);
		destroyShaderProgram(_stencilPassVertexShader);

		destroyShaderProgram(_geometryPassFragmentShader);
		destroyShaderProgram(_geometryPassVertexShader);

		destroyFrameBuffer(_frameBuffer);

		destroyGBuffer(_gBuffer);
	}

	void run() {
		//--------------------------------------------------------------------------------------------------------------
		// Render Loop
		//--------------------------------------------------------------------------------------------------------------
		while(_keepRunning) {
			_window.makeAktiveRenderWindow();

			glClearColor(0, 0, 0, 1);
			glClearDepth(1.0);

			for(renderGroup; _renderGroups) {
				with(renderGroup.viewport) glViewport(x, y, width, height);

				geometryPass();
				lightningPass();
				finalPass();
			}
		}
	}

	void stop() {
		this._keepRunning = false;
	}

private:
	//------------------------------------------------------------------------------------------------------------------
	// Geometry Pass		
	//------------------------------------------------------------------------------------------------------------------
	void geometryPass() {
		//enable depth mask _before_ glClear ing the depth buffer!
		check!glDepthMask(GL_TRUE);
		check!glEnable(GL_DEPTH_TEST);		
		check!glDepthFunc(GL_LEQUAL);	
		
		check!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _frameBuffer.hframeBuffer); 
		check!glDrawBuffer(GL_COLOR_ATTACHMENT3);
		GLenum[] drawBuffers = [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2];
		check!glDrawBuffers(drawBuffers.length, drawBuffers.ptr);
		check!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		
		glBindProgramPipeline(shaderPipeline.hShaderPipeline);
		
		foreach(vao; _scenes) {
			mesh._vertexData.bind();

			glUseProgramStages(_shaderPipeline.hShaderPipeline, GL_VERTEX_SHADER_BIT, _geometryPassVertexShader);
			glUseProgramStages(_shaderPipeline.hShaderPipeline, GL_FRAGMENT_SHADER_BIT, _geometryPassFragmentShader);
			
			setCullMode(CullMode.Back);
			mesh._vertexShader.sendUniform("u_vpMatrix", camera.viewProjectionMatrix);	
			mesh._fragmentShader.sendTexture("u_textureImage", this._texture, 0);
			
			foreach(model; this._models) {
				mesh._vertexShader.sendUniform("u_modelMatrix", model.modelMatrix);	
				check!glDrawArrays(GL_TRIANGLES, 0, 36);
			}
			
			mesh._vertexData.unbind();
		}
		
		glBindProgramPipeline(0);
		
		check!glDepthMask(GL_FALSE);
	}

	//------------------------------------------------------------------------------------------------------------------
	// Lightning Pass		
	//------------------------------------------------------------------------------------------------------------------
	void lightningPass() {
		this.framebuffer.bind(FrameBuffer.Target.Write);  
		check!glDrawBuffer(GL_COLOR_ATTACHMENT3);
		
		check!glEnable(GL_STENCIL_TEST);
		foreach(pointLight; scene.pointLights)
		{
			//------------------------------------------------------------------------------------------------------
			// Stencil Pass
			//------------------------------------------------------------------------------------------------------
			glBindProgramPipeline(shaderPipeline.hShaderPipeline);
			
			this.framebuffer.bind(FrameBuffer.Target.Write); 
			check!glDrawBuffer(GL_NONE);
			check!glClear(GL_STENCIL_BUFFER_BIT);//TODO: reqired?
			
			this._vao.bind();
			check!glEnable(GL_DEPTH_TEST);
			check!glDisable(GL_CULL_FACE);
			check!glStencilFunc(GL_ALWAYS, 0, 0);
			check!glStencilOpSeparate(GL_BACK, GL_KEEP, GL_INCR, GL_KEEP);
			check!glStencilOpSeparate(GL_FRONT, GL_KEEP, GL_DECR, GL_KEEP);		
			
			glUseProgramStages(shaderPipeline.hShaderPipeline, GL_VERTEX_SHADER_BIT, stencilPassVertexShader);
			glUseProgramStages(shaderPipeline.hShaderPipeline, GL_FRAGMENT_SHADER_BIT, stencilPassFragmentShader);
			
			this.vertexShader.sendUniform("u_mvpMatrix", camera.viewProjectionMatrix * pointLight.modelMatrix);
			
			check!glDrawArrays(GL_TRIANGLES, 0, 36);
			
			this._vao.unbind();
			
			glBindProgramPipeline(0);
			
			//------------------------------------------------------------------------------------------------------
			// PointLight Pass
			//------------------------------------------------------------------------------------------------------
			glBindProgramPipeline(shaderPipeline.hShaderPipeline);
			//~				camera.gbuffer.bind(GBuffer.Pass.Lighting);
			this.framebuffer.bind(FrameBuffer.Target.Write);  
			check!glDrawBuffer(GL_COLOR_ATTACHMENT3);
			
			this._vao.bind();
			
			check!glDisable(GL_DEPTH_TEST);
			
			check!glEnable(GL_BLEND);
			check!glBlendFunc(GL_ONE, GL_ONE);
			check!glBlendEquation(GL_FUNC_ADD);
			
			check!glStencilFunc(GL_NOTEQUAL, 0, 0xFF);
			
			check!glEnable(GL_CULL_FACE);
			check!glCullFace(GL_FRONT);
			
			
			glUseProgramStages(shaderPipeline.hShaderPipeline, GL_VERTEX_SHADER_BIT, pointLightPassVertexShader);
			glUseProgramStages(shaderPipeline.hShaderPipeline, GL_FRAGMENT_SHADER_BIT, pointLightPassFragmentShader);
			
			this.vertexShader.sendUniform("u_mvpMatrix", camera.viewProjectionMatrix * pointLight.modelMatrix);
			
			this.fragmentShader.sendUniform("u_viewport", Vec4f(camera.viewport.x, camera.viewport.y, camera.viewport.width, camera.viewport.height));
			this.fragmentShader.sendUniform("u_viewProjMatrix", camera.viewProjectionMatrix);
			this.fragmentShader.sendUniform("u_projMatrix", camera.projectionMatrix);
			this.fragmentShader.sendUniform("u_viewMatrix", camera.viewMatrix);
			this.fragmentShader.sendTexture("u_gbuffer.depth", camera.gbuffer.depth, 0);
			this.fragmentShader.sendTexture("u_gbuffer.normal", camera.gbuffer.normal, 1);
			this.fragmentShader.sendTexture("u_gbuffer.color", camera.gbuffer.color, 2);
			this.fragmentShader.sendTexture("u_gbuffer.depthstencil", camera.gbuffer.depthstencil, 4);
			
			
			this.fragmentShader.sendUniform("u_light.color", pointLight.color);
			this.fragmentShader.sendUniform("u_light.ambientIntensity", pointLight.ambientIntensity);
			this.fragmentShader.sendUniform("u_light.diffuseIntensity", pointLight.diffuseIntensity);
			this.fragmentShader.sendUniform("u_light.constant", pointLight.constant);
			this.fragmentShader.sendUniform("u_light.linear", pointLight.linear);
			this.fragmentShader.sendUniform("u_light.exp", pointLight.exp);
			this.fragmentShader.sendUniform("u_light.position", pointLight.position);
			
			check!glDrawArrays(GL_TRIANGLES, 0, 36);
			
			this._vao.unbind();
			
			check!glDisable(GL_BLEND);
			
			glBindProgramPipeline(0);
		}
		check!glDisable(GL_STENCIL_TEST);
	}
	
	//------------------------------------------------------------------------------------------------------------------
	// Final Pass		
	//------------------------------------------------------------------------------------------------------------------
	void finalPass() {
		check!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
		check!glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
		check!glReadBuffer(GL_COLOR_ATTACHMENT3);
		with(camera.viewport) {
			check!glBlitFramebuffer(0, 0, width, height, 0, 0, width, height, GL_COLOR_BUFFER_BIT, GL_LINEAR);	
		}
		
		_window.swapBuffers();
	}
}












struct Vertex {
	float x, y, z;
}

struct Normal {
	float x, y, z;
}

struct UV {
	float u, v;
}







final class Mesh {
public:
	Vertex[] vertexData;
	Normal[] normalData;
	UV[] textureData;
	RGBAf[] colorData;

	VertexArrayObject vao;
	VertexBufferObject!(VertexBufferObjectTarget.Array) vboVertexData;
	VertexBufferObject!(VertexBufferObjectTarget.Array) vboNormalData;
	VertexBufferObject!(VertexBufferObjectTarget.Array) vboTextureData;
	VertexBufferObject!(VertexBufferObjectTarget.Array) vboColorData;

	this(string filePath) {
		writeln("loading scene: ", filePath);
		auto scene = aiImportFile(filePath.toStringz(),	aiProcess_Triangulate);
		writeln("meshes: ", scene.mNumMeshes);
		for(uint m = 0; m < scene.mNumMeshes; ++m) {  
			const(aiMesh*) mesh = scene.mMeshes[m];
			assert(mesh !is null);
			writeln("mesh[", m, "] faces : ", mesh.mNumFaces);
			for (uint f = 0; f < mesh.mNumFaces; ++f) {	 
				const(aiFace*) face = &mesh.mFaces[f];
				assert(face !is null);
				
				for(uint v = 0; v < 3; ++v) {
					aiVector3D p, n, uv; 
					assert(face.mNumIndices > v);
					uint vertex = face.mIndices[v];
					assert(mesh.mNumVertices > vertex);
					p = mesh.mVertices[vertex];
					n = mesh.mNormals[vertex];
					
					// check if the mesh has texture coordinates
					if(mesh.mTextureCoords[0] !is null) {
						uv = mesh.mTextureCoords[0][vertex];
					}
					
					vertexData ~= Vertex(p.x, p.y, p.z);
					normalData ~= Normal(n.x, n.y, n.z);
					textureData ~= UV(uv.x, uv.y);
					colorData ~= RGBAf(n.x, n.y, n.z, 1.0f);
				}
			}
		}
		writeln("unloading scene: ", filePath);
		aiReleaseImport(scene);

		//-----------------------------
		// upload
		writeln("uploading mesh: ", filePath);
		vao = new VertexArrayObject();
		vao.bind();

		writeln("vertex data");
		vboVertexData = new VertexBufferObject!(VertexBufferObjectTarget.Array);
		vboVertexData.bind();
		GLuint attribIndex = 0;
		glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Vertex.sizeof * vertexData.length) , vertexData.ptr, GL_STATIC_DRAW);		
		glEnableVertexAttribArray(attribIndex);
		glVertexAttribPointer(attribIndex, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		vboVertexData.unbind();

		writeln("normal data");
		vboNormalData = new VertexBufferObject!(VertexBufferObjectTarget.Array);
		vboNormalData.bind();
		attribIndex = 1;
		glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Normal.sizeof * normalData.length) , normalData.ptr, GL_STATIC_DRAW);		
		glEnableVertexAttribArray(attribIndex);
		glVertexAttribPointer(attribIndex, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		vboNormalData.unbind();

		writeln("uv data");
		vboTextureData = new VertexBufferObject!(VertexBufferObjectTarget.Array);
		vboTextureData.bind();
		attribIndex = 2;
		glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(UV.sizeof * textureData.length) , textureData.ptr, GL_STATIC_DRAW);		
		glEnableVertexAttribArray(attribIndex);
		glVertexAttribPointer(attribIndex, 2, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		vboTextureData.unbind();

		writeln("color data");
		vboColorData = new VertexBufferObject!(VertexBufferObjectTarget.Array);
		vboColorData.bind();
		attribIndex = 3;
		glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(RGBAf.sizeof * colorData.length) , colorData.ptr, GL_STATIC_DRAW);		
		glEnableVertexAttribArray(attribIndex);
		glVertexAttribPointer(attribIndex, 4, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		vboColorData.unbind();		
		
		vao.unbind();
		writeln("done");
	}
}

void setupTweakbar() {
	writeln("creating TweakBar");
	double time        = 0, dt;              // Current time and enlapsed time
	double turn        = 0;                  // Model turn counter
	double speed       = 0.3;                // Model rotation speed
	int wire           = 0;                  // Draw model in wireframe?
	uint frameCount    = 0;
	double fps    = 0;
	float bgColor[3]   = [0.1f, 0.2f, 0.4f]; // Background color
	ubyte cubeColor[4] = [255, 0, 0, 128];   // Model color (32bits RGBA)
	
	auto quat = Quaternionf(0,0,0,1);
	
	//		auto w = this._window.getBounds()[2];
	//		auto h = this._window.getBounds()[3];
	TwWindowSize(1600, 900);
	
//	// Create a tweak bar
//	auto bar = TwNewBar("TweakBar");
//	TwDefine(" GLOBAL help='This example shows how to integrate AntTweakBar with GLFW and OpenGL.' "); // Message added to the help bar.		
//	// Add 'speed' to 'bar': it is a modifable (RW) variable of type TW_TYPE_DOUBLE. Its key shortcuts are [s] and [S].
//	TwAddVarRW(bar, "speed", TW_TYPE_DOUBLE, &speed, " label='Rot speed' min=0 max=2 step=0.01 keyIncr=s keyDecr=S help='Rotation speed (turns/second)' ");		
//	// Add 'wire' to 'bar': it is a modifable variable of type TW_TYPE_BOOL32 (32 bits boolean). Its key shortcut is [w].
//	TwAddVarRW(bar, "wire", TW_TYPE_BOOL32, &wire, " label='Wireframe mode' key=CTRL+w help='Toggle wireframe display mode.' ");		
//	// Add 'time' to 'bar': it is a read-only (RO) variable of type TW_TYPE_DOUBLE, with 1 precision digit
//	TwAddVarRO(bar, "time", TW_TYPE_DOUBLE, &time, " label='Time' precision=1 help='Time (in seconds).' ");
//	//
//	TwAddVarRO(bar, "frameCount", TW_TYPE_UINT32, &frameCount, " label='FrameCount' precision=1 help='FrameCount (in counts).' ");
//	TwAddVarRO(bar, "fps", TW_TYPE_DOUBLE, &fps, " label='fps' precision=1 help='fps (in fps).' ");		
//	// Add 'bgColor' to 'bar': it is a modifable variable of type TW_TYPE_COLOR3F (3 floats color)
//	TwAddVarRW(bar, "bgColor", TW_TYPE_COLOR3F, &bgColor, " label='Background color' ");		
//	// Add 'cubeColor' to 'bar': it is a modifable variable of type TW_TYPE_COLOR32 (32 bits color) with alpha
//	TwAddVarRW(bar, "cubeColor", TW_TYPE_COLOR32, &cubeColor, " label='Cube color' alpha help='Color and transparency of the cube.' ");
//	//
//	TwAddVarRW(bar, "quaternion", TW_TYPE_QUAT4F, &quat, " label='Cubde color' alpha help='Color anwdwd transparency of the cube.' ");
}

//-----------------
// Create Shaders
enum vertexShaderSource = "
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

enum fragmentShaderSource = "
			#version 420 core
			in vec4 v_color;

			out vec4 FragColor;

			void main()
			{
				FragColor = v_color;
			}
		";


auto createShaderPipeline(Shader!(ShaderType.Vertex) vertexShader, Shader!(ShaderType.Fragment) fragmentShader) {	
	assert(vertexShader.isLinked, vertexShader.infoLog());
	assert(fragmentShader.isLinked, fragmentShader.infoLog());

	writeln("a: ");
	auto shaderPipeline = new ShaderPipeline();
	shaderPipeline.bind();
	shaderPipeline.use(vertexShader);
	shaderPipeline.use(fragmentShader);
	writeln("b: ");
	assert(shaderPipeline.isValidProgramPipeline, shaderPipeline.infoLog());
	shaderPipeline.unbind();
	writeln("c: ");
	return shaderPipeline;
}

class Tester {
	Window _window;
	bool _keepRunning = true;

	this() {
		this._window = initThree();
		this._window.onKey.connect!"_onKey"(this);
		this._window.onClose.connect!"_onClose"(this);
	}
	
	~this() {
		import core.memory;
		writeln("GC.collect: ");
		GC.collect();
		//Collect window _AFTER_ everything else
		this._window = null;
		GC.collect();
		deinitThree();
	}

	void run() {
		RGBAf rgg;

		auto mesh = new Mesh("C:/Coding/models/Collada/duck.dae");


		setupTweakbar();

		writeln("creating shaders: ");
		auto vertexShader = new Shader!(ShaderType.Vertex)(vertexShaderSource);
		auto fragmentShader = new Shader!(ShaderType.Fragment)(fragmentShaderSource);
		writeln("creating shader pipeline: ");
		auto shaderPipeline = createShaderPipeline(vertexShader, fragmentShader);


		writeln("connectiong window callbacks: ");
		this._window.onSize.connect!"onSize"(this);
		this._window.onPosition.connect!"onPosition"(this);
		this._window.onButton.connect!"onButton"(this);
		this._window.onCursorPos.connect!"onCursorPos"(this);

		writeln("begin render loop: ");
		//-----------------
		// Render Loop
		glfwSetTime(0);
		while(this._keepRunning) {
					
			this._window.clear(0, 0, 0.5, 1);

			shaderPipeline.bind();
			mesh.vao.bind();
			//vboVertexData.bind();
			glDrawArrays(GL_TRIANGLES, 0, mesh.vertexData.length);
			//vbo.unbind();
			mesh.vao.unbind();
			shaderPipeline.unbind();

			TwDraw();

			this._window.swapBuffers();
			updateWindows();


//			++frameCount;
//			//if(frameCount % 100 == 0) {
//				time = glfwGetTime();
//				fps = cast(double)frameCount / time;
//			//}
		}
	}

	void onSize(Window window, int width, int height) {
		TwWindowSize(width, height);
	}

	void onPosition(Window window, int x, int y) {
	}

	void onButton(Window window , int button, ButtonAction action) {
		TwMouseAction twaction = action == ButtonAction.Pressed ? TW_MOUSE_PRESSED : TW_MOUSE_RELEASED;
		TwMouseButtonID twbutton;

		switch(button) {
			default:
			case GLFW_MOUSE_BUTTON_LEFT: twbutton = TW_MOUSE_LEFT; break;
			case GLFW_MOUSE_BUTTON_RIGHT: twbutton = TW_MOUSE_RIGHT; break;
			case GLFW_MOUSE_BUTTON_MIDDLE: twbutton = TW_MOUSE_MIDDLE; break;			
		}

		TwMouseButton(twaction, twbutton);
	}

	void onCursorPos(Window window, double x, double y) {
		TwMouseMotion(cast(int)x, this._window.getBounds()[3] - cast(int)y);
	}
	
	void stop() {
		this._keepRunning = false;
	}
	
	void _onKey(Window window, Key key, ScanCode scanCode, KeyAction action, KeyMod keyMod) {
		if(window is this._window && action == KeyAction.Pressed) {
			if(key == Key.Escape) {
				this.stop();
			}
		}
	}

	void _onClose(Window window) {
		this.stop();
	}
}


class InputHandler {
private:
	Window _window;
	OpenGlRenderer _renderer;

public:
	this(Window window, OpenGlRenderer renderer) {
		_window = window;
		_renderer = renderer;

		_window.onKey.connect!"_onKey"(this);
		_window.onClose.connect!"_onClose"(this);
		_window.onSize.connect!"_onSize"(this);
		_window.onPosition.connect!"_onPosition"(this);
		_window.onButton.connect!"_onButton"(this);
		_window.onCursorPos.connect!"_onCursorPos"(this);
	}

private:
	void _onKey(Window window, Key key, ScanCode scanCode, KeyAction action, KeyMod keyMod) {
		if(window is _window && action == KeyAction.Pressed) {
			if(key == Key.Escape) {
				_renderer.stop();
			}
		}
	}
	
	void _onClose(Window window) {
		_renderer.stop();
	}

	void _onSize(Window window, int width, int height) {
	}
	
	void _onPosition(Window window, int x, int y) {
	}
	
	void _onButton(Window window , int button, ButtonAction action) {
	}
	
	void _onCursorPos(Window window, double x, double y) {
	}
}

void main() {
	auto window = initThree();
	{
		OpenGlRenderer renderer = new OpenGlRenderer(window);

		InputHandler inputHandler = new InputHandler(window, renderer);

		renderer.run();
	}
	
	import core.memory;
	GC.collect();
	//Collect window _AFTER_ everything else
	this._window = null;
	GC.collect();
	deinitThree();
}