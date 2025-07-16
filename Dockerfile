#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.23@sha256:d7d5a44b6f80c0c365c9d21ded6f97edf7a7503c15066b770db8b37d2deebccd AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:c1b052e22f088693b2420bb62a47799ebf90bce8f63385e13e74dbdc3d60dec7 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
