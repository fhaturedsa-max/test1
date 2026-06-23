import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 3000;

// Serve public static assets
app.use(express.static(path.join(__dirname, 'dist')));

// Fallback all other routes to index.html (SPA routing logic)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Simulator running at http://0.0.0.0:${PORT}/`);
});
