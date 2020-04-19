# This container is used to build a Hubot.
FROM node:13-buster-slim AS builder

ARG HUBOT_ADAPTER="shell"
ARG HUBOT_DESCRIPTION="Delightfully aware robutt"
ARG HUBOT_NAME="Hubot"
ARG HUBOT_OWNER="Bot Wrangler <bw@example.com>"

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

# Build hubot
RUN yo hubot --adapter="${HUBOT_ADAPTER}" \
  --description="${HUBOT_DESCRIPTION}" \
  --name="${HUBOT_NAME}" \
  --owner="${HUBOT_OWNER}" \
  --defaults

# Remove hubot-scripts.json because it's [deprecated](https://github.com/github/hubot-scripts/issues/1113)
RUN rm -f hubot-scripts.json

# Create runtime container
FROM node:13-buster-slim
LABEL maintainer="5547581+3ch01c@users.noreply.github.com"

ARG HUBOT_ADAPTER="shell"
ENV HUBOT_ADAPTER="${HUBOT_ADAPTER}"
ARG HUBOT_PACKAGES
ARG HUBOT_PORT=8080
ENV HUBOT_PORT="${HUBOT_PORT}"

EXPOSE "${HUBOT_PORT}"

# Switch to app context
WORKDIR /hubot

# Copy hubot code from builder image. We have to chown it to 0 because yo.
COPY --from=builder --chown=0 /hubot .

# Add custom scripts
COPY external-scripts.json .
COPY scripts .

# Install the things
RUN npm i
# Install external scripts
RUN npm i -S $(tr -d '\n' < external-scripts.json | sed -E 's/("|,|\[|\]|\n)/ /g')
# Install other packages
RUN npm i -S ${HUBOT_PACKAGES}

# Patch vulnerabilities
RUN npm audit fix

# The entrypoint script handles setting up the environment on run
COPY entrypoint.sh .

# Run hubot
ENTRYPOINT ["sh", "-c", "./entrypoint.sh"]
CMD ["-a", "${HUBOT_ADAPTER}", "-n", "${HUBOT_NAME}"]
