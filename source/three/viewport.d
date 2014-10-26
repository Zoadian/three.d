module three.viewport;

import three.common;

struct Viewport {
}

void construct(out Viewport viewport) pure @safe nothrow @nogc {
}

void destruct(ref Viewport viewport) pure @safe nothrow @nogc {
	viewport = Viewport.init;
}