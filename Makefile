.PHONY: all

all:  image push

APP=$(shell basename $(shell git remote get-url origin))
REGESTRY=gcr.io/kuber-351315/
CURRENTARCH=$(shell dpkg --print-architecture)
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse HEAD|cut -c1-7)

TARGETOS=linux darwin windows
TARGETARCH=arm64 amd64

format:
	gofmt -s -w ./

lint: format
	golint

test: lint
	go test -v
get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/den-vasyliev/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH} --no-cache --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	docker rmi ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}