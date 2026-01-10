# Order for Publishing modules and docker images

When you publish a module or docker image version, you need to make sure that all the modules that depends on that version are updated after its submodule has been updated.

The order is:

1) partytime
2) podverse-helpers
3) podverse-external-services
4) podverse-notifications
5) podverse-orm
6) podverse-parser
7) podverse-mq
8) podverse-workers
9) podverse-api
10) podverse-web-deploy
11) podverse-qa

If you update and publish package 1, you need to update and publish packages 2-11.

If you update package 4, you need to update and publish packages 5-11.

etc.
