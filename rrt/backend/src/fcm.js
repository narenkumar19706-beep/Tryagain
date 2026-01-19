import admin from 'firebase-admin';
import fs from 'fs';
import path from 'path';

const keyPath = path.join(process.cwd(), 'serviceAccountKey.json');

if (!fs.existsSync(keyPath)) {
  console.log('❌ Missing backend/serviceAccountKey.json');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(keyPath),
});

export function districtToTopic(district) {
  return `district_${district.toLowerCase().trim().replaceAll(' ', '_')}`;
}

export async function subscribeTokenToDistrictTopic(token, district) {
  const topic = districtToTopic(district);
  await admin.messaging().subscribeToTopic([token], topic);
  return topic;
}

export async function sendDistrictPush({ district, title, body, data = {} }) {
  const topic = districtToTopic(district);

  const msg = {
    topic,
    notification: { title, body },
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    ),
    android: {
      priority: 'high',
      ttl: 30 * 1000,
      notification: {
        channelId: 'rrt_alerts',
        sound: 'default',
      },
    },
  };

  const messageId = await admin.messaging().send(msg);
  return { topic, messageId };
}
