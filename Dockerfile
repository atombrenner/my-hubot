FROM alpine:latest

RUN apk add --update nodejs
RUN npm install -g npm

# now we create a hubot
RUN npm install -g yo generator-hubot

# Create and login as hubot user (will not run as root)
RUN	adduser hubot -h /hubot -s /bin/sh -D
USER	hubot
WORKDIR /hubot

# Install hubot
RUN yo hubot --owner="Rodemaster <werbung@atombrenner.de>" --name="bot" --description="thats classified" --adapter="slack"  --defaults
RUN npm install aws-sdk

# Activate some built-in scripts
#ADD hubot/hubot-scripts.json /hubot/
#ADD hubot/external-scripts.json /hubot/

#RUN npm install cheerio --save && npm install
#ADD hubot/scripts/hubot-leitwerk.coffee /hubot/scripts/
#ADD hubot/scripts/hubot-lunch.coffee /hubot/scripts/

# And go
ADD get-secrets.js /hubot/get-secrets.js
CMD ["/bin/sh", "-c", "node get-secrets.sh; ./secrets.sh;"]
#CMD ["/bin/sh", "-c", "node get-secrets.sh; ./secrets.sh; ./bin/hubot --adapter slack"]
