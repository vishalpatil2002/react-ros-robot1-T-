const express = require('/app/backend/node_modules/express');
const path = require('path');

const app = express();
const buildPath = '/app/frontend/build';

app.use(express.static(buildPath));

app.get('*', (req, res) => {
  res.sendFile(path.join(buildPath, 'index.html'));
});

app.listen(3000, '0.0.0.0', () => {
  console.log('React frontend running on port 3000');
});
