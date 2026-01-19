const express = require('express');

const { env } = require('./config/env');
const { logger } = require('./utils/logger');
const healthRoutes = require('./routes/health.routes');
const volunteerRoutes = require('./routes/volunteer.routes');
const sosRoutes = require('./routes/sos.routes');

const app = express();

app.use(express.json());

app.get('/', (_req, res) => {
  res.json({ ok: true, message: 'RRT backend running.' });
});

app.use('/api/health', healthRoutes);
app.use('/api/volunteers', volunteerRoutes);
app.use('/api/sos', sosRoutes);

app.use((req, res) => {
  res.status(404).json({ ok: false, message: 'Not Found' });
});

app.use((err, _req, res, _next) => {
  logger.error('Unhandled error', { error: err.message });
  res.status(500).json({ ok: false, message: 'Server error' });
});

app.listen(env.port, () => {
  logger.info(`RRT backend listening on port ${env.port}`);
});
