const {
  addSosEvent,
  listSosEvents,
} = require('../store/memory.store');
const { sendError, sendSuccess } = require('../utils/response');
const { logger } = require('../utils/logger');
const { sendToTopic } = require('../services/fcm.service');
const { getSosTopic } = require('../services/topic.service');

const createSos = async (req, res) => {
  const { message, location, reporterId } = req.body || {};

  if (!message) {
    return sendError(res, 'Message is required.');
  }

  const sosEvent = addSosEvent({
    message: message.trim(),
    location: location || null,
    reporterId: reporterId || null,
  });

  try {
    await sendToTopic(getSosTopic(), {
      id: sosEvent.id,
      message: sosEvent.message,
      location: sosEvent.location,
    });
  } catch (error) {
    logger.warn('FCM send failed', { error: error.message });
  }

  return sendSuccess(res, sosEvent, 'SOS created.', 201);
};

const getSosEvents = (_req, res) => {
  return sendSuccess(res, listSosEvents());
};

module.exports = {
  createSos,
  getSosEvents,
};
