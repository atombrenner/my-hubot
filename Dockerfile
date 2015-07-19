FROM alpine:latest

RUN apk add --update nodejs
RUN npm install -g npm

# now we create a hubot
RUN npm install -g yo generator-hubot

# Create and login as hubot user (will not run as root)
RUN	adduser hubot -h /hubot -s /bin/sh -D
USER	hubot
WORKDIR /hubot

# Copy Hubot sources to images
COPY hubot /hubot

# And go
ENTRYPOINT ["/bin/sh", "-c", "cd ~; ls; env; node get-secrets.js; cat secrets.sh"]
#CMD ["/bin/sh", "-c", "node get-secrets.js; ./secrets.sh; ./bin/hubot --adapter slack"]
