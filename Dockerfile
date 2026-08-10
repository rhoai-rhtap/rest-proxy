#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.26.5-1786035555@sha256:b72e800dbf68fa9ca272385e034e76babbba43d465762ffcceba7516637043cc AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:0494929e1841c6c908f2b4869a9e39d46bbeb68e241887fb2b254c91ab30419c as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
