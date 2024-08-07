.PHONY: changelog release

changelog:
	git-chglog --config .chglog/config.yml -o CHANGELOG.md --next-tag `semtag final -s minor -o`

release:
	semtag final -s minor
