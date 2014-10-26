module three.camera;

import three.common;

struct Camera {
}

void construct(out Camera camera) pure @safe nothrow @nogc {
}

void destruct(ref Camera camera) pure @safe nothrow @nogc {
	camera = Camera.init;
}