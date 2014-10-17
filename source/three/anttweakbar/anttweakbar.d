module three.anttweakbar.anttweakbar;

import derelict.anttweakbar.anttweakbar;

import std.string;
import std.stdio;

import three.primitives;


template toAntTweakBarType(T) {
	static if(is(T == bool)) {
		alias toAntTweakBarType = TW_TYPE_BOOLCPP;
	}
	else static if(is(T == byte)) {
		alias toAntTweakBarType = TW_TYPE_INT8;
	}
	else static if(is(T == short)) {
		alias toAntTweakBarType = TW_TYPE_INT16;
	}
	else static if(is(T == int)) {
		alias toAntTweakBarType = TW_TYPE_INT32;
	}
	else static if(is(T == ubyte)) {
		alias toAntTweakBarType = TW_TYPE_UINT8;
	}
	else static if(is(T == ushort)) {
		alias toAntTweakBarType = TW_TYPE_UINT16;
	}
	else static if(is(T == uint)) {
		alias toAntTweakBarType = TW_TYPE_UINT32;
	}
	else static if(is(T == float)) {
		alias toAntTweakBarType = TW_TYPE_FLOAT;
	}
	else static if(is(T == double)) {
		alias toAntTweakBarType = TW_TYPE_DOUBLE;
	}
	else static if(is(T == Vector3f)) {
		alias toAntTweakBarType = TW_TYPE_DIR3D;
	}
	else static if(is(T == Quaternionf)) {
		alias toAntTweakBarType = TW_TYPE_QUAT4F;
	}
	else static assert(false, "no type convertion possible");
}


final class TweakBar {
private:
	TwBar* _handle;
	
public:	   
	///
	this(string name) {
		this._handle = TwNewBar(name.toStringz());
		writeln("TweakBar created: ", this._handle);
	}
	
	///
	~this() {
		TwDeleteBar(this._handle);
		writeln("TweakBar destroyed: ", this._handle);
	}

public:
	void addVarRW(T)(string name, string def, ref T t) {
		TwAddVarRW(this._handle, name.toStringz(), toAntTweakBarType!T, &t, def.toStringz());
	}
		
public:	  
	///
	@property bool isValid() const @safe nothrow {
		return (this._handle != null);
	}
}