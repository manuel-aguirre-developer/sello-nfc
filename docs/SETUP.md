
---

## ⚡ Setup Automático (Recomendado)

Si querés evitar hacer todo manual:

```bash
cd /mnt/disco1/proyectos/Personal/sello-nfc
./setup-dev.sh
```

Esto crea y configura todo (backend, frontend, whatsapp-service) automáticamente.

Después, en 3 terminales diferentes:
```bash
# Terminal 1
cd backend/SelloNFC && dotnet run

# Terminal 2
cd frontend && npm run dev

# Terminal 3
cd whatsapp-service && npm start
```
