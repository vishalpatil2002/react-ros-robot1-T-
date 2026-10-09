const http = require('http');
const fs = require('fs');
const path = require('path');

const buildDir = '/app/frontend/build';
const port = 3000;

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.mp3': 'audio/mpeg',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2'
};

http.createServer((req, res) => {
  let requestPath = decodeURIComponent((req.url || '/').split('?')[0]);
  let filePath = path.join(buildDir, requestPath);

  if (!filePath.startsWith(buildDir)) {
    res.writeHead(403);
    return res.end('Forbidden');
  }

  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
    filePath = path.join(buildDir, 'index.html');
  }

  const contentType =
    mimeTypes[path.extname(filePath).toLowerCase()] || 'application/octet-stream';

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(500);
      return res.end('Internal server error');
    }

    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
}).listen(port, '0.0.0.0', () => {
  console.log(`React frontend listening on port ${port}`);
});
