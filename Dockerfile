FROM caddy:2.5.2-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ARG version=HEAD

RUN apk add --no-cache rsync=3.2.3-r5 openssh=8.8_p1-r1 ruby=3.0.4-r0

COPY etc/ /etc
COPY cleanup.rb /usr/local/bin

# The -D switch sets the password hash to "!". As no password hashes
# to this string, this disables password login. However, ! is also
# interpreted to mean locked, so SSH key logins wont work either. So
# change it to "*" which matches no hashes either, but isn't locked.
RUN adduser -Dh /srv store && \
        echo "store:*" | chpasswd -e && \ 
        mkdir /srv/backstore && \
        chown -R store.store /srv


# Use S6-overlay as init.
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /; \
        rm -f /tmp/s6-overlay-amd64.tar.gz
# Export env to s6 started services.
ENV S6_KEEP_ENV 1

LABEL org.opencontainers.image.version=${version}
LABEL org.opencontainers.image.title=Backstore
LABEL org.opencontainers.image.description="simple image for storing BackstopJS reports"
LABEL org.opencontainers.image.url=https://github.com/reload/backstore
LABEL org.opencontainers.image.documentation=https://github.com/reload/backstore
LABEL org.opencontainers.image.vendor="Reload"
LABEL org.opencontainers.image.licenses=Apache-2.0
LABEL org.opencontainers.image.source="https://github.com/reload/backstore"

EXPOSE 80
EXPOSE 1985

ENTRYPOINT ["/init"]
