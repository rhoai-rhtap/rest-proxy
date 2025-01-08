#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.21@sha256:742ae6ec1aef3e7faae488c47695fb64964d342aefecf52d23bd9d5e6731d0b6 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:22448ec2e9234d99a2cd9adf9e571a367d1e4b0e1546b2b5c36518e5183e1b32 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
