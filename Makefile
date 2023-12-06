DIR = $(shell pwd)
TESTS = $(DIR)/tests

db:
	cd $(TESTS)/indexing && codeql database create indexing --language=python --overwrite
	cd $(TESTS)/taint && codeql database create taint --language=python --overwrite
	cd $(TESTS)/exceptions && codeql database create exceptions --language=python --overwrite
