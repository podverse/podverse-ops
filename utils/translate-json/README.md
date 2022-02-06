# Automatic Translation Tool

This library helps you automatically create a new i18n translation JSON file, based on the English JSON files available in the podverse-rn and podverse-web repos. The JSON files within the podverse-ops/utils/translate-json 

## Installation

`npm install`

## Add a new language file

Run the following command:

`yarn create-human-language-file <repo name> <language code>`

A file that is a copy of the repo's English JSON file should be created at `./human-translated-overrides/<repo name>/<language code>-human.json`.

Any values that are put in this JSON file will *override* the values that otherwise be inserted by Google Translate when you run the translate script explained below.

## Auto-translate a language file

NOTE: Before running the command, you must import/require the human-translated-overrides file you created in the previous section to the ./translate-json/util.js file in the corresponding translations object.

Run the following command:

`yarn translate:<repo name> <language code> <Google API key>`

This will update the `<language code>>.json` file in the target repo, inserting the values defined in the human-translated-overrides file for this this repo and language code, and auto-translating all the remaining values.
