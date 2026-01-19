const volunteers = [];
const sosEvents = [];

const addVolunteer = (payload) => {
  const record = {
    id: `vol_${volunteers.length + 1}`,
    name: payload.name,
    email: payload.email,
    phone: payload.phone,
    createdAt: new Date().toISOString(),
  };
  volunteers.push(record);
  return record;
};

const listVolunteers = () => [...volunteers];

const addSosEvent = (payload) => {
  const record = {
    id: `sos_${sosEvents.length + 1}`,
    message: payload.message || 'SOS',
    location: payload.location || null,
    reporterId: payload.reporterId || null,
    createdAt: new Date().toISOString(),
  };
  sosEvents.push(record);
  return record;
};

const listSosEvents = () => [...sosEvents];

module.exports = {
  addVolunteer,
  listVolunteers,
  addSosEvent,
  listSosEvents,
};
