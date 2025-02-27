#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.22@sha256:1f949a762e705956c71be4a4d37f8d2151a244ecd2deb28bcb8ded3b9aa8a441 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:52064479ee49a4823c70b9eb7a993e2b36ffce05cb8d55ecb7fbb2b8dfe01ca9 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
