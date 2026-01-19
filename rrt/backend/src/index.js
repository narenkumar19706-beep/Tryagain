import dotenv from 'dotenv';
import express from 'express';
import morgan from 'morgan';

import { router } from './routes.js';

dotenv.config();

const app = express();
const port = Number(process.env.PORT) || 8080;

app.use(express.json());
app.use(morgan('dev'));

app.get('/', (_req, res) => {
  res.json({ ok: true, message: 'RRT backend running.' });
});

app.use('/api', router);

app.use((req, res) => {
  res.status(404).json({ ok: false, message: 'Not Found' });
});

app.use((err, _req, res, _next) => {
  console.error('Unhandled error', err);
  res.status(500).json({ ok: false, message: 'Server error' });
});

app.listen(port, () => {
  console.log(`RRT backend listening on port ${port}`);
});
