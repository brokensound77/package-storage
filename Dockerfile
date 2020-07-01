# Here the version of the registry is specified this storage branch uses.
# It should always be a specific version to make sure builds are reproducible.
ARG PACKAGE_REGISTRY=cbd9baa8e0f8fe6b55b1f4efb1e69d89ac145b7c
FROM docker.elastic.co/package-registry/package-registry:${PACKAGE_REGISTRY}

LABEL package-registry=${PACKAGE_REGISTRY}

# Adds specific config and packages
COPY deployment/package-registry.yml /registry/config.yml
COPY packages /packages/snapshot

RUN git clone https://github.com/elastic/package-storage
WORKDIR /registry/package-storage

# Get in production packages
RUN git checkout production
RUN cp -r packages /packages/production

# Get in staging packages
RUN git checkout staging
# If empty, create it. There might be no packages in staging. Otherwise cp fails
RUN mkdir -p packages
RUN cp -r packages /packages/staging

WORKDIR /registry

# Cleanup
RUN rm -r packages package-storage

# Sanity check on the packages. If packages are not valid, container does not even build.
RUN ./package-registry -dry-run