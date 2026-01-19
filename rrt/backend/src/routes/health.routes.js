const express = require('express');

const { sendSuccess } = require('../utils/response');

const router = express.Router();

router.get('/', (_req, res) => {
  return sendSuccess(res, {
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
