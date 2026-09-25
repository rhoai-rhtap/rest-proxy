#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.7-1790232813@sha256:93b85580bf0737559318b12baa82cf034db7fce7a6c095c593ff156c09b50339 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:b2df364e16af80aa65b010decd2c0fbf96923242eabc1ae6c327753c3dc72f0c as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
