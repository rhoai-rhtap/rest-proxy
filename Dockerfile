#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.9-1778693610@sha256:396aac5e42d1ba66b541ece00e7effdee2342306c5cfa92c88113d9abb5a7ec7 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:6815c92ac2d9989e90132b8cbd707f85e86fce17baeaceb647d12b5614c35f91 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
