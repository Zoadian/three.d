import std.stdio;

import three;
import std.typecons;

import derelict.opengl3.gl3;
import three.gl.util;

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
		while(this._keepRunning) {
			updateWindows();
					
			this._window.clear(0, 0, 0.5, 1);

			shaderPipeline.bind();
			vao.bind();
			vbo.bind();
			glDrawArrays(GL_TRIANGLES, 0, 3);
			vbo.unbind();
			vao.unbind();
			shaderPipeline.unbind();

			this._window.swapBuffers();			
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