# --- Build Stage ---
FROM node:20-alpine AS build
WORKDIR /usr/src/app
COPY app/package*.json ./
RUN npm install --omit=dev
RUN npm install -g npm@latest
COPY app/. .

# --- Runtime Stage ---
FROM node:20-alpine
WORKDIR /usr/src/app

RUN apk --no-cache add --virtual .build-deps && \
rm -rf /var/cache/apk/*

# Create a non-root user and switch to it

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=build /usr/src/app .

# Set ownership of the app directory

RUN chown -R appuser:appgroup /usr/src/app

RUN chmod 700  /usr/src/app

USER appuser

HEALTHCHECK --interval=30s --timeout=3s \
CMD node healthcheck.js

# To run with a read-only filesystem, add the --read-only flag to the docker run command.
CMD [ "npm", "start" ]
