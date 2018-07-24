FROM elixir:1.6
RUN wget -qO /usr/local/bin/selenium.jar https://selenium-release.storage.googleapis.com/3.13/selenium-server-standalone-3.13.0.jar && \
    curl -sL https://github.com/mozilla/geckodriver/releases/download/v0.21.0/geckodriver-v0.21.0-linux64.tar.gz | tar xz -C /usr/local/bin && \
    chmod a+x /usr/local/bin/geckodriver
RUN mkdir /opt/firefox && \
    wget -O FirefoxSetup.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar xjf FirefoxSetup.tar.bz2 -C /opt/firefox/ && \
    ln -s /opt/firefox/firefox/firefox /usr/local/bin/firefox && \
    apt-get update && \
    apt-get install -y openjdk-8-jre   libdbus-glib-1-2
ENV MIX_ENV dev
ENV CONFD_VERSION 0.16.0
RUN wget -qO /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd 
WORKDIR /app/behaviour_test/elixir
ADD behaviour_test/confd /etc/confd/
ADD mix.exs mix.lock /app/
ADD config /app/config/
ADD behaviour_test/statics /app/behaviour_test/statics/
ADD behaviour_test/ssl /app/behaviour_test/ssl/
ADD behaviour_test/elixir /app/behaviour_test/elixir/
RUN mix do local.hex --force, local.rebar --force, deps.get
ADD lib /app/lib/
ADD behaviour_test/entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT [ "/bin/entrypoint.sh" ]