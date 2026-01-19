const path = require('path');

const dotenv = require('dotenv');

dotenv.config({
  path: process.env.ENV_PATH || path.resolve(process.cwd(), '.env'),
});

const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: Number(process.env.PORT) || 4000,
  logLevel: process.env.LOG_LEVEL || 'info',
  serviceAccountPath:
    process.env.SERVICE_ACCOUNT_PATH || 'serviceAccountKey.json',
};

module.exports = { env };
