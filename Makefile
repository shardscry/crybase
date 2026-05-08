CRYSTAL_CACHE_DIR ?= .crystal-cache
COVERAGE_DIR ?= coverage
COVERAGE_BIN ?= /tmp/crybase-coverage

.PHONY: coverage

coverage:
	@if ! command -v kcov >/dev/null 2>&1; then \
		echo "kcov is required. Install it or run the coverage job in CI."; \
		exit 1; \
	fi
	CRYSTAL_CACHE_DIR=$(CRYSTAL_CACHE_DIR) crystal build coverage.cr --debug -o $(COVERAGE_BIN)
	kcov $(COVERAGE_DIR) $(COVERAGE_BIN)
