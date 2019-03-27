PROJECT_NAME = burrow_exporter
PROJECT_ROOT = $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROJECT_REV = $(shell git rev-parse HEAD)
PROJECT_NAMESPACE = github.com/jirwin

GOPATH = $(PROJECT_ROOT)/.go
GOPATH_NAMESPACE = $(GOPATH)/src/$(PROJECT_NAMESPACE)
GOPATH_PROJECT = $(GOPATH_NAMESPACE)/$(PROJECT_NAME)

BIN_DIR = bin

.PHONY: all setup build test release artifact

all: build

setup:
	go get github.com/Masterminds/glide
	mkdir -p $(GOPATH_NAMESPACE)
	ln -nfs $(PROJECT_ROOT) $(GOPATH_PROJECT)
	mkdir -p $(GOPATH_PROJECT)/$(BIN_DIR)
	cd $(GOPATH_PROJECT)
	$(GOPATH)/bin/glide install

build: setup
	cd $(GOPATH_PROJECT); go build -o bin/$(PROJECT_NAME)

test: setup
	go test

artifact: build
	cd $(GOPATH_PROJECT)
	tar -zcvf /tmp/$(PROJECT_NAME)_$(PROJECT_REV).tar.gz $(BIN_DIR)

publish-artifact: artifact
	gsutil cp /tmp/$(PROJECT_NAME)_$(PROJECT_REV).tar.gz gs://lqm-artifact-storage/$(PROJECT_NAME)/$(PROJECT_REV)