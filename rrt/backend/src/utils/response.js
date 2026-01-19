const sendSuccess = (res, data, message = 'OK', status = 200) => {
  return res.status(status).json({
    ok: true,
    message,
    data,
  });
};

const sendError = (res, message, status = 400, details) => {
  return res.status(status).json({
    ok: false,
    message,
    details,
  });
};

module.exports = {
  sendSuccess,
  sendError,
};
