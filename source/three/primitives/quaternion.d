module three.primitives.quaternion;

import std.traits;

struct Quaternion(T) if(isFloatingPoint!T) {
	float x, y, z, w;
}

alias Quaternionf = Quaternion!(float);