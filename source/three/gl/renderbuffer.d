// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.gl.renderbuffer;

import derelict.opengl3.gl3;
import three.gl.util;


//==============================================================================
///
final class Renderbuffer {
private:
	GLuint _id;

public:	   
	///
	this() {
		check!glGenRenderbuffers(1, &this._id);
	}

	///
	~this() {
		check!glDeleteRenderbuffers(1, &this._id); 
	}
	
public:	  
	///
	void bind() { 
		check!glBindRenderbuffer(GL_RENDERBUFFER, this._id);
	}

	///
	static void unbind(){ 
		check!glBindRenderbuffer(GL_RENDERBUFFER, 0);
	}  
	
public:	  
	///
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
}
