#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.23@sha256:f28b875248f01fec44db5a5a0d842c89540c702144b341ee826d336bed5edaca AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:084c06bf84ceb8ed8f868bd27e7fc6b2c83ae4e16f8e1f979dd7317961c7dd8a as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
