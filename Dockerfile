# Copyright 2021 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM registry.redhat.io/ubi8/go-toolset@sha256:fe1c5eee22c78e1a9806323ee46329a41ac99521c5022c84765c4d698abb4e81 AS build

LABEL image="build"

USER root
WORKDIR /opt/app

COPY go.mod go.sum ./

# Download dependencies before copying the source so they will be cached
RUN go mod download

# Copy the source
COPY . ./


# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
# don't provide "default" values (e.g. 'ARG TARGETARCH=amd64') for non-buildx environments,
# see https://github.com/docker/buildx/issues/510
ARG TARGETOS
ARG TARGETARCH

# Build the binaries using native go compiler from BUILDPLATFORM but compiled output for TARGETPLATFORM
# https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

RUN GOOS=${TARGETOS:-linux} \
    GOARCH=${TARGETARCH:-amd64} \
    CGO_ENABLED=0 \
    GO111MODULE=on \
    go build -a -o /go/bin/server ./proxy/


###############################################################################
# Stage 3: Copy binaries only to create the smallest final runtime image
###############################################################################
FROM registry.access.redhat.com/ubi8/ubi-micro@sha256:e74286e0fed10f4ebfcaddd5d7f93a10f914d2ce16951ca95a427a618d9c3421 as runtime

ARG USER=2000

USER ${USER}

#COPY version /etc/modelmesh-version
COPY --from=build /go/bin/server /go/bin/server

CMD ["/go/bin/server"]
