const express = require('express');

const { createSos, getSosEvents } = require('../controllers/sos.controller');

const router = express.Router();

router.get('/', getSosEvents);
router.post('/', createSos);

module.exports = router;
