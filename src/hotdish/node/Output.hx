package hotdish.node;

using hotdish.cli.CliTools;
using haxe.io.Path;

enum abstract OutputType(String) to String {
	final Js = 'js';
	final Php = 'php';
	// etc
}

/**
	Compile a Haxe project and output it to the given target.

	This Node should be the child of at least one Build node.
**/
class Output extends Node {
	@:prop final type:OutputType;
	@:prop final output:String;
	@:prop final children:Array<Node> = [];

	function build() {
		return children;
	}

	function execute():Task<Nothing> {
		var build = Build.from(this);
		var flags = build.toCliFlags();
		var main = switch build.getMain() {
			case Some(main):
				main;
			case None:
				return new Error(NotFound, 'No `main` was set');
		}
		var cmd = ['haxe'.createNodeCommand()]
			.concat(flags)
			.concat(['-main $main', getBuildFlag()])
			.join(' ');

		#if debug trace(cmd); #end

		var code = try Sys.command(cmd) catch (e) {
			return new Error(InternalError, e.message);
		}

		if (code != 0) {
			return new Error(InternalError, 'Compile failed');
		}

		return Task.resolve(Nothing);
	}

	public function getBuildFlag() {
		return switch type {
			case Js: '-js ${output.withExtension('js')}';
			default: '-$type $output';
		}
	}
}
