// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.gl.vao;

import derelict.opengl3.gl3;
import three.gl.util;

import std.stdio;
//==============================================================================
///
final class VertexArrayObject {
private:
	uint _id;

public:	   
	///
	this() {
		check!glGenVertexArrays(1, &this._id);
		writeln("vao created: ", this._id);
	}

	///
	~this() {
		writeln("vao destroxing..: ", this._id);
		check!glDeleteVertexArrays(1, &this._id);
		writeln("vao destroyed: ", this._id);
	}
	
public:		   
	///
	void bind() { 
		assert(this.isValid);
		check!glBindVertexArray(this._id);
	}

	///
	static void unbind() { 
		check!glBindVertexArray(0);
	}  
	
public:	  
	///
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
}
