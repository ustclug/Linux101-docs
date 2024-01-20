.PHONY: all css

all:
	mkdocs build

css: docs/css/extra.css

docs/css/extra.css: docs/css/extra.scss
	scss -t compact $^ > $@
