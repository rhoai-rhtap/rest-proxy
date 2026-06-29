#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.10-1782735547@sha256:714a5cd6606e882e4a1cbe980453e5acb846ab1c2b9abeae6b687ba3c425c999 AS build

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
