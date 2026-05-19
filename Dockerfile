#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.9-1779165261@sha256:14a6ab412f9f9a8e258fa64d2d399231e2d58c3b0017be8d876f80106a885fb6 AS build

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
