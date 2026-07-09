#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.10-1783614278@sha256:17d09cc2a734335aa2d009bb1b20e6a02f29c7ce8930fef04459d9d46410863a AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:a75feff77922ee018f8247d38de068d45f38b6eada96b57aa178986df73068a4 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
