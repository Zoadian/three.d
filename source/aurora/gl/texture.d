// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module aurora.gl.texture;

import derelict.opengl3.gl3;
import aurora.gl.util;


//==============================================================================
///
final class Texture {
private:
	uint _id;

public:		 
	///
	this() {
		check!glGenTextures(1, &this._id);
	}

	///
	~this() {
		check!glDeleteTextures(1, &this._id);
	}
	
public:		  
	///
	void activate(uint location) {
		check!glActiveTexture(GL_TEXTURE0 + location);
	}

	///
	void bind() {
		check!glBindTexture(GL_TEXTURE_2D, this._id);
	}

	///
	static void unbind() { 
		check!glBindTexture(GL_TEXTURE_2D, 0); 
	}
	
public:				
	///
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
}
