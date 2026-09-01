#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.7-1788216198@sha256:dbbc2bfd4c30ba0c4111794f4ec557e43d89baf2acaeca822eb00b8feb58c679 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:474100da9b79cf73efde76dabac9f8a397dea30de3b4a59e5162665ad9e14b6e as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
