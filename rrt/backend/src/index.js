import express from 'express';
import dotenv from 'dotenv';
import morgan from 'morgan';
import { router } from './routes.js';

dotenv.config();

const app = express();
app.use(express.json());
app.use(morgan('dev'));

app.use('/api', router);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`✅ Backend running: http://localhost:${PORT}`);
});
