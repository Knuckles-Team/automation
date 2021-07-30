DOCKER_NAME ?= audel
DOCKER_BUILD_ARGS ?=
DOCKER_RUN_ARGS ?= --device /dev/mem:/dev/mem --cap-add SYS_RAWIO

CONTAINER_BINARY_DIRECTORY ?= /virt/virtualization/source
BAREMETAL_BINARY_DIRECTORY ?= ./virtualization/source
LOG_WRAPPER ?= log_wrapper.sh
RUN_BINARY ?= virt-run.sh
SETUP_BINARY ?= virt-dep-setup.sh
VT_CONTENT ?= autoreboots
TEST_ARGS ?= --time 36000 --run $(VT_CONTENT)
QUICK_TEST_ARGS ?= --time 3600 --run $(VT_CONTENT)
DOCKER_TAG ?= vt-suite-$(VT_CONTENT)
PUSH_TAG ?= $(DOCKER_TAG)
TEST_LABEL ?= $(DOCKER_TAG)
NODE_LABEL ?= $(DOCKER_TAG)

LOG := $(DOCKER_TAG)_$(shell date +%Y%m%d_%H%M%S).log

docker-build:
	chmod +x $(shell pwd)/prepare_virt.sh
	$(shell pwd)/prepare_virt.sh $(VT_CONTENT)
	time docker build $(DOCKER_BUILD_ARGS) . -t $(DOCKER_NAME):$(DOCKER_TAG) | tee -a $(LOG)

docker-test: docker-build
	time docker run $(DOCKER_RUN_ARGS) --rm --privileged --entrypoint $(CONTAINER_BINARY_DIRECTORY)/$(LOG_WRAPPER) $(DOCKER_NAME):$(DOCKER_TAG) $(CONTAINER_BINARY_DIRECTORY)/$(RUN_BINARY) $(TEST_ARGS) 2>&1 | tee -a $(LOG)




