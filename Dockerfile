ARG BUILDER_IMAGE=debian:testing

FROM $BUILDER_IMAGE AS builder

ARG BUILD_SCRIPT=aria2-gnu-linux-build.sh

COPY $BUILD_SCRIPT .

RUN bash $BUILD_SCRIPT

FROM scratch

COPY --from=builder /root/output /
