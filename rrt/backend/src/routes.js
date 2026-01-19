import express from "express";
import { store } from "./store.js";
import { subscribeTokenToDistrictTopic, sendDistrictPush } from "./fcm.js";

export const router = express.Router();

router.get("/health", (req, res) => {
  res.json({ ok: true, service: "rrt-backend" });
});

router.post("/register", async (req, res) => {
  try {
    const { name, phoneNumber, district, fcmToken, address } = req.body || {};

    if (!phoneNumber || !district || !fcmToken) {
      return res.status(400).json({
        ok: false,
        message: "phoneNumber, district, fcmToken required",
      });
    }

    store.volunteers.set(phoneNumber, {
      name: name || "",
      phoneNumber,
      district,
      address: address || "",
      fcmToken,
      updatedAt: new Date().toISOString(),
    });

    const topic = await subscribeTokenToDistrictTopic(fcmToken, district);

    return res.json({
      ok: true,
      message: "Registered + subscribed",
      topic,
    });
  } catch (e) {
    return res.status(500).json({ ok: false, message: String(e) });
  }
});

// START SOS
router.post("/sos/start", async (req, res) => {
  try {
    const { phoneNumber, district, comment, lat, lng, name, address } =
      req.body || {};

    if (!phoneNumber || !district) {
      return res
        .status(400)
        .json({ ok: false, message: "phoneNumber & district required" });
    }

    const sosId = `sos_${Date.now()}`;

    store.activeSos.set(district, {
      sosId,
      startedAt: new Date().toISOString(),
      byPhone: phoneNumber,
      name: name || "",
      address: address || "",
      comment: comment || "",
      lat: lat ?? "",
      lng: lng ?? "",
      updates: [],
    });

    const push = await sendDistrictPush({
      district,
      title: "🚨 SOS ALERT",
      body: comment?.trim()
        ? `Help needed: ${comment.trim()}`
        : "Emergency alert raised in your district",
      data: {
        type: "SOS_START",
        sosId,
        district,
        phoneNumber,
        name: name || "",
        address: address || "",
        lat: lat ?? "",
        lng: lng ?? "",
        comment: comment ?? "",
        startedAt: store.activeSos.get(district).startedAt,
      },
    });

    return res.json({ ok: true, sosId, push });
  } catch (e) {
    return res.status(500).json({ ok: false, message: String(e) });
  }
});

// SEND UPDATE
router.post("/sos/update", async (req, res) => {
  try {
    const { sosId, district, message } = req.body || {};

    if (!sosId || !district || !message) {
      return res.status(400).json({
        ok: false,
        message: "sosId, district, message required",
      });
    }

    const active = store.activeSos.get(district);
    if (!active || active.sosId !== sosId) {
      return res.status(404).json({
        ok: false,
        message: "No active SOS found for this district",
      });
    }

    const updateId = `upd_${Date.now()}`;
    const update = {
      updateId,
      message: String(message).slice(0, 250),
      at: new Date().toISOString(),
    };

    active.updates.push(update);

    const push = await sendDistrictPush({
      district,
      title: "📌 SOS UPDATE",
      body: update.message,
      data: {
        type: "SOS_UPDATE",
        sosId,
        district,
        updateId,
        message: update.message,
        at: update.at,
      },
    });

    return res.json({ ok: true, push });
  } catch (e) {
    return res.status(500).json({ ok: false, message: String(e) });
  }
});

// STOP SOS
router.post("/sos/stop", async (req, res) => {
  try {
    const { sosId, district } = req.body || {};
    if (!district) {
      return res.status(400).json({ ok: false, message: "district required" });
    }

    const active = store.activeSos.get(district);
    store.activeSos.delete(district);

    const push = await sendDistrictPush({
      district,
      title: "✅ SOS STOPPED",
      body: "The SOS alert has been stopped.",
      data: {
        type: "SOS_STOP",
        sosId: sosId || active?.sosId || "",
        district,
        stoppedAt: new Date().toISOString(),
      },
    });

    return res.json({ ok: true, push });
  } catch (e) {
    return res.status(500).json({ ok: false, message: String(e) });
  }
});
