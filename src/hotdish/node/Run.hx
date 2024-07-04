package hotdish.node;

using hotdish.cli.CliTools;

/**
	Run a Haxe script based on parent Build nodes.
**/
class Run extends Node {
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
			.concat(['--run ${main}'])
			.join(' ');

		var code = try Sys.command(cmd) catch (e) {
			return new Error(InternalError, e.message);
		}

		if (code != 0) {
			return new Error(InternalError, 'Compile failed');
		}

		return Task.resolve(Nothing);
	}
}
