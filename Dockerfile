#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25@sha256:1e154e39459b2513a9b07784f10e4dd54076271f8b0f45ff9cb1d9c4cf834791 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:6bcadcf383738d7f6933d3c299cbbe5b6d40cfd12dc74821c401d544420aff16 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
