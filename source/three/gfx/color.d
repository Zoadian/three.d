// Written in the D programming language.
/**						   
Copyright: Copyright Felix 'Zoadian' Hufnagel 2014-.

License:   $(WEB http://www.gnu.org/licenses/lgpl.html, LGPLv3).

Authors:   $(WEB zoadian.de, Felix 'Zoadian' Hufnagel)
*/
module three.gfx.color;

import std.typecons;
import std.typetuple;
import std.conv;

struct RedColorComponent(T) { T r; alias r this; }
struct GreenColorComponent(T) { T g; alias g this; }
struct BlueColorComponent(T) { T b; alias b this; }
struct AlphaColorComponent(T) { T a; alias a this; }

///
enum isRedColorComponent(T) = is(typeof(_isRedColorComponent(T.init)));
private void _isRedColorComponent(T)(RedColorComponent!(T) t) {}
///
enum isGreenColorComponent(T) = is(typeof(_isGreenColorComponent(T.init)));
private void _isGreenColorComponent(T)(GreenColorComponent!(T) t) {}
///
enum isBlueColorComponent(T) = is(typeof(_isBlueColorComponent(T.init)));
private void _isBlueColorComponent(T)(BlueColorComponent!(T) t) {}	
///
enum isAlphaColorComponent(T) = is(typeof(_isAlphaColorComponent(T.init)));
private void _isAlphaColorComponent(T)(AlphaColorComponent!(T) t) {}

enum isRGBColorComponent(T) = isRedColorComponent!T || isGreenColorComponent!T || isBlueColorComponent!T;
enum isRGBAColorComponent(T) = isRGBColorComponent!T || isAlphaColorComponent!T;

enum hasRedColorComponent(T...) = anySatisfy!(isRedColorComponent, T);
enum hasGreenColorComponent(T...) = anySatisfy!(isGreenColorComponent, T);
enum hasBlueColorComponent(T...) = anySatisfy!(isBlueColorComponent, T);
enum hasAlphaColorComponent(T...) = anySatisfy!(isAlphaColorComponent, T);

enum isRGB(T...) = T.length == 3 && isRedColorComponent!(T[0]) && isGreenColorComponent!(T[1]) && isBlueColorComponent!(T[2]);  
enum isRGBA(T...) = T.length == 4 && isRGB!(T[0..3]) && isAlphaColorComponent!(T[3]);
enum isARGB(T...) = T.length == 4 && isAlphaColorComponent!(T[3]) && isRGB!(T[0..3]);

enum isBGR(T...) = T.length == 3 && isBlueColorComponent!(T[0]) && isGreenColorComponent!(T[1]) && isRedColorComponent!(T[2]);  
enum isBGRA(T...) = T.length == 4 && isBGR!(T[0..3]) && isAlphaColorComponent!(T[3]);
enum isABGR(T...) = T.length == 4 && isAlphaColorComponent!(T[3]) && isBGR!(T[0..3]);
																 
alias RGB(T) = TypeTuple!(RedColorComponent!T, GreenColorComponent!T, BlueColorComponent!T);						   
alias RGBA(T) = TypeTuple!(RGB!T, AlphaColorComponent!T);
alias ARGB(T) = TypeTuple!(AlphaColorComponent!T, RGB!T);
																	
alias BGR(T) = TypeTuple!(BlueColorComponent!T, GreenColorComponent!T, RedColorComponent!T);						   
alias BGRA(T) = TypeTuple!(BGR!T, AlphaColorComponent!T);
alias ABGR(T) = TypeTuple!(AlphaColorComponent!T, BGR!T);


enum isValidColorComponentDefinition(T...) = allSatisfy!(isRGBAColorComponent, T) && NoDuplicates!(T).length == T.length;

static assert(isValidColorComponentDefinition!(RGBA!float));

private string _genMembers(size_t IDX, N...)() {
	string ret;
	foreach(K; N) {
		ret ~= "alias " ~ K ~ " = _components[" ~ to!string(IDX-1) ~ "];\n";	  
	}
	return ret;
}		

private mixin template _GenAccessors(size_t IDX, T...) {
	static if(T.length == 1) {
		mixin(_genMembers!(IDX, __traits(allMembers, T[0]))());
	}
	else {					
		mixin _GenAccessors!(IDX+1, T[0]);	
		mixin _GenAccessors!(IDX+1, T[1..$]);	
	}
}

struct Color(COMPONENTS...) if (isValidColorComponentDefinition!COMPONENTS) {
	COMPONENTS _components;		
	mixin _GenAccessors!(0, COMPONENTS);  
}
