#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.23@sha256:f79e40e156b5c887b1e12ae7a2f6c59b0f720e9fc7874a328a1d76e558297f48 AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:0fe81f64dab0570da191fbc74004fff651027640496fb220661da4e9d83860f7 as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
