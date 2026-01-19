const { addVolunteer, listVolunteers } = require('../store/memory.store');
const { sendError, sendSuccess } = require('../utils/response');
const { logger } = require('../utils/logger');

const registerVolunteer = (req, res) => {
  const { name, email, phone } = req.body || {};

  if (!name || !email || !phone) {
    return sendError(res, 'Name, email, and phone are required.');
  }

  const volunteer = addVolunteer({
    name: name.trim(),
    email: email.trim(),
    phone: phone.trim(),
  });

  logger.info('Volunteer registered', { id: volunteer.id });
  return sendSuccess(res, volunteer, 'Volunteer registered.', 201);
};

const getVolunteers = (_req, res) => {
  return sendSuccess(res, listVolunteers());
};

module.exports = {
  registerVolunteer,
  getVolunteers,
};
