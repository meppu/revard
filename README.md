# Revard

Revard is a basic [Lanyard](https://github.com/Phineas/lanyard) implementation for Revolt.

Revard allows you to expose your Revolt activities real-time with low latency.

## REST API

### Getting an user's informations

`GET /api/users/:id`

> Example Response

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

## WebSocket

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

## Contributing

You can always report bugs and request features via [GitHub Issues](/issues).

For pull requests, make sure your code is well-formatted and at least can explain itself.

## License

Revard is licensed under the MIT License.
