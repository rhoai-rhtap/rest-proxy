#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.24@sha256:c7c95c4e0a1b1b0ff30d6da0eb3ae9502b2d68fdcc45a446d108066a470f4ba6 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:37552f11d3b39b3360f7be7c13f6a617e468f39be915cd4f8c8a8531ffc9d43d as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
