<div align="center">

![logo](.github/assets/revard.png)

# Revard

Revard is a basic implementation of [Lanyard](https://github.com/Phineas/lanyard) for Revolt.

</div>

<hr />

## Index

- [Revard](#revard)
  - [Index](#index)
  - [Introduction](#introduction)
  - [REST API](#rest-api)
    - [Retrieving user information](#retrieving-user-information)
    - [Avatar Endpoint](#avatar-endpoint)
    - [Background Endpoint](#background-endpoint)
  - [WebSocket](#websocket)
  - [Card](#card)
    - [Card Options](#card-options)
  - [Self-hosting](#self-hosting)
    - [Environment variables](#environment-variables)
    - [Docker](#docker)
  - [Contributing](#contributing)
  - [License](#license)

## Introduction

Revard empowers you to effortlessly expose and monitor your Revolt activities.

An instance is currently running at `revard.meppu.boo`. Before using it, you must join [this server](https://revard.meppu.boo/).

## REST API

### Retrieving user information

`GET /api/users/:id`

> Give it a try: https://revard.meppu.boo/api/users/01F6YN5JWMHJFKPDZVYB6434HX

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

### Avatar Endpoint

`GET /api/users/:id/avatar`

Returns the avatar image of the specified user. (It actually redirects 🤓)

### Background Endpoint

`GET /api/users/:id/background`

Returns the background image of the specified user. (It actually redirects 🤓)

## WebSocket

> Check out [this file](https://github.com/meppu/website/blob/main/js/index.js) for an example of WebSocket usage.

Revard's WebSocket functionality is designed to be simpler than that of Lanyard.

You can establish a WebSocket connection by using the `/gateway` endpoint. Revard uses JSON for sending and receiving data.

After connecting, you need to send a ping every 30 seconds. You can accomplish this by sending a `ping` frame or by simply sending the following data:

```json
{ "event": "ping" }
```

To subscribe to one or more users, make use of the `subscribe` event:

```json
{
  "event": "subscribe",
  "ids": ["01H30ENXEN04AJFV7PBF8G8BH3", "01F6YN5JWMHJFKPDZVYB6434HX"]
}
```

By doing so, you will receive real-time updates for the specified users within the `ids` array. If the `ids` is an empty list (`[]`) or `null`, it will unsubscribe from all the subscriptions without returning anything.

To update subscribers, resend the same data with the updated `ids` value.

> ⚠️ Starting from version `0.5.4`, The capability to monitor all members on the server has been removed as a precautionary measure against potential misuse.

## Card

With the new update, Revard now has the capability to render an SVG card for your Revolt profile. This allows you to embed your Revolt profile, for example, in your GitHub README.

The endpoint for the card is available at `/card/:id`. For example:

- `https://revard.meppu.boo/card/01F6YN5JWMHJFKPDZVYB6434HX`
  ![card](https://revard.meppu.boo/card/01F6YN5JWMHJFKPDZVYB6434HX)

### Card Options

You can provide certain options to customize the card using query parameters:

> Anything with `=` requires a value, anything inside `[]` denotes the format of the value.

- `hide_banner`: Hides your profile background.
- `hide_badges`: Hides your badges.
- `hide_status`: Hides your text status.
- `bg_color=[hexadecimal color without #]`: Changes the background color.
- `mask_color=[hexadecimal color without #]`: Changes the color of the semi-transparent mask.

Example usage:

![minimal-card](https://revard.meppu.boo/card/01F6YN5JWMHJFKPDZVYB6434HX?hide_banner&hide_badges)

## Self-hosting

If you prefer not to join our server or want to make it specific to your own server, you can host Revard yourself.

### Environment variables

Before running the bot, you must set the following environment variables:

- `BOT_TOKEN`: Your bot's token. Please note that self-bots are not supported at the moment.
- `REVOLT_SERVER_ID`: The server ID to watch. To avoid conflicts, ensure that your bot is only in one server.
- `REVOLT_SERVER_LINK`: The URL for Revolt server redirection.
- `MONGO_URL`: The URL for MongoDB (must support SSL).
- `PORT`: The port to listen on. If not given, it falls back to 8000.

Additionally, if you are using this bot for another Revolt host, you need to set these special environment variables:

- `REVOLT_WEBSOCKET`: Revolt WebSocket URL. The default is "wss://ws.revolt.chat".
- `REVOLT_API`: Revolt API URL. The default is "https://api.revolt.chat".
- `AUTUMN_URL`: Autumn (Revolt CDN) URL. The default is "https://autumn.revolt.chat".

### Docker

You can use Docker to host your own bot. For example:

```bash
$ docker run --env-file=.env ghcr.io/meppu/revard:latest start
```

## Contributing

You can always report bugs and request features via [GitHub Issues](/issues).

When submitting pull requests, ensure that your code is well-formatted and can adequately explain itself.

## License

Revard is licensed under the MIT License.
