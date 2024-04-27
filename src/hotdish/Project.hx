package hotdish;

enum abstract ProjectLicense(String) from String {
	final GPL;
	final LGPL;
	final BSD;
	final Public;
	final MIT;
	final Apache;
}

class Project extends Node {
	@:prop public final name:String;
	@:json(from = SemVer.parse(value), to = value.toString()) @:prop public final version:SemVer;
	@:prop public final description:String;
	@:prop public final url:String;
	@:prop public final releasenote:String;
	@:prop public final license:ProjectLicense;
	@:prop public final contributors:Array<String>;
	@:prop public final tags:Array<String> = [];

	@:prop final children:Array<Node>;

	public function run() {
		initialize(null);
		return apply().eager();
	}

	function build() {
		return children;
	}
}
