// This awesome script is written by Trevor Ewen and Randhi Pratama Putra
// and will automatically translate a json file using the Google Translate API.
// Source: https://github.com/tewen/gtd-scripts/blob/master/translate-json

const fs = require('fs');
const _ = require('lodash');
const path = require('path');
const agent = require('superagent-promise')(require('superagent'), Promise);
const { googleAPIKey, humanTranslations, inputFile, languageKey, outputPath, overridesFilePath } = require('./util')
let dicc = {};

const sortObject = (obj) => {
  return _(obj).toPairs().sortBy(0).fromPairs().value()
}

if (process.argv.length === 5) {
  const apiUrl = _.template('https://www.googleapis.com/language/translate/v2?key=<%= googleAPIKey %>&q=<%= value %>&source=en&target=<%= languageKey %>');
  const transformResponse = (res, key, languageKey) => {
    return {key, value:_.get(JSON.parse(res.text), ['data', 'translations', 0, 'translatedText'], '')};
  }

  const inputJSON = JSON.parse(fs.readFileSync(path.resolve(inputFile), 'utf-8'))

  let promArr =[]
  dicc[languageKey] = {}

  for (const wordKey in inputJSON) {
    if(humanTranslations[languageKey][wordKey]) {
      promArr.push(new Promise((resolve) => {
        resolve({key:wordKey, value: humanTranslations[languageKey][wordKey] })
      }))
    } else {
      humanTranslations[languageKey][wordKey] = ""
      const englishValue = inputJSON[wordKey]
      promArr.push(agent('GET', apiUrl({
        value: encodeURI(englishValue),
        languageKey,
        googleAPIKey
      }))
      .then((res) => {
        return transformResponse(res, wordKey)
      }))
    }
  }
  
  Promise.all(promArr).then(resArr => {
    resArr = _.sortBy( resArr, 'key' )
    
    for (const res of resArr) {
      const {key, value} = res
      dicc[languageKey][key] = value
    }
    
    fs.writeFileSync(overridesFilePath, JSON.stringify(sortObject(humanTranslations[languageKey]), null, 2));
    fs.writeFileSync(outputPath, JSON.stringify(dicc[languageKey], null, 2));
    console.log("All Done!!")
  })
} else {
  console.error('You must provide a repo name, a language key, and a Google API key.');
}
