module three.scene;

public import derelict.assimp3.assimp;

public import std.experimental.logger;

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

struct VertexData {
	Position position;
	Normal normal;
	Color color;
	TextureCoordinate textureCoordinate;
}

alias IndexData = uint;

struct MeshDescriptor {
	size_t vertexOffset;
	size_t vertexCount;
	size_t indexOffset;
	size_t indexCount;
}

struct ModelDescriptor {
	size_t meshDescriptorOffset;
	size_t meshDescriptorCount;
}

struct Scene {
	//TODO: use page allocator
	VertexData[] vertexData; 
	IndexData[] indexData;
	MeshDescriptor[] meshDescriptors;
	ModelDescriptor[] modelDescriptors;

public:
	void construct() pure @safe nothrow @nogc {
	}
	
	void destruct() pure @safe nothrow @nogc {
	}

public:
	size_t vertexCount() @property {
		return vertexData.length;
	}

	size_t indexCount() @property {
		return indexData.length;
	}
	
	size_t meshCount() @property {
		return meshDescriptors.length;
	}

	size_t modelCount() @property {
		return modelDescriptors.length;
	}

public:
	void loadModel(string filePath) {
		import std.traits;
		import std.string : toStringz;
		auto importedScene = aiImportFile(filePath.toStringz(), aiProcess_Triangulate); scope(exit) aiReleaseImport(importedScene);

		this.modelDescriptors ~= ModelDescriptor(this.meshCount, importedScene.mNumMeshes);
		
		for(uint m = 0; m < importedScene.mNumMeshes; ++m) {	
			const(aiMesh*) meshData = importedScene.mMeshes[m];
			assert(meshData !is null);
			
			size_t numIndices = 0;
			foreach(f; 0..meshData.mNumFaces) {
				numIndices += meshData.mFaces[f].mNumIndices;
			}

			this.meshDescriptors ~= MeshDescriptor(this.vertexCount, meshData.mNumVertices, this.indexCount, numIndices);

			foreach(v; 0..meshData.mNumVertices) {
				this.vertexData ~= VertexData(
					Position(meshData.mVertices[v].x, meshData.mVertices[v].y, meshData.mVertices[v].z),
					Normal(meshData.mNormals[v].x, meshData.mNormals[v].y, meshData.mNormals[v].z),
					(meshData.mColors[0] !is null) ? Color(meshData.mColors[0][v].r, meshData.mColors[0][v].g, meshData.mColors[0][v].b, meshData.mColors[0][v].a) : Color(0, 0, 0, 1),
					(meshData.mTextureCoords[0] !is null) ? TextureCoordinate(meshData.mTextureCoords[0][v].x, meshData.mTextureCoords[0][v].y) : TextureCoordinate(0, 0)
				);
			}
			
			size_t curIndexDataIdx = 0;
			foreach(f; 0..meshData.mNumFaces) {
				assert(meshData.mFaces !is null);
				foreach(i; 0..meshData.mFaces[f].mNumIndices) {
					assert(meshData.mFaces[f].mIndices !is null);
					this.indexData ~= IndexData(meshData.mFaces[f].mIndices[i]);		
				}
			}
		}
	}
}











version(none) {

struct Scene {
	ModelData modelData;
	
	void construct() pure @safe nothrow @nogc {
	}
	
	void destruct() pure @safe nothrow @nogc {
	}
}

struct MeshData {
	VertexData[] vertexData;
	IndexData[] indexData;
}

struct ModelData {
	string filePath;
	MeshData[] meshData;

	size_t vertexCount() const @safe {
		import std.algorithm : map, reduce;

		return meshData.length == 0 ? 0 : meshData.map!("a.vertexData.length").reduce!("a + b");
	}
	
	size_t indexCount() const @safe {
		import std.algorithm : map, reduce;
		return meshData.length == 0 ? 0 : meshData.map!("a.indexData.length").reduce!("a + b");
	}

	size_t meshCount() const @safe {
		return meshData.length;
	}
}

//ModelData createCubeModel() {
//}

ModelData loadModelData(string filePath) {
	import std.traits;
	import std.string : toStringz;
	auto scene = aiImportFile(filePath.toStringz(),	aiProcess_Triangulate); scope(exit) aiReleaseImport(scene);

	ModelData modelData;
	modelData.filePath = filePath;
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
}