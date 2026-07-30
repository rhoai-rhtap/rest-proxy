#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.5-1785357990@sha256:fa14b2bb1ef146d6d07ab0bcf1db80545b243c85991c96d40f4847999521c7b9 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:aebee49fbdff1791e32f483bfcff17e0be20dd36b2034d535076fd9d0e34ff89 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
