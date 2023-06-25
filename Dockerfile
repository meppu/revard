FROM docker.io/elixir:1.14-alpine AS build

# set build-time environment variables
ENV MIX_ENV=prod

WORKDIR /app

# prepare build folder
ADD . /app/
RUN cd /app

# pre-compile
RUN apk add --update git
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

# compile
RUN mix compile
RUN mix release

FROM docker.io/elixir:1.14-alpine

COPY --from=build /app/_build/prod/rel/revard /release/revard
ENTRYPOINT [ "/release/revard/bin/revard" ]
