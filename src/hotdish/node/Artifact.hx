package hotdish.node;

import hotdish.provider.FileSystemProvider;

class Artifact extends Node {
	@:prop final path:String;
	@:prop final contents:String;
	@:prop final children:Array<Node> = [];

	function build() {
		return children;
	}

	function execute():Task<Nothing> {
		var fs = FileSystemProvider.sure(this);
		return fs.file(path).write(contents);
	}
}
