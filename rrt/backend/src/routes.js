import express from 'express';

import { sendDistrictPush, subscribeTokenToDistrictTopic } from './fcm.js';
import { store } from './store.js';

export const router = express.Router();

router.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'rrt-backend' });
});

router.post('/register', async (req, res) => {
  try {
    const { name, phoneNumber, district, fcmToken } = req.body || {};

    if (!phoneNumber || !district || !fcmToken) {
      return res.status(400).json({
        ok: false,
        message: 'phoneNumber, district, fcmToken required',
      });
    }

    store.volunteers.set(phoneNumber, {
      name: name || '',
      phoneNumber,
      district,
      fcmToken,
      updatedAt: new Date().toISOString(),
    });

    const topic = await subscribeTokenToDistrictTopic(fcmToken, district);

    return res.json({
      ok: true,
      message: 'Registered + subscribed',
      topic,
    });
  } catch (error) {
    return res.status(500).json({ ok: false, message: String(error) });
  }
});

router.post('/sos/start', async (req, res) => {
  try {
    const { phoneNumber, district, comment, lat, lng } = req.body || {};

    if (!phoneNumber || !district) {
      return res
        .status(400)
        .json({ ok: false, message: 'phoneNumber & district required' });
    }

    const sosId = `sos_${Date.now()}`;

    store.activeSos.set(district, {
      sosId,
      startedAt: new Date().toISOString(),
      byPhone: phoneNumber,
      comment: comment || '',
      lat: lat ?? '',
      lng: lng ?? '',
    });

    const push = await sendDistrictPush({
      district,
      title: '🚨 SOS ALERT',
      body: comment?.trim()
        ? `Help needed: ${comment.trim()}`
        : 'Emergency alert raised in Bangalore',
      data: {
        type: 'SOS_START',
        sosId,
        district,
        phoneNumber,
        comment: comment ?? '',
        lat: lat ?? '',
        lng: lng ?? '',
      },
    });

    return res.json({ ok: true, sosId, push });
  } catch (error) {
    return res.status(500).json({ ok: false, message: String(error) });
  }
});

router.post('/sos/stop', async (req, res) => {
  try {
    const { district } = req.body || {};
    if (!district) {
      return res.status(400).json({ ok: false, message: 'district required' });
    }

    store.activeSos.delete(district);

    const push = await sendDistrictPush({
      district,
      title: '✅ SOS STOPPED',
      body: 'SOS alert stopped.',
      data: { type: 'SOS_STOP', district },
    });

    return res.json({ ok: true, push });
  } catch (error) {
    return res.status(500).json({ ok: false, message: String(error) });
  }
});
