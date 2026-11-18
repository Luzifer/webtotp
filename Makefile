default: lint

prod:
	$(MAKE) build NODE_ENV=production

build: node_modules
	node ci/build.mjs

lint: node_modules
	./node_modules/.bin/eslint src

node_modules:
	pnpm ci

.PHONY: node_modules
