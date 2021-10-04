const fs = require('fs');
const moment = require('moment');
const _ = require('lodash');
const path = require('path');
const agent = require('superagent-promise')(require('superagent'), Promise);


const inputFile = process.argv[2];
const languageKey = process.argv[3]

if(fs.existsSync(languageKey+"-human.json")) {
    console.log("File for " + languageKey + " already exists.")
} else {

    const inputJSON = JSON.parse(fs.readFileSync(path.resolve(inputFile), 'utf-8'))
    const newObj = {}
    
    for (const key in inputJSON) {
        newObj[key] = ""
    }
    
    fs.writeFileSync(languageKey + "-human.json", JSON.stringify(newObj, null, 2));
}