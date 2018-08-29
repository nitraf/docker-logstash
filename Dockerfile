#FROM jeanblanchard/busybox-java
FROM anapsix/alpine-java:7

# Logstash version
ENV VERSION 1.5.0
ENV LOGSTASH_HOME /opt/logstash
ENV GEM_PATH "$LOGSTASH_HOME/vendor/bundle/jruby/1.9"

# GEM
ENV WEBHDFS_VERSION 0.5.5

#RUN opkg-install bash

RUN apk add --update -t deps wget ca-certificates curl

RUN curl "http://download.elastic.co/logstash/logstash/logstash-$VERSION.tar.gz" \
        | gunzip -c - | tar -xf - -C /opt && \
        mv "/opt/logstash-$VERSION" "$LOGSTASH_HOME" && \
        mkdir "$LOGSTASH_HOME/conf.d" && \
        mkdir -p /usr/local/bin

ENV PATH "$PATH:$LOGSTASH_HOME/vendor/jruby/bin"

# Prerequisites for the logstash-webhdfs plugin
RUN echo "gem \"webhdfs\", \">= $WEBHDFS_VERSION\"" >> "$LOGSTASH_HOME/Gemfile"
RUN gem install --source "http://rubygems.org/" -i "$GEM_PATH" webhdfs -v "$WEBHDFS_VERSION"

COPY conf.d/* "$LOGSTASH_HOME/conf.d/"
COPY plugins/* "$GEM_PATH/gems/logstash-core-$VERSION-java/lib/logstash/outputs/"
COPY start.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/start.sh"]

CMD ["logstash"]
