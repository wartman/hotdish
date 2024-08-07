package hotdish;

import haxe.macro.Expr;
import kit.macro.*;
import kit.macro.step.*;

function build() {
	return ClassBuilder.fromContext().addBundle(new NodeBuilder()).export();
}

class NodeBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function steps():Array<BuildStep> return [
		new AutoInitializedFieldBuildStep({meta: 'prop'}),
		new ConstructorBuildStep(),
		this
	];

	public function apply(builder:ClassBuilder) {
		var cls = builder.getClass();
		var tp:TypePath = builder.getTypePath();
		var path = tp.pack.concat([tp.name]);
		var ret:ComplexType = TPath(tp);

		builder.add(macro class {
			@:noUsing
			public static function from(node:hotdish.Node):$ret {
				return return maybeFrom(node).orThrow();
			}

			@:noUsing
			public static function maybeFrom(node:hotdish.Node):kit.Maybe<$ret> {
				return node.findAncestorOfType($p{path});
			}
		});

		switch builder.findField('execute') {
			case Some(_):
			case None:
				builder.add(macro class {
					function execute():kit.Task<kit.Nothing> {
						return kit.Task.nothing();
					}
				});
		}

		switch builder.findField('finish') {
			case Some(_):
			case None:
				builder.add(macro class {
					function finish():kit.Task<kit.Nothing> {
						return kit.Task.nothing();
					}
				});
		}

		switch builder.findField('build') {
			case Some(_):
			case None:
				builder.add(macro class {
					function build():Array<hotdish.Node> {
						return [];
					}
				});
		}
	}
}
