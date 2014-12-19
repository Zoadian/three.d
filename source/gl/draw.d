module three.gl.draw;

import three.common;
import three.mesh;

struct GlDrawElementsIndirectCommand {
	GLuint count;
	GLuint instanceCount;
	GLuint firstIndex;
	GLuint baseVertex;
	GLuint baseInstance;
}

struct GlDrawParameter {
	Matrix4 transformationMatrix;
}