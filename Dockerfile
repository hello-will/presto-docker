FROM openjdk:8-jre-alpine

ENV PRESTO_VERSION 0.210

RUN apk add --no-cache bash python curl less && \
  mkdir -p /opt/presto && \
  mkdir -p /opt/presto/etc && \
  mkdir -p /opt/presto/etc/catalog && \
  curl https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz -o presto-server.tar.gz && \
  tar xfz presto-server.tar.gz -C /opt/presto --strip-components=1 && \
  rm presto-server.tar.gz && \
  curl https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar -o /usr/local/bin/presto
RUN chmod a+x /usr/local/bin/presto

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8080
CMD [ "help" ]
