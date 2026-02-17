#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25@sha256:ad14167aab654a920fc4cfdca6829a40ea1b9909509a519a8bc1f9afb07a63bf AS build

#rhoai-2.13-1

LABEL image="build"

USER root
WORKDIR /opt/app

COPY go.mod go.sum ./

# Download dependencies before copying the source so they will be cached
RUN go mod download

# Copy the source
COPY . ./

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o /go/bin/server ./proxy/

#ubi-micro
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:9397bb617358901e4ca47796047fcf00b9912c115f8a7dc2c65c706847d0036a as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
