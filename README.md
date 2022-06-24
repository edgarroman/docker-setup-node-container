# Overview

Recently, using Docker to develop applications is becoming popular.  This repo documents a number of reasonable
workflows for developers to set up and manage a Node app with a single codebase.  If you have many microservices
or other infrastructure to setup (such as automatically deploying a database), then you'll probably
want to augment this workflow.

## Goals

- Focus on Node.js environment
- Allow local development without Docker
- Allow local development with Docker
- Allow easy scripts to build container images
- Isolate container scripts from source code
- Be straightforward, but explain all the steps so modifications can be made

# Directory Structure and Files

You'll want to start with a simple directory structure.

```
.
└── Main_Project_Directory/
    ├── server-code/
    │   ├── server.js
    │   ├── package.json
    │   ├── # All your other source code files
    │   └── node_modules/
    │       └── # Local dev only (see notes)
    ├── .gitignore
    ├── .dockerignore
    ├── Dockerfile
    └── README.md
```

(This graph generated on https://tree.nathanfriend.io/)

### **Notes**

- The `server-code` directory is an arbitrary name.
You may rename it, but be sure to update all the references in the Dockerfiles and Docker commands.
The purpose of this subdirectory is to isolate your server code from all the container stuff.

- The `node_modules` directory will be ignored when using Docker.
The directory is used during local development without containers.
More details are below.

# Workflow Guide

We'll explore four workflows of developing, running, and testing your code:

1. Local development without containers
1. Local development with containers
1. Local testing in a container
1. Production build

This section describes how to use the workflows, but does not get into the details of the container setup.
We'll explain the container setup in a later section.

## Local development without containers

This workflow does not use Docker at all.
This allows you to develop your code locally on your system with the least number of abstractions and complications.  

This means that your local system is directly running Node and directly loading your code.
This workflow will requires the least amount of processing power by your machine
and will provide the most responsive development environment.
When you make changes to your code, they be reflected as quickly as possible.  
(By the way, we're using `nodemon` to
detect changes to the code and have Node reloaded to recognize those changes.)

The downside to this approach is that most likely your local machine
is not running the operating system that your final container will be running.
If you're running Windows, MacOS, or even some flavors of Linux, the packages used locally
may not be identical to those ultimately used in production.

The differences these packages have between platforms could inject subtle bugs and errors that would be confounding and difficult to debug.
While many straightforward Javascript packages may be identical between platforms,
there also may be differences when your code needs to interact with the host machine's operating system.  

With the pitfalls noted above, why should you take this approach?  
In my experience, it's faster and easier to this approach when developing most applications.
You don't need to spin up Docker and it uses less CPU cycles
on your local machine.  I prefer it when working on a project by myself that does not need collaboration.  
When I do collaborate with others, it's best to use one of the other approaches below.

### Steps to get up and running

1. Navigate to the directory: `cd server-code`
1. First time or if there is no `node_modules` directory, run: `npm install` or `yarn` if you prefer
1. To start the local server, run: `npm start`

## Local Development with Containers Workflow

This workflow allows you to develop by running your code container environment.
This container environment matches exactly what you will be deploying to production.


 so you can run your code in the actual environment 
of production.  

## Local Testing in Docker (without live code updates)

This setup allows you build and run the container locally.  However, when you make code changes,
you'll have to rebuild the container to see the updates.  Also, the `node_modules` folder in the source
directory is ignored and re-created during the build process of the container.

### To build

```sh
docker build . -t nodetest1
```

### To run development mode with console messages being printed out to the screen:

Type Ctrl-C to stop the container

```sh
docker run -ti --rm -p 8080:8080  nodetest1
```

### To run the container in the background without anything printed to the console

To stop the container, use the Docker GUI or Docker CLI commands

```sh
docker run -d --rm -p 8080:8080  nodetest1
```

### To start the container and get a shell prompt so you can look around

This is very useful during debugging of the container to see where files and directories live

```sh
docker run -ti --rm --entrypoint /bin/sh nodetest1
```


```sh
docker run -ti --rm -p 8080:8080 -v "$(pwd)/server-code:/home/node/app" -v /home/node/app/node_modules nodetest1
```

 
```sh
docker run -ti --rm -p 8080:8080 -v "$(pwd)/server-code:/home/node/app" -v /home/node/app/node_modules --entrypoint /bin/sh nodetest1
```
