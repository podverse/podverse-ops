# Local Dev Setup

Podverse uses many modules that are maintained in separate repos. This guide is intended to help you use shortcuts for an easier development workflow.

## Summary

- Setup environment variables for Docker services and local apps.
- Run the required Docker services.
- Initialize the database schema.
- Install and link all NPM dependencies.
- Run (build + hot reload) all Podverse modules in separate terminals.

## Environment Variables

Before running a Podverse Docker service, you will need to create an enviroment variable file for it within the `podverse-ops/config` directory.

Duplicate each of the `.env.example` files found within `podverse-ops/config` and add the corresponding values.

The Podverse repos that run locally (the ones that don't simply need to build, but need to run) will need their own `.env` file within their project directory for local development purposes. For example, for local dev, you will need a corresponding `podverse-api/.env` file, and a `podverse-workers/.env` file.

## Required Docker services

The Podverse infrastructure requires 2 Docker services:
- `podverse_db` - a Postgres database
- `podverse_queue` - a RabbitMQ instance (AMQP queue service)

You will need Docker installed locally. To start these containers in the background, from the root of `podverse-ops`, run the following command (using either `docker-compose` or `docker compose`):

```
docker-compose -f ./docker/docker-compose.yml up -d
```

## Initialize Database Schema

When you start a clean instance of `podverse_db`, you will need to initialize the database schema.

To initialize the database, run the SQL found in the `podverse-ops/database/init_database.sql` file. Execute the following command from the root of the `podverse-ops` repo:

```
docker exec -i podverse_db psql -U user -d postgres -f /opt/database/combined/init_database.sql
```

Note: the `user` and `postgres` value may need to change depending on your environment variables.

## Install and link all dependencies

For a convenient local dev workflow, you can clone all of the Podverse repos on your machine within the same directory, and then run the `podverse-ops/dev/npm-link-modules.sh` script from the root of the `podverse-ops` directory. This will handle 1) installing all the `node_modules` for those repos, and 2) `npm link`-ing the required podverse dependencies for each individual module.

## Open and run all repos in separate terminals

If you would like to use one command to run all of the Podverse modules in separate terminals, you can use the VS Code extension Terminals Manager.

To make it work, duplicate the `podverse-ops/.vscode/terminals.json.example` file, rename it to `terminals.json`, and update the paths in the file to point to where you have the repos cloned locally. Then, with the `terminals.json` file open in VS Code, open the Command Palette, and select `Terminals: Run`. This will open a terminal in each of the (actively developed) Podverse modules, with the `npm run dev:watch` command running.
