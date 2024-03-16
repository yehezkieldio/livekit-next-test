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

FROM node:21-slim AS runner
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/.env.local ./.env.local

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED 1

COPY --from=builder  /app/.next/standalone ./

EXPOSE 3000
USER bun
CMD ["bun", "run", "start"]

# # use the official Bun image
# # see all versions at https://hub.docker.com/r/oven/bun/tags
# FROM oven/bun:1 as base
# WORKDIR /usr/src/app

# # install dependencies into temp directory
# # this will cache them and speed up future builds
# FROM base AS install
# RUN mkdir -p /temp/dev
# COPY package.json bun.lockb /temp/dev/
# RUN cd /temp/dev && bun install --frozen-lockfile


# # copy node_modules from temp directory
# # then copy all (non-ignored) project files into the image
# FROM base AS prerelease
# COPY --from=install /temp/dev/node_modules node_modules
# COPY . .
# RUN ls -la
# COPY .env.local .env.local
# ENV NODE_ENV=production
# ENV NEXT_TELEMETRY_DISABLED 1
# RUN bun next telemetry disable
# RUN bun run build

# # copy production dependencies and source code into final image
# FROM base AS release
# COPY --from=install /temp/dev/node_modules node_modules
# COPY --from=prerelease /usr/src/app/.next .next

# COPY --from=prerelease /usr/src/app/tsconfig.json .
# COPY --from=prerelease /usr/src/app/tailwind.config.ts .
# COPY --from=prerelease /usr/src/app/next-env.d.ts .
# COPY --from=prerelease /usr/src/app/app app
# COPY --from=prerelease /usr/src/app/package.json .
# COPY --from=prerelease /usr/src/app/public public
# COPY --from=prerelease /usr/src/app/.env.local .env.local
# COPY --from=prerelease /usr/src/app/next.config.mjs next.config.mjs

# # run the app
# USER bun
# # EXPOSE 3000/tcp
# ENTRYPOINT [ "bun", "run", "start" ]