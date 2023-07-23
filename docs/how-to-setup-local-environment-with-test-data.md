# How to setup local environment with test data

In order to work with test data through localhost, you will need to create a local database container, manticore container, and then run the `populateDatabase` script from the `podverse-api` repo. We have a `Makefile` to make this process easier.

## Prerequisites

The repos you will potentially need to clone locally include:

- `podverse-ops`
- `podverse-api`
- `podverse-rn`
- `podverse-web`

You will also need Docker installed to run the `make` / `docker compose` commands.

## Local setup steps

1. From the root of the `podverse-ops` repo, run `make local_up_db`.
2. From the root of the `podverse-ops` repo, run `make local_up_manticore_server`.
3. You will need to setup the environment variables in the `podverse-api` repo before running commands in it. You can find a sample `podverse-api` localhost config with comments [here](https://github.com/podverse/podverse-ops/blob/master/config/podverse-api-local.env.example).
4. From the root of the `podverse-api` repo, run `yarn dev:seeds:qa:populateDatabase`.
5. From the root of the `podverse-ops` repo, run `make local_manticore_indexes_init`.

Your local environment should now be ready to receive API requests and return data.

If you add more podcasts to your local database and would like them to show up in the Manticore search results, you will need to refresh the Manticore indexes by running `make local_manticore_indexes_rotate`.

For making requests to `podverse-api`, you can find our latest Postman collection [here](https://github.com/podverse/podverse-api/tree/develop/docs/postman).
