// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module aurora.primitives.rect;

import aurora.primitives.point;

import std.traits;

/**
	+-------->   x
	|
	|
	|
	|
	v
	
	y
	
*/
struct Rect2(T) if(isNumeric!T) {
private:
	T[4] data; //l,t,r,b

public:	
	///
	T x() const @safe nothrow @property {
		return this.left;
	}
	
	///
	T y() const @safe nothrow @property {
		return this.top;
	}
	
public:	
	///
	T left() const @safe nothrow @property {
		return data[0];
	}
	
	///
	T top() const @safe nothrow @property {
		return data[1];
	}
	
	///
	T right() const @safe nothrow @property {
		return data[2];
	}	
	
	///
	T bottom() const @safe nothrow @property {
		return data[3];
	}
	
public:	
	///
	T width() const @safe nothrow @property { 
		return this.right - this.left;
	}
	
	///
	T height() const @safe nothrow @property { 
		return this.bottom - this.top;
	}
	
public:	
	///
	Point!(2,T) center() const @safe nothrow @property {
		return Point!(2,T)(this.x + this.width / 2, this.y + this.height / 2);
	}		
	
	///
	Point!(2,T) leftTop() const @safe nothrow @property {
		return Point!(2,T)(this.left, this.top);
	}
	
	///
	Point!(2,T) rightTop() const @safe nothrow @property {
		return Point!(2,T)(this.right, this.top);
	}	
	
	///
	Point!(2,T) rightBottom() const @safe nothrow @property {
		return Point!(2,T)(this.right, this.bottom);
	}	
	
	///
	Point!(2,T) leftBottom() const @safe nothrow @property {
		return Point!(2,T)(this.left, this.bottom);
	}	
}


///
struct RectOffset2(T) if(isNumeric!T) {
private:
	T[4] data; //l,t,r,b
	
public:	
	///
	T left() const @safe nothrow @property {
		return data[0];
	}
	
	///
	T top() const @safe nothrow @property {
		return data[1];
	}
	
	///
	T right() const @safe nothrow @property {
		return data[2];
	}	
	
	///
	T bottom() const @safe nothrow @property {
		return data[3];
	}
	
public:	
	/// equal to left + right
	T horizontal() const @safe nothrow @property {
		return this.left + this.right;
	}
	
	/// equal to top + bottom
	T vertical() const @safe nothrow @property {
		return this.top + this.bottom;
	}	
}