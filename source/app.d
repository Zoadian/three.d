import std.stdio;

import three;
import std.typecons;

import derelict.opengl3.gl3;
import three.gl.util;

import derelict.anttweakbar.anttweakbar;
import derelict.glfw3.glfw3;
import derelict.assimp3.assimp;

import std.string;

struct Vertex {
	float x, y, z;
}

struct Normal {
	float x, y, z;
}

struct UV {
	float u, v;
}

struct Color {
	float r, g, b, a;
}

struct Vector {
	float x, y, z;
}

struct Quaternion {
	float x, y, z, w;
}




final class Mesh {
public:
	Vertex[] vertexData;
	Normal[] normalData;
	UV[] textureData;
	Color[] colorData;

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
					colorData ~= Color(n.x, n.y, n.z, 1.0f);
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
		glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Color.sizeof * colorData.length) , colorData.ptr, GL_STATIC_DRAW);		
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
	
	auto quat = Quaternion(0,0,0,1);
	
	//		auto w = this._window.getBounds()[2];
	//		auto h = this._window.getBounds()[3];
	TwWindowSize(1600, 900);
	
	// Create a tweak bar
	auto bar = TwNewBar("TweakBar");
	TwDefine(" GLOBAL help='This example shows how to integrate AntTweakBar with GLFW and OpenGL.' "); // Message added to the help bar.		
	// Add 'speed' to 'bar': it is a modifable (RW) variable of type TW_TYPE_DOUBLE. Its key shortcuts are [s] and [S].
	TwAddVarRW(bar, "speed", TW_TYPE_DOUBLE, &speed, " label='Rot speed' min=0 max=2 step=0.01 keyIncr=s keyDecr=S help='Rotation speed (turns/second)' ");		
	// Add 'wire' to 'bar': it is a modifable variable of type TW_TYPE_BOOL32 (32 bits boolean). Its key shortcut is [w].
	TwAddVarRW(bar, "wire", TW_TYPE_BOOL32, &wire, " label='Wireframe mode' key=CTRL+w help='Toggle wireframe display mode.' ");		
	// Add 'time' to 'bar': it is a read-only (RO) variable of type TW_TYPE_DOUBLE, with 1 precision digit
	TwAddVarRO(bar, "time", TW_TYPE_DOUBLE, &time, " label='Time' precision=1 help='Time (in seconds).' ");
	//
	TwAddVarRO(bar, "frameCount", TW_TYPE_UINT32, &frameCount, " label='FrameCount' precision=1 help='FrameCount (in counts).' ");
	TwAddVarRO(bar, "fps", TW_TYPE_DOUBLE, &fps, " label='fps' precision=1 help='fps (in fps).' ");		
	// Add 'bgColor' to 'bar': it is a modifable variable of type TW_TYPE_COLOR3F (3 floats color)
	TwAddVarRW(bar, "bgColor", TW_TYPE_COLOR3F, &bgColor, " label='Background color' ");		
	// Add 'cubeColor' to 'bar': it is a modifable variable of type TW_TYPE_COLOR32 (32 bits color) with alpha
	TwAddVarRW(bar, "cubeColor", TW_TYPE_COLOR32, &cubeColor, " label='Cube color' alpha help='Color and transparency of the cube.' ");
	//
	//		TwAddVarRW(bar, "quaternion", TW_TYPE_QUAT4F, &quat, " label='Cube color' alpha help='Color and transparency of the cube.' ");
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


void main() {

	Unique!(Tester) tester = new Tester();	
	tester.run();
}