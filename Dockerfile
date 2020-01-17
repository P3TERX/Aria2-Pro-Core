ARG BUILDER_IMAGE

FROM ${BUILDER_IMAGE:-debian:testing} AS builder

ARG BUILD_SCRIPT

COPY ${BUILD_SCRIPT:-aria2-gnu-linux-build.sh} .

RUN bash ${BUILD_SCRIPT:-aria2-gnu-linux-build.sh}

FROM scratch

COPY --from=builder /root/output /
