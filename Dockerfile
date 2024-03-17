FROM imbios/bun-node:21-slim AS deps
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && \
  apt-get install -yq openssl git ca-certificates tzdata && \
  ln -fs /usr/share/zoneinfo/Asia/Makassar /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata
WORKDIR /app

COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

FROM deps AS builder
WORKDIR /app
COPY . .

RUN bun run build

FROM imbios/bun-node:21-slim AS runner
WORKDIR /app

COPY --from=deps /app/node_modules node_modules
COPY --from=builder /app/.env.local .env.local

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED 1

COPY --from=builder  /app/package.json .
COPY --from=builder  /app/.next .next
COPY --from=builder  /app/public public

RUN ls -a

EXPOSE 3000
CMD ["bun", "start"]
