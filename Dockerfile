# syntax=docker/dockerfile:1

# ── Build stage ──────────────────────────────────────────────────────────────
FROM alpine:3.20 AS builder

ARG ZIG_VERSION=0.15.2

RUN apk add --no-cache curl xz sqlite-dev

RUN curl -fsSL \
    "https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz" \
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

RUN apk add --no-cache ca-certificates sqlite-libs

COPY --from=builder /src/zig-out/bin/nullclaw /usr/local/bin/nullclaw

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r//' /usr/local/bin/docker-entrypoint.sh \
  && chmod +x /usr/local/bin/docker-entrypoint.sh

RUN addgroup -S nullclaw && adduser -S nullclaw -G nullclaw
USER nullclaw

WORKDIR /home/nullclaw

ENV PORT=3000

ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]