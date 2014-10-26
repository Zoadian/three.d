module three.renderTarget;

import three.common;

struct RenderTarget {
	uint width;
	uint height;
	GLuint textureTarget;
}

void construct(out RenderTarget renderTarget, uint width, uint height) nothrow {
	renderTarget.width = width;
	renderTarget.height = height;
	glCheck!glGenTextures(1, &renderTarget.textureTarget);
	glCheck!glBindTexture(GL_TEXTURE_2D, renderTarget.textureTarget);
	glCheck!glTexStorage2D(GL_TEXTURE_2D, 1, GL_RGBA32F, width, height);
	glCheck!glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_RGBA, GL_FLOAT, null);	
	glCheck!glBindTexture(GL_TEXTURE_2D, 0);
}

void destruct(ref RenderTarget renderTarget) nothrow {
	glCheck!glDeleteTextures(1, &renderTarget.textureTarget);
	renderTarget = RenderTarget.init;
}