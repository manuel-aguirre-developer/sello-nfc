# 🎫 Fidelización NFC - Sistema de Sellos Digitales

> **Fricción Cero.** Un escaneo NFC, un WhatsApp, listo.

Plataforma B2B2C que permite a locales pequeños (cafeterías, peluquerías, restaurantes, bares) capturar clientes, gestionar sellos digitales y automatizar comunicaciones por WhatsApp, eliminando toda fricción.

---

## 📋 Tabla de Contenidos

1. [Quick Start](#quick-start)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Stack Tecnológico](#stack-tecnológico)
4. [Documentación](#documentación)
5. [Contribuir](#contribuir)
6. [Contacto](#contacto)

---

## 🚀 Quick Start

### **Para devs nuevos**

1. **Leer** [`PRD.md`](./PRD.md) (5 min) - Entiende qué estamos construyendo
2. **Leer** [`ARCHITECTURE.md`](./ARCHITECTURE.md) (10 min) - Entiende cómo está armado
3. **Ejecutar** [`SETUP.md`](./SETUP.md) (30 min) - Levanta todo localmente
4. **Explorar** [`API.md`](./API.md) - Lista de endpoints
5. **Leer** [`CONTRIBUTING.md`](./CONTRIBUTING.md) - Cómo contribuir

### **Levantar proyecto local (3 pasos)**

```bash
# 1. Backend
cd backend && dotnet run

# 2. Frontend (otra terminal)
cd frontend && npm run dev

# 3. WhatsApp Service (otra terminal)
cd whatsapp-service && npm start
```

Listo. Backend: http://localhost:5000, Frontend: http://localhost:5173

---

## 📁 Estructura del Proyecto

```
fidelizacion-nfc/
├── docs/                           # 📖 Documentación
│   ├── PRD.md                      # Product Requirements Document
│   ├── ARCHITECTURE.md             # Diagrama y componentes
│   ├── SETUP.md                    # Guía de setup local
│   ├── API.md                      # Endpoints REST
│   ├── DATABASE.md                 # Esquema de BD
│   ├── CONTRIBUTING.md             # Convenciones de código
│   └── README.md                   # Este archivo
│
├── backend/                        # 🖥️ API (ASP.NET Core)
│   ├── Controllers/
│   ├── Services/
│   ├── Data/
│   ├── Models/
│   ├── appsettings.Development.json
│   ├── Program.cs
│   └── Dockerfile (después)
│
├── frontend/                       # 💻 WebApp (React/Vite)
│   ├── src/
│   │   ├── pages/                  # Scan, Dashboard, Tarjeta
│   │   ├── components/
│   │   ├── api/                    # HTTP client
│   │   ├── hooks/                  # useNFC, etc
│   │   └── App.jsx
│   ├── .env.local
│   ├── vite.config.js
│   └── package.json
│
├── whatsapp-service/               # 📱 Microservicio WhatsApp (Node.js)
│   ├── index.js
│   ├── routes/
│   ├── services/
│   ├── .env
│   └── package.json
│
├── .gitignore
├── .github/
│   └── workflows/                  # CI/CD (después)
│       ├── test.yml
│       └── deploy.yml
│
└── README.md
```

---

## 🛠️ Stack Tecnológico

| Componente | Tech | Razón |
|-----------|------|-------|
| **Backend** | ASP.NET Core 8 (C#) | Sólido, performante, $0 en Oracle Cloud |
| **Frontend** | React 18 + Vite | Ultraligero, NFC nativo |
| **DB** | PostgreSQL + PostGIS | Supabase free, geo-queries incluidas |
| **WhatsApp** | Node.js + whatsapp-web.js | Sin costos de API Meta |
| **Hosting Backend** | Oracle Cloud Always Free | $0/mes, ARM Linux |
| **Hosting Frontend** | Vercel | $0/mes, auto-deploy |
| **NFC** | Web NFC API | Nativa, sin librerías |

**Cost: $0/mes inicial** ✅

---

## 📖 Documentación

Cada documento está enfocado en un aspecto específico:

### **Antes de empezar**
- [`PRD.md`](./PRD.md) - Qué vamos a construir, por qué, success criteria
- [`ARCHITECTURE.md`](./ARCHITECTURE.md) - Cómo está organizado el código, flujos de datos

### **Para levantar ambiente**
- [`SETUP.md`](./SETUP.md) - Paso a paso: variables, comandos, troubleshooting

### **Para trabajar en features**
- [`API.md`](./API.md) - Todos los endpoints, payloads, responses
- [`DATABASE.md`](./DATABASE.md) - Esquema, queries útiles, migrations
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) - Git workflow, convenciones, code review

---

## 🔑 Conceptos Clave

### **Cliente (Usuario)**
1. Apoya teléfono en NFC del local
2. Se abre webapp ultraligera (sin descargar nada)
3. Ingresa WhatsApp (único dato requerido)
4. Suma 1 sello digital
5. Recibe mensaje automático por WhatsApp

### **Local (B2B)**
1. Recibe lista de clientes con WhatsApp
2. Dashboard: ve clientes, sellos, últimas visitas
3. Puede enviar mensajes masivos por WhatsApp
4. Bonus (v1.5): ve otros locales de la red cerca

### **Red (Nosotros)**
- Cobramos comisión por cliente capturado o suscripción fija
- Facilitamos cross-traffic entre locales afiliados

---

## 🔄 Workflow

```
📅 Sprint 1: Setup, API básica, BD
  └─ Feature: ✅ GET /scan, POST /usuarios, tablas creadas

📅 Sprint 2: Frontend + Automatización
  └─ Feature: ✅ Webapp NFC, WhatsApp automático

📅 Sprint 3: Dashboard + Testing
  └─ Feature: ✅ Dashboard dueño, todo testeado

🧪 Pilot (1 local real)
  └─ Feedback, ajustes, go/no-go
```

---

## 📊 Métricas MVP

| Métrica | Target |
|---------|--------|
| % usuarios completan WhatsApp | >70% |
| Tiempo escaneo → confirmación | <10s |
| Retorno (7 días) | >30% |
| Tasa error WhatsApp | <1% |

---

## 🤝 Contribuir

1. **Leer** [`CONTRIBUTING.md`](./CONTRIBUTING.md)
2. **Branch naming**: `feature/nombre`, `bugfix/nombre`
3. **Commits**: `feat: descripción`, `fix: descripción`
4. **PR**: Descripción clara, otro dev revisa
5. **Merge**: Solo después de aprobación

```bash
# Ejemplo
git checkout -b feature/agregar-permiso-ubicacion
# ... código ...
git commit -m "feat: solicitar permiso de ubicación al confirmar escaneo"
git push origin feature/agregar-permiso-ubicacion
# → Abrir PR en GitHub
```

---

## 🐛 Reportar Issues

Usar GitHub Issues con template:
- **Bug**: Qué pasó, steps to reproduce, error esperado vs actual
- **Feature**: Qué necesitamos, acceptance criteria, tareas

---

## 📝 Notas Importantes

### **Secrets & Credenciales**

❌ NUNCA: Pushear `.env`, contraseñas, keys
✅ SIEMPRE: Agregar a `.gitignore`, documentar en `SETUP.md` cómo obtenerlas

### **Deployment**

- **Staging**: develop → auto-deploy a staging
- **Prod**: staging → manual → tag version → auto-deploy a prod

### **Testing**

- Antes de mergear a develop: tests pasan
- Antes de prod: todo testeado manualmente en staging

---

## 🚨 En Caso de Emergencia

### **API no levanta**
```bash
cd backend
dotnet clean && dotnet build
dotnet run
```

### **Frontend no carga**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run dev
```

### **WhatsApp no conecta**
```bash
cd whatsapp-service
rm -rf whatsapp-session/
npm start
# Escanear QR nuevamente
```

### **Problema en BD**
1. Ir a Supabase Console
2. SQL Editor → copiar query de `DATABASE.md`
3. O contactar al otro dev

---

## 📚 Recursos Útiles

- [ASP.NET Core Docs](https://docs.microsoft.com/aspnet/core)
- [React Docs](https://react.dev)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Web NFC API](https://developer.mozilla.org/en-US/docs/Web/API/Web_NFC_API)
- [Postman](https://www.postman.com/) - Para testear API

---

## 👥 Equipo

- **Backend**: [Nombre]
- **Frontend**: [Nombre]
- **PM**: Manuel (también dev)

---

## 📧 Contacto

Preguntas? Slack o issues en GitHub.

---

**Last Updated**: Enero 2024 | **Version**: 0.1 MVP | **Status**: 🚀 En desarrollo
