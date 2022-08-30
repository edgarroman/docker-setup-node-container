# Base node images can be found here: https://hub.docker.com/_/node?tab=description&amp%3Bpage=1&amp%3Bname=alpine
ARG NODE_IMAGE=node:16.17-alpine

#####################################################################
# Base Image 
# 
# All these commands are common to both development and production builds
#
#####################################################################
FROM $NODE_IMAGE AS base
ARG NPM_VERSION=npm@8.18.0

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
RUN npm install -g $NPM_VERSION

# Specific to your framework
#
# Some frameworks force a global install tool such as aws-amplify or firebase.  Run those commands here
# RUN npm install -g firebase

# Create space for our code to live
RUN mkdir -p /home/node/app && chown -R node:node /home/node/app
WORKDIR /home/node/app

# Switch to the `node` user instead of running as `root` for improved security
USER node

# Expose the port to listen on here.  Express uses 8080 by default so we'll set that here.
ENV PORT=8080
EXPOSE $PORT

#####################################################################
# Development build
# 
# These commands are unique to the development builds
#
#####################################################################
FROM base AS development

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
# Production build
# 
# These commands are unique to the production builds
#
#####################################################################
FROM base AS production

# Indicate to all processes in the container that this is a production build
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# Now copy all source code  
COPY --chown=node:node server-code ./
RUN npm install && npm cache clean --force

# Finally, if the container is run in headless, non-interactive mode, start up node
# This can be overridden by the user running the Docker CLI by specifying a different endpoint
CMD ["node","server.js"]

