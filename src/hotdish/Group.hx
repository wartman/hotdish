package hotdish;

class Group extends Node {
	@:prop final children:Array<Node>;

	public function build() {
		return children;
	}

	public function run() {
		initialize(null);
		return apply().eager();
	}
}
