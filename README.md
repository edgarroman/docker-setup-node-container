# File Structure


```
.
└── Main_Project_Directory/
    ├── server-code/
    │   ├── server.js
    │   ├── package.json
    │   ├── # All your other source code files
    │   └── node_modules/
    │       └── # Local dev only (see notes)
    ├── .dockerignore
    ├── Dockerfile
    └── README.md
```

(This graph generated from https://tree.nathanfriend.io/)

### Notes

- The `node_modules` directory will be ignored when building the Docker image.  The directory is included
here for local development.

# Guide

## Local Development

This setup does not include Docker at all. Steps:

1. Navigate to the directory: `cd server-code`
1. First time or if there is no `node_modules` directory, run:`npm install`
1. To start a local server, run: `node server.js`

## Local Testing in Docker

This setup allows you build and run the container locally.  However, when you make code changes,
you'll have to rebuild the container to see the updates.  Also, the `node_modules` folder in the source
directory is ignored and re-created during the build process of the container.

**To build:**

```sh
docker build . -t nodetest1
```

**To run development mode with console messages being printed out to the screen:**

Type Ctrl-C to stop the container

```sh
docker run -ti --rm -p 8080:8080  nodetest1
```

**To run the container in the background without anything printed to the console:**

To stop the container, use the Docker GUI or Docker CLI commands

```sh
docker run -d --rm -p 8080:8080  nodetest1
```


```sh
docker run -ti --rm -v "$(pwd):/home/node/app"  --entrypoint /bin/sh nodetest1
```
