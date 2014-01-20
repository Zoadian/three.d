// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.primitives.point;

import std.traits;

struct Vector(size_t D, T) if(D > 0 && isNumeric!T) {
public:
	T[D] data;
	
	alias data this;
	
	static if(D >= 1) {
		T x() @safe @property const {
			return data[0];
		}
		
		void x(T t) @safe @property {
			data[0] = t;
		}
	}
	
	static if(D >= 2) {
		T y() @safe @property const {
			return data[1];
		}
		
		void y(T t) @safe @property {
			data[1] = t;
		}
	}
	
	static if(D >= 3) {
		T z() @safe @property const {
			return data[2];
		}
		
		void z(T t) @safe @property {
			data[2] = t;
		}
	}
}

alias Vector2f = Vector!(2, float);
alias Vector3f = Vector!(3, float);

alias Point2f = Vector2f;
alias Point3f = Vector3f;
