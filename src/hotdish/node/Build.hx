package hotdish.node;

typedef Dependency = {
	public final name:String;
	public final ?version:SemVer;
}

typedef Resource = {
	public final name:String;
	public final path:String;
}

enum BuildMode {
	ModeBuild;
	ModeRun;
}

/**
	Configures a Haxe project, setting up sources, flags and dependencies
	for the compiler. Build nodes are composable and will inherit the
	configuration of their parents.
**/
class Build extends Node {
	@:prop public final sources:Array<String> = [];
	@:prop public final main:String = null;
	@:prop public final flags:BuildFlags = new BuildFlags();
	@:prop public final macros:Array<String> = [];
	@:prop public final dependencies:Array<Dependency> = [];
	@:prop public final resources:Array<Resource> = [];

	@:prop final children:Array<Node> = [];

	function build():Array<Node> {
		return children;
	}

	public function getDependencies() {
		var out = Build.maybeFrom(this)
			.map(build -> build.getDependencies())
			.or(() -> []);

		return out.concat(dependencies);
	}

	public function getBuildFlags():BuildFlags {
		var other:BuildFlags = Build.maybeFrom(this)
			.map(build -> build.getBuildFlags())
			.or(() -> {});

		return flags.merge(other);
	}

	// @todo: rename this to `toCliFlags`.
	public function getFlags(?options:{
		public final mode:BuildMode;
	}):Array<String> {
		var out = Build.maybeFrom(this)
			.map(build -> build.getFlags())
			.or(() -> []);

		for (source in sources) {
			out.push('-cp $source');
		}

		for (dep in dependencies) {
			out.push('-lib ${dep.name}');
		}

		out = out.concat(flags.toEntries());

		for (expr in macros) {
			out.push('--macro $expr');
		}

		for (resource in resources) {
			out.push('--resource ${resource.path}@${resource.name}');
		}

		if (main != null) switch options?.mode {
			case ModeRun:
				out.push('--run $main');
			default:
				out.push('-main $main');
		}

		return out;
	}
}

// @todo: maybe use a macro to type this thing?
typedef BuildFlagsObject = {};

abstract BuildFlags(BuildFlagsObject) from BuildFlagsObject {
	@:from public static function fromMap(map:Map<String, Dynamic>):BuildFlags {
		var obj = {};
		for (name => value in map) {
			Reflect.setField(obj, name, value);
		}
		return new BuildFlags(obj);
	}

	public function new(?props) {
		this = props ?? {};
	}

	public function set(name:String, value:Dynamic) {
		Reflect.setField(this, name, value);
	}

	public function toEntries() {
		var out:Array<String> = [];
		for (field in Reflect.fields(this)) {
			var value = Reflect.field(this, field);
			switch field {
				case 'debug':
					if (value == true) out.push('--debug');
				case 'dce':
					out.push('-dce ${value}');
				case field if (value == true):
					out.push('-D $field');
				default:
					out.push('-D $field=$value');
			}
		}
		return out;
	}

	public function merge(other:BuildFlags):BuildFlags {
		var out = {};
		var obj = other.unwrap();
		for (field in Reflect.fields(this)) {
			Reflect.setField(out, field, Reflect.field(this, field));
		}
		for (field in Reflect.fields(obj)) {
			if (!Reflect.hasField(out, field)) {
				Reflect.setField(out, field, Reflect.field(obj, field));
			}
		}
		return out;
	}

	public function unwrap():{} {
		return this;
	}
}
