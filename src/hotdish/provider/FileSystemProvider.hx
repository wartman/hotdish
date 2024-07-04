package hotdish.provider;

import kit.file.*;
import kit.file.adaptor.SysAdaptor;

class FileSystemProvider extends Node {
	public static function sure(context:Node):FileSystem {
		return maybeFrom(context)
			.map(provider -> provider.fs)
			.or(() -> new FileSystem(new SysAdaptor(Sys.getCwd())));
	}

	@:prop public final fs:FileSystem = new FileSystem(new SysAdaptor(Sys.getCwd()));

	@:prop final children:Array<Node>;

	function build() {
		return children;
	}
}
