package hotdish.node;

typedef Dependency = {
	public final name:String;
	public final ?version:SemVer;
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

	@:prop final children:Array<Node> = [];

	function build():Array<Node> {
		return children;
	}

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
	public function new(?props) {
		this = props ?? {};
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
}
