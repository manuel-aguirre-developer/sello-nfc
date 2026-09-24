# Architecture - Fidelización NFC

## 1. Diagrama de Alto Nivel

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE (Navegador)                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │  WebApp React (Vite)                              │  │
│  │  - NFC Scan → redirige                            │  │
│  │  - Captura WhatsApp                               │  │
│  │  - Mostrar sellos                                 │  │
│  │  - Permiso ubicación                              │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            ↓ HTTPS
┌──────────────────────────────────────────────────────────┐
│             BACKEND (ASP.NET Core)                        │
│  Oracle Cloud Always Free (ARM Linux)                     │
│                                                            │
│  ┌──────────────────────────────────────────────────┐   │
│  │  API REST (Controllers)                           │   │
│  │  - POST /scan (NFC)                               │   │
│  │  - POST /usuarios (registro WhatsApp)             │   │
│  │  - GET /local/:id/dashboard                       │   │
│  │  - POST /whatsapp/send (trigger manual)           │   │
│  └──────────────────────────────────────────────────┘   │
│                           ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Lógica de Negocio (Services)                     │   │
│  │  - UsuarioService                                 │   │
│  │  - LocalService                                   │   │
│  │  - VisitaService                                  │   │
│  │  - WhatsAppService                                │   │
│  └──────────────────────────────────────────────────┘   │
│                           ↓                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Data Access Layer (Entity Framework)             │   │
│  │  - DbContext                                      │   │
│  │  - Repositories                                   │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
         ↓                          ↓                  ↓
    PostgreSQL          WhatsApp-web.js         Geolocation
    (Supabase)          (Node.js microservicio) (cliente-side)
    PostGIS
```

---

## 2. Componentes

### **Frontend (React/Vite) - Vercel**

**Estructura:**
```
src/
├── pages/
│   ├── Scan.jsx       (NFC scan → captura WhatsApp)
│   ├── Tarjeta.jsx    (dashboard usuario: sellos)
│   └── Radar.jsx      (proximidad, v1.5)
├── components/
│   ├── FormuarioWhatsApp.jsx
│   ├── TarjetaSellos.jsx
│   └── Mapa.jsx
├── api/
│   └── client.js      (fetch a backend)
├── hooks/
│   └── useNFC.js      (lectura NFC Web API)
└── utils/
    └── geolocation.js
```

**Dependencies:**
- React 18+
- Vite
- Axios (HTTP client)
- Leaflet o Google Maps (v1.5)

**Deploy:** Vercel (auto desde GitHub)

---

### **Backend (ASP.NET Core 8) - Oracle Cloud**

**Estructura:**
```
src/
├── Controllers/
│   ├── ScanController.cs
│   ├── UsuariosController.cs
│   ├── LocalesController.cs
│   └── WhatsAppController.cs
├── Services/
│   ├── IUsuarioService.cs / UsuarioService.cs
│   ├── ILocalService.cs / LocalService.cs
│   ├── IVisitaService.cs / VisitaService.cs
│   └── IWhatsAppService.cs / WhatsAppService.cs
├── Data/
│   ├── AppDbContext.cs
│   ├── Migrations/
│   └── Repositories/
│       ├── IUsuarioRepository.cs
│       ├── ILocalRepository.cs
│       └── IVisitaRepository.cs
├── Models/
│   ├── Usuario.cs
│   ├── Local.cs
│   └── Visita.cs
├── DTOs/
│   ├── ScanRequestDto.cs
│   ├── UsuarioResponseDto.cs
│   └── DashboardDto.cs
└── Program.cs (Dependency Injection)
```

**Dependencies:**
- ASP.NET Core 8
- Entity Framework Core
- Npgsql (PostgreSQL)
- HttpClient

**Deploy:** Oracle Cloud VM (manual con SSH)

---

### **Microservicio WhatsApp (Node.js) - Oracle Cloud**

**Estructura:**
```
whatsapp-service/
├── index.js           (Express app + whatsapp-web.js)
├── routes/
│   └── send.js        (POST /send)
├── services/
│   └── whatsappService.js
└── .env              (credenciales WhatsApp)
```

**Dependencies:**
- Express
- whatsapp-web.js
- Axios (comunicación con API core)
- dotenv

**Deploy:** PM2 en Oracle Cloud VM (inicia con el sistema)

---

### **Base de Datos (PostgreSQL) - Supabase**

**Tablas:**

```sql
-- Usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    whatsapp VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Locales
CREATE TABLE locales (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    nfc_code VARCHAR(50) UNIQUE NOT NULL,
    dueño_whatsapp VARCHAR(20) NOT NULL,
    direccion VARCHAR(255),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Visitas
CREATE TABLE visitas (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuarios(id),
    local_id INT REFERENCES locales(id),
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Mensajes WhatsApp
CREATE TABLE mensajes_whatsapp (
    id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuarios(id),
    tipo VARCHAR(50), -- 'bienvenida', 'reseña', 'promo'
    contenido TEXT,
    enviado BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMP DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_usuarios_whatsapp ON usuarios(whatsapp);
CREATE INDEX idx_visitas_usuario ON visitas(usuario_id);
CREATE INDEX idx_visitas_local ON visitas(local_id);
CREATE INDEX idx_locales_nfc ON locales(nfc_code);
```

**PostGIS (v1.5):**
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
ALTER TABLE locales ADD COLUMN geom GEOMETRY(Point, 4326);
CREATE INDEX idx_locales_geom ON locales USING GIST(geom);
```

---

## 3. Flujos de Datos

### **Flujo: Cliente Escanea NFC**

```
1. Cliente abre navegador, apoya en NFC
2. NFC Web API lee: nfc_code = "ABC123"
3. Frontend redirige: /scan?code=ABC123
4. GET /api/scan?code=ABC123
   ↓
5. Backend valida nfc_code en BD
6. Responde: { local_id: 5, local_name: "Café Barista" }
7. Frontend muestra: "¿Cuál es tu WhatsApp?"
8. Usuario ingresa + confirma
9. POST /api/usuarios
   Body: { whatsapp: "5491112345678", nombre: "Juan", local_id: 5 }
   ↓
10. Backend: crea usuario si no existe, suma visita
11. Response: { usuario_id: 42, sellos: 1 }
12. Trigger: WhatsAppService → envía bienvenida
13. Frontend muestra: "¡Punto sumado! 1/10 sellos"
```

### **Flujo: Dueño Envía Mensaje Manual**

```
1. Dueño en dashboard: clientes de su local
2. Click "Enviar mensaje a todos"
3. POST /api/whatsapp/send
   Body: { local_id: 5, contenido: "¡Ven mañana!" }
   ↓
4. Backend: crea registros en mensajes_whatsapp (pendientes)
5. WhatsAppService: itera y envía cada mensaje
6. Actualiza: enviado = TRUE
7. Frontend muestra: "5 mensajes enviados"
```

---

## 4. Convenciones

### **Naming**

- Controllers: `ScanController`, `UsuariosController`
- Services: `IUsuarioService`, `UsuarioService`
- Repositories: `IUsuarioRepository`, `UsuarioRepository`
- DTOs: `UsuarioResponseDto`, `ScanRequestDto`
- Frontend: camelCase para variables, PascalCase para componentes

### **Versionado API**

Inicialmente: `/api/v1/` (preparate para v2)

### **Errores**

```json
{
  "success": false,
  "error": "Usuario ya existe",
  "code": "USER_ALREADY_EXISTS"
}
```

---

## 5. Seguridad (MVP)

- [ ] HTTPS obligatorio
- [ ] Rate limiting en API (100 req/min por IP)
- [ ] Validar nfc_code antes de cualquier operación
- [ ] Sanitizar entrada (WhatsApp, nombre)
- [ ] Variables de entorno para secrets (.env)

**NO MVP (después):** Auth tokens, JWT, roles

---

## 6. Performance

- API response: <200ms
- Webapp carga: <3s
- WhatsApp envío: <5s
- Queries con índices

---

## 7. Monitoreo (Mínimo)

- Logs en console/archivo del backend
- Cloudflare Analytics para frontend
- Alerts en Supabase si conexiones > umbral
