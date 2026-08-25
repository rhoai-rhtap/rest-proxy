#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.5-1787592407@sha256:55276de7c67120ea2abf1be9cc0729ee86e5051e2dc16902de9c0f2e0d3d67a2 AS build

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
