#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.22@sha256:dac954880015b2b7990e34e5443e184a70e43d6a4e1b816d4eeac61c2d5fad45 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:eae27ba458e682d6d830f6c77c9e3a4c33cf1718461397b741e674d9d37450f3 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
