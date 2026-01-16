#!/usr/bin/env node

const { Client } = require('pg');
const bcrypt = require('bcrypt');

async function createSuperuser() {
  const email = process.env.SUPERUSER_EMAIL;
  const password = process.env.SUPERUSER_PASSWORD;

  if (!email || !password) {
    console.error('ERROR: SUPERUSER_EMAIL and SUPERUSER_PASSWORD environment variables are required');
    process.exit(1);
  }

  // Database connection config from environment
  const client = new Client({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5999', 10),
    database: process.env.DB_DATABASE || process.env.POSTGRES_DB || 'postgres',
    user: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || '',
  });

  try {
    await client.connect();

    // Check if superuser already exists
    const existingCheck = await client.query(
      'SELECT aac.admin_account_id FROM admin_account_credentials aac WHERE aac.email = $1',
      [email]
    );

    if (existingCheck.rows.length > 0) {
      const adminAccountId = existingCheck.rows[0].admin_account_id;
      console.log(`Superuser account already exists with email: ${email} (admin_account_id: ${adminAccountId})`);
      await client.end();
      return;
    }

    // Hash the password using bcrypt with saltRounds=10 and genSalt (matching podverse-orm pattern)
    const saltRounds = 10;
    const salt = await bcrypt.genSalt(saltRounds);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Generate a random id_text (15 characters, matching nano_id_v2 domain)
    const idText = generateRandomIdText();

    // Begin transaction
    await client.query('BEGIN');

    try {
      // Create admin_account with superuser role (admin_account_role_id = 1)
      const accountResult = await client.query(
        'INSERT INTO admin_account (id_text, admin_account_role_id) VALUES ($1, $2) RETURNING id',
        [idText, 1] // 1 = superuser role
      );
      const adminAccountId = accountResult.rows[0].id;

      // Create admin_account_credentials
      await client.query(
        'INSERT INTO admin_account_credentials (admin_account_id, email, password) VALUES ($1, $2, $3)',
        [adminAccountId, email, hashedPassword]
      );

      // Commit transaction
      await client.query('COMMIT');

      console.log(`Superuser account created successfully: ${email} (admin_account_id: ${adminAccountId})`);
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    }

    await client.end();
  } catch (error) {
    console.error('ERROR creating superuser:', error.message);
    await client.end();
    process.exit(1);
  }
}

// Generate random ID text (15 characters, matching nano_id_v2 domain)
// This is a simplified version - in production this should match the exact algorithm used
function generateRandomIdText() {
  const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  let result = '';
  for (let i = 0; i < 15; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

createSuperuser();
