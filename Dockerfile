#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.5-1784141349@sha256:f89075fe359199d3ba9bde88e56b6b858916ba4f401541beb509535ee9b3a3a9 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:6bb49cfd53b09e5f5c776b493e09cad9cfa9333baeaef5b377b0b8dbf8d27e90 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
