FROM elixir:1.6-alpine
ENV ELIXIR_ERL_OPTIONS "-proto_dist Elixir.Clusterable.EPMD.Service -epmd_module Elixir.Clusterable.EPMD.Client"
ENV MIX_ENV dev
ENV CONFD_VERSION 0.16.0
RUN apk --no-cache add nodejs
RUN wget -qO /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd 
WORKDIR /app/behaviour_test/elixir
ADD behaviour_test/confd /etc/confd/
ADD mix.exs mix.lock /app/
ADD config /app/config/
ADD behaviour_test/elixir /app/behaviour_test/elixir/
RUN mix do local.hex --force, local.rebar --force, deps.get
ADD lib /app/lib/
ADD behaviour_test/entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT [ "/bin/entrypoint.sh" ]