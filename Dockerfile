ARG BUILDER_IMAGE=debian:testing

FROM $BUILDER_IMAGE AS builder

WORKDIR /P3TERX/aria2-builder

COPY . .

ARG BUILD_SCRIPT=aria2-gnu-linux-build.sh

RUN bash $BUILD_SCRIPT

FROM scratch

COPY --from=builder /root/output /
