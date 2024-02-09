DOCKER ?= docker
PWD ?= pwd
GEN_SBOM ?= ./gen_sbom.sh

.PHONY: test
test:
	$(DOCKER) run --rm -it \
		-v $(PWD):/build \
		--workdir /build \
		bats/bats:1.9.0 test/**.bats --timing --show-output-of-passing-tests --verbose-run

.PHONY: shellcheck
shellcheck:
	$(DOCKER) run --rm -it \
		-v $(PWD):/build \
		--workdir /build \
		koalaman/shellcheck-alpine:v0.9.0 shellcheck -x ./*.sh ./**/*.bats

.PHONY: clean
clean:
	$(shell rm -rf sbom_output)
	$(shell rm -rf output)
	$(shell rm -rf samples/node/node_modules)
	$(shell rm -rf samples/java/target)

.PHONY: docker
docker:
	$(DOCKER) build --build-arg ARCH=arm64 --tag cyclonedx-bitbucket-pipe:dev .

.PHONY: docker-amd64
docker-amd64:
	$(DOCKER) buildx build --platform linux/amd64 --build-arg ARCH=amd64 --tag cyclonedx-bitbucket-pipe:dev .

.PHONY: docker-lint
docker-lint:
	$(DOCKER) run --rm -it \
		-v "$(shell pwd)":/build \
		--workdir /build \
		hadolint/hadolint:v2.12.0-alpine hadolint Dockerfile*

.PHONY: markdown-lint
markdown-lint:
	$(DOCKER) run --rm -it \
		-v "$(shell pwd)":/build \
		--workdir /build \
		markdownlint/markdownlint:0.13.0 *.md

.PHONY: scan-node-project
scan-node-project:
	export CDXGEN_SPEC_VERSION="1.5" && \
	export CDXGEN_PROJECT_TYPE="node" && \
	export CDXGEN_PATH_TO_SCAN="samples/node" && \
	export CDXGEN_PRINT_AS_TABLE="true" && \
	export CDXGEN_DEBUG_MODE="debug" && \
	export DEBUG_BASH="true" && \
	$(GEN_SBOM)

.PHONY: scan-go-project
scan-go-project:
	export CDXGEN_SPEC_VERSION="1.5" && \
	export CDXGEN_PROJECT_TYPE="go" && \
	export CDXGEN_PATH_TO_SCAN="samples/go" && \
	export CDXGEN_PRINT_AS_TABLE="true" && \
	export CDXGEN_DEBUG_MODE="debug" && \
	export DEBUG_BASH="false" && \
	$(GEN_SBOM)

.PHONY: scan-python-project
scan-python-project:
	export CDXGEN_SPEC_VERSION="1.5" && \
	export CDXGEN_PROJECT_TYPE="python" && \
	export CDXGEN_PATH_TO_SCAN="samples/python" && \
	export CDXGEN_PRINT_AS_TABLE="true" && \
	export CDXGEN_DEBUG_MODE="debug" && \
	export DEBUG_BASH="false" && \
	$(GEN_SBOM)

.PHONY: scan-java-project
scan-java-project:
	export CDXGEN_SPEC_VERSION="1.5" && \
	export CDXGEN_PROJECT_TYPE="java" && \
	export CDXGEN_PATH_TO_SCAN="samples/java" && \
	export CDXGEN_PRINT_AS_TABLE="true" && \
	export CDXGEN_DEBUG_MODE="debug" && \
	export DEBUG_BASH="false" && \
	$(GEN_SBOM)

.PHONY: scan-project
scan-project:
	export CDXGEN_SPEC_VERSION="1.5" && \
	export CDXGEN_PROJECT_TYPE="universal" \
	export CDXGEN_PRINT_AS_TABLE="true" && \
	export CDXGEN_DEBUG_MODE="debug" && \
	export DEBUG_BASH="false" && \
	$(GEN_SBOM)

.PHONY: scan-node-project-docker
scan-node-project-docker:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp \
		--env-file variables.list \
		--env CDXGEN_PROJECT_TYPE=node \
		--env CDXGEN_PATH_TO_SCAN=samples/node/ \
		cdxgen-bitbucket-pipe:dev

.PHONY: scan-python-project-docker
scan-python-project-docker:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp \
		--env-file variables.list \
		--env CDXGEN_PROJECT_TYPE=python \
		--env CDXGEN_PATH_TO_SCAN=samples/python/ \
		cyclonedx-bitbucket-pipe:dev

.PHONY: scan-java-project-docker
scan-java-project-docker:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp \
		--env-file variables.list \
		--env CDXGEN_PROJECT_TYPE=java \
		--env CDXGEN_PATH_TO_SCAN=samples/java/ \
		cyclonedx-bitbucket-pipe:dev

.PHONY: scan-go-project-docker
scan-go-project-docker:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp  \
		--env-file variables.list \
		--env CDXGEN_PROJECT_TYPE=go \
		--env CDXGEN_PATH_TO_SCAN=samples/go/ \
		cyclonedx-bitbucket-pipe:dev

.PHONY: scan-universal-project-docker
scan-universal-project-docker:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp  \
		--env-file variables.list \
		--env CDXGEN_PROJECT_TYPE=universal \
		cyclonedx-bitbucket-pipe:dev

.PHONY: docker-debug
docker-debug:
	$(DOCKER) run --rm -it \
		-v $(PWD)/samples:/tmp/samples \
		--workdir /tmp \
		--env-file variables.list \
		--entrypoint bash \
		cyclonedx-bitbucket-pipe:dev
