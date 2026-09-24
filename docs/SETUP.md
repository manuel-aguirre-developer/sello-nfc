# Setup Local - Fidelización NFC

## 0. Pre-requisitos

- **Node.js** 18+
- **.NET 8 SDK**
- **Git**
- Cuenta **Supabase** (free tier)
- Cuenta **Oracle Cloud** (free tier, para deploy posterior)
- **VSCode** o editor de tu preferencia

---

## 1. Clonar Repositorio

```bash
git clone <repo-url>
cd fidelizacion-nfc
```

**Estructura esperada:**
```
fidelizacion-nfc/
├── backend/                (ASP.NET Core)
├── frontend/               (React/Vite)
├── whatsapp-service/       (Node.js)
├── docs/                   (este setup, PRD, etc)
└── README.md
```

---

## 2. Backend (ASP.NET Core)

### **2.1 Variables de Entorno**

Crear `backend/appsettings.Development.json`:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=<supabase-host>;Database=postgres;Username=postgres;Password=<supabase-password>;Port=5432;SSL Mode=Require;"
  },
  "AppSettings": {
    "JwtSecret": "tu-secret-muy-largo-aqui",
    "WhatsAppApiUrl": "http://localhost:3001"
  }
}
```

**Obtener credenciales Supabase:**
1. Ir a https://supabase.com → Create project
2. Esperar a que se cree
3. Settings → Database → Connection string (Psql)
4. Copiar host, password, etc.

### **2.2 Instalar Dependencias**

```bash
cd backend
dotnet restore
```

### **2.3 Crear Base de Datos (Migrations)**

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

Esto crea las tablas automáticamente.

### **2.4 Ejecutar API Local**

```bash
dotnet run
```

Debería ver:
```
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:7000
      Now listening on: http://localhost:5000
```

**Testear:**
```bash
curl http://localhost:5000/health
# Respuesta esperada: { "status": "ok" }
```

---

## 3. Frontend (React/Vite)

### **3.1 Variables de Entorno**

Crear `frontend/.env.local`:

```
VITE_API_URL=http://localhost:5000/api
VITE_MAPS_API_KEY=xxx  # Dejar vacío por ahora (v1.5)
```

### **3.2 Instalar Dependencias**

```bash
cd frontend
npm install
```

### **3.3 Ejecutar Dev Server**

```bash
npm run dev
```

Debería ver:
```
VITE v4.x.x  ready in xxx ms

➜  Local:   http://localhost:5173/
```

Abrir navegador en `http://localhost:5173`

---

## 4. Microservicio WhatsApp (Node.js)

### **4.1 Variables de Entorno**

Crear `whatsapp-service/.env`:

```
BACKEND_API_URL=http://localhost:5000/api
WHATSAPP_SESSION_NAME=whatsapp-session
PORT=3001
```

### **4.2 Instalar Dependencias**

```bash
cd whatsapp-service
npm install
```

### **4.3 Ejecutar Servicio**

```bash
npm start
```

**Primera ejecución:**
- whatsapp-web.js abrirá un navegador simulado
- Escanear QR code con WhatsApp real
- Sesión se guarda en `whatsapp-session/`

Debería ver:
```
WhatsApp service running on port 3001
Client ready!
```

---

## 5. Testear Flujo Completo

### **5.1 Crear Local de Prueba (en Supabase)**

```bash
# Ir a Supabase Console → SQL Editor
INSERT INTO locales (nombre, nfc_code, dueño_whatsapp, direccion, lat, lng)
VALUES ('Café Test', 'ABC123', '5491112345678', 'Calle Falsa 123', -34.7561, -58.2516);
```

### **5.2 Testear Escaneo en Frontend**

1. Abrir `http://localhost:5173/scan?code=ABC123`
2. Ingresár WhatsApp (ej: 5491112345678)
3. Click "Confirmar"
4. Debería recibir mensaje WhatsApp automáticamente

### **5.3 Testear Dashboard**

1. Abrir `http://localhost:5173/dashboard?local_id=1`
2. Ver clientes capturados
3. Click "Enviar mensaje" → debería llegar a WhatsApp

---

## 6. Comandos Útiles

### **Backend**

```bash
# Crear migration nueva
dotnet ef migrations add MigracionName

# Ver logs detallados
dotnet run --launch-profile "https"

# Limpiar y recompilar
dotnet clean && dotnet build
```

### **Frontend**

```bash
# Build para producción
npm run build

# Preview producción local
npm run preview

# Lint
npm run lint
```

### **WhatsApp**

```bash
# Ver sesión actual
ls -la whatsapp-session/

# Borrar sesión (para rescannear QR)
rm -rf whatsapp-session/
```

---

## 7. Troubleshooting

| Problema | Solución |
|----------|----------|
| "Connection refused" a Supabase | Verificar credenciales, revisar IP whitelist en Supabase |
| NFC no funciona en navegador | Usar HTTPS o localhost (NFC solo funciona en origin seguro) |
| WhatsApp service no inicia | Borrar `whatsapp-session/` e intentar de nuevo |
| API devuelve 404 | Verificar CORS en `Program.cs` del backend |
| Frontend no conecta a API | Verificar `VITE_API_URL` en `.env.local` |

---

## 8. Stack Ports

| Servicio | Puerto | URL |
|----------|--------|-----|
| Frontend (Vite) | 5173 | http://localhost:5173 |
| Backend (API) | 5000 | http://localhost:5000 |
| Backend HTTPS | 7000 | https://localhost:7000 |
| WhatsApp Service | 3001 | http://localhost:3001 |
| PostgreSQL | 5432 | (Supabase remoto) |

---

## 9. Próximos Pasos

- [ ] Todos pueden ejecutar `npm run dev` (frontend) + `dotnet run` (backend)
- [ ] Crear 1 local de test en BD
- [ ] Testear flujo completo
- [ ] Documentar issues encontrados
