# Hubot

This is a [Dockerized](https://www.docker.com/) version of [Hubot](https://github.com/hubotio/hubot).

## Quick Start

Start up a chat bot that runs in an interactive shell.

```sh
$ docker run -it 3ch01c/hubot

Hubot> @hubot ping
Hubot> PONG
```

That's fun, but you probably wanted something more functional that would connect to your
team's chat, right?

If you use [Docker Compose](https://docs.docker.com/compose/), this repository
already has a [docker-compose.yml](docker-compose.yml) with a bunch of nifty
features to get you started, but you probably want to configure at least a [chat
adapter](#chat-adapters) for a team chat. Maybe a different name, too. Some things, like your bot's
name, can be configured at runtime with [`environment` arguments](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file) or environment
files like [hubot.env](hubot.env). You might also need to configure API keys or other runtime variables depending on the chat adapter you use.

```sh
cat <<'EOF' > hubot.env
HUBOT_HELP_REPLY_IN_PRIVATE=true
HUBOT_NAME=hubot
HUBOT_SLACK_TOKEN=xoxb-YOUR-TOKEN-HERE
REDIS_URL=redis://redis:6379/hubot
EOF
docker run --env-file=hubot.env hubot
```

Other things, like adding chat adapters, have to be configured at build-time
using [`build-arg`
arguments](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg)
or a [`.env` file](https://docs.docker.com/compose/env-file/) because the
container has to be rebuilt to install them.

```sh
docker build --build-arg HUBOT_ADAPTER="slack" -t hubot . # or `docker-compose build` after you update build args.
```

Note that environment files like [hubot.env](hubot.env) are not used during the
build process, only a `.env` file if you have one.

## Configuration

### Building Your Bot

You can use `docker-compose build` or `docker build` to build your own bot. Some common reasons
for building your own bot are to change the [chat
adapter](https://hubot.github.com/docs/adapters/) and to add
[scripts](#extending-your-bot).

<a name="chat-adapters"></a>
Changing the adapter is done by changing the `HUBOT_ADAPTER` build argument which defaults to the
[Campfire adapter](https://hubot.github.com/docs/adapters/campfire/). There's [a
lot of adapters on NPM](https://www.npmjs.com/search?q=hubot-adapter). If you want to connect your bot to
[Slack](https://slack.com/), use the
[hubot-slack](https://www.npmjs.com/package/hubot-slack) package.

```sh
docker build --build-arg HUBOT_ADAPTER="slack" -t hubot . # or `docker-compose build` after you update build args.
```

Note that the
`hubot-` prefix is omitted for chat adapters. If you use the provided
[docker-compose.yml](docker-compose.yml), you can change the chat adapter under
the `args` block. See the [docker
build](https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables---build-arg)
and [Compose file](https://docs.docker.com/compose/compose-file/#args)
documentation for more information on how to supply build arguments.

Depending on the chat adapter, you
might need to provide additional environment variables at runtime. For example, the Slack adapter requires
`HUBOT_SLACK_TOKEN`.

```sh
docker run -e HUBOT_SLACK_TOKEN=<your slack token here> hubot
```

If you use the provided [docker-compose.yml](docker-compose.yml), you can add these variables to
`environment` block or to [hubot.env](hubot.env). Just remember that variables in the
`environment` block trump environment files.

<a name="extending-your-bot"></a>

### Extending Your Bot

You can also give your bot extra functionality by adding [scripts](https://hubot.github.com/docs/scripting/) to
`external-scripts.json`, then rebuilding the container to make them available to
your bot. There's also [a lot of scripts on NPM](https://www.npmjs.com/search?q=hubot-scripts).

```sh
sed -i '' 's/]/, "hubot-vtr-scripts"]/' external-scripts.json # one way to add another script to external-scripts.json
docker build --build-arg HUBOT_ADAPTER="slack" -t hubot . # or `docker-compose build`
```

Conversely, you can remove scripts from
[external-scripts.json](external-scripts.json) if you don't want your bot to
have those abilities. If you use the provided
[docker-compose.yml](docker-compose.yml), `external-scripts.json` will be bind mounted to the container,
and the abilities will become unavailable, but if you really want to uninstall those packages from the
container, you need to either rebuild it or go in and manually remove them.

```sh
sed -i '' 's/, "hubot-vtr-scripts"//' external-scripts.json
# optional: docker build --build-arg HUBOT_ADAPTER="slack" -t hubot . or `docker-compose build`
docker run -v ./external-scripts.json:/hubot/external-scripts.json hubot # or `docker-compose restart`
```

### Developing Scripts

If you want to make your own scripts, you can use the `scripts` directory for
developing and testing them. You should eventually [publish them as a module to
NPM](https://docs.npmjs.com/packages-and-modules/contributing-packages-to-the-registry), though. If you use the provided [docker-compose.yml](docker-compose.yml),
the `scripts` directory will be bind mounted to the container at runtime, and
the scripts will be available to your bot the next time you `docker-compose restart`.

````sh
docker run -v ./scripts:/hubot/scripts hubot # or `docker-compose restart`
```

If your scripts require additional packages, you should
add them to the `HUBOT_PACKAGES` build argument and rebuild the container.

```sh
docker build --build-arg HUBOT_ADAPTER="slack" --build-arg HUBOT_PACKAGES="lodash" -t hubot .
````

### Persistence

If you use the provided [docker-compose.yml](docker-compose.yml), the included
Redis server provides your bot with a persistent memory across restarts. If you
want to share the same Redis server with multiple bots, but want them each to
have their own memory, change the `REDIS_URL` to something unique for each bot,
like their names (e.g., `redis://redis:6379/ada`, `redis://redis:6379/jarvis`).

## Troubleshooting

If your container won't build or crashes on run, try overriding the entrypoint
with `/bin/bash` to look around and test things. It's
[Debian-based](https://hub.docker.com/_/debian) which hopefully makes it easier
to troubleshoot.

```sh
docker run -it --rm --entrypoint /bin/bash hubot
apt update && apt install -y curl && curl example.com
```

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
