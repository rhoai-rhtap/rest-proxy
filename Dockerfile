#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.10-1782087643@sha256:d79ca3b1f2bcd3c101680b73a34425c65fa5976f9663d8fcccaabd0d7d518e5b AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:41d80530c06076f7f96094e998b28a22009b9247fe207d6b62b7f5aa61656ea7 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
