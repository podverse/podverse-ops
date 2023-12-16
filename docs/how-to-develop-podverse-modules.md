 # How to develop Podverse modules

NOTE: Before reading this guide, we recommend you follow the steps in [How to setup local environment with test data]().

If you have any questions, please feel free to reach out using one of our [Contact options](https://podverse.fm/contact).

## Yarn VS NPM

Please see the related note in our [CONTRIBUTING guide](https://github.com/podverse/podverse-ops/blob/master/CONTRIBUTING.md#yarn-vs-npm).

## Linking modules locally

Podverse maintains several different node_modules which are used across multiple apps. We do this to enable reusability, keep our code cleaner, and have clear separation of concerns for code repos.

If you are familiar with how `yarn link` works, then you may not need this guide, but our `dev-yarn-setup.sh` scripts may still make setup more convenient.

A prerequisite is you must have [Node Version Manager](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) installed locally. Every Podverse repo must be using the exact same version of Node.js, or linking will not work.

For simplicity of documenting these steps and using the helper script, we recommend cloning *all* of the Podverse repos, within the same directory:

podverse-api
podverse-external-services
podverse-fdroid
podverse-ops
podverse-orm
podverse-parser
podverse-serverless
podverse-shared
podverse-web
podverse-workers

For convenience, you can run [this script](https://github.com/podverse/podverse-ops/blob/master/dev-clone-all-repos.sh) from within the `podverse-ops` repo to clone them all at once

Once you have all the repos cloned, you can then go into the `podverse-ops` repo, run the `nvm use` command to make sure you are using the correct version of Node.js, then run the `./dev-yarn-setup.sh` script.

This script will do the following steps, in order:

1) Run `nvm use` from within the `podverse-ops` repo to make sure you are running the correct version of Node.js before proceeding.
2) Go into each module repo (using `cd ../<repo name>`) and run the `yarn link` command.
3) Go into each module repo (again) and run the `yarn link <module name>` command for each external Podverse module that is used by that repo.

Now all of the related local repos should be linked and ready to go.

Next, we recommend you open each of the following repos in a separate terminal, and run `yarn dev:watch`:

podverse-external-services
podverse-ops
podverse-orm
podverse-parser
podverse-shared

These are the repos of the modules which are used across multiple apps. The `yarn dev:watch` command will not only rebuild the module when you make changes to that repo, but will watch for changes within *all* of the linked modules, and rebuild when those change too.

The individual app repos, like `podverse-api`, should then have their own `yarn dev:watch` command that will also rebuild when linked modules are changed.

You should now be able to make changes to Podverse's modules, and have those changes be automatically pulled in and used by other Podverse repos on your local machine.

## Terminals Manager

There is a handy extension for VSCode called "Terminals Manager" that I use to open all of the Podverse repos in a separate terminal at once.

To use Terminals Manager, you will need to install the extension, copy the [example file](https://github.com/podverse/podverse-ops/blob/master/.vscode/terminals.json.example), rename it to remove the ".example" from the end, and you also may need to update the `"cwd": "<some path>"` line so it points to where you have the repos on your local machine.

Once your `terminals.json` file is ready, make sure it is open in VSCode, then use the CMD+Shift+P shortcut to open up the "Run command" menu, then run the "Terminals: Run" command.

## Debugging local environment issues

In order for `yarn link` to work, all of your Podverse repos must be on the same version of Node.js. Please use the `nvm use` command in each repo to ensure they are using the Node.js version specified in the `.nvmrc` file.

Please note how the `dev:watch` command has parameters like the following:

```
--watch $(realpath node_modules/podverse-external-services) --watch $(realpath node_modules/podverse-shared)
```

Those parameters are needed to watch for changes in the *locally linked* module.

## Making sure a terminal is always using the correct Node.js version

I add a script to my `.zshrc` file that makes `nvm use` always run when I open a repo in the terminal. This ensures that whenever I open a repo, if a `.nvmrc` file is available in it, then the terminal will automatically use that Node.js version specified.

```
# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```
