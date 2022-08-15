# Overview

Recently, using Docker to develop applications is becoming popular.
This repo documents a number of reasonable workflows for developers to set up and manage a Node app with a single codebase.
If you have many microservices or other infrastructure to setup
(such as a separate container for a database), then you'll probably
want to augment this workflow.

## Goals

-   Focus on Node.js environment
-   Allow local development without Docker
-   Allow local development with Docker
-   Provide scripts to build container images for testing and production
-   Isolate container scripts from source code
-   Be straightforward, but explain all the steps so modifications can be made

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

-   The `server-code` directory is an arbitrary name.
    You may rename it, but be sure to update all the references in the Dockerfiles and Docker commands.
    The purpose of this subdirectory is to isolate your server code from all the container stuff.

-   The `node_modules` directory will be ignored when using Docker.
    The directory is used during local development without containers.
    More details are below.

# Workflow Guide

We'll explore workflows of developing and testing your code:

1. Local development without containers
1. Local development with containers
1. Production Build and Local Testing with containers

This section describes how to use the workflows, but does not get into the details of the container setup.
We'll explain the container setup later.

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
on your local machine. I prefer it when working on a project by myself that does not need collaboration.  

When I do collaborate with others, it's best to use one of the other approaches below.

### Steps to get up and running

1. Navigate to the directory: `cd server-code`
1. First time or if there is no `node_modules` directory, run: `npm install` or `yarn` if you prefer
1. To start the local server, run: `npm start`

This should look very familiar to many developers since it's the default approach most folks take when developing a Node app.

## Local Development with Containers Workflow

This workflow allows you to develop by running your code in a container environment.
This container environment matches almost exactly what you will be deploying to production.

This is a development workflow where you can still edit your source code
and any updates will be reflected in the server. We are still using
`nodemon` to detect source code changes and reload Node.

### Steps to get up and running

1. Start Docker on your local machine
1. Navigate to the main project directory (not in `server-code`)
1. If this the first time you are running the container, or if you have changed _any_ package dependencies, then run:

    ```sh
    docker build . -t mynodeapp --target=development
    ```

1. Run the following command:
    ```sh
    docker run -ti --rm -p 8080:8080 -v "$(pwd)/server-code:/home/node/app" -v /home/node/app/node_modules mynodeapp
    ```

What you should see is Docker will start to run your container
in the terminal window and any console messages will appear as they are printed out.

Changes to the source code should trigger a reload of Node and will be reflected in the console.

**Notes**

-   If you make any changes to dependent packages, then you'll have to run the `docker build` command as shown above. Any time you add / remove a package or update the version.

-   We assume that node will be running on port 8080. If this is not the case for your project, feel free to change it, but make sure to change it everywhere.

This workflow is made possible by some clever Docker commands. We'll expand on the command above here:

-   `docker run`: This is the primary Docker command to take a container image and run it
-   `-ti`: This instructs Docker to run this container interactively so you can see the output console
-   `--rm`: After you exit the container instance by pressing `Ctrl-c` this flag instructs Docker to clean up after the container
-   `-p 8080:8080`: Ensure port 8080 on the container is mapped to port 8080 on your local machine so you can use `http://localhost:8080`
-   `-v "$(pwd)/server-code:/home/node/app"`: This maps the directory `server-code` (along with your source code) into the container directory `/home/node/app`. So your source code and everything in the `server-code` directory is available in the container.
-   `-v /home/node/app/node_modules`: This is a special command that excludes the `node_modules` directory on your local machine and instead keeps the container's `node_modules` directory that was created during the build phase. This is important because the `node_modules` on your local machine is full of packages that are specific to the local machine operating system. And since we want the package for the container operating system, this flag makes that one directory shine through.
-   `mynodeapp`: This is whatever you want to call your container image.

## Production Build for Local Testing with Containers Workflow (without live code updates)

This workflow allows you to test your container image by running it locally but with production settings.
It's an exact match of what you would deploy in production, but it allows you to view the
console output to help remove any bugs or errors.

For this workflow, there is no live reloading of source code.
So if you make a change to the source code, you'll have to run the build step for every change.

### Steps to get up and running

1. Start Docker on your local machine
1. Navigate to the main project directory (not in `server-code`)
1. If this the first time you are running the container, or if you have changed _any_ source code, then run:
    ```sh
        docker build . --target=production -t mynodeprod .
    ```
1. To run an instance locally, run the following command:
    ```sh
    docker run -ti --rm -p 8080:8080 mynodeprod
    ```

## Additional notes

### To run the container in the background without anything printed to the console

To stop the container, use the Docker GUI or Docker CLI commands

```sh
docker run -d --rm -p 8080:8080  mynodeprod
```

### To start the container and get a shell prompt so you can look around

This is very useful during debugging of the container to see where files and directories live

```sh
docker run -ti --rm --entrypoint /bin/sh mynodeprod
```

```sh
docker run -ti --rm -p 8080:8080 -v "$(pwd)/server-code:/home/node/app" -v /home/node/app/node_modules --entrypoint /bin/sh mynodeapp
```

## Docker Compose for dev

```sh
docker compose build
```

To run

```sh
docker compose up
```

And shutdown

```sh
docker compose down
```

To run interactive. Uncomment stuff and go

```sh
docker compose run --rm app
```
