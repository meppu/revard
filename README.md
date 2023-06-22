<div align="center">

![logo](.github/assets/revard.png)

# Revard

Revard is a basic [Lanyard](https://github.com/Phineas/lanyard) implementation for Revolt.

</div>

<hr />

Revard allows you to expose your Revolt activities throught WebSocket easily.

An instance is currently running at `revard.meppu.boo`, You must join [this server](https://revard.meppu.boo/) before using it.

## REST API

### Getting an user's informations

`GET /api/users/:id`

> Try it out: https://revard.meppu.boo/api/users/01F6YN5JWMHJFKPDZVYB6434HX

Example response:

```json
{
  "_id": "01H30ENXEN04AJFV7PBF8G8BH3",
  "avatar": {
    "_id": "3BwmoTaiAoIBunlZxpVyi4s6TOpmS-BG8YDB0ItXjt",
    "content_type": "image/png",
    "filename": "FwMNRM3WYBQ5w4j.png",
    "metadata": {
      "height": 400,
      "type": "Image",
      "width": 427
    },
    "size": 81008,
    "tag": "avatars"
  },
  "badges": 0,
  "bot": {
    "owner": "01F6YN5JWMHJFKPDZVYB6434HX"
  },
  "discriminator": "2007",
  "online": true,
  "username": "Glowie"
}
```

`GET /api/users/:id/avatar`

Returns user's avatar image (actually redirects 🤓)

`GET /api/users/:id/background`

Returns user's background image (actually redirects 🤓)

## WebSocket

> Check out [this file](https://github.com/meppu/website/blob/main/js/index.js) for example WebSocket usage.

Revard's WebSocket is actually way simpler than Lanyard.

You can connect WebSocket from `/gateway` endpoint. Revard uses JSON for sending/receiving data.

After connection, you need to send a ping every 30 second. This can be done with sending `ping` frame, or just sending following data:

```json
{ "event": "ping" }
```

To subscribe one or more user, You can use `subscribe` event:

```json
{
  "event": "subscribe",
  "ids": ["01H30ENXEN04AJFV7PBF8G8BH3", "01F6YN5JWMHJFKPDZVYB6434HX"]
}
```

Now you will receive updates for users in `ids`. If you want to watch whole server, you can just send an empty array. If you don't want to watch anything, set it to `null`.

To update subscribers, just send same thing again with updated `ids` value.

## Self-hosting

If you don't want to join our server, or make it special for your own server, you can host it yourself.

### Environment variables

You must set some environment variables before running the bot:

- `BOT_TOKEN`: Your bot's token, self-bots are not supported right now.
- `REVOLT_SERVER_ID`: Server ID to watch. Please keep your bot in only one server to avoid conflicts.
- `REVOLT_SERVER_LINK`: Server URL for redirecting.
- `MONGO_URL`: MongoDB URL (must support SSL).
- `PORT`: Port to listen, fallbacks to 8000 if not given.

And some special environment variables if you use this bot for another Revolt host:

- `REVOLT_WEBSOCKET`: Revolt websocket url, default is "wss://ws.revolt.chat".
- `REVOLT_API`: Revolt API url, default is "https://api.revolt.chat".
- `AUTUMN_URL`: Autumn (Revolt CDN) url, default is "https://autumn.revolt.chat".

### Docker

You can use Docker to host your own bot, for example:

```bash
$ docker run --env-file=.env ghcr.io/meppu/revard:latest start
```

## Contributing

You can always report bugs and request features via [GitHub Issues](/issues).

For pull requests, make sure your code is well-formatted and at least can explain itself.

## License

Revard is licensed under the MIT License.
