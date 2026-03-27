# Stage 1: Build the application
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# Create a non-root user and group with a fixed UID/GID for consistency with distroless images
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
# Set ownership of the application directory to the non-root user
RUN chown -R appuser:appgroup /app

# Stage 2: Create the distroless image
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=build /app/index.js .
COPY --from=build /app/package.json .
COPY --from=build /app/healthcheck.js .
# Set the user to the non-root user (e.g., nonroot with UID 65532, common in distroless)
USER 65532:65532

# Command to run the application
# Sensitive environment variables (e.g., MY_SECRET) should be passed at runtime using `docker run -e`
# or managed via Docker Secrets/volume mounts in production environments.
CMD ["node", "index.js"]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD ["node", "healthcheck.js"]