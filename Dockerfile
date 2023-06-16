FROM docker.io/elixir:1.14-alpine AS build

ENV MIX_ENV=prod

WORKDIR /app
ADD . /app/
RUN cd /app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

RUN mix compile
RUN mix release

FROM docker.io/elixir:1.14-alpine

COPY --from=build /app/_build/prod/rel/revard /otp/revard

ENTRYPOINT [ "/otp/revard/bin/revard" ]