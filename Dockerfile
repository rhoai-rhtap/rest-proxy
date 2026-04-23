#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.8-1776905877@sha256:742270db7c7e3b8e8e7eb6625f6c2a3f75b04105e92a02a885cec4f125da7ad0 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:936355df011657b9c6eaefbc08cd1e3e9a0103afbd0a2b83296be59586af8f8d as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
