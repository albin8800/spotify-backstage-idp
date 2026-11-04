# ==========================================                                                                                                                                                                                          
# Stage 1: Build Environment
# ==========================================
FROM node:24-bookworm-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 \
      g++ \
      make \
      git \
      libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app                                                                                                                                                                                                                          
                                                                                                                                                                                                                                      
# Copy Yarn 4 config and manifests from portal/                                                                                                                                                                                       
COPY portal/.yarn ./.yarn                                                                                                                                                                                                             
COPY portal/.yarnrc.yml ./                                                                                                                                                                                                            
COPY portal/package.json portal/yarn.lock portal/backstage.json ./

# Copy package manifests from portal/
COPY portal/packages/app/package.json packages/app/
COPY portal/packages/backend/package.json packages/backend/

# Install dependencies using Yarn 4
RUN yarn install --immutable

# Copy all portal source code and build
COPY portal/ .
RUN yarn tsc
RUN yarn build:backend

# ==========================================
# Stage 2: Production Runtime
# ==========================================
FROM node:24-bookworm-slim AS runner

RUN apt-get update && \
    apt-get install -y --no-install-recommends tini libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV NODE_ENV=production

# Copy Yarn files and manifests for production install
COPY portal/.yarn ./.yarn
COPY portal/.yarnrc.yml ./
COPY portal/backstage.json portal/yarn.lock portal/package.json ./

# Copy skeleton from builder and install production dependencies
COPY --from=builder /app/packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# Copy backend bundle and configs
COPY --from=builder /app/packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz
COPY --from=builder /app/app-config*.yaml ./

USER node
EXPOSE 7007

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
