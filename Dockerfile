#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.7-1790750376@sha256:1439433a2cd76f0c20035001d46074e85a59ccd0d318a16023c3fd9fdd18ddf5 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:1ffcd8e04fb749a30cb80170c49858d7e978f42b475e7780dfde20f33c387ca8 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
