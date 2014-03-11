// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.gl.framebuffer;

import derelict.opengl3.gl3;
import three.gl.util;


//==============================================================================
///
enum FramebufferTarget : GLenum {
	Write = GL_DRAW_FRAMEBUFFER,
	Read = GL_READ_FRAMEBUFFER
}


//==============================================================================
///
enum FramebufferStatus : GLenum {
	Complete = GL_FRAMEBUFFER_COMPLETE,
	Error = 0,
	Undefines = GL_FRAMEBUFFER_UNDEFINED,
	IncompleteAttachment = GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT,
	IncompleteMissingAttachment = GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,
	IncompleteDrawBuffer = GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER,
	IncompleteReadBuffer = GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER,
	Unsupported = GL_FRAMEBUFFER_UNSUPPORTED,
	IncompleteMultisample = GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE,        
	IncompleteLayerTargets = GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS
}


//==============================================================================
///
enum FramebufferAttachment {
	Color = GL_COLOR_ATTACHMENT0, 
	Depth = GL_DEPTH_ATTACHMENT, 
	Stencil = GL_STENCIL_ATTACHMENT,
	DepthStencil = GL_DEPTH_STENCIL_ATTACHMENT
}


//==============================================================================
///
final class Framebuffer {
private:
	GLuint _id;

public:	   
	///
	this() {
		check!glGenFramebuffers(1, &this._id); 
	}

	///
	~this() {
		check!glDeleteFramebuffers(1, &this._id);
	}
	
public:	   
	///
	void bind(FramebufferTarget target) { 
		assert(this.isValid);
		check!glBindFramebuffer(target, this._id);
	}    

	///
	static void unbind(FramebufferTarget target) { 
		check!glBindFramebuffer(target, 0);
	}
		
	
	//~ version(OpenGL4) {
		//~ void defaultWidth(Target target, uint width) { check!glFramebufferParameteri(target, GL_FRAMEBUFFER_DEFAULT_WIDTH, width); }
		//~ uint defaultWidth(Target target) { GLint width; check!glGetFramebufferParameteriv(target, GL_FRAMEBUFFER_DEFAULT_WIDTH, &width); }
		
		//~ void defaultHeight(Target target, uint height) { check!glFramebufferParameteri(target, GL_FRAMEBUFFER_DEFAULT_HEIGHT, height); }
		//~ uint defaultWidth(Target target) { GLint height; check!glGetFramebufferParameteriv(target, GL_FRAMEBUFFER_DEFAULT_HEIGHT, &height); }
		
		//~ void defaultLayers(Target target, uint layers) { check!glFramebufferParameteri(target, GL_FRAMEBUFFER_DEFAULT_LAYERS, layers); }
		//~ uint defaultWidth(Target target) { GLint layers; check!glGetFramebufferParameteriv(target, GL_FRAMEBUFFER_DEFAULT_LAYERS, &layers); }
		
		//~ void defaultSamles(Target target, uint samples) { check!glFramebufferParameteri(target, GL_FRAMEBUFFER_DEFAULT_SAMPLES, samples); }
		//~ uint defaultWidth(Target target) { GLint samples; check!glGetFramebufferParameteriv(target, GL_FRAMEBUFFER_DEFAULT_SAMPLES, &samples); }
		
		//~ void defaultFixedSampleLocations(Target target, uint fixedSampleLocations) { check!glFramebufferParameteri(target, GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS, fixedSampleLocations); }
		//~ uint defaultFixedSampleLocations(Target target) { GLint fixedSampleLocations; check!glGetFramebufferParameteriv(target, GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS, &fixedSampleLocations); }
	//~ }
	
	//~ void attach(Target target, Attachment attachment, Texture texture, uint location) {
		//~ debug{assert(this.db_isBound(target), "framebuffer not bound");}
		//~ switch(attachment) {
			//~ case Attachment.Color:
				//~ check!glFramebufferTexture2D(target, attachment + location, GL_TEXTURE_2D, texture.id, 0);
				//~ break;
			//~ default:
				//~ check!glFramebufferTexture2D(target, attachment, GL_TEXTURE_2D, texture.id, 0);
		//~ }
	//~ }
	
public:		
	///
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
		
	///
	static FramebufferStatus status(FramebufferTarget target) {
		return cast(FramebufferStatus) check!glCheckFramebufferStatus(target);
	}    
}
