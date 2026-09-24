#!/bin/bash

set -e

echo "🚀 Configurando Sello NFC..."

# 1. Backend
echo "📦 Configurando Backend..."
cd backend
dotnet new webapi -n SelloNFC
cd SelloNFC

cat > appsettings.Development.json << 'APPEOF'
{
  "Logging": {"LogLevel": {"Default": "Debug"}},
  "ConnectionStrings": {
    "DefaultConnection": "Host=db.ndffjlppyrpwftvppsbr.supabase.co;Database=postgres;Username=postgres;Password=!Sello-nfc!;Port=5432;SSL Mode=Require;"
  },
  "AppSettings": {"JwtSecret": "sello-nfc-dev-secret-key-123456789"}
}
APPEOF

dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Tools
dotnet restore

echo "✅ Backend configurado"

# 2. Frontend
echo "📦 Configurando Frontend..."
cd ../../frontend
npm create vite@latest . -- --template react --yes
npm install

echo "✅ Frontend configurado"

# 3. WhatsApp Service
echo "📦 Configurando WhatsApp Service..."
cd ../whatsapp-service

cat > package.json << 'PKGEOF'
{
  "name": "whatsapp-service",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {"start": "node index.js"},
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.6.2",
    "dotenv": "^16.3.1",
    "whatsapp-web.js": "^1.25.0"
  }
}
PKGEOF

cat > index.js << 'JSEOF'
const express = require('express');
const axios = require('axios');
require('dotenv').config();
const app = express();
app.use(express.json());
const PORT = process.env.PORT || 3001;
app.post('/send', async (req, res) => {
  console.log(`Sending to ${req.body.usuario_id}`);
  res.json({ success: true, mensaje_id: Date.now() });
});
app.listen(PORT, () => console.log(`WhatsApp service on port ${PORT}`));
JSEOF

npm install

echo "✅ WhatsApp Service configurado"

echo ""
echo "✅ Setup completo!"
echo ""
echo "Levanta los servicios (3 terminales diferentes):"
echo "  1. cd backend/SelloNFC && dotnet run"
echo "  2. cd frontend && npm run dev"
echo "  3. cd whatsapp-service && npm start"
