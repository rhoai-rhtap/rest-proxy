#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.9-1777568311@sha256:5a9e0dc79df7573a41217837093b8f9e72bb5c0fff44c8f3cbc1850a16b26c6a AS build

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
