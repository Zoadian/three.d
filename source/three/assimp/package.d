// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/



module three.assimp;

import std.traits;


version(none){

Model loadModel(string filePath, Vec3f position = Vec3f(0,0,0), Vec3f scale = Vec3f(1,1,1), Quatf orientation = Quatf(0,0,0,1)) {
	if(!exists(filePath)) throw new Exception("File does not exist");
	try{			
		"loading model: ".writeln(filePath);
		auto scene = aiImportFile(filePath.toStringz(),	0
		                          //| aiPostProcessSteps.CalcTangentSpace
		                          //| aiPostProcessSteps.Triangulate
		                          //| aiPostProcessSteps.JoinIdenticalVertices
		                          //| aiPostProcessSteps.GenNormals
		                          //| aiPostProcessSteps.FlipWindingOrder
		                          //| aiPostProcessSteps.SortByPType
		                          );
		
		Mesh[] meshes;	
		
		for(uint k = 0; k < scene.mNumMeshes; ++k) {  
			
			"mesh".writeln();
			const(aiMesh*) mesh = scene.mMeshes[k];
			assert(mesh !is null);
			float[] vertexData;
			
			for (uint t = 0; t < mesh.mNumFaces; ++t) {	 
				//"face".writeln();
				const(aiFace*) face = &mesh.mFaces[t];
				assert(face !is null);
				for(uint v = 0; v < 3; ++v) {  
					//"a".writeln();
					aiVector3D p, n, uv;  
					assert(face.mNumIndices > v);
					uint vertex = face.mIndices[v];
					assert(mesh.mNumVertices > vertex);
					p = mesh.mVertices[vertex];
					n = mesh.mNormals[vertex];	              
					
					// check if the mesh has texture coordinates
					if(mesh.mTextureCoords[0] !is null) {
						uv = mesh.mTextureCoords[0][vertex];
					}
					
					//TODO: speed this up!
					vertexData ~= [p.x, p.y, p.z, n.x, n.y, n.z, uv.x, uv.y, 1.0f, 1.0f, 1.0f];
				}
			}
			
			"genvdata".writeln();
			//alias VertexData!(VertexBufferObject!(BufferTarget.Array, VTX_POSITION, VTX_NORMAL, VTX_TEXCOORD, VTX_COLOR)) AssimpVertexData;
			//meshes ~= new VertexMesh!(AssimpVertexData)(vertexData, mesh.mNumFaces);
		}
		
		
		"release".writeln();
		aiReleaseImport(scene);
		"loaded".writeln();
		return new Model(position, scale, orientation, meshes);	 
	}catch(Exception e)
	{
		assert(0);
	}
}
}
