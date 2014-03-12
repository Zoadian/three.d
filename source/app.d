import std.stdio;

import three;
import std.typecons;

import derelict.opengl3.gl3;
import three.gl.util;

import derelict.anttweakbar.anttweakbar;
import derelict.glfw3.glfw3;

class Tester {
	Unique!(Window) _window;
	bool _keepRunning = true;


	this() {
		this._window = initThree();
		this._window.onKey.connect!"_onKey"(this);
		this._window.onClose.connect!"_onClose"(this);
	}
	
	~this() {
		//_window.destroy();
		deinitThree();
	}
	
	void run() {
		double time        = 0, dt;              // Current time and enlapsed time
		double turn        = 0;                  // Model turn counter
		double speed       = 0.3;                // Model rotation speed
		int wire           = 0;                  // Draw model in wireframe?
		uint frameCount    = 0;
		double fps    = 0;
		float bgColor[3]   = [0.1f, 0.2f, 0.4f]; // Background color
		ubyte cubeColor[4] = [255, 0, 0, 128];   // Model color (32bits RGBA)

		TwWindowSize(640, 480);

		// Create a tweak bar
		auto bar = TwNewBar("TweakBar");
		TwDefine(" GLOBAL help='This example shows how to integrate AntTweakBar with GLFW and OpenGL.' "); // Message added to the help bar.
		
		// Add 'speed' to 'bar': it is a modifable (RW) variable of type TW_TYPE_DOUBLE. Its key shortcuts are [s] and [S].
		TwAddVarRW(bar, "speed", TW_TYPE_DOUBLE, &speed,
		           " label='Rot speed' min=0 max=2 step=0.01 keyIncr=s keyDecr=S help='Rotation speed (turns/second)' ");
		
		// Add 'wire' to 'bar': it is a modifable variable of type TW_TYPE_BOOL32 (32 bits boolean). Its key shortcut is [w].
		TwAddVarRW(bar, "wire", TW_TYPE_BOOL32, &wire,
		           " label='Wireframe mode' key=CTRL+w help='Toggle wireframe display mode.' ");
		
		// Add 'time' to 'bar': it is a read-only (RO) variable of type TW_TYPE_DOUBLE, with 1 precision digit
		TwAddVarRO(bar, "time", TW_TYPE_DOUBLE, &time, " label='Time' precision=1 help='Time (in seconds).' ");

		TwAddVarRO(bar, "frameCount", TW_TYPE_UINT32, &frameCount, " label='FrameCount' precision=1 help='FrameCount (in counts).' ");
		TwAddVarRO(bar, "fps", TW_TYPE_DOUBLE, &fps, " label='fps' precision=1 help='fps (in fps).' ");
		
		// Add 'bgColor' to 'bar': it is a modifable variable of type TW_TYPE_COLOR3F (3 floats color)
		TwAddVarRW(bar, "bgColor", TW_TYPE_COLOR3F, &bgColor, " label='Background color' ");
		
		// Add 'cubeColor' to 'bar': it is a modifable variable of type TW_TYPE_COLOR32 (32 bits color) with alpha
		TwAddVarRW(bar, "cubeColor", TW_TYPE_COLOR32, &cubeColor,
		           " label='Cube color' alpha help='Color and transparency of the cube.' ");


		//-----------------
		// Create Mesh
		Vector3f vertices[3] = [
			Vector3f(-1.0f, -1.0f, 0.0f),
			Vector3f( 1.0f, -1.0f, 0.0f),
			Vector3f( 0.0f,  1.0f, 0.0f)
		];

		Unique!(VertexArrayObject) vao = new VertexArrayObject();
		vao.bind();
		Unique!(VertexBufferObject!(VertexBufferObjectTarget.Array)) vbo = new VertexBufferObject!(VertexBufferObjectTarget.Array);
		vbo.bind();

		GLuint attribIndex = 0;
		glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(vertices.sizeof) , vertices.ptr, GL_STATIC_DRAW);		
		glEnableVertexAttribArray(attribIndex);
		glVertexAttribPointer(attribIndex, 3, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		vbo.unbind();
		vao.unbind();

		//-----------------
		// Create Shaders
		enum vertexShaderSource = "
			#version 420 core

			layout(location = 0) in vec3 in_position;
			//layout(location = 1) in vec3 in_normal;
			//layout(location = 2) in vec2 in_texcoord;
			//layout(location = 3) in vec3 in_color;

			out gl_PerVertex 
			{
		    	vec4 gl_Position;
		 	};

			void main()
			{
				gl_Position = vec4(0.5 * in_position.x, 0.5 * in_position.y, in_position.z, 1.0);
			}
		";

		enum fragmentShaderSource = "
			#version 420 core

			out vec4 FragColor;

			void main()
			{
				FragColor = vec4(1.0, 0.0, 0.0, 1.0);
			}
		";

		Unique!(Shader!(ShaderType.Vertex)) vertexShader = new Shader!(ShaderType.Vertex)(vertexShaderSource);
		Unique!(Shader!(ShaderType.Fragment)) fragmentShader = new Shader!(ShaderType.Fragment)(fragmentShaderSource);

		assert(vertexShader.isLinked, vertexShader.infoLog());
		assert(fragmentShader.isLinked, fragmentShader.infoLog());

		Unique!(ShaderPipeline) shaderPipeline = new ShaderPipeline();
		shaderPipeline.bind();
		shaderPipeline.use(vertexShader);
		shaderPipeline.use(fragmentShader);
		assert(shaderPipeline.isValidProgramPipeline, shaderPipeline.infoLog());
		shaderPipeline.unbind();

		//-----------------
		// Render Loop
		glfwSetTime(0);
		while(this._keepRunning) {
					
			this._window.clear(0, 0, 0.5, 1);

			shaderPipeline.bind();
			vao.bind();
			vbo.bind();
			glDrawArrays(GL_TRIANGLES, 0, 3);
			vbo.unbind();
			vao.unbind();
			shaderPipeline.unbind();

			TwDraw();

			this._window.swapBuffers();

			++frameCount;
			if(frameCount % 100 == 0) {
				updateWindows();
				time = glfwGetTime();
				fps = cast(double)frameCount / time;
			}
		}
	}
	
	void stop() {
		this._keepRunning = false;
	}
	
	void _onKey(Window window, Key key, ScanCode scanCode, KeyAction action, KeyMod keyMod) {
		if(window is this._window.opDot() && action == KeyAction.Pressed) {
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