package hotdish.node;

using hotdish.cli.CliTools;

/**
	Run a Haxe script based on parent Build nodes.
**/
class Run extends Node {
	function execute():Task<Nothing> {
		var cmd = ['haxe'.createNodeCommand()].concat(Build.from(this).getFlags({
			mode: ModeRun
		})).join(' ');

		var code = try Sys.command(cmd) catch (e) {
			return new Error(InternalError, e.message);
		}

		if (code != 0) {
			return new Error(InternalError, 'Compile failed');
		}

		return Task.resolve(Nothing);
	}
}
