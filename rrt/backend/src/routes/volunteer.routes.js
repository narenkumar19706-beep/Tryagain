const express = require('express');

const {
  getVolunteers,
  registerVolunteer,
} = require('../controllers/volunteer.controller');

const router = express.Router();

router.get('/', getVolunteers);
router.post('/', registerVolunteer);

module.exports = router;
