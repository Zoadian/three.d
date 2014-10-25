import std.stdio;

import std.typecons;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import derelict.anttweakbar.anttweakbar;
import derelict.freeimage.freeimage;	
import derelict.freetype.ft;
import derelict.assimp3.assimp;

import std.string;
import std.experimental.logger;



//======================================================================================================================
// 
//======================================================================================================================
import std.traits : ReturnType;
ReturnType!func glCheck(alias func, string file = __FILE__, size_t line = __LINE__, string mod = __MODULE__, string funcd = __FUNCTION__, string pretty = __PRETTY_FUNCTION__, Args...)(Args args) nothrow {
	import std.stdio;
	import std.stdio : stderr;
	import std.array : join;
	import std.range : repeat;
	import std.string : format;
	try{
		debug scope(exit) {
			GLenum err = glGetError();
			if(err != GL_NO_ERROR) {
				stderr.writeln("\n===============================");
				stderr.writeln("File: ", file, "\nLine: ", line, "\nModule: ",mod, "\nFunction: ",funcd, "\n",pretty);
				stderr.writeln("-------------------------------");
				stderr.writefln(`OpenGL function "%s(%s)" failed: "%s."`, func.stringof, format("%s".repeat(Args.length).join(", "), args), glErrorString(err));
				stderr.writeln("=============================== \n");
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

string glErrorString(GLenum error) pure @safe nothrow @nogc {
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


//======================================================================================================================
// 
//======================================================================================================================
alias SoA(T) = T[];

//======================================================================================================================
// 
//======================================================================================================================
struct SOAVector3 {
	SoA!float x;
	SoA!float y;
	SoA!float z;
}

struct SOAQuaternion {
	SoA!float x;
	SoA!float y;
	SoA!float z;
	SoA!float w;
}


//======================================================================================================================
// 
//======================================================================================================================
struct Window {
private:
	GLFWwindow* glfwWindow = null;
	string title;
	uint x, y, width, height;
	KeyAction[int] keyStates;
	ButtonAction[int] buttonStates;
}

alias ScanCode = int;

enum IconifyAction {
	Iconified,
	Restored
}

enum FocusAction {
	Focused,
	Defocused
}

enum CursorAction {
	Entered,
	Leaved
}

enum ButtonAction {
	Pressed,
	Released
}

enum KeyAction {
	Pressed,
	Released,
	Repeated
}

enum KeyMod {
	Shift = 0x0001,
	Control = 0x0002,
	Alt = 0x0004,
	Super = 0x0008,
}

enum Key {
	Unknown = -1,
	Space = 32,
	Apostrophe = 39,
	Comma = 44,
	Minus = 45,
	Period = 46,
	Slash = 47,
	Key0 = 48,
	Key1 = 49,
	Key2 = 50,
	Key3 = 51,
	Key4 = 52,
	Key5 = 53,
	Key6 = 54,
	Key7 = 55,
	Key8 = 56,
	Key9 = 57,
	Semicolon = 59,
	Equal = 61,
	KeyA = 65,
	KeyB = 66,
	KeyC = 67,
	KeyD = 68,
	KeyE = 69,
	KeyF = 70,
	KeyG = 71,
	KeyH = 72,
	KeyI = 73,
	KeyJ = 74,
	KeyK = 75,
	Keyl = 76,
	KeyM = 77,
	KeyN = 78,
	KeyO = 79,
	KeyP = 80,
	KeyQ = 81,
	KeyR = 82,
	KeyS = 83,
	KeyT = 84,
	KeyU = 85,
	KeyV = 86,
	KeyW = 87,
	KeyX = 88,
	KeyY = 89,
	KeyZ = 90,
	LeftBracket = 91,
	Backslash = 92,
	RightBracket = 93,
	GraveAccent = 96,
	World1 = 161,
	World2 = 162,
	Escape = 256,
	Enter = 257,
	Tab = 258,
	Backspace = 259,
	Insert = 260,
	Delete = 261,
	Right = 262,
	Left = 263,
	Down = 264,
	Up = 265,
	PageUp = 266,
	PageDown = 267,
	Home = 268,
	End = 269,
	CapsLock = 280,
	ScrollLock = 281,
	NumLock = 282,
	PrintScreen = 283,
	Pause = 284,
	F1 = 290,
	F2 = 291,
	F3 = 292,
	F4 = 293,
	F5 = 294,
	F6 = 295,
	F7 = 296,
	F8 = 297,
	F9 = 298,
	F10 = 299,
	F11 = 300,
	F12 = 301,
	F13 = 302,
	F14 = 303,
	F15 = 304,
	F16 = 305,
	F17 = 306,
	F18 = 307,
	F19 = 308,
	F20 = 309,
	F21 = 310,
	F22 = 311,
	F23 = 312,
	F24 = 313,
	F25 = 314,
	NumBlock0 = 320,
	NumBlock1 = 321,
	NumBlock2 = 322,
	NumBlock3 = 323,
	NumBlock4 = 324,
	NumBlock5 = 325,
	NumBlock6 = 326,
	NumBlock7 = 327,
	NumBlock8 = 328,
	NumBlock9 = 329,
	KpDecimal = 330,
	KpDivide = 331,
	KpMultiply = 332,
	KpSubtract = 333,
	KpAdd = 334,
	KpEnter = 335,
	KpEqual = 336,
	LeftShift = 340,
	LeftControl = 341,
	LeftAlt = 342,
	LeftSuper = 343,
	RightShift = 344,
	RightControl = 345,
	RightAlt = 346,
	RightSuper = 347,
	Menu = 348
}

void construct(out Window window, string title, uint width, uint height) nothrow {
	window.x = 0;
	window.y = 0;
	window.width = width;
	window.height = height;

	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 4);
	
	glfwDefaultWindowHints();
	glfwWindowHint(GLFW_RED_BITS, 8);
	glfwWindowHint(GLFW_GREEN_BITS, 8);
	glfwWindowHint(GLFW_BLUE_BITS, 8);
	glfwWindowHint(GLFW_ALPHA_BITS, 0);
	glfwWindowHint(GLFW_DEPTH_BITS, 24);
	glfwWindowHint(GLFW_STENCIL_BITS, 8);
	window.glfwWindow = glfwCreateWindow(width, height, title.toStringz(), null, null);
	assert(window.glfwWindow !is null);

//	glfwSetWindowUserPointer(window.glfwWindow, cast(void*)&window);
//	glfwSetWindowPosCallback(window.glfwWindow, cast(GLFWwindowposfun)&_GLFWwindowposfun);
//	glfwSetWindowSizeCallback(window.glfwWindow, cast(GLFWwindowsizefun)&_GLFWwindowsizefun);
//	glfwSetWindowCloseCallback(window.glfwWindow, cast(GLFWwindowclosefun)&_GLFWwindowclosefun);
//	glfwSetWindowRefreshCallback(window.glfwWindow, cast(GLFWwindowrefreshfun)&_GLFWwindowrefreshfun);
//	glfwSetWindowIconifyCallback(window.glfwWindow, cast(GLFWwindowiconifyfun)&_GLFWwindowiconifyfun);
//	glfwSetMouseButtonCallback(window.glfwWindow, cast(GLFWmousebuttonfun)&_GLFWmousebuttonfun);
//	glfwSetCursorPosCallback(window.glfwWindow, cast(GLFWcursorposfun)&_GLFWcursorposfun);
//	//glfwSetCursorEnterCallback(window.glfwWindow, cast(GLFWcursorenterfunfun)&_GLFWcursorenterfunfun);
//	glfwSetScrollCallback(window.glfwWindow, cast(GLFWscrollfun)&_GLFWscrollfun);
//	glfwSetKeyCallback(window.glfwWindow, cast(GLFWkeyfun)&_GLFWkeyfun);
//	glfwSetCharCallback(window.glfwWindow, cast(GLFWcharfun)&_GLFWcharfun);

	glfwMakeContextCurrent(window.glfwWindow);
}

void destruct(ref Window window) nothrow @nogc {
//	glfwSetWindowPosCallback(window.glfwWindow, null);
//	glfwSetWindowSizeCallback(window.glfwWindow, null);
//	glfwSetWindowCloseCallback(window.glfwWindow, null);
//	glfwSetWindowRefreshCallback(window.glfwWindow, null);
//	glfwSetWindowIconifyCallback(window.glfwWindow, null);
//	glfwSetMouseButtonCallback(window.glfwWindow, null);
//	glfwSetCursorPosCallback(window.glfwWindow, null);
//	//glfwSetCursorEnterCallback(this._glfwWindow, null);
//	glfwSetScrollCallback(window.glfwWindow, null);
//	glfwSetKeyCallback(window.glfwWindow, null);
//	glfwSetCharCallback(window.glfwWindow, null);
	
	glfwDestroyWindow(window.glfwWindow);

	window = Window.init;
}

void makeAktiveRenderWindow(ref Window window) nothrow @nogc {
	glfwMakeContextCurrent(window.glfwWindow);
}

void swapBuffers(ref Window window) nothrow @nogc {
	glfwSwapBuffers(window.glfwWindow);
}

void pollEvents(ref Window window) nothrow @nogc {
	glfwPollEvents();
}

@property void setTitle(ref Window window, string title) nothrow {
	glfwSetWindowTitle(window.glfwWindow, title.toStringz());
}

KeyAction keyState(ref Window window, int key) pure @safe nothrow {
	try {
		return window.keyStates.get(key, KeyAction.Released);
	}
	catch(Exception) {
		return KeyAction.Released;
	}
}

ButtonAction buttonState(ref Window window, int button) pure @safe nothrow {
	try {
		return window.buttonStates.get(button, ButtonAction.Released);
	}
	catch(Exception) {
		return ButtonAction.Released;
	}
}

//======================================================================================================================
// 
//======================================================================================================================
struct Viewport {
}

void construct(out Viewport viewport) pure @safe nothrow @nogc {
}

void destruct(ref Viewport viewport) pure @safe nothrow @nogc {
	viewport = Viewport.init;
}

//======================================================================================================================
// 
//======================================================================================================================
struct Scene {
	SOAMesh mesh;
}

void construct(out Scene scene) pure @safe nothrow @nogc {
}

void destruct(ref Scene scene) pure @safe nothrow @nogc {
	scene = Scene.init;
}

//======================================================================================================================
// 
//======================================================================================================================
struct Camera {
}

void construct(out Camera camera) pure @safe nothrow @nogc {
}

void destruct(ref Camera camera) pure @safe nothrow @nogc {
	camera = Camera.init;
}

//======================================================================================================================
// 
//======================================================================================================================
struct RenderTarget {
	uint width;
	uint height;
	GLuint textureTarget;
}

void construct(out RenderTarget renderTarget, uint width, uint height) nothrow {
	renderTarget.width = width;
	renderTarget.height = height;
	glCheck!glGenTextures(1, &renderTarget.textureTarget);
	glCheck!glBindTexture(GL_TEXTURE_2D, renderTarget.textureTarget);
	glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA32F, width, height);
	glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
	glCheck!glBindTexture(GL_TEXTURE_2D, 0);
}

void destruct(ref RenderTarget renderTarget) nothrow {
	glCheck!glDeleteTextures(1, &renderTarget.textureTarget);
	renderTarget = RenderTarget.init;
}

//======================================================================================================================
// 
//======================================================================================================================
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
	gBuffer.width = height;

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
	glGenProgramPipelines(1, &pipeline.pipeline); 
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
}

void destruct(ref OpenGlTiledDeferredRenderer deferredRenderer) nothrow {
	deferredRenderer.gBuffer.destruct();
	deferredRenderer = OpenGlTiledDeferredRenderer.init;
}

// draw the scene supersampled with renderer's with+height onto renderTarget at position+size of viewport
void renderOneFrame(ref OpenGlTiledDeferredRenderer renderer, ref Scene scene, ref Camera camera, ref RenderTarget renderTarget, ref Viewport viewport) nothrow {
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
	glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, renderer.gBuffer.fbo); scope(exit) glCheck!glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0); 
	glCheck!glDrawBuffer(GL_COLOR_ATTACHMENT0 + 0);
	glCheck!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	GLenum[] drawBuffers = [GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2];
	glCheck!glDrawBuffers(drawBuffers.length, drawBuffers.ptr);
	glCheck!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

	//bind pipeline
	glCheck!glBindProgramPipeline(renderer.pipeline.pipeline); scope(exit) glCheck!glBindProgramPipeline(0);

	{// Draw Geometry
		scope(exit) glCheck!glBindVertexArray(0);
		scope(exit) glCheck!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0); // TODO: GL_ELEMENT_ARRAY_BUFFER should be vao state, but bugs might make this necessary

		for(size_t meshIdx = 0; meshIdx < scene.mesh.cnt; ++meshIdx) {
			glCheck!glBindVertexArray(scene.mesh.vao[meshIdx]); 

			glCheck!glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, scene.mesh.vboIndices[meshIdx]); // TODO: GL_ELEMENT_ARRAY_BUFFER should be vao state, but bugs might make this necessary

			glCheck!glDrawElements(GL_TRIANGLES, scene.mesh.cntIndices[meshIdx], GL_UNSIGNED_SHORT, null);
		}
	}
}




//======================================================================================================================
// 
//======================================================================================================================
struct SOAMesh {
	SoA!GLuint vao;
	SoA!GLuint vboVertices;
	SoA!GLuint vboNormals;
	SoA!GLuint vboTexcoords;
	SoA!GLuint vboColors;
	SoA!GLuint vboIndices;
	SoA!GLuint cntIndices;
	size_t cnt;
}

void loadModel(ref SOAMesh mesh, string filePath) {
	import std.traits;
	auto scene = aiImportFile(filePath.toStringz(),	aiProcess_Triangulate); scope(exit) aiReleaseImport(scene);

	for(uint m = 0; m < scene.mNumMeshes; ++m) {	
		const(aiMesh*) meshData = scene.mMeshes[m];
		assert(meshData !is null);
		
		//-----------------------------
		// create mesh
		auto meshIdx = mesh.cnt;
		++mesh.cnt;
		mesh.vao.length = mesh.cnt;
		mesh.vboVertices.length = mesh.cnt;
		mesh.vboNormals.length = mesh.cnt;
		mesh.vboTexcoords.length = mesh.cnt;
		mesh.vboIndices.length = mesh.cnt;
		mesh.cntIndices.length = mesh.cnt;

		//-----------------------------
		// upload data
		glCheck!glGenVertexArrays(1, &mesh.vao[meshIdx]);
		glCheck!glBindVertexArray(mesh.vao[meshIdx]); scope(exit) glCheck!glBindVertexArray(0);

		alias Vertex = float[3];
		alias Normal = float[3];
		alias TexCoord = float[2];
		alias Color = float[4];
		alias Index = uint[1];

		size_t cntIndices = 0;
		foreach(f; 0..meshData.mNumFaces) {
			cntIndices += meshData.mFaces[f].mNumIndices;				
		}

		{// upload vertex data
			Vertex[] vertexData;
			vertexData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				vertexData[v] = [meshData.mVertices[v].x, meshData.mVertices[v].y, meshData.mVertices[v].z];
			}
			glCheck!glGenBuffers(1, &mesh.vboVertices[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboVertices[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 0;
			glCheck!glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Vertex.sizeof * vertexData.length) , vertexData.ptr, GL_STATIC_DRAW);		
			glCheck!glEnableVertexAttribArray(attribIndex);
			glCheck!glVertexAttribPointer(attribIndex, Vertex.sizeof / ForeachType!Vertex.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}

		{// upload normal data
			Normal[] normalData;
			normalData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				normalData[v] = [meshData.mNormals[v].x, meshData.mNormals[v].y, meshData.mNormals[v].z];
			}
			glCheck!glGenBuffers(1, &mesh.vboNormals[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboNormals[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 1;
			glCheck!glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Normal.sizeof * normalData.length) , normalData.ptr, GL_STATIC_DRAW);		
			glCheck!glEnableVertexAttribArray(attribIndex);
			glCheck!glVertexAttribPointer(attribIndex, Normal.sizeof / ForeachType!Normal.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}

		if(meshData.mTextureCoords[0] !is null) {// upload texture data
			TexCoord[] textureData;
			textureData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				textureData[v] = [meshData.mTextureCoords[0][v].x, meshData.mTextureCoords[0][v].y];
			}
			glCheck!glGenBuffers(1, &mesh.vboTexcoords[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboTexcoords[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 2;
			glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(TexCoord.sizeof * textureData.length) , textureData.ptr, GL_STATIC_DRAW);		
			glEnableVertexAttribArray(attribIndex);
			glVertexAttribPointer(attribIndex, TexCoord.sizeof / ForeachType!TexCoord.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}

		if(meshData.mColors[0] !is null) {// upload color data
			Color[] colorData;
			colorData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				colorData[v] = [meshData.mColors[0][v].r, meshData.mColors[0][v].g, meshData.mColors[0][v].b, meshData.mColors[0][v].a];
			}
			glCheck!glGenBuffers(1, &mesh.vboTexcoords[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboTexcoords[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 2;
			glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Color.sizeof * colorData.length) , colorData.ptr, GL_STATIC_DRAW);		
			glEnableVertexAttribArray(attribIndex);
			glVertexAttribPointer(attribIndex, Color.sizeof / ForeachType!Color.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}

		{// upload index data
			Index[] indexData;
			indexData.length = cntIndices;
			size_t curIndexDataIdx = 0;
			foreach(f; 0..meshData.mNumFaces) {
				assert(meshData.mFaces !is null);
				foreach(i; 0..meshData.mFaces[f].mNumIndices) {
					assert(meshData.mFaces[f].mIndices !is null);
					indexData[curIndexDataIdx++] = meshData.mFaces[f].mIndices[i];		
				}
			}
			glCheck!glGenBuffers(1, &mesh.vboIndices[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboIndices[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 3;
			glCheck!glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Index.sizeof * indexData.length) , indexData.ptr, GL_STATIC_DRAW);		
			glCheck!glEnableVertexAttribArray(attribIndex);
			glCheck!glVertexAttribPointer(attribIndex, Index.sizeof / ForeachType!Index.sizeof, GL_UNSIGNED_INT, GL_FALSE, 0, cast(void*)0);
		}
	}
}

//======================================================================================================================
// 
//======================================================================================================================
void main() {
	Window window;
	Viewport viewport;
	Scene scene;
	Camera camera;
	RenderTarget renderTarget;
	OpenGlTiledDeferredRenderer renderer;

	DerelictGL3.load();
	DerelictGLFW3.load();
	DerelictFI.load();
//	DerelictFT.load();
	DerelictASSIMP3.load();
	DerelictAntTweakBar.load();
	if(!glfwInit()) throw new Exception("Initialising GLFW failed"); scope(exit) glfwTerminate();

	window.construct("Three.d", 1600, 900); scope(exit) window.destruct();

	try {
		GLVersion glVersion = DerelictGL3.reload();
		import std.conv : to;
		writeln("Reloaded OpenGL Version: ", to!string(glVersion)); 
	} catch(Exception e) {
		writeln("Reloading OpenGl failed: " ~ e.msg);
	}

//	static FT_Library _s_freeTypeLibrary
//	if(!FT_Init_FreeType(&_s_freeTypeLibrary)) throw new Exception("Initialising FreeType failed"); scope(exit) FT_Done_FreeType(_s_freeTypeLibrary);
	if(TwInit(TW_OPENGL_CORE, null) == 0) throw new Exception("Initialising AntTweakBar failed"); scope(exit) TwTerminate();

	viewport.construct(); scope(exit) window.destruct();
	scene.construct(); scope(exit) window.destruct();
	camera.construct(); scope(exit) window.destruct();
	renderTarget.construct(window.width, window.height); scope(exit) renderTarget.destruct();
	renderer.construct(window.width, window.height); scope(exit) renderer.destruct();

	scene.mesh.loadModel("C:/Coding/models/Collada/duck.dae");

	while(true) {
		window.pollEvents();

		window.makeAktiveRenderWindow();

		glCheck!glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glCheck!glClearDepth(1.0f);
		glCheck!glClearColor(0.5, 0, 0, 1);

		renderer.renderOneFrame(scene, camera, renderTarget, viewport);

		window.swapBuffers();
	}
}




/+++


	

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


+++/