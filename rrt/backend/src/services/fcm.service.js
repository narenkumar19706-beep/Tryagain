const { logger } = require('../utils/logger');

const sendToTopic = async (topic, payload) => {
  logger.info('Sending FCM message', { topic, payload });
  await new Promise((resolve) => setTimeout(resolve, 200));
  return { messageId: `mock-${Date.now()}` };
};

module.exports = {
  sendToTopic,
};
