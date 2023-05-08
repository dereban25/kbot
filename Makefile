APP=$(shell basename $(shell git remote get-url origin))
REGESTRY=gcr.io/kuber-351315/
CURRENTARCH=$(shell dpkg --print-architecture)
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse HEAD|cut -c1-7)

TARGETOS_LINUX=linux
TARGETOS_MAC=darwin
TARGETOS_WINDOWS=windows
TARGETARC_MAC=arm64
TARGETARC_LINUX=amd64
TARGETARC_WINDOWS=x64

format:
	gofmt -s -w ./

lint: format
	golint

test: lint
	go test -v
get:
	go get

linux: format get
	CGO_ENABLED=0 GOOS=${TARGETOS_LINUX} GOARCH=${TARGETARC_LINUX} ${BUILD}${VERSION}

mac: format get
	CGO_ENABLED=0 GOOS=${TARGETOS_MAC} GOARCH=${TARGETARC_MAC} ${BUILD}${VERSION}

windows: format get
	CGO_ENABLED=0 GOOS=${TARGETOS_WINDOWS} GOARCH=${TARGETARC_WINDOWS} ${BUILD}${VERSION}
image_linux:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARC_LINUX} --build-arg build_arc=linux .
	latest_image=${REGISTRY}/${APP}:${VERSION}-${TARGETARC_LINUX}
	export latest_image

image_mac:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARC_MAC} --build-arg build_arc=mac .
	export latest_image=${REGISTRY}/${APP}:${VERSION}-${TARGETARC_MAC}

image_windows:
	docker build -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARC_WINDOWS} --build-arg build_arc=windows .
	export latest_image=${REGISTRY}/${APP}:${VERSION}-${TARGETARC_WINDOWS}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	docker rmi ${REGESTRY}/${APP}:${VERSION}-${TARGETARCH}