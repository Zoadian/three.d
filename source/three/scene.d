module three.scene;

import three.common;
import three.mesh;

struct Scene {
	SOAMesh mesh;
}

void construct(out Scene scene) pure @safe nothrow @nogc {
}

void destruct(ref Scene scene) pure @safe nothrow @nogc {
	scene = Scene.init;
}