const repoName = process.argv[2]
const languageKey = process.argv[3]
const googleAPIKey = process.argv[4]

const validRepoNameParameters = [
  'podverse-rn',
  'podverse-web'
]

if (!repoName || !validRepoNameParameters.includes(repoName)) {
  console.log(`You must provide a repo name parameter. Options: ${validRepoNameParameters.join(', ')}`)
  return
}

if (!languageKey) {
  console.log('You must provide a language key parameter.')
  return
}

const rnTranslations = {
  es: require("./human-translated-overrides/podverse-rn/es-human.json"),
  lt: require("./human-translated-overrides/podverse-rn/lt-human.json")
}

const webTranslations = {}

let humanTranslations = {}
if (repoName === 'podverse-rn') {
  humanTranslations = rnTranslations
} else if (repoName === 'podverse-web') {
  humanTranslations = webTranslations
} else {
  return 'Error: Translations file not found.'
}

const getRepoPath = () => {
  if (repoName === 'podverse-rn') {
    return '../../../podverse-rn/src/resources/i18n/translations'
  } else if (repoName === 'podverse-web') {
    return `../../../podverse-web/public/locales`
  } else {
    throw new Error(`Invalid repo name provided. Valid options: ${validRepoNameParameters.join(', ')}`)
  }
}

const repoPath = getRepoPath()
const inputFile = `${repoPath}/en.json`
const overridesFilePath = `./human-translated-overrides/${repoName}/${languageKey}-human.json`
const outputPath = `${repoPath}/${languageKey}.json`

module.exports = {
  googleAPIKey,
  humanTranslations,
  inputFile,
  languageKey,
  outputPath,
  overridesFilePath
}
