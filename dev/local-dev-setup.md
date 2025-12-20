# Local Dev Setup

Podverse uses many modules that are maintained in separate repos. This guide is intended to help you get setup and use shortcuts for an easier development workflow.

## Summary

- Setup environment variables for Docker services and local apps.
- Run the required Docker services.
- Initialize the database schema.
- Install and link all NPM dependencies.
- Run (build + hot reload) all Podverse modules in separate terminals.
- A shortcut using the Terminals Manager extension to easily build:watch all repos.
- Dummy data (podverse-qa)
- Podcast Index
- Podcasting 2.0

## Note on version naming

The newest Podverse infrastructure is named `v5` internally, because the previous version (currently on web and mobile app stores) was `v4`.

Publicly, we sometimes refer to the new Podverse we're building as "Podverse 2.0", because the new infrastructure closely aligns with the "Podcasting 2.0" RSS standards...but from a dev perspective, we mean `v5`.

## Clone all repos

The `v5` infrastructure is highly modularized. You will need to clone all of the following repos within the same directory locally, and checkout the `v5-develop` branch on each one.

I am listing them in a top-down order (ex. `podverse-helpers` is used by everything, `podverse-orm` is used by `podverse-parser` and `podverse-api` etc.):
- [podverse-ops](https://github.com/podverse/podverse-ops/blob/v5-develop/)
- [podverse-helpers](https://github.com/podverse/podverse-helpers/blob/v5-develop/)
- [podverse-external-services](https://github.com/podverse/podverse-external-services/blob/v5-develop/)
- [podverse-orm](https://github.com/podverse/podverse-orm/blob/v5-develop/)
- [podverse-parser](https://github.com/podverse/podverse-parser/blob/v5-develop/)
- [podverse-mq](https://github.com/podverse/podverse-mq/blob/v5-develop/)
- [podverse-api](https://github.com/podverse/podverse-api/blob/v5-develop/)
- [podverse-web](https://github.com/podverse/podverse-web/blob/v5-develop/)
- [podverse-workers](https://github.com/podverse/podverse-workers/blob/v5-develop/)
- [podverse-qa](https://github.com/podverse/podverse-qa/blob/v5-develop/)

## Environment Variables

Before running a Podverse Docker service, you will need to create an enviroment variable file for it within the `podverse-ops/config` directory.

Duplicate each of the `.env.example` files found within `podverse-ops/config` and add the corresponding values.

The Podverse repos that run locally (the ones that don't simply need to build, but need to run) will need their own `.env` file within their project directory for local development purposes. For example, for local dev, you will need a corresponding `podverse-api/.env` file, `podverse-web/.env`, and a `podverse-workers/.env` file.

## Required Docker services

The Podverse infrastructure requires 2 Docker services running:
- `podverse_db` - a Postgres database
- `podverse_mq` - a ActiveMQArtemis instance (AMQP queue service)

You will need Docker installed locally. To start these containers in the background, from the root of `podverse-ops`, run the following `make` commands:

```
make local_db_up
```

```
make local_mq_up
```

The database will automatically be populated with the schema from `podverse-ops/database/combined/init_database.sql`.

The ActiveMQ service is needed for pulling messages from the mq for RSS feed parsing.

## Install and link all dependencies

For a convenient local dev workflow, after you have cloned all of the Podverse repos on your machine within the same directory, you can then run the `podverse-ops/dev/npm-link-modules.sh` script from the root of the `podverse-ops` directory. This will handle 1) installing all the `node_modules` for those repos, and 2) `npm link`-ing the required dependencies for each individual module.

## Open and run all repos in separate terminals

If you would like to use one command to run all of the Podverse modules in separate terminals, you can use the VS Code extension Terminals Manager.

To make it work, duplicate the `podverse-ops/.vscode/terminals.json.example` file, rename it to `terminals.json`, and update the paths in the file to point to where you have the repos cloned locally. Then, with the `terminals.json` file open in VS Code, open the Command Palette, and select `Terminals: Run`. This will open a terminal in each of the (actively developed) Podverse modules, with the `npm run dev:watch` command running.

For even more convenience, you can use the `podverse-ops/.vscode/terminals-rundev.json.example`, which will call the corresponding `build:watch` or `dev:watch` commands for each repo.

## Dummy data (podverse-qa)

To populate the database with dummy data, you can run the `make local_qa_init_data` command from within the `podverse-qa` repo ([Makefile](https://github.com/podverse/podverse-qa/blob/v5-develop/Makefile)).

## podverse-workers

The `podverse-workers` repo handles a variety of server-side functions. One useful command for getting started is `npm run parser_rss_parse_feed -- -p 920666 -f`, which will parse a feed on-demand. The `-p` value corresponds with the Podcast Index ID for the feed (in this case, [Podcasting 2.0](https://podcastindex.org/podcast/920666)), and `-f` is optional, but it tells the parser to skip the "should we re-parse this feed?" logic, and "force" reparsing.

Note: Parsing one feed, can potentially result in parsing MANY feeds, as one feed may contain references to many feeds using the `<podcast:remoteItem>` tag ([more info](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/tags/remote-item.md)). 

## Podcast Index

Podcast Index is the world's largest open podcast directory.

Podverse v5 *requires* a feed to be in the Podcast Index in order to be added to our own directory. PI basically serves as a search engine, and a filtering mechanism for Podverse. They handle the complex tasks of curating feeds, reducing spam, and handling de-duplication, so we can focus on app development.

Podverse also uses Podcast Index endpoints to tell us when an RSS feed has updated, and that feed [should be added to our MQ for parsing](https://github.com/podverse/podverse-workers/blob/v5-develop/src/commands/mq/rss/mqRSSAddRecentlyUpdatedFeedsFromPodcastIndex.ts).

## Podcasting 2.0

The premise of Podverse v5 is to be as compatible and scalable with the Podcasting 2.0 RSS namespaces as possible. Features like livestreams, music feeds, transcripts, and more are made possible thanks to Podcasting 2.0. For more on the Podcasting 2.0, please see their [documentation](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md).

## Conclusion

If any of these steps are unclear, feel free to ask any questions, and we would greatly appreciate help updating our documentation. Thank you!
