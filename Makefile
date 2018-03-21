ARCH?=amd64
OUT_DIR?=./_output
REGISTRY ?= gcr.io/bskiba-gke-dev
IMAGE ?= custom-metrics-sample-adapter
TAG ?= dev

.PHONY: all test verify-gofmt gofmt verify release

all: build
build: vendor
	CGO_ENABLED=0 GOARCH=$(ARCH) go build -a -tags netgo -o $(OUT_DIR)/$(ARCH)/sample-adapter github.com/kubernetes-incubator/custom-metrics-apiserver

release: build
	docker build --pull -t ${REGISTRY}/${IMAGE}-${ARCH}:${TAG} .
	docker push ${REGISTRY}/${IMAGE}-${ARCH}:${TAG}

vendor: glide.lock
	glide install -v

test: vendor
	CGO_ENABLED=0 go test ./pkg/...

verify-gofmt:
	./hack/gofmt-all.sh -v

gofmt:
	./hack/gofmt-all.sh

verify: verify-gofmt test
