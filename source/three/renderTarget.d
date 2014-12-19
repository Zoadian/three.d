module three.renderTarget;

import three.gl.util;

struct RenderTarget {
	uint width;
	uint height;
	GLuint textureTarget;

	void construct(uint width, uint height) nothrow {
		this.width = width;
		this.height = height;
		glCheck!glGenTextures(1, &this.textureTarget);
		glCheck!glBindTexture(GL_TEXTURE_2D, this.textureTarget);
		glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA32F, width, height);
		glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
		glCheck!glBindTexture(GL_TEXTURE_2D, 0);
	}
	
	void destruct() nothrow {
		glCheck!glDeleteTextures(1, &this.textureTarget);
	}
}
