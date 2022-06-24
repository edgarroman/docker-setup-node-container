# Base node images can be found here: https://hub.docker.com/_/node?tab=description&amp%3Bpage=1&amp%3Bname=alpine
ARG NODE_IMAGE=node:16.15-alpine

FROM $NODE_IMAGE AS base

# While root is the default user to run as, why not be explicit?
USER root

# Run tini as the init process and it will clean zombie processes as needed
# Generally you can achieve this same effect by adding `--init` in your `docker RUN` command
# And Nodejs servers tend not to spawn processes, so this is belt and suspenders
# More info: https://github.com/krallin/tini
RUN apk add --no-cache tini
# Tini is now available at /sbin/tini
ENTRYPOINT ["/sbin/tini", "--"]

# Upgrade some global packages
RUN npm install -g npm@8.5.4

# Specific to your framework
#
# Some frameworks force a global install tool such as aws-amplify or firebase.  Run those commands here
# RUN npm install -g firebase

# Expose the port to listen on here.  Express uses 8080 by default so we'll set that here.
ENV PORT=8080
EXPOSE $PORT

# Create space for our code to live
RUN mkdir -p /home/node/app && chown node:node /home/node/app
WORKDIR /home/node/app

# Switch to the `node` user instead of running as `root` for improved security
USER node

# Copy the package.json file over and run `npm install`
COPY server-code/package*.json ./
RUN npm install

# Now copy rest of the code.  We separate these copies so that Docker can cache the node_modules directory
# So only when you add/remove/update package.json file will Docker rebuild the node_modules dir.
COPY server-code ./

# Finally, if the container is run in headless, non-interactive mode, start up node
# This can be overridden by the user running the Docker CLI by specifying a different endpoint
CMD ["npm","start"]


#####################################################################
#
# Finish with: https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
#
#FROM base AS production
#ENV NODE_ENV=production
#RUN npm ci --only=production

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
#COPY package*.json ./
#COPY server-code/package*.json ./
#RUN npm install

# If you are building your code for production
# RUN npm ci --only=production

#FROM base AS dependencies
#COPY --chown=node:node ./package*.json ./
#RUN npm ci
#COPY --chown=node:node . .

#
#FROM base AS production
#ENV NODE_ENV=production
#ENV PORT=$PORT
#ENV HOST=0.0.0.0
#COPY --chown=node:node ./package*.json ./
#RUN npm ci --production
#COPY --chown=node:node --from=build /home/node/app/build .
#EXPOSE $PORT
#CMD [ "dumb-init", "sails", "lift" ]
#CMD ["node","server.js"]

