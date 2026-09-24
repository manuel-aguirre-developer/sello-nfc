const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3001;

app.post('/send', async (req, res) => {
  const { usuario_id, contenido } = req.body;
  console.log(`Sending to ${usuario_id}: ${contenido}`);
  res.json({ success: true, mensaje_id: Date.now() });
});

app.listen(PORT, () => {
  console.log(`WhatsApp service running on port ${PORT}`);
});
