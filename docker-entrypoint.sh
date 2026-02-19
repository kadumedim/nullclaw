# syntax=docker/dockerfile:1

# ── Build stage ──────────────────────────────────────────────────────────────
FROM alpine:3.20 AS builder

ARG ZIG_VERSION=0.15.0
ARG TARGETOS=linux
ARG TARGETARCH=x86_64

RUN apk add --no-cache curl xz

# Download the official Zig tarball
RUN curl -fsSL \
    "https://ziglang.org/download/${ZIG_VERSION}/zig-${TARGETOS}-${TARGETARCH}-${ZIG_VERSION}.tar.xz" \
    -o /tmp/zig.tar.xz \
  && mkdir -p /usr/local/zig \
  && tar -xJf /tmp/zig.tar.xz --strip-components=1 -C /usr/local/zig \
  && rm /tmp/zig.tar.xz

ENV PATH="/usr/local/zig:${PATH}"

WORKDIR /src
COPY . .

RUN zig build -Doptimize=ReleaseSmall

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM alpine:3.20

RUN apk add --no-cache ca-certificates

COPY --from=builder /src/zig-out/bin/nullclaw /usr/local/bin/nullclaw

RUN addgroup -S nullclaw && adduser -S nullclaw -G nullclaw
USER nullclaw

WORKDIR /home/nullclaw

# Railway injects PORT; nullclaw gateway reads --port
ENV PORT=3000

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]