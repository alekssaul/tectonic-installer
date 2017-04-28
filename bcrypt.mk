TOP_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

BCRYPT_REPOSITORY=https://github.com/coreos/bcrypt-tool.git
BCRYPT_BRANCH=v1.0.0
BCRYPT_RELEASE_TARBALL_BASEURL=https://github.com/coreos/bcrypt-tool/releases/download/$(BCRYPT_BRANCH)/
BCRYPT_BUILD_DIR=$(TOP_DIR)/build/bcrypt-tool
BCRYPT_BINS_DIR=$(TOP_DIR)/bin
BCRYPT_GO_IMAGE=golang:1.8
BCRYPT_GO_OS=linux darwin windows
BCRYPT_GOARCH=386 amd64

PATH  := $(TOP_DIR)/bin/BCRYPT:$(PATH)
SHELL := env PATH="${PATH}" /bin/bash
$(info Using BCRYPT binary [$(shell which BCRYPT 2> /dev/null)])

ifeq ($(OS), Windows_NT)
    GOOS = windows
    ifeq ($(PROCESSOR_ARCHITECTURE), AMD64)
        GOARCH = amd64
    else ifeq ($(PROCESSOR_ARCHITECTURE), x86)
        GOARCH = 386
    endif
else
    OS := $(shell uname -s)
    ARCH := $(shell uname -m)
    ifeq ($(OS), Linux)
        GOOS = linux
    else ifeq ($(OS), Darwin)
        GOOS = darwin
    endif
    ifeq ($(ARCH), x86_64)
        GOARCH = amd64
    else ifneq ($(filter %86, $(ARCH)),)
        GOARCH = 386
    else ifneq ($(findstring arm, $(ARCH)),)
        GOARCH = arm
    endif
endif

$(BCRYPT_BINS_DIR):
	mkdir -p $(BCRYPT_BINS_DIR)

$(BCRYPT_BUILD_DIR):
	git clone -b $(BCRYPT_BRANCH) $(BCRYPT_REPOSITORY) $(BCRYPT_BUILD_DIR)

bcrypt-download: $(BCRYPT_BINS_DIR)
	curl -L $(BCRYPT_RELEASE_TARBALL_BASEURL)/bcrypt-tool-v1.0.1-$(GOOS)-$(GOARCH).tar.gz > $(BCRYPT_BINS_DIR)/bcrypt.tar.gz
	cd $(BCRYPT_BINS_DIR) && tar -zxvf bcrypt.tar.gz
	cp $(BCRYPT_BINS_DIR)/bcrypt-tool/bcrypt-tool $(BCRYPT_BINS_DIR)/bcrypt

bcrypt-clean:
	rm -rf $(BCRYPT_BUILD_DIR) $(BCRYPT_BINS_DIR)
