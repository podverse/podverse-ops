# How to contribute to Podverse

[Podverse](https://podverse.fm) is a labor of love to create a high quality cross-platform FOSS podcast app, and help drive forward adoption of new RSS namespaces ([Podcasting 2.0](https://github.com/Podcastindex-org/podcast-namespace/blob/main/podcasting2.0.md)), so new features are possible in open podcasting.

## Bounties

*WORK IN PROGRESS - we haven't finalized the terms for bounties yet, but should have them ready soon.*

We currently charge $18 per year for a Podverse Premium membership, which is covering most of our bills at the moment, but we're still far from being able to afford to pay our core team members.

Also, we use the [value for value model](https://value4value.info/), and extend Podverse Premium memberships for free to anyone who asks for one.

That said, we have invested in a bounties program to help encourage FOSS contributions to Podverse on major features or bug fixes that our core team either doesn't know how to do, or won't realistically have time to complete.

If you may be interested in working on a bounty, you can find descriptions for them in [this directory](https://github.com/podverse/podverse-ops/tree/master/bounties).

If you decide to pick one up, please let us know as soon as possible so we can reserve it for you to work on, and also verify our payment method and terms will work for you.

## Documentation

If you see any parts of the documentation that can be improved, please let us know, or create a PR with the changes.

## Translations

### Weblate

If you'd like to add or update translations in the mobile or web app, please visit our [Weblate page](https://hosted.weblate.org/projects/podverse/). Weblate is a FOSS language localization tool that makes it easy to crowd-source translations for software. Any changes you make there will automatically create a pull request that we can then merge into the Podverse repos.

### Bounties

We will also pay a bounty to people who make major contributions towards translating the mobile or web site into different languages. Please visit the [translations bounty page](https://github.com/podverse/podverse-ops/tree/master/bounties/translations) for more info.

## Programming

The full Podverse tech stack is primarily written with JavaScript, TypeScript, and Node.js, and we use React and React Native for the website and mobile app.

Our core dev team has good JavaScript and iOS experience, but almost no Android, and limited database experience, so those are both areas we could particularly use help with.

Below is info to help you get started running the Podverse apps locally on your machine.

### Environment configs

You can find example `.env` files for all Podverse repos [here](https://github.com/podverse/podverse-ops/tree/master/config).

### Local environment setup

Podverse uses [Docker Compose](https://github.com/podverse/podverse-ops/tree/master/docker-compose) and a [Makefile](https://github.com/podverse/podverse-ops/blob/master/Makefile) for local environment setup.

If you are only working on the front-end (mobile or web), you may not need to use Docker or Make, as you can just run the apps locally using npm, and update the `.env` file to point to the prod Podverse API at `https://api.podverse.fm/api/v1` instead of `http://localhost:1234/api/v1`.

If you are working on podverse-api or our Manticore search engine, you will need to use the Make commands to get started.

You can use the following commands to get the Postgres database and Manticore search engine running locally:

```bash
# initialize the database
make local_up_db

# initialize the manticore database and run the manticore api
make local_up_manticore_server

# initialize the manticore indexes
# this only needs to run once, the first time 
make local_manticore_indexes_init

# update / rotate the manticore indexes
# this runs whenever you want to update the search indexes
make local_manticore_indexes_rotate
```

The database will automatically import the [schema-only.sql.gz file](https://github.com/podverse/podverse-ops/tree/master/db/schema-only), which initializes the tables and indexes.

To destroy the database locally, you can run:

```bash
make local_down_db
```

To destroy all the Podverse containers locally:

```bash
make local_down
```

After the database and Manticore are running locally, you can then run whichever app you want to work on by going into its repo and running `npm run dev` (or `npm run dev:ios` or `npm run dev:android` for the mobile app).

For more info about how to run and begin working on each app, please check the README in their respective repos:

[podverse-api](https://github.com/podverse/podverse-api)
[podverse-rn](https://github.com/podverse/podverse-rn)
[podverse-web](https://github.com/podverse/podverse-web)

Also, we welcome any contributions to help improve or cleanup this repo [podverse-ops](https://github.com/podverse/podverse-ops).

If you have any issues with the startup process, please 

### Bounties

Please visit the [bounties directory](https://github.com/podverse/podverse-ops/tree/master/bounties) in this repo for more info.

## Contact us

If you'd like to reach us with questions, we'd be happy to hear from you, and can be reached by creating a Github issue in its respective repo, or by contacting us via:

[Matrix](https://matrix.to/#/#podverse-space:matrix.org) (preferred)
[Discord](https://discord.gg/6HkyNKR)
[Email](mailto:contact@podverse.fm)

Thanks for reading! ❤️
