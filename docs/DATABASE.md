# Database - Fidelización NFC

## 1. Diagrama ER (Entity Relationship)

```
┌──────────────────┐
│    USUARIOS      │
├──────────────────┤
│ id (PK)          │
│ whatsapp (UNIQUE)│◄─────────┐
│ nombre           │          │
│ created_at       │          │
└──────────────────┘          │
         ▲                    │
         │                    │
         │ 1:N                │
    ┌────┴─────────────────────┘
    │
┌───┴──────────────────┐         ┌──────────────────┐
│    VISITAS           │         │    LOCALES       │
├──────────────────────┤         ├──────────────────┤
│ id (PK)              │         │ id (PK)          │
│ usuario_id (FK)      │────┐    │ nombre           │
│ local_id (FK)        │    └───►│ nfc_code (UNIQUE)│
│ timestamp            │         │ dueño_whatsapp   │
└──────────────────────┘         │ direccion        │
         ▲                        │ lat              │
         │ 1:N                    │ lng              │
         │                        │ created_at       │
    ┌────┴─────────┐              └──────────────────┘
    │              │
┌───┴────────────────────────┐
│  MENSAJES_WHATSAPP         │
├────────────────────────────┤
│ id (PK)                    │
│ usuario_id (FK)            │
│ tipo                       │
│ contenido                  │
│ enviado (BOOLEAN)          │
│ timestamp                  │
└────────────────────────────┘
```

---

## 2. Tablas

### **usuarios**

```sql
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    whatsapp VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_usuarios_whatsapp ON usuarios(whatsapp);
```

**Validaciones:**
- `whatsapp`: Formato +549XXXXXXXXXX o 549XXXXXXXXXX (min 10 dígitos)
- `nombre`: Opcional, max 255 caracteres

---

### **locales**

```sql
CREATE TABLE locales (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    nfc_code VARCHAR(50) UNIQUE NOT NULL,
    dueño_whatsapp VARCHAR(20) NOT NULL,
    direccion VARCHAR(500),
    lat DECIMAL(10, 8),
    lng DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_locales_nfc_code ON locales(nfc_code);
CREATE INDEX idx_locales_dueño ON locales(dueño_whatsapp);
```

**Validaciones:**
- `nfc_code`: Único, alphanumeric
- `lat/lng`: Coordenadas válidas (-90 a 90, -180 a 180)

---

### **visitas**

```sql
CREATE TABLE visitas (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    local_id INT NOT NULL REFERENCES locales(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visitas_usuario ON visitas(usuario_id);
CREATE INDEX idx_visitas_local ON visitas(local_id);
CREATE INDEX idx_visitas_timestamp ON visitas(timestamp);
```

**Notas:**
- Una fila por visita (cada escaneo = una visita)
- Sellos = COUNT(*) de visitas para usuario+local

---

### **mensajes_whatsapp**

```sql
CREATE TABLE mensajes_whatsapp (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    local_id INT REFERENCES locales(id) ON DELETE SET NULL,
    tipo VARCHAR(50) NOT NULL, -- 'bienvenida', 'reseña', 'promo', 'recordatorio'
    contenido TEXT NOT NULL,
    enviado BOOLEAN DEFAULT FALSE,
    timestamp_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    timestamp_envio TIMESTAMP,
    error_envio TEXT
);

CREATE INDEX idx_mensajes_usuario ON mensajes_whatsapp(usuario_id);
CREATE INDEX idx_mensajes_enviado ON mensajes_whatsapp(enviado);
CREATE INDEX idx_mensajes_tipo ON mensajes_whatsapp(tipo);
```

---

## 3. Queries Útiles

### **Contar sellos de un usuario en un local**

```sql
SELECT COUNT(*) AS sellos
FROM visitas
WHERE usuario_id = 42
  AND local_id = 5;
```

### **Top 10 clientes más frecuentes de un local**

```sql
SELECT 
    u.id,
    u.whatsapp,
    u.nombre,
    COUNT(v.id) AS visitas,
    MAX(v.timestamp) AS ultima_visita
FROM usuarios u
JOIN visitas v ON u.id = v.usuario_id
WHERE v.local_id = 5
GROUP BY u.id
ORDER BY visitas DESC
LIMIT 10;
```

### **Clientes nuevos en últimos X días**

```sql
SELECT 
    u.id,
    u.whatsapp,
    u.nombre,
    u.created_at
FROM usuarios u
WHERE u.created_at >= NOW() - INTERVAL '30 days'
ORDER BY u.created_at DESC;
```

### **Mensajes WhatsApp pendientes**

```sql
SELECT 
    mw.id,
    mw.usuario_id,
    u.whatsapp,
    mw.contenido,
    mw.tipo
FROM mensajes_whatsapp mw
JOIN usuarios u ON mw.usuario_id = u.id
WHERE mw.enviado = FALSE
ORDER BY mw.timestamp_creacion ASC;
```

### **Clientes duplicados (mismo WhatsApp)**

```sql
SELECT 
    whatsapp,
    COUNT(*) AS cantidad
FROM usuarios
GROUP BY whatsapp
HAVING COUNT(*) > 1;
```

---

## 4. Entity Framework Core Models

### **Usuario.cs**

```csharp
public class Usuario
{
    public int Id { get; set; }
    public string WhatsApp { get; set; } // Unique
    public string Nombre { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Relationships
    public ICollection<Visita> Visitas { get; set; } = new List<Visita>();
    public ICollection<MensajeWhatsApp> Mensajes { get; set; } = new List<MensajeWhatsApp>();
}
```

### **Local.cs**

```csharp
public class Local
{
    public int Id { get; set; }
    public string Nombre { get; set; }
    public string NfcCode { get; set; } // Unique
    public string DueñoWhatsApp { get; set; }
    public string Direccion { get; set; }
    public decimal? Lat { get; set; }
    public decimal? Lng { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Relationships
    public ICollection<Visita> Visitas { get; set; } = new List<Visita>();
    public ICollection<MensajeWhatsApp> Mensajes { get; set; } = new List<MensajeWhatsApp>();
}
```

### **Visita.cs**

```csharp
public class Visita
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public int LocalId { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    // Relationships
    public Usuario Usuario { get; set; }
    public Local Local { get; set; }
}
```

### **MensajeWhatsApp.cs**

```csharp
public class MensajeWhatsApp
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public int? LocalId { get; set; }
    public string Tipo { get; set; } // 'bienvenida', 'reseña', 'promo'
    public string Contenido { get; set; }
    public bool Enviado { get; set; } = false;
    public DateTime TimestampCreacion { get; set; } = DateTime.UtcNow;
    public DateTime? TimestampEnvio { get; set; }
    public string ErrorEnvio { get; set; }

    // Relationships
    public Usuario Usuario { get; set; }
    public Local Local { get; set; }
}
```

### **AppDbContext.cs**

```csharp
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<Local> Locales { get; set; }
    public DbSet<Visita> Visitas { get; set; }
    public DbSet<MensajeWhatsApp> MensajesWhatsApp { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Unique constraints
        modelBuilder.Entity<Usuario>()
            .HasIndex(u => u.WhatsApp)
            .IsUnique();

        modelBuilder.Entity<Local>()
            .HasIndex(l => l.NfcCode)
            .IsUnique();

        // Foreign keys
        modelBuilder.Entity<Visita>()
            .HasOne(v => v.Usuario)
            .WithMany(u => u.Visitas)
            .HasForeignKey(v => v.UsuarioId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Visita>()
            .HasOne(v => v.Local)
            .WithMany(l => l.Visitas)
            .HasForeignKey(v => v.LocalId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<MensajeWhatsApp>()
            .HasOne(m => m.Usuario)
            .WithMany(u => u.Mensajes)
            .HasForeignKey(m => m.UsuarioId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

---

## 5. Migrations (ASP.NET Core)

### **Crear migration inicial**

```bash
cd backend
dotnet ef migrations add InitialCreate
```

Esto crea automáticamente el archivo en `Data/Migrations/`

### **Aplicar migrations a BD**

```bash
dotnet ef database update
```

### **Ver estado de migrations**

```bash
dotnet ef migrations list
```

---

## 6. PostGIS (Fase v1.5)

Cuando implementes "Radar de Proximidad":

```sql
-- Habilitar extensión
CREATE EXTENSION IF NOT EXISTS postgis;

-- Agregar columna geométrica a locales
ALTER TABLE locales ADD COLUMN geom GEOMETRY(Point, 4326);

-- Crear índice espacial
CREATE INDEX idx_locales_geom ON locales USING GIST(geom);

-- Poblar con coordenadas existentes
UPDATE locales 
SET geom = ST_Point(lng, lat, 4326)
WHERE lat IS NOT NULL AND lng IS NOT NULL;

-- Query: locales a menos de 500 metros
SELECT id, nombre, 
       ST_Distance(geom, ST_Point(-58.2516, -34.7561, 4326)) as distancia
FROM locales
WHERE ST_DWithin(geom, ST_Point(-58.2516, -34.7561, 4326), 0.005)
ORDER BY distancia
LIMIT 10;
```

---

## 7. Backups & Restore

### **Backup con Supabase**

Supabase realiza backups automáticos diarios. Para backup manual:

```bash
# Via pgBackRest (Supabase Panel)
# Settings → Backups → Request backup
```

### **Restore**

```bash
pg_restore -h <host> -U postgres -d <dbname> -Fc backup.dump
```

---

## 8. Optimización

### **Vacuum & Analyze**

```sql
VACUUM ANALYZE;
```

### **Ver índices**

```sql
SELECT * FROM pg_indexes WHERE schemaname = 'public';
```

### **Ver tamaño de tablas**

```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## 9. Troubleshooting

| Problema | Solución |
|----------|----------|
| "too many connections" | Supabase free: máx 2 conexiones. Usar connection pooling en backend |
| "unique constraint violation" | Dato duplicado. Ver query de duplicados arriba |
| Queries lentas | Revisar índices con `EXPLAIN ANALYZE` |
| Migrations fallidas | `dotnet ef migrations remove` y reintentar |
