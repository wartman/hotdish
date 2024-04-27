package hotdish.node;

/**
	Run a generic console command.
**/
class Command extends Node {
	@:prop final command:String;

	function execute():Task<Nothing> {
		var code = try Sys.command(command) catch (e) {
			return new Error(InternalError, e.message);
		}

		if (code != 0) {
			return new Error(InternalError, 'Command failed');
		}

		return Nothing;
	}
}
