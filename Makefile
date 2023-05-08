# Message colors
_SUCCESS := "\033[32m[%s]\033[0m %s\n"
_DANGER := "\033[31m[%s]\033[0m %s\n"
_INFO := "\033[1;34m[%s]\033[0m %s\n"
_ATTAINTION := "\033[93m[%s]\033[0m %s\n"
#APP for test 
IMAGE_BUILDER := quay.io/projectquay/golang:1.20
# IMAGE_BUILDER_WINDOWS := mcr.microsoft.com/windows/servercore:ltsc2019
STATIC_DOCKERFILE := Dockerfile.stub
DOCKERFILE := Dockerfile

APP := $(shell basename $(shell git remote get-url origin 2>/dev/null || echo "defapp"))
GIT_PATH := $(shell git remote get-url origin | sed 's/.*github.com\//github.com\//;s/\.git$$//' || echo "github.com/yourname/yourrepo")

# Convert domething text to lowercase
to_lowercase = $(shell echo $(1) | tr A-Z a-z)

#Version get
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "unknown-$(shell date +%s)")

LDFLAGS_SET_VALUE := cmd.appVersion
# LDFLAGS := -X $(GIT_PATH)/$(LDFLAGS_SET_VALUE)=$(VERSION)
LDFLAGS := "-s -w"

# default OS typew
UNAME := $(shell uname -s 2>/dev/null || echo "linux")
OS ?= $(call to_lowercase,$(UNAME))

TARGETARCH := amd64
ARCH_SHORT_NAME := amd
APP_FULL_NAME := $(APP)-$(OS)$(ARCH_SHORT_NAME)

# OS types can be
SUPPORTED_OS = linux darwin windows
# Supported architecturees
SUPPORTED_ARCH := amd64 arm64

# Verify the OS type
ifeq ($(filter $(OS),$(SUPPORTED_OS)),)
$(error Invalid OS type $(OS). Supported OS types are: $(SUPPORTED_OS))
endif

#REGISTRY NAME
REGISTRY := adalbertbarta

#IF using like this please check the Dockerfile.stub stuble settings!!! Also atantion for settings $ based variables in makefile
BUILDER_LAST_ACTION := COPY --from=builder /go/src/app/\$$APP_NAME ./toTestAPP

CERT_SETTINGS := COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT := ENTRYPOINT [\"./toTestAPP\", \"start\"]

EXPOSE :=8888

# List of variables to display in help
VARIABLES_ARRAY := APP GIT_PATH VERSION LDFLAGS_SET_VALUE LDFLAGS OS TARGETARCH IMAGE_BUILDER REGISTRY SUPPORTED_ARCH CERT_SETTINGS ENTRYPOINT STATIC_DOCKERFILE DOCKERFILE



.PHONY: help
help: ##Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf $(_DANGER) "Available variables and theur values:"
	@printf $(_INFO) "-----------START-----------"
	@$(foreach var,$(VARIABLES_ARRAY),printf $(_ATTAINTION) "$(var) = $($(var))";)
	@printf $(_INFO) "-----------END-----------"
	@printf $(_DANGER) "AND VARIABLES AND VALUES"

# Default target to print settings
.DEFAULT_GOAL := help

test: ## Check test or kode errors
	@if ! go test -v -cover ./...; then \
		printf $(_DANGER) "Tests failed,build stopp"; \
		exit 1; \
	fi
	@printf $(_SUCCESS) "Tests was passed, OK"
	@echo "\n"

build: test ## Build the binary for OS type
	@printf $(_SUCCESS) "Builder for $(OS) architecture $(TARGETARCH)"
	@go get ./...
	@printf $(_ATTAINTION) "-----------START BUILD-----------"
	CGO_ENABLED=0 GOOS=$(OS) GOARCH=$(TARGETARCH) go build  -v  -o $(APP_FULL_NAME) -ldflags $(LDFLAGS)
	@printf $(_ATTAINTION) "-----------END BUILD-----------"
	@if [ $$? -ne 0 ]; then \
        printf $(_DANGER) "Error: Failed to build $(APP_FULL_NAME) for $(OS)"; \
        exit 1; \
    fi
	@printf $(_SUCCESS) "Successfully built $(APP_FULL_NAME) for $(OS) with architecture $(TARGETARCH)\n"
	

linux: ## Build for linucx, by default this made for amd64
	@make build OS=linux

macos: ## Build for macos, by default this made for amd64
	@make build OS=darwin

windows: ## Build for windows, by default this made for amd64
	@make build OS=windows

arm%: ## ARM64 architecture set for os type, use like armlinux armmacos 
	$(eval OS=$*)
	$(eval OS=$(call to_lowercase,$(OS)))
	$(eval TARGETARCH=arm64)
	$(eval ARCH_SHORT_NAME=arm)
	$(eval APP_FULL_NAME=$(APP)-$(OS)$(ARCH_SHORT_NAME))
	@if [ -z "$(OS)" ]; then \
		OS=linux; \
	fi
	@printf $(_SUCCESS) "Successfully start build arm64 $(APP_FULL_NAME)"
	@make $(OS) TARGETARCH=$(TARGETARCH) ARCH_SHORT_NAME=$(ARCH_SHORT_NAME)

amd%:## AMD64 architecture set for os type, use like amdlinux amdmacos amdwindows
	$(eval OS=$*)
	$(eval OS=$(call to_lowercase,$(OS)))
	$(eval TARGETARCH=amd64)
	$(eval ARCH_SHORT_NAME=amd)
	$(eval APP_FULL_NAME=$(APP)-$(OS)$(ARCH_SHORT_NAME))
	@printf $(_SUCCESS) "Successfully start build amd64 $(OS)"
	@make $(OS) TARGETARCH=$(TARGETARCH) ARCH_SHORT_NAME=$(ARCH_SHORT_NAME)

preconfig: ## Make Dockerfile from template it can be more powerful in future
	@if [ -f $(STATIC_DOCKERFILE) ]; then \
		cat $(STATIC_DOCKERFILE) > $(DOCKERFILE); \
		echo $(BUILDER_LAST_ACTION) >> $(DOCKERFILE); \
		echo $(CERT_SETTINGS) >> $(DOCKERFILE); \
		echo $(ENTRYPOINT) >> $(DOCKERFILE); \
	else \
        printf $(_DANGER) "$(STATIC_DOCKERFILE) does not exist"; \
    fi

image: ## Default image maker for linux or you need call with makefile variables!!!
	@docker build \
	--no-cache \
	-t $(REGISTRY)/$(APP)-$(OS)$(ARCH_SHORT_NAME):$(VERSION) \
	-f $(DOCKERFILE) \
	--build-arg APP_NAME=$(APP)-$(OS)$(ARCH_SHORT_NAME) \
	--build-arg OS_TARGET=$(ARCH_SHORT_NAME)$(OS) \
	--build-arg FROM_IMAGE=$(IMAGE_BUILDER) \
	.

image%:## Build the Docker image for the OS type, use like imagelinux imagemacos imagewindows
	$(eval OS=$*)
	$(eval OS=$(call to_lowercase,$(OS)))
	$(eval ARCH_SHORT_NAME=amd)
	@docker build \
	--no-cache \
	-t $(REGISTRY)/$(APP)-$(OS)$(ARCH_SHORT_NAME):$(VERSION) \
	-f $(DOCKERFILE) \
	--build-arg APP_NAME=$(APP)-$(OS)$(ARCH_SHORT_NAME) \
	--build-arg OS_TARGET=$(ARCH_SHORT_NAME)$(OS) \
	--build-arg FROM_IMAGE=$(IMAGE_BUILDER) \
	. > dockerbuild.log 2>&1
	@cat dockerbuild.log
	@make push


imagearm%:## Build the Docker image for the OS type, use like imagearmlinux imagearmmacos
	$(eval OS=$*)
	$(eval OS=$(call to_lowercase,$(OS)))
	$(eval ARCH_SHORT_NAME=arm)
	$(if $(filter $(OS),linux),$(eval PLATFORM=linux/arm64))
	$(if $(filter $(OS),macos),$(eval PLATFORM=darwin/arm64))
	@docker build \
	--no-cache \
	-t $(REGISTRY)/$(APP)-$(OS)$(ARCH_SHORT_NAME):$(VERSION) \
	-f $(DOCKERFILE) \
	--build-arg APP_NAME=$(APP)-$(OS)$(ARCH_SHORT_NAME) \
	--build-arg OS_TARGET=$(ARCH_SHORT_NAME)$(OS) \
	--build-arg FROM_IMAGE=$(IMAGE_BUILDER) \
	$(if $(PLATFORM),--platform $(PLATFORM)) \
	. > dockerbuild.log 2>&1;
	@cat dockerbuild.log
	@make push

push:## Push the Docker image for the specified OS type
	@printf $(_INFO) "Start pushing your docker image with registry and nameversion: $(REGISTRY)/$(APP_FULL_NAME):$(VERSION) !\n"
	@read -p "Are you sure you want to continue? [y/N] " confirm && \
	if [ "$$confirm" = "y" ]; then \
		docker push $(REGISTRY)/$(APP_FULL_NAME):$(VERSION); \
		printf $(_SUCCESS) "Your image was Successfully pushed!\n"; \
	else \
		printf $(_WARNING) "Push cancelled by user!\n"; \
	fi

save: ## Save Docker image to a tar file
	@docker images
	@read -p "Enter the name of the Docker image to save: " IMAGE_NAME; \
	read -p "Enter the path to save the Docker image: " IMAGE_PATH; \
	if [ -f "$$IMAGE_PATH/$$IMAGE_NAME.tar" ]; then \
        printf $(_WARNING) "The image file already exists. Do you want to overwrite it? [y/n]: "; \
        read OVERWRITE; \
        if [ $$OVERWRITE != "y" ]; then \
            printf $(_INFO) "The image file was not saved."; \
            exit 0; \
        fi; \
    fi; \
	docker save -o $$IMAGE_PATH/$$IMAGE_NAME.tar $$IMAGE_NAME; \
	printf $(_SUCCESS) "The Docker image was saved to $$IMAGE_PATH/$$IMAGE_NAME.tar."


clean:## Clean all targets and images
	@for os in $(SUPPORTED_OS); do \
        rm -f $(APP)-$$os*; \
        docker images --filter=reference=$(REGISTRY)/$(APP)-$$os* -q | xargs -r docker rmi -f || true; \
    done