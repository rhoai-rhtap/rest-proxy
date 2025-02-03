#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.22@sha256:cb6d0d225da06acffdaea76081e9396e104b2e3cfb670c9d99cc3352761953c2 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:34d05733611f4c7c9e07e5b00191c9928f1e7d0e126d51276b4bc75eb3331dab as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
