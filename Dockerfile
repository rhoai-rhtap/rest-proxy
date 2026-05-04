#go-toolset:1.21
FROM registry.redhat.io/ubi8/go-toolset:1.25.9-1777883740@sha256:04558ab2ebcebce1c9d1028d2c6b5e8c825fdb402489d1345e44f5376d6a879b AS build

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
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:b496831ffe8c601aa98cdea6e5251cc4b9cf4838aaef59d24a4fba67481d958a as runtime

ARG USER=2000


USER ${USER}

COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
