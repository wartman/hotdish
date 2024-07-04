package hotdish.node;

import hotdish.provider.*;

using haxe.io.Path;

/**
	Generate a hxml file from parent Build nodes. This node will also 
	check for a parent Output node in order to include output 
	target configuration.

	While hxml files aren't required for Hotdish projects to work,
	they *are* needed for editors and IDEs, meaning this Node is 
	recommended for most projects.
**/
class Hxml extends Node {
	@:prop final name:String = null;

	function execute():Task<Nothing> {
		var fs = FileSystemProvider.sure(this);
		var name = this.name == null ? 'build' : name;
		var build = Build.from(this);
		var body = [
			'# THIS IS A GENERATED FILE. DO NOT EDIT.',
			''
		].concat(build.toCliFlags());

		switch build.getMain() {
			case Some(main):
				body.push('-main $main');
			case None:
		}

		switch Output.maybeFrom(this) {
			case Some(output):
				body.push(output.getBuildFlag());
			case None:
		}

		return fs
			.file(name.withExtension('hxml'))
			.write(body.join('\n'));
	}
}
