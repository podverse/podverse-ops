// This awesome script is written by Trevor Ewen and Randhi Pratama Putra
// and will automatically translate a json file using the Google Translate API.
// Source: https://github.com/tewen/gtd-scripts/blob/master/translate-json

const fs = require('fs');
const moment = require('moment');
const _ = require('lodash');
const path = require('path');
const agent = require('superagent-promise')(require('superagent'), Promise);
const { translate } = require("google-translate-api-browser");
let dicc = {};

const humanTranslations = {
    es: require("./es-human.json")
}

const sortObject = (obj) => {
    return _(obj).toPairs().sortBy(0).fromPairs().value()
}

if (process.argv.length === 6) {
    //Args
    const inputFile = process.argv[2];
    const languageKey = process.argv[3]
    const outputFile = process.argv[4];
    const apiKey = process.argv[5];

    const apiUrl = _.template('https://www.googleapis.com/language/translate/v2?key=<%= apiKey %>&q=<%= value %>&source=en&target=<%= languageKey %>');
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
            promArr.push(agent('GET', apiUrl({
                value: encodeURI(wordKey),
                languageKey,
                apiKey
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

        fs.writeFileSync(languageKey + "-human.json", JSON.stringify(sortObject(humanTranslations[languageKey]), null, 2));
        fs.writeFileSync(outputFile, JSON.stringify(dicc[languageKey], null, 2));
        console.log("All Done!!")
    })
} else {
    console.error('You must provide an input json file, and a comma-separated list of language codes, an output file, and a Google API key.');
}