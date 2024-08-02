import hotdish.*;
import hotdish.node.*;

function main() {
	var project = new Project({
		name: 'hotdish',
		version: '0.0.1',
		description: 'Composable build tools for Haxe',
		url: 'https://github.com/wartman/hotdish',
		license: MIT,
		releasenote: 'First release',
		contributors: ['wartman'],
		tags: ['markup', 'compiler'],
		children: [
			new Build({
				sources: ['src'],
				dependencies: [
					{version: '0.2.0', name: 'kit'},
					{version: '0.1.0', name: 'kit.file'}
				],
				children: [
					new HaxeLib({}),
					new Hxml({name: 'build-main'}),
					new Build({
						sources: ['test'],
						main: 'Run',
						children: [
							new Hxml({name: 'build-test'}),
							new Run({})
						]
					})
				]
			})
		]
	});

	project.run();
}
