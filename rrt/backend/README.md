# RRT Backend (Node.js)

Node.js API source for the RRT service.

## Structure
- `src/index.js` - app entry
- `src/routes.js` - API routes
- `src/store.js` - in-memory data store
- `src/fcm.js` - Firebase Cloud Messaging helpers
- `serviceAccountKey.json` - Firebase service account key

## Getting started
1. Install dependencies: `npm install`
2. Start the server: `npm run start`

## Environment
Set the local port in `.env`.

## API
- `GET /api/health`
- `GET /api/volunteers`
- `POST /api/volunteers`
- `GET /api/sos`
- `POST /api/sos`
