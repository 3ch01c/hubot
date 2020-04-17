# Hubot

This is a [Dockerized](https://www.docker.com/) version of [Hubot](https://github.com/hubotio/hubot).

## Quick Start

If you use [Docker Compose](https://docs.docker.com/compose/), this repository
already has a [docker-compose.yml](docker-compose.yml) to get you started. It's
recommended to configure your runtime environment in environment files like
like [hubot.env](hubot.env). Learn
more about environment files from the [docker run](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file)
and [Compose file](https://docs.docker.com/compose/compose-file/#env_file) docs.

```sh
cat <<'EOF' > hubot.env
HUBOT_ADAPTER=slack
HUBOT_AUTH_ADMIN=
HUBOT_HELP_REPLY_IN_PRIVATE=true
HUBOT_NAME=hubot
HUBOT_SLACK_TOKEN=
REDIS_URL=redis://redis:6379/hubot
EOF
```

Once you have things configured, bring up the stack.

```sh
docker-compose up
```

## Customization

### Building Your Own Bot

You can use `docker-compose build` or `docker build` to build your own bot. Some common reasons
for building your own bot are to change the [chat
adapter](https://hubot.github.com/docs/adapters/) and to add
[scripts](#extending-your-bot).

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
the `HUBOT_SLACK_TOKEN`.

```sh
docker run -e HUBOT_SLACK_TOKEN=<your slack token here> hubot
```

If you use the provided
[docker-compose.yml](docker-compose.yml), you can add these variables to
[hubot.env](hubot.env).

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
[docker-compose.yml](docker-compose.yml), this file will be bind mounted to the container,
and the abilities will become unavailable the next time you `docker-compose restart`, but if you want to completely remove those packages from the
container, you need to rebuild it.

```sh
sed -i '' 's/, "hubot-vtr-scripts"//' external-scripts.json
# optional: docker build --build-arg HUBOT_ADAPTER="slack" -t hubot . or `docker-compose build`
docker run -v ./external-scripts.json:/hubot/external-scripts.json hubot # or `docker-compose restart`
```

### Developing Scripts

If you want to make your own scripts, you can use the `scripts` directory for
developing and testing them. You should eventually publish them as a module to
NPM, though. If you use the provided [docker-compose.yml](docker-compose.yml),
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
with `/bin/bash` to look around inside.

```sh
docker run -it --rm --entrypoint /bin/bash hubot
```

## License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).
