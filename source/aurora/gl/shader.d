// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module aurora.gl.shader;

import derelict.opengl3.gl3;
import aurora.gl.util;


//==============================================================================
///
enum ShaderType {
	Vertex      			= GL_VERTEX_SHADER,
	Fragment    			= GL_FRAGMENT_SHADER,
	Geometry    			= GL_GEOMETRY_SHADER,
	TesselationControl 		= GL_TESS_CONTROL_SHADER, 
	TesselationEvaluation 	= GL_TESS_EVALUATION_SHADER
}


//==============================================================================
///
final class Shader(ShaderType TYPE) {		
private:
	uint _id;

public:	   
	///
	this(string source) {
		auto szSource = [source.toStringz()];
		this._id = check!glCreateShaderProgramv(TYPE, 1, szSource.ptr);
	}

	///
	~this() {
		check!glDeleteProgram(this._id);
	}

public:	  
	///
	@property bool isValid() const {
		return (this._id > 0 && this.isLinked);
	}

	///
	@property bool isLinked() const {
		GLint linked;
		check!glGetProgramiv(this._id, GL_LINK_STATUS, &linked);
		return linked != 0;
	}
	
public:	  
	///
	int getUniformLocation(string name) {
		int* px = (name in this._uniformLocationCache);
		if(px !is null) return *px;
		auto szName = name.toStringz();
		assert(this._id > 0);
		int x = check!glGetUniformLocation(this._id, &szName[0]);
		//assert(x != -1, "wrong uniform location : " ~ name);
		try{if(x == -1) "wrong uniform location : ".writeln(name);}catch(Exception e){}
		
		this._uniformLocationCache[name] = x;
		//if(x == -1) throw new Exception("uniform location "~name~" not found");
		return x;
	}	

	///
	string infoLog() {
		int len;
		check!glGetProgramiv(this._id, GL_INFO_LOG_LENGTH , &len);
		if (len > 1) {
			char[] msg = new char[len];
			check!glGetProgramInfoLog(this._id, len, null, cast(char*) msg);
			return cast(string)msg;
		}
		return "";
	}
}


//==============================================================================
///
final class ShaderPipeline {
private:
	GLuint _id;
	uint[ShaderType] _currentlyUsed;
	
public:	 
	///
	this() { 
		glGenProgramPipelines(1, &this._id); 
	}

	///
	~this() { 
		glDeleteProgramPipelines(1, &this._id);
	}
	
public:			
	///
	@property bool isValid() const {
		return (this._id > 0 && this.isValidProgramPipeline);
	}

	///
	@property bool isValidProgramPipeline() const { 
		glValidateProgramPipeline(this._id); 
		GLint status;
		glGetProgramPipelineiv(this._id, GL_VALIDATE_STATUS, &status);
		return status != 0;
	}
	
public:    
	/// 
	void bind()  { 
		glBindProgramPipeline(this._id); 
	}

	///
	static void unbind()  { 
		glBindProgramPipeline(0);
	}

	///
	void activate(T)(T shaderProgram) { // TODO: add check if it is a shaderProgram
		glActiveShaderProgram(this._id, shaderProgram._id);
	}

	///
	void use(T)(T shaderProgram) { // TODO: add check if it is a shaderProgram
		//check if shaderProgram is already in use by this pipeline
		if(_currentlyUsed.get(T.type, 0) == shaderProgram._id) return;
		glUseProgramStages(this._id, shaderTypeBitIdentifier!(shaderProgram.type), shaderProgram._id);
	}

	///
	string infoLog() {
		int len;
		glGetProgramiv(this._id, GL_INFO_LOG_LENGTH , &len);
		if (len > 1) {
			char[] msg = new char[len];
			glGetProgramPipelineInfoLog(this._id, len, null, cast(char*) msg);
			return cast(string)msg;
		}
		return "";
	}
}
