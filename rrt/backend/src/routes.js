import crypto from 'crypto';
import { Router } from 'express';

import { sendDistrictPush, subscribeTokenToDistrictTopic } from './fcm.js';
import { store } from './store.js';

const router = Router();

const sendSuccess = (res, data, message = 'OK', status = 200) => {
  return res.status(status).json({ ok: true, message, data });
};

const sendError = (res, message, status = 400, details) => {
  return res.status(status).json({ ok: false, message, details });
};

const createId = (prefix) => {
  if (typeof crypto.randomUUID === 'function') {
    return `${prefix}_${crypto.randomUUID()}`;
  }
  return `${prefix}_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
};

router.get('/health', (_req, res) => {
  return sendSuccess(res, {
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

router.get('/volunteers', (_req, res) => {
  return sendSuccess(res, Array.from(store.volunteers.values()));
});

router.post('/volunteers', async (req, res) => {
  const { name, email, phone, district, token } = req.body || {};

  if (!name || !email || !phone) {
    return sendError(res, 'Name, email, and phone are required.');
  }

  const volunteer = {
    id: createId('vol'),
    name: name.trim(),
    email: email.trim(),
    phone: phone.trim(),
    district: district ? district.trim() : null,
    createdAt: new Date().toISOString(),
  };

  store.volunteers.set(volunteer.id, volunteer);

  let topic;
  if (token && district) {
    try {
      topic = await subscribeTokenToDistrictTopic(token, district);
    } catch (error) {
      console.warn('FCM subscribe failed', error);
    }
  }

  return sendSuccess(
    res,
    {
      volunteer,
      topic,
    },
    'Volunteer registered.',
    201
  );
});

router.get('/sos', (_req, res) => {
  return sendSuccess(res, Array.from(store.activeSos.values()));
});

router.post('/sos', async (req, res) => {
  const { district, title, body, data, reporterId, location } = req.body || {};

  if (!district || !body) {
    return sendError(res, 'District and body are required.');
  }

  const sosEvent = {
    id: createId('sos'),
    district: district.trim(),
    title: title?.trim() || 'SOS Alert',
    body: body.trim(),
    data: typeof data === 'object' && data !== null ? data : {},
    reporterId: reporterId || null,
    location: location || null,
    createdAt: new Date().toISOString(),
  };

  store.activeSos.set(sosEvent.id, sosEvent);

  let pushResult;
  let pushError;
  try {
    pushResult = await sendDistrictPush({
      district: sosEvent.district,
      title: sosEvent.title,
      body: sosEvent.body,
      data: {
        sosId: sosEvent.id,
        ...sosEvent.data,
      },
    });
  } catch (error) {
    pushError = error.message;
    console.warn('FCM send failed', error);
  }

  return sendSuccess(
    res,
    {
      sos: sosEvent,
      push: pushResult,
      pushError,
    },
    'SOS dispatched.',
    201
  );
});

export default router;
