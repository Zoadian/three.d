module three.gl.draw;

public import derelict.opengl3.gl3;
import three.mesh;

struct GlDrawCommand {
	GLuint vertexCount;
	GLuint instanceCount;
	GLuint firstIndex;
	GLuint baseVertex;
	GLuint baseInstance;
}

struct GlDrawParameter {
	Matrix4 transformationMatrix;
}

struct Position {
	float x, y, z;
}

struct Normal {
	float x, y, z;
}

struct Color {
	float r, g, b, a;
}

struct TextureCoordinate {
	float u, v;
}

struct Matrix4 {
	float[4*4] data;
}

struct VertexData {
	Position position;
	Normal normal;
	Color color;
	TextureCoordinate textureCoordinate;
}

alias IndexData = uint;
