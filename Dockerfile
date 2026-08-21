#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.5-1787215294@sha256:6e1aff6035d68a465ae3b5f0d5e155dbf7f2c965b03aa9c9e4bfb3f5e1d7a34a AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:474100da9b79cf73efde76dabac9f8a397dea30de3b4a59e5162665ad9e14b6e as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
