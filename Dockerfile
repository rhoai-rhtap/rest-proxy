#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.5-1784016833@sha256:a5cbb382c4e217745e3d0ff5ce4f8686a34e52d91649ef0791ef855b3bf62bfb AS build

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
