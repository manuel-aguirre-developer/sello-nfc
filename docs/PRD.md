# PRD - Sistema de Fidelización NFC "Fricción Cero"

## 1. Problema

**Target**: Locales pequeños-medianos (cafeterías, peluquerías, restaurantes, bares)

- Apps de fidelización tradicionales fracasan: requieren descargas, registros largos, contraseñas
- Dueños pierden datos de clientes y contacto directo
- No hay forma de capturar feedback post-visita
- Clientes no saben qué otros negocios afiliados hay cerca

---

## 2. Solución

### **Experiencia del Usuario**

1. **Escaneo NFC**: Cliente apoya teléfono en cartelito NFC del local
2. **Captura**: Webapp se abre en navegador (sin instalar app)
   - Solicita: WhatsApp (requerido) + Nombre (opcional)
   - Suma 1 sello/punto
3. **Descubrimiento**: Sistema pide permiso de ubicación → muestra negocios cercanos en mapa
4. **Retención**: Recibe mensaje automático por WhatsApp con tarjeta digital

### **Experiencia del Dueño**

1. **Base de Datos**: Captura WhatsApp + nombre de clientes
2. **Reseñas Automáticas**: Al día siguiente, envía encuesta → si buena → link Google Maps
3. **Campaigns**: Envía mensajes masivos por WhatsApp (cumpleaños, promociones)
4. **Cross-Traffic**: Clientes ven otros negocios de la red cerca de ellos

---

## 3. MVP Scope

### **✅ MVP v1 Incluye**

**Cliente:**
- Escaneo NFC → redirige a webapp
- Captura WhatsApp + nombre
- Dashboard: sellos en el local actual
- Permiso de ubicación (sin radar visual aún)

**Dueño:**
- Dashboard: lista de clientes capturados
- Ver sellos por cliente
- Exportar CSV de contactos
- Enviar mensaje manual por WhatsApp

**Sistema:**
- Almacenamiento en PostgreSQL/Supabase
- Integración WhatsApp Business (via whatsapp-web.js)
- Generación de códigos NFC únicos por local

### **❌ MVP v1 NO Incluye**

- Radar de proximidad visual (mapa interactivo)
- Reseñas automáticas
- Rewards/descuentos
- Roles de admin, subadmins
- Analítica avanzada
- Multi-idioma

---

## 4. Flujos Principales

### **Flujo 1: Cliente Visita Local**

```
1. Cliente apoya teléfono en NFC
2. Se abre webapp en navegador (localhost/scan?code=ABC123)
3. Pregunta: "¿Cuál es tu WhatsApp?" + nombre opcional
4. Click "Confirmar" → registra punto
5. Pide permiso de ubicación (opcional por ahora)
6. Muestra: "¡Punto sumado! Tienes 1/10 sellos"
7. WhatsApp automático: "Bienvenida a [Local], tu tarjeta digital..."
```

### **Flujo 2: Dueño Revisa Dashboard**

```
1. Dueño accede: dashboard.localhost/local/ABC123/clientes
2. Ve: lista de clientes (WhatsApp, nombre, fecha última visita, sellos)
3. Filtros básicos: últimas 30 días, más frecuentes, nuevos
4. Botón: "Enviar mensaje WhatsApp a todos"
```

### **Flujo 3: WhatsApp Automático**

```
- Trigger: cliente confirma punto
- Acción: envía mensaje + imagen de tarjeta digital (HTML renderizado a JPG)
- Contenido: "Hola [Nombre], tienes 1/10 sellos en [Local]. Descarga aquí: [link]"
```

---

## 5. Métricas de Éxito (MVP)

| Métrica | Target |
|---------|--------|
| % de usuarios que completan WhatsApp en escaneo | >70% |
| Tiempo desde escaneo a confirmación | <10s |
| Retorno al local (7 días) | >30% |
| Tasa de error en integración WhatsApp | <1% |

---

## 6. Especificaciones Técnicas

### **Datos Principales**

**Usuario**
```
id, whatsapp (unique), nombre, created_at
```

**Local**
```
id, nombre, nfc_code (unique), dueño_whatsapp, direccion, lat, lng, created_at
```

**Visita**
```
id, usuario_id, local_id, timestamp, sellos_acumulados
```

**Mensaje WhatsApp**
```
id, usuario_id, tipo (bienvenida|reseña|promo), contenido, timestamp, enviado (bool)
```

### **Endpoints Core MVP**

```
POST /api/scan
  Body: { nfc_code }
  Response: { local_id, local_name, usuario_existente: bool }

POST /api/usuarios
  Body: { whatsapp, nombre, local_id }
  Response: { usuario_id, sellos }

GET /api/local/:local_id/dashboard
  Response: { clientes: [...], total_visitas, sellos_totales }

POST /api/whatsapp/send
  Body: { usuario_id, tipo, contenido }
  Response: { mensaje_id, enviado }

GET /api/usuarios/:whatsapp/tarjeta
  Response: { sellos, local_name, imagen_tarjeta_url }
```

### **Integraciones**

- **WhatsApp**: whatsapp-web.js (Node.js microservicio)
- **NFC Web API**: nativa del navegador
- **Geolocation API**: nativa del navegador
- **PostGIS**: queries de proximidad (v1.5+)

---

## 7. Responsabilidades (2 Devs)

**Frontend (React/Vite):**
- Webapp NFC
- Dashboard dueño
- Integración Geolocation API

**Backend (ASP.NET Core):**
- API REST
- Lógica de negocio
- Integraciones (WhatsApp, PostgreSQL)

---

## 8. Timeline

| Sprint | Duración | Qué |
|--------|----------|-----|
| 1 | 1 semana | Setup, API básica, BD |
| 2 | 1 semana | Webapp NFC + WhatsApp automático |
| 3 | 1 semana | Dashboard dueño + testing |
| Pilot | 1-2 sem | 1 local real, recolectar feedback |

---

## 9. Riesgos

| Riesgo | Mitigación |
|--------|-----------|
| whatsapp-web.js inestable | Monitoring, logs; cambiar a API oficial si cae |
| NFC no funciona en todos los phones | Fallback: QR code |
| PostgreSQL free tier limita conexiones | Monitorear desde v1, plan upgrade |
| Latencia en Oracle Cloud ARM | Testear compilación temprano |

---

## 10. Success Criteria

MVP lanzado cuando:
- [ ] API levanta sin errores
- [ ] Webapp carga en <3s
- [ ] WhatsApp se envía en <5s
- [ ] 1 local piloto captura 10+ clientes
- [ ] Documentación completa para 2do dev
