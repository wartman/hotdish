package hotdish.node;

class Step extends Node {
	@:prop final children:Array<Node>;
	@:prop final then:() -> Array<Node>;

	function build() {
		return children;
	}

	function finish():Task<Nothing> {
		var tasks = then()
			.map(node -> node.initialize(this))
			.map(node -> node.apply());
		return Task.parallel(...tasks);
	}
}
