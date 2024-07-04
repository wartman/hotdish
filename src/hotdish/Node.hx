package hotdish;

import kit.Assert.assert;

enum NodeStatus {
	Uninitialized;
	Initialized(parent:Null<Node>);
}

@:autoBuild(hotdish.NodeBuilder.build())
abstract class Node {
	var __status:NodeStatus = Uninitialized;
	var __children:Null<Array<Node>> = null;

	abstract function build():Array<Node>;

	abstract function execute():Task<Nothing>;

	abstract function finish():Task<Nothing>;

	public function initialize(parent:Null<Node>):Node {
		assert(__status == Uninitialized);
		__status = Initialized(parent);
		__children = build().map(node -> node.initialize(this));
		return this;
	}

	public function apply():Task<Nothing> {
		return execute()
			.next(_ -> applyChildren())
			.next(_ -> finish());
	}

	function applyChildren():Task<Nothing> {
		return Task.sequence(...getChildren().map(child -> child.apply()));
	}

	public function getParent():Null<Node> {
		return switch __status {
			case Uninitialized:
				throw 'Attempted to get the parent of an un-initialized node.';
			case Initialized(parent):
				return parent;
		}
	}

	public function getChildren() {
		return switch __children {
			case null:
				throw 'Attempted to get the children of an un-initialized node.';
			case children:
				return children;
		}
	}

	public function findAncestor<T:Node>(match:(node:Node) -> Bool):Maybe<T> {
		var parent = getParent();
		if (parent == null) return None;
		if (match(parent)) return Some(cast parent);
		return parent.findAncestor(match);
	}

	public function findAncestorOfType<T:Node>(type:Class<T>):Maybe<T> {
		return findAncestor(node -> Std.isOfType(node, type));
	}
}
