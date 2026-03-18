#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.7-1773837226@sha256:edafdebdc03a888bb731f834477b4246cb6221d05d5b0694ca51060a509edf26 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:7c8f2380c237fb53e29f04d15040bf4f6ed9a29296dbdde60c3c0a058a211f64 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
