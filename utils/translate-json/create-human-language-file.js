const fs = require('fs');
const _ = require('lodash');
const path = require('path');
const { inputFile, overridesFilePath } = require('./util')

if (fs.existsSync(overridesFilePath)) {
  console.log(`File for ${overridesFilePath} already exists.`)
} else {
  const inputJSON = JSON.parse(fs.readFileSync(path.resolve(inputFile), 'utf-8'))
  const newObj = {}
  
  for (const key in inputJSON) {
      newObj[key] = ''
  }
  
  fs.writeFileSync(overridesFilePath, JSON.stringify(newObj, null, 2));
}
