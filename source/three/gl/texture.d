// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.gl.texture;

import derelict.opengl3.gl3;
import three.gl.util;

//==============================================================================
enum TextureTarget : GLenum {		
	Texture1D = GL_TEXTURE_1D, 
	Texture2D = GL_TEXTURE_2D, 
	Texture3D = GL_TEXTURE_3D, 
	Texture1DArray = GL_TEXTURE_1D_ARRAY, 
	Texture2DArray = GL_TEXTURE_2D_ARRAY, 
	TextureRectangle = GL_TEXTURE_RECTANGLE, 
	TextureCubeMap = GL_TEXTURE_CUBE_MAP, 
	TextureCubeMapArray = GL_TEXTURE_CUBE_MAP_ARRAY, 
	TextureBuffer = GL_TEXTURE_BUFFER, 
	Texture2DMultisample = GL_TEXTURE_2D_MULTISAMPLE,
	Texture2DMultisampleArray = GL_TEXTURE_2D_MULTISAMPLE_ARRAY,
	
	//~ CubeMapPositiveX = GL_TEXTURE_CUBE_MAP_POSITIVE_X, 
	//~ CubeMapNegativeX = GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 
	//~ CubeMapPositiveY = GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 
	//~ CubeMapNegativeY = GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 
	//~ CubeMapPositiveZ = GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 
	//~ CubeMapNegativeZ = GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 
}


//==============================================================================
static struct TextureUnit(size_t locationIdx, TextureTarget textureTarget) {
    @disable this();
    @disable this(this); 
public:	
	static void makeActive() {
		check!glActiveTexture(GL_TEXTURE0 + locationIdx);
	}

	static void bindTexture(Texture texture) { 
		glBindTexture(textureTarget, texture._id);
	}
    
    static void unbindTexture() { 
		glBindTexture(textureTarget, 0);
	}
	
public:
	version(OpenGL4) {
        @property void depthStencilTextureMode(StencilTextureMode opt) {
            glTexParameteri(textureTarget, GL_DEPTH_STENCIL_TEXTURE_MODE, opt); 
        }
        
        @property StencilTextureMode depthStencilTextureMode(Target target) {             
            StencilTextureMode opt;
            glGetTexParameteri(textureTarget, GL_DEPTH_STENCIL_TEXTURE_MODE, &opt); 
            return opt;
        }
    }
    
    @property void baseLevel(int opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_BASE_LEVEL, opt); 
    }
	
    @property int baseLevel() {
        int opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_BASE_LEVEL, &opt); 
        return opt;
    }
     
    @property void borderColor(Color color) {
        glTexParameterfv(textureTarget, GL_TEXTURE_BORDER_COLOR, color.data.ptr);
    }
	
    @property Color borderColor() {
        Color color;
        glGetTexParameterfv(textureTarget, GL_TEXTURE_BORDER_COLOR, color.data.ptr);
        return color;
    }
    
    @property void compareFunction(CompareFunction opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_COMPARE_FUNC, opt); 
    }
	
    @property CompareFunction compareFunction() {
        CompareFunction opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_COMPARE_FUNC, cast(int*)&opt); 
        return opt;
    }
    
    @property void compareMode(CompareMode opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_COMPARE_MODE, opt); 
    }
	
    @property int compareMode() {
        CompareMode opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_COMPARE_MODE, cast(int*)&opt); 
        return opt;
    }
    
    @property void lodBias(float opt) {
        glTexParameterf(textureTarget, GL_TEXTURE_LOD_BIAS, opt);    
    }
	
    @property float lodBias() {
        float opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_LOD_BIAS, cast(int*)&opt); 
        return opt;
    }

    @property void minFilter(MinFilter opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_MIN_FILTER, opt);    
    }
	
    @property MinFilter minFilter() {
        MinFilter opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_MIN_FILTER, cast(int*)&opt); 
        return opt;
    }
    
    @property void magFilter(MagFilter opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_MAG_FILTER, opt);    
    }
	
    @property MagFilter magFilter() {
        MagFilter opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_MAG_FILTER, cast(int*)&opt); 
        return opt;
    }
    
    @property void minLod(int opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_MIN_LOD, opt);    
    }
	
    @property int minLod() {
        int opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_MIN_LOD, cast(int*)&opt); 
        return opt;
    }
    
    @property void maxLod(int opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_MAX_LOD, opt);    
    }
	
    @property int maxLod() {
        int opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_MAX_LOD, cast(int*)&opt); 
        return opt;
    }
    
    @property void maxLevel(int opt) {
        glTexParameteri(textureTarget, GL_TEXTURE_MAX_LEVEL, opt);    
    }
	
    @property int maxLevel() {
        int opt;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_MAX_LEVEL, cast(int*)&opt); 
        return opt;
    }
    
    void setSwizzle(Swizzle r, Swizzle g, Swizzle b, Swizzle a) {
        glTexParameteri(textureTarget, GL_TEXTURE_SWIZZLE_R, r); 
        glTexParameteri(textureTarget, GL_TEXTURE_SWIZZLE_G, g); 
        glTexParameteri(textureTarget, GL_TEXTURE_SWIZZLE_B, b); 
        glTexParameteri(textureTarget, GL_TEXTURE_SWIZZLE_A, a);    
    }
	
    void getSwizzle(out Swizzle r, out Swizzle g, out Swizzle b, out Swizzle a) {
        glGetTexParameteriv(textureTarget, GL_TEXTURE_SWIZZLE_R, cast(int*)&r);
        glGetTexParameteriv(textureTarget, GL_TEXTURE_SWIZZLE_G, cast(int*)&g);
        glGetTexParameteriv(textureTarget, GL_TEXTURE_SWIZZLE_B, cast(int*)&b);
        glGetTexParameteriv(textureTarget, GL_TEXTURE_SWIZZLE_A, cast(int*)&a);
    }
    @property void swizzle(Swizzle rgba) {
        glTexParameteri(textureTarget, GL_TEXTURE_SWIZZLE_RGBA, rgba);    
    }
	
    @property Swizzle swizzle() {
        Swizzle rgba;
        glGetTexParameteriv(textureTarget, GL_TEXTURE_SWIZZLE_R, cast(int*)&rgba);
        return rgba;
    }
    
    void setWrap(Wrap s, Wrap t, Wrap r) {
        glTexParameteri(textureTarget, GL_TEXTURE_WRAP_S, s); 
        glTexParameteri(textureTarget, GL_TEXTURE_WRAP_T, t); 
        glTexParameteri(textureTarget, GL_TEXTURE_WRAP_R, r);  
    }
	
    void getWrap(out Wrap s, out Wrap t, out Wrap r) {
        glGetTexParameteriv(textureTarget, GL_TEXTURE_WRAP_S, cast(int*)&s);
        glGetTexParameteriv(textureTarget, GL_TEXTURE_WRAP_T, cast(int*)&t);
        glGetTexParameteriv(textureTarget, GL_TEXTURE_WRAP_R, cast(int*)&r);
    }
}





private void _isTextureUnit(T...)(TextureUnit!(T) t) {}
enum isTextureUnit(T) = is(typeof(_isTextureUnit(T.init)));









//==============================================================================
version(OpenGL4){
    enum StencilTextureMode : GLenum {
        DepthComponent = GL_DEPTH_COMPONENT,
        //TODO: StencilComponent = GL_STENCIL_COMPONENT
    }
}

//==============================================================================
enum CompareFunction : GLenum {
    LessOrEqual = GL_LEQUAL,
    GreaterOrEqual = GL_GEQUAL,
    Less = GL_LESS,
    Greater = GL_GREATER,
    Equal = GL_EQUAL,
    NotEqual = GL_NOTEQUAL,
    Always = GL_ALWAYS,
    Never = GL_NEVER       
}

//==============================================================================
enum CompareMode : GLenum {
    CompareRefToTexture = GL_COMPARE_REF_TO_TEXTURE,
    None = GL_NONE
}

//==============================================================================
enum MinFilter : GLenum {
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR,
    NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
    LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
    NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,
    LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR        
}

//==============================================================================
enum MagFilter : GLenum {
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR     
}

//==============================================================================
enum Swizzle : GLenum {
    Red = GL_RED, 
    Green = GL_GREEN, 
    Blue = GL_BLUE, 
    Alpha = GL_ALPHA, 
    Zero = GL_ZERO,
    One = GL_ONE
}

//==============================================================================
enum Wrap : GLenum {
    ClampToEdge = GL_CLAMP_TO_EDGE, 
    ClampToBorder = GL_CLAMP_TO_BORDER, 
    MirroredRepeat = GL_MIRRORED_REPEAT,
    Repeat = GL_REPEAT
}



//==============================================================================
enum TextureFormat : GLenum {
	Red = GL_RED,
	RG = GL_RG,
	RBG = GL_RGB,
	BGR = GL_BGR,
	RGBA = GL_RGBA,
	BGRA = GL_BGRA,
	DepthComponent = GL_DEPTH_COMPONENT,
	StencilIndex = GL_STENCIL_INDEX,
}

//==============================================================================
enum TextureType : GLenum {
	UByte = GL_UNSIGNED_BYTE, 
	Byte = GL_BYTE,
	UShort = GL_UNSIGNED_SHORT, 
	Short = GL_SHORT, 
	UInt = GL_UNSIGNED_INT, 
	Int = GL_INT, 
	Float = GL_FLOAT, 
	//GL_UNSIGNED_BYTE_3_3_2, 
	//GL_UNSIGNED_BYTE_2_3_3_REV, 
	//GL_UNSIGNED_SHORT_5_6_5, 
	//GL_UNSIGNED_SHORT_5_6_5_REV, 
	//GL_UNSIGNED_SHORT_4_4_4_4, 
	//GL_UNSIGNED_SHORT_4_4_4_4_REV, 
	//GL_UNSIGNED_SHORT_5_5_5_1, 
	//GL_UNSIGNED_SHORT_1_5_5_5_REV, 
	//GL_UNSIGNED_INT_8_8_8_8, 
	//GL_UNSIGNED_INT_8_8_8_8_REV, 
	//GL_UNSIGNED_INT_10_10_10_2, 
	//GL_UNSIGNED_INT_2_10_10_10_REV,
}


//==============================================================================
///
final class Texture(TextureFormat FORMAT, TextureType TYPE) {
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
	@property bool isValid() const @safe nothrow {
		return (this._id > 0);
	}
}


private void _isTexture(T...)(Texture!(T) t) {}
enum isTexture(T) = is(typeof(_isTexture(T.init)));
