module three.mesh;

import three.common;



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

struct MeshData {
	VertexData[] vertexData;
	IndexData[] indexData;
}

struct ModelData {
	MeshData[] meshData;
}

ModelData loadModelData(string filePath) {
	import std.traits;
	import std.string : toStringz;
	auto scene = aiImportFile(filePath.toStringz(),	aiProcess_Triangulate); scope(exit) aiReleaseImport(scene);

	ModelData modelData;
	modelData.meshData.length = scene.mNumMeshes;

	for(uint m = 0; m < scene.mNumMeshes; ++m) {	
		const(aiMesh*) meshData = scene.mMeshes[m];
		assert(meshData !is null);

		size_t cntIndices = 0;
		foreach(f; 0..meshData.mNumFaces) {
			cntIndices += meshData.mFaces[f].mNumIndices;
		}

		modelData.meshData[m].vertexData.length = meshData.mNumVertices;
		modelData.meshData[m].indexData.length = cntIndices;

		foreach(v; 0..meshData.mNumVertices) {
			modelData.meshData[m].vertexData[v].position = Position(meshData.mVertices[v].x, meshData.mVertices[v].y, meshData.mVertices[v].z);

			modelData.meshData[m].vertexData[v].normal = Normal(meshData.mNormals[v].x, meshData.mNormals[v].y, meshData.mNormals[v].z);

			if(meshData.mColors[0] !is null) {
				modelData.meshData[m].vertexData[v].color = Color(meshData.mColors[0][v].r, meshData.mColors[0][v].g, meshData.mColors[0][v].b, meshData.mColors[0][v].a);
			}
			else {
				modelData.meshData[m].vertexData[v].color = Color(0, 0, 0, 1);
			}

			if(meshData.mTextureCoords[0] !is null) {
				modelData.meshData[m].vertexData[v].textureCoordinate = TextureCoordinate(meshData.mTextureCoords[0][v].x, meshData.mTextureCoords[0][v].y);
			}
			else {
				modelData.meshData[m].vertexData[v].textureCoordinate = TextureCoordinate(0, 0);
			}
		}

		size_t curIndexDataIdx = 0;
		foreach(f; 0..meshData.mNumFaces) {
			assert(meshData.mFaces !is null);
			foreach(i; 0..meshData.mFaces[f].mNumIndices) {
				assert(meshData.mFaces[f].mIndices !is null);
				modelData.meshData[m].indexData[curIndexDataIdx++] = meshData.mFaces[f].mIndices[i];		
			}
		}
	}
	return modelData;
}
