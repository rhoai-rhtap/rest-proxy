#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25@sha256:48299a681e5ea00239d5ce32145d7474d5ee6002b0d36b61cf939b23353d5dc5 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:1f94090c7a33edbbdf132daf81f12f83ef50fcdf771cc6d9f69785f24ab3dd86 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
