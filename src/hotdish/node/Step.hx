package hotdish.node;

class Step extends Node {
	@:prop final children:Array<Node>;
	@:prop final then:() -> Array<Node>;

	function build() {
		return children;
	}

	function finish():Task<Nothing> {
		var nodes = then();
		for (node in nodes) node.initialize(this);
		return Task.parallel(...[for (node in nodes) node.apply()]);
	}
}
