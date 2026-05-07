#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.9-1778099762@sha256:d1d77b6d5ad038c1890a5578875b96f05dbeafa8314a2a331f596501a6435d8e AS build

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
