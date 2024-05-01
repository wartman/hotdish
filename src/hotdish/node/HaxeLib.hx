package hotdish.node;

import haxe.Json.stringify;
import hotdish.provider.*;

/**
	Generate a `haxelib.json` using parent Project and Build nodes. 
**/
class HaxeLib extends Node {
	function execute():Task<Nothing> {
		var fs = FileSystemProvider.sure(this);
		var project = Project.from(this);
		var build = Build.from(this);
		var dependencies:{} = {};

		for (dep in build.dependencies) {
			Reflect.setField(dependencies, dep.name, dep.version?.toString() ?? '0.0.1');
		}

		var body = stringify({
			name: project.name,
			classPath: build.sources[0] ?? 'src',
			description: project.description,
			version: project.version.toString(),
			url: project.url,
			releasenote: project.releasenote,
			license: project.license,
			contributors: project.contributors,
			tags: project.tags,
			dependencies: dependencies
		}, '  ');

		return fs.file('haxelib.json').write(body);
	}
}
