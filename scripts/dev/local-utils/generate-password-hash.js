#!/usr/bin/env node

const bcrypt = require('bcrypt');

const password = process.argv[2];

if (!password) {
  console.error('Usage: npm run generate-password-hash <password>');
  console.error("Example: npm run generate-password-hash 'Test!1Aa'");
  process.exit(1);
}

const saltRounds = 10;

bcrypt.hash(password, saltRounds).then(hash => {
  console.log('\nPassword:', password);
  console.log('Bcrypt hash (cost 10):');
  console.log(hash);
  console.log('\nCopy this hash into your SQL seed file.');
});
