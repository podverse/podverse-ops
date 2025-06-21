# Order for Publishing modules and docker images

When you publish a module or docker image version, you need to make sure that all the modules that depends on that version are updated after its submodule has been updated.

The order is:

1) podverse-helpers
2) podverse-external-services
3) podverse-orm
4) podverse-parser
5) podverse-queue
6) podverse-workers
7) podverse-api

If you update and publish package 1, you need to update and publish packages 2-7.

If you update package 4, you need to update and publish packages 5-7.

etc.
