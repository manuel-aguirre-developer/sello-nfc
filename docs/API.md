# API REST - Fidelización NFC

**Base URL (local):** `http://localhost:5000/api/v1`

**Base URL (prod):** `https://api.fidelizacion-nfc.com/api/v1`

---

## 1. Health Check

### `GET /health`

Verificar que API está activa.

**Response (200):**
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 2. Scan (NFC)

### `GET /scan`

Cliente escanea NFC. Backend valida el código y devuelve info del local.

**Query Params:**
- `code` (string, required): Código NFC único

**Response (200):**
```json
{
  "success": true,
  "local_id": 5,
  "local_name": "Café Barista",
  "direccion": "Calle Falsa 123",
  "mensaje_bienvenida": "¡Bienvenido a nuestro café!"
}
```

**Response (404):**
```json
{
  "success": false,
  "error": "Código NFC no válido",
  "code": "INVALID_NFC_CODE"
}
```

**Frontend usage:**
```javascript
// Al cargar página de scan
const params = new URLSearchParams(window.location.search);
const nfcCode = params.get('code');

const res = await fetch(`${VITE_API_URL}/scan?code=${nfcCode}`);
const data = await res.json();
```

---

## 3. Usuarios

### `POST /usuarios`

Registrar nuevo usuario o capturar visita si ya existe.

**Request Body:**
```json
{
  "whatsapp": "5491112345678",
  "nombre": "Juan Pérez",
  "local_id": 5
}
```

**Response (201 - Usuario nuevo):**
```json
{
  "success": true,
  "usuario_id": 42,
  "whatsapp": "5491112345678",
  "nombre": "Juan Pérez",
  "sellos": 1,
  "es_nuevo": true,
  "mensaje": "¡Bienvenido!"
}
```

**Response (200 - Usuario existente):**
```json
{
  "success": true,
  "usuario_id": 42,
  "whatsapp": "5491112345678",
  "nombre": "Juan Pérez",
  "sellos": 2,
  "es_nuevo": false,
  "mensaje": "¡Bienvenido de nuevo!"
}
```

**Response (400 - Validación fallida):**
```json
{
  "success": false,
  "error": "WhatsApp inválido",
  "code": "INVALID_WHATSAPP"
}
```

**Validaciones:**
- `whatsapp`: Formato válido (54 9 1234567890 o 5491234567890)
- `nombre`: Max 255 caracteres
- `local_id`: Debe existir en BD

**Side Effects:**
- Crea entrada en tabla `visitas` con timestamp
- Envía mensaje WhatsApp automático (vía microservicio)

---

### `GET /usuarios/{whatsapp}`

Obtener tarjeta digital del usuario.

**Response (200):**
```json
{
  "success": true,
  "usuario_id": 42,
  "whatsapp": "5491112345678",
  "nombre": "Juan Pérez",
  "locales_visitas": [
    {
      "local_id": 5,
      "local_name": "Café Barista",
      "sellos": 2,
      "ultima_visita": "2024-01-15T10:30:00Z"
    },
    {
      "local_id": 8,
      "local_name": "Pizzería Bella",
      "sellos": 1,
      "ultima_visita": "2024-01-10T19:00:00Z"
    }
  ],
  "total_sellos": 3
}
```

---

## 4. Locales

### `POST /locales`

Crear nuevo local (solo admin/dueño).

**Request Body:**
```json
{
  "nombre": "Café Barista",
  "nfc_code": "ABC123",
  "dueño_whatsapp": "5491112345678",
  "direccion": "Calle Falsa 123",
  "lat": -34.7561,
  "lng": -58.2516
}
```

**Response (201):**
```json
{
  "success": true,
  "local_id": 5,
  "nombre": "Café Barista",
  "nfc_code": "ABC123"
}
```

---

### `GET /locales/{local_id}`

Obtener detalles del local.

**Response (200):**
```json
{
  "success": true,
  "local_id": 5,
  "nombre": "Café Barista",
  "nfc_code": "ABC123",
  "dueño_whatsapp": "5491112345678",
  "direccion": "Calle Falsa 123",
  "lat": -34.7561,
  "lng": -58.2516,
  "total_clientes": 45,
  "total_visitas": 127,
  "created_at": "2024-01-10T08:00:00Z"
}
```

---

### `GET /locales/{local_id}/clientes`

Listar clientes del local con filtros opcionales.

**Query Params:**
- `dias` (int, default 30): Últimas X días
- `orden` (string, default "fecha"): "fecha" | "visitas" | "nombre"

**Response (200):**
```json
{
  "success": true,
  "local_id": 5,
  "total_clientes": 45,
  "clientes": [
    {
      "usuario_id": 42,
      "whatsapp": "5491112345678",
      "nombre": "Juan Pérez",
      "visitas": 3,
      "sellos": 3,
      "ultima_visita": "2024-01-15T10:30:00Z"
    },
    {
      "usuario_id": 43,
      "whatsapp": "5491122334455",
      "nombre": "María González",
      "visitas": 1,
      "sellos": 1,
      "ultima_visita": "2024-01-14T15:00:00Z"
    }
  ]
}
```

**Frontend usage:**
```javascript
const res = await fetch(`${VITE_API_URL}/locales/5/clientes?dias=30&orden=visitas`);
const data = await res.json();
// Mostrar tabla de clientes
```

---

## 5. WhatsApp

### `POST /whatsapp/send`

Enviar mensaje manual a usuario.

**Request Body:**
```json
{
  "usuario_id": 42,
  "contenido": "¡Hola Juan! Te extrañamos, ¡ven mañana por un café gratis!",
  "tipo": "promo"
}
```

**Response (200):**
```json
{
  "success": true,
  "mensaje_id": 1001,
  "usuario_id": 42,
  "estado": "pendiente",
  "tipo": "promo"
}
```

**Tipos válidos:** `bienvenida`, `reseña`, `promo`, `recordatorio`

---

### `POST /whatsapp/send-bulk`

Enviar mensaje a todos los clientes del local.

**Request Body:**
```json
{
  "local_id": 5,
  "contenido": "¡Happy Hour mañana de 18 a 20hs!",
  "tipo": "promo"
}
```

**Response (200):**
```json
{
  "success": true,
  "local_id": 5,
  "mensajes_enviados": 45,
  "tipo": "promo"
}
```

---

### `GET /whatsapp/historial/{usuario_id}`

Ver historial de mensajes del usuario.

**Response (200):**
```json
{
  "success": true,
  "usuario_id": 42,
  "mensajes": [
    {
      "mensaje_id": 1,
      "tipo": "bienvenida",
      "contenido": "¡Bienvenido a Café Barista!",
      "enviado": true,
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "mensaje_id": 2,
      "tipo": "promo",
      "contenido": "Ven mañana y lleva 2 cafés, paga 1",
      "enviado": true,
      "timestamp": "2024-01-15T11:00:00Z"
    }
  ]
}
```

---

## 6. Dashboard

### `GET /dashboard/{local_id}`

Panel completo del dueño del local.

**Response (200):**
```json
{
  "success": true,
  "local_id": 5,
  "nombre": "Café Barista",
  "stats": {
    "total_clientes": 45,
    "clientes_nuevos_hoy": 3,
    "total_visitas": 127,
    "visitas_hoy": 5,
    "ticket_promedio": 450.50
  },
  "top_clientes": [
    {
      "usuario_id": 42,
      "nombre": "Juan Pérez",
      "visitas": 12,
      "ultima_visita": "2024-01-15T10:30:00Z"
    }
  ],
  "mensajes_pendientes": 2,
  "proximidad": []  // v1.5: otros locales cerca
}
```

---

## 7. Códigos de Error

| Code | HTTP | Descripción |
|------|------|-------------|
| INVALID_NFC_CODE | 404 | Código NFC no válido |
| INVALID_WHATSAPP | 400 | Formato WhatsApp inválido |
| LOCAL_NOT_FOUND | 404 | Local no existe |
| USUARIO_NOT_FOUND | 404 | Usuario no existe |
| INTERNAL_SERVER_ERROR | 500 | Error del servidor |

---

## 8. Rate Limiting

- **100 requests/minuto** por IP
- **Aplicable a:** `/scan`, `/usuarios`, `/whatsapp/*`
- **Response (429):**
```json
{
  "success": false,
  "error": "Too many requests",
  "retry_after_seconds": 60
}
```

---

## 9. Testing con Postman

**Variables de Entorno Postman:**

```
{
  "base_url": "http://localhost:5000/api/v1",
  "local_id": "5",
  "usuario_id": "42",
  "whatsapp": "5491112345678",
  "nfc_code": "ABC123"
}
```

**Request de ejemplo:**
```
GET {{base_url}}/scan?code={{nfc_code}}
```

---

## 10. CORS

Backend permite requests desde:
- `http://localhost:5173` (dev frontend)
- `http://localhost:3000` (alt frontend)
- `https://*.vercel.app` (prod frontend)

Si necesitas agregar más, editar `Program.cs`:
```csharp
var allowedOrigins = new[] { "https://tu-dominio.com" };
services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", builder =>
        builder.WithOrigins(allowedOrigins).AllowAnyMethod().AllowAnyHeader()
    );
});
```

---

## 11. Versionado

API actual: **v1**

Futuras versiones pueden coexistir:
- `GET /api/v1/usuarios`
- `GET /api/v2/usuarios` (cuando haya cambios breaking)
