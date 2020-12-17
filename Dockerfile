FROM caddy:2.1.1-alpine

RUN apk add --no-cache rsync openssh

ADD etc/ /etc

# The -D switch sets the password hash to "!". As no password hashes
# to this string, this disables password login. However, ! is also
# interpreted to mean locked, so SSH key logins wont work either. So
# change it to "*" which matches no hashes either, but isn't locked.
RUN adduser -Dh /srv store && \
        echo "store:*" | chpasswd -e && \ 
        chown store.store /srv

# Use S6-overlay as init.
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.8.0/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /; \
        rm -f /tmp/s6-overlay-amd64.tar.gz
# Export env to s6 started services.
ENV S6_KEEP_ENV 1

ENTRYPOINT ["/init"]
