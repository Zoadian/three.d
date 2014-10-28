module three.mesh;

import three.common;

struct SOAMesh {
	SoA!GLuint vao;
	SoA!GLuint vboVertices;
	SoA!GLuint vboNormals;
	SoA!GLuint vboTexcoords;
	SoA!GLuint vboColors;
	SoA!GLuint vboIndices;
	SoA!GLuint cntIndices;
	size_t cnt;
}

void loadModel(ref SOAMesh mesh, string filePath) {
	import std.traits;
	import std.string : toStringz;
	auto scene = aiImportFile(filePath.toStringz(),	aiProcess_Triangulate); scope(exit) aiReleaseImport(scene);
	
	for(uint m = 0; m < scene.mNumMeshes; ++m) {	
		const(aiMesh*) meshData = scene.mMeshes[m];
		assert(meshData !is null);
		
		//-----------------------------
		// create mesh
		auto meshIdx = mesh.cnt;
		++mesh.cnt;
		mesh.vao.length = mesh.cnt;
		mesh.vboVertices.length = mesh.cnt;
		mesh.vboNormals.length = mesh.cnt;
		mesh.vboTexcoords.length = mesh.cnt;
		mesh.vboIndices.length = mesh.cnt;
		mesh.cntIndices.length = mesh.cnt;
		
		//-----------------------------
		// upload data
		glCheck!glGenVertexArrays(1, &mesh.vao[meshIdx]);
		glCheck!glBindVertexArray(mesh.vao[meshIdx]); scope(exit) glCheck!glBindVertexArray(0);
		
		alias Vertex = float[3];
		alias Normal = float[3];
		alias TexCoord = float[2];
		alias Color = float[4];
		alias Index = uint[1];

		size_t cntIndices = 0;
		foreach(f; 0..meshData.mNumFaces) {
			cntIndices += meshData.mFaces[f].mNumIndices;				
		}
		mesh.cntIndices[meshIdx] = cntIndices;
		
		{// upload vertex data
			Vertex[] vertexData;
			vertexData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				vertexData[v] = [meshData.mVertices[v].x, meshData.mVertices[v].y, meshData.mVertices[v].z];
			}
			glCheck!glGenBuffers(1, &mesh.vboVertices[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboVertices[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 0;
			glCheck!glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Vertex.sizeof * vertexData.length) , vertexData.ptr, GL_STATIC_DRAW);		
			glCheck!glEnableVertexAttribArray(attribIndex);
			glCheck!glVertexAttribPointer(attribIndex, Vertex.sizeof / ForeachType!Vertex.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}
		
		{// upload normal data
			Normal[] normalData;
			normalData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				normalData[v] = [meshData.mNormals[v].x, meshData.mNormals[v].y, meshData.mNormals[v].z];
			}
			glCheck!glGenBuffers(1, &mesh.vboNormals[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboNormals[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 1;
			glCheck!glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Normal.sizeof * normalData.length) , normalData.ptr, GL_STATIC_DRAW);		
			glCheck!glEnableVertexAttribArray(attribIndex);
			glCheck!glVertexAttribPointer(attribIndex, Normal.sizeof / ForeachType!Normal.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}
		
		if(meshData.mTextureCoords[0] !is null) {// upload texture data
			TexCoord[] textureData;
			textureData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				textureData[v] = [meshData.mTextureCoords[0][v].x, meshData.mTextureCoords[0][v].y];
			}
			glCheck!glGenBuffers(1, &mesh.vboTexcoords[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboTexcoords[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 2;
			glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(TexCoord.sizeof * textureData.length) , textureData.ptr, GL_STATIC_DRAW);		
			glEnableVertexAttribArray(attribIndex);
			glVertexAttribPointer(attribIndex, TexCoord.sizeof / ForeachType!TexCoord.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}
		
		if(meshData.mColors[0] !is null) {// upload color data
			Color[] colorData;
			colorData.length = meshData.mNumVertices;
			foreach(v; 0..meshData.mNumVertices) {
				colorData[v] = [meshData.mColors[0][v].r, meshData.mColors[0][v].g, meshData.mColors[0][v].b, meshData.mColors[0][v].a];
			}
			glCheck!glGenBuffers(1, &mesh.vboTexcoords[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboTexcoords[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 2;
			glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Color.sizeof * colorData.length) , colorData.ptr, GL_STATIC_DRAW);		
			glEnableVertexAttribArray(attribIndex);
			glVertexAttribPointer(attribIndex, Color.sizeof / ForeachType!Color.sizeof, GL_FLOAT, GL_FALSE, 0, cast(void*)0);
		}
		
		{// upload index data
			Index[] indexData;
			indexData.length = cntIndices;
			size_t curIndexDataIdx = 0;
			foreach(f; 0..meshData.mNumFaces) {
				assert(meshData.mFaces !is null);
				foreach(i; 0..meshData.mFaces[f].mNumIndices) {
					assert(meshData.mFaces[f].mIndices !is null);
					indexData[curIndexDataIdx++] = meshData.mFaces[f].mIndices[i];		
				}
			}
			glCheck!glGenBuffers(1, &mesh.vboIndices[meshIdx]);
			glCheck!glBindBuffer(GL_ARRAY_BUFFER, mesh.vboIndices[meshIdx]); scope(exit) glCheck!glBindBuffer(GL_ARRAY_BUFFER, 0); 
			GLuint attribIndex = 3;
			glCheck!glBufferData(GL_ARRAY_BUFFER, cast(ptrdiff_t)(Index.sizeof * indexData.length) , indexData.ptr, GL_STATIC_DRAW);		
			glCheck!glEnableVertexAttribArray(attribIndex);
			glCheck!glVertexAttribPointer(attribIndex, Index.sizeof / ForeachType!Index.sizeof, GL_UNSIGNED_INT, GL_FALSE, 0, cast(void*)0);
		}
	}
}