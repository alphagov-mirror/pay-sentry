FROM sentry:9

ARG CHAMBER_URL=https://github.com/segmentio/chamber/releases/download/v1.15.0/chamber-v1.15.0-linux-amd64

ADD src/files/chamber.sha256sum /tmp/chamber.sha256sum
RUN apt-get update && apt-get -y install openssl wget && \
    wget -qO /usr/bin/chamber $CHAMBER_URL && \
    sha256sum -c /tmp/chamber.sha256sum && \
    chmod 755 /usr/bin/chamber && \
    apt-get -y remove openssl wget

EXPOSE 9000

WORKDIR /app

ADD src/docker-startup.sh /app/docker-startup.sh
ADD src/run-with-chamber.sh /app/run-with-chamber.sh

USER sentry
CMD bash ./docker-startup.sh
