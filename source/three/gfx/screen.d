module three.gfx.scene;

/+++

struct PositionGraph {
	struct InternalId {
		uint id;

		this(size_t depth, size_t position) {
			id = (depth & 0x000000ff) | (position << 8);
		}

		size_t depth() {
			return id & 0x000000ff;
		}

		size_t position() {
			return (id & 0xffffff00) >>> 8;
		}
	}

	enum initialDepth = 5;

	InternalId[Entity] _internalMapping; //fast entity -> component lookup
	SoAEntity[] _entity = new SoAEntity[initialDepth]; //fast component -> entity lookup
	SoAVec3[] _position = new SoAVec3[initialDepth];

	void createRootNode(Entity entity, Position position) {
		_appendNode(0, entity, position);
	}

	void createChildNode(Entity parent, Entity entity, Position position) {
		auto p = parent in _internalMapping;
		if(p is null) {
			//TODO: if not in there?
		}
		auto depth = p.depth + 1;
		// increase depth array if not large enouth
		if(_entity.length < depth) {
			_entity.length = depth;
		}
		// assign values
		append(depth, entity, position);
	}

private:
	void _appendNode(size_t depth, Entity entity, Position position) {
		_entity[depth].append(entity);
		_position[depth].x.append(position.x);
		_position[depth].y.append(position.y);
		_position[depth].z.append(position.z);
		_internalMapping[entity] = InternalId(depth, _entity[depth].length];
	}
}




struct SoAEntity() {
	Entity[] entity;
}

struct SoAVec3() {
	float[] x;
	float[] y;
	float[] z;
}

struct SoAQuat() {
	float[] x;
	float[] y;
	float[] z;
	float[] w;
}

struct LocalTransformCM {
private:
	size_t _length = 0;
	size_t _capacity = 0;
	ubyte* _data;

	mixin Vec3 _position;
	mixin Quat _orientation;
	mixin Vec3 _scale;
	//~ mixin Vec3 _velocity;
	//~ mixin Vec3 _acceleration;


}



class DebugNameCM {
	void setDebugName(Entity e, string name);
	string debugName(Entity e);
}



void vector(string op)(ref Vectors r, Vectors a, Vectors b) {
	mixin("r.x[] = a.x[]" ~ op ~ "b.x[];");
	mixin("r.y[] = a.y[]" ~ op ~ "b.y[];");
	mixin("r.z[] = a.z[]" ~ op ~ "b.z[];");
}

void quat_mul(ref Quaternions r, Quaternions a, Quaternions b) {
	r.x[] = a.w[] * b.x[] + a.x[] * b.w[] + b.y[] * b.z[] - a.z[] * b.y[];
	r.y[] = a.w[] * b.y[] - a.x[] * b.z[] + a.y[] * b.w[] + a.z[] * b.x[];
	r.z[] = a.w[] * b.z[] + a.x[] * b.y[] - a.y[] * b.x[] + a.z[] * b.w[];
	r.w[] = a.w[] * b.w[] - a.x[] * b.x[] - a.y[] * b.y[] - a.z[] * b.z[];
}

struct Positions {
	float[] x;
	float[] z;
	float[] x;
}

struct Orientations {
	float[] x;
	float[] z;
	float[] x;
	float[] w;
}

struct Scales {
	float[] x;
	float[] z;
	float[] x;
}

struct Position {
	float x;
	float z;
	float x;
}

struct Orientation {
	float x;
	float z;
	float x;
	float w;
}

struct Scale {
	float x;
	float z;
	float x;
}

struct Scene {
	Entity _entities;
	Positions _positions;
	Orientations _orientations;
	Scales _scales;
	int[] _parents;
	
	/// keep them sorted by tree depth, so we iterate the tree breath first when iterating the array
	void insert(Entity entity, int parent, Position position, Orientation orientation, Scale scale) {
		auto idx = parents.countUntil!(a=>a>b)(parent);
		if(idx == -1) { // insert at end
			_entities.append(entity);
			
			_parents.append(parent);
			
			_positions.x.append(position.x);
			_positions.y.append(position.y);
			_positions.z.append(position.z);
			
			_orientations.x.append(orientation.x);
			_orientations.y.append(orientation.y);
			_orientations.z.append(orientation.z);
			_orientations.w.append(orientation.w);
			
			_scales.x.append(scale.x);
			_scales.y.append(scale.y);
			_scales.z.append(scale.z);
		}
		else { // insert at idx and move all right of idx
			_entities.insertInPlace(idx, entity);
			
			_parents.insertInPlace(idx, parent);
			
			_positions.x.insertInPlace(idx, position.x);
			_positions.y.insertInPlace(idx, position.y);
			_positions.z.insertInPlace(idx, position.z);
			
			_orientations.x.insertInPlace(idx, orientation.x);
			_orientations.y.insertInPlace(idx, orientation.y);
			_orientations.z.insertInPlace(idx, orientation.z);
			_orientations.w.insertInPlace(idx, orientation.w);
			
			_scales.x.insertInPlace(idx, scale.x);
			_scales.y.insertInPlace(idx, scale.y);
			_scales.z.insertInPlace(idx, scale.z);
		}
	}
}

// 4
// 2 3 5 6
//    ^x
//

// 1
// 2 3 5 6
//^x
//

// 9
// 2 3 5 6
//         ^x
//


+++/