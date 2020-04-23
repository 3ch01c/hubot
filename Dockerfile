# This container is used to build a Hubot.
FROM node:13-buster-slim AS builder

# Create an unprivileged user because [Yeoman doesn't run as root](https://github.com/yeoman/yeoman/issues/1179)
RUN adduser --system --uid 1001 --home /hubot --shell /bin/bash hubot

# Give user write access to /usr/local
RUN chown -R 1001 /usr/local

# Switch to user environment
USER hubot
WORKDIR /hubot

# Install node packages
RUN npm i -g coffeescript \
  yo \
  yeoman-generator@^0.18.10 \
  generator-hubot

# Custom build arguments
ARG HUBOT_ADAPTER="shell"
ARG HUBOT_DESCRIPTION="Delightfully aware robutt"
ARG HUBOT_NAME="Hubot"
ARG HUBOT_OWNER="Bot Wrangler <bw@example.com>"

# Build hubot
RUN yo hubot --adapter="${HUBOT_ADAPTER}" \
  --description="${HUBOT_DESCRIPTION}" \
  --name="${HUBOT_NAME}" \
  --owner="${HUBOT_OWNER}" \
  --defaults

# Remove hubot-scripts.json because it's [deprecated](https://github.com/github/hubot-scripts/issues/1113)
RUN rm -f hubot-scripts.json

# Install Hubot dependencies
RUN npm i

# Install user-defined packages
ARG HUBOT_PACKAGES
RUN npm i -S ${HUBOT_PACKAGES}

# Add custom scripts
COPY external-scripts.json .
RUN npm i -S $(tr -d '\n' < external-scripts.json | sed -E 's/("|,|\[|\]|\n)/ /g')
COPY scripts .

# Patch vulnerabilities
RUN npm audit fix

# Create runtime container
FROM node:13-buster-slim
LABEL maintainer="5547581+3ch01c@users.noreply.github.com"

# Switch to app context
WORKDIR /hubot

# Copy hubot code from builder image. We have to chown it to 0 because yo.
COPY --from=builder --chown=0 /hubot .

ARG HUBOT_PORT=8080
ENV HUBOT_PORT="${HUBOT_PORT}"
EXPOSE "${HUBOT_PORT}"

# Run hubot
ARG HUBOT_ADAPTER="shell"
ENV HUBOT_ADAPTER="${HUBOT_ADAPTER}"
ENTRYPOINT ["bin/hubot"]
