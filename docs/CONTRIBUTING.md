# Contributing - Guía para Contribuidores

## 1. Git Workflow

### **Ramas**

```
main (producción)
  ↑
staging (pre-producción)
  ↑
develop (desarrollo activo)
  ↑
feature/* (features nuevas)
bugfix/* (bugfixes)
hotfix/* (fixes urgentes a main)
```

### **Crear una rama nueva**

```bash
# Actualizar develop
git checkout develop
git pull origin develop

# Crear feature
git checkout -b feature/nombre-descriptivo

# Ejemplo:
# feature/nfc-scan
# feature/whatsapp-automation
# bugfix/validar-whatsapp
```

### **Workflow de una feature**

```bash
# 1. Crear rama desde develop
git checkout -b feature/mi-feature

# 2. Hacer cambios locales
# ... código ...

# 3. Commit con mensaje claro
git add .
git commit -m "feat: descripción clara del cambio"

# 4. Push a remoto
git push origin feature/mi-feature

# 5. Abrir Pull Request en GitHub
# - Título descriptivo
# - Descripción de qué, por qué, cómo
# - Assignar a otro dev para review

# 6. Después de aprobar
# - Merge a develop
# - Borrar rama local y remota
git checkout develop
git pull origin develop
git branch -d feature/mi-feature
git push origin --delete feature/mi-feature
```

---

## 2. Commits

### **Formato**

```
<tipo>(<scope>): <descripción>

<cuerpo (opcional)>

<footer (opcional)>
```

### **Tipos**

- `feat`: Feature nueva
- `fix`: Bug fix
- `docs`: Documentación
- `style`: Formato, linting (sin cambios de lógica)
- `refactor`: Refactorización sin cambiar comportamiento
- `perf`: Mejora de performance
- `test`: Tests nuevos o fixes
- `chore`: Tareas (dependencias, config)

### **Ejemplos**

```
feat(nfc): agregar validación de código NFC
fix(whatsapp): resolver error al enviar mensajes
docs(api): actualizar documentación de endpoints
refactor(usuarios): mejorar UsuarioService
```

---

## 3. Code Style

### **C# (Backend)**

```csharp
// ✅ BIEN
public class UsuarioService
{
    private readonly IUsuarioRepository _usuarioRepository;

    public UsuarioService(IUsuarioRepository usuarioRepository)
    {
        _usuarioRepository = usuarioRepository;
    }

    public async Task<UsuarioResponseDto> CrearUsuarioAsync(string whatsapp)
    {
        // Validación explícita
        if (string.IsNullOrEmpty(whatsapp))
            throw new ArgumentException("WhatsApp no puede estar vacío");

        var usuario = new Usuario { WhatsApp = whatsapp };
        await _usuarioRepository.AddAsync(usuario);
        return MapToDto(usuario);
    }
}

// ❌ MAL
public class UsuarioService {
  public void CrearUsuario(string w) {
    var u = new Usuario();
    u.WhatsApp = w;
    // ...
  }
}
```

**Convenciones:**
- Métodos públicos: PascalCase (`CrearUsuario`)
- Variables privadas: camelCase (`_usuarioRepository`)
- Interfaces: prefix `I` (`IUsuarioRepository`)
- Async methods: suffix `Async` (`CrearUsuarioAsync`)
- DTOs: suffix `Dto` (`UsuarioResponseDto`)

### **JavaScript/React (Frontend)**

```javascript
// ✅ BIEN
const ScanPage = () => {
  const [isLoading, setIsLoading] = useState(false);

  const handleScan = async (nfcCode) => {
    setIsLoading(true);
    try {
      const response = await fetch(`${VITE_API_URL}/scan?code=${nfcCode}`);
      const data = await response.json();
      // ...
    } catch (error) {
      console.error('Scan error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="scan-container">
      {/* JSX */}
    </div>
  );
};

// ❌ MAL
const ScanPage = () => {
  const scan = () => {
    fetch('/scan').then(r => r.json()).then(d => console.log(d));
  };
  return <div></div>;
};
```

**Convenciones:**
- Componentes: PascalCase (`ScanPage`, `FormuarioWhatsApp`)
- Hooks: camelCase (`useNFC`, `useGeolocation`)
- Constants: UPPER_SNAKE_CASE (`API_URL`, `MAX_RETRIES`)
- Props: camelCase (`isLoading`, `onSubmit`)

---

## 4. Testing

### **Backend - Unit Tests**

```csharp
// Tests/UsuarioServiceTests.cs
[TestClass]
public class UsuarioServiceTests
{
    private Mock<IUsuarioRepository> _repositoryMock;
    private UsuarioService _service;

    [TestInitialize]
    public void Setup()
    {
        _repositoryMock = new Mock<IUsuarioRepository>();
        _service = new UsuarioService(_repositoryMock.Object);
    }

    [TestMethod]
    public async Task CrearUsuario_ConWhatsAppValido_DevuelveUsuario()
    {
        // Arrange
        var whatsapp = "5491112345678";

        // Act
        var resultado = await _service.CrearUsuarioAsync(whatsapp);

        // Assert
        Assert.IsNotNull(resultado);
        Assert.AreEqual(whatsapp, resultado.WhatsApp);
    }

    [TestMethod]
    [ExpectedException(typeof(ArgumentException))]
    public async Task CrearUsuario_ConWhatsAppVacio_LanzaError()
    {
        await _service.CrearUsuarioAsync("");
    }
}
```

Ejecutar:
```bash
dotnet test
```

### **Frontend - Component Tests**

```javascript
// src/__tests__/ScanPage.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';
import ScanPage from '../pages/ScanPage';

describe('ScanPage', () => {
  test('renders form with WhatsApp input', () => {
    render(<ScanPage />);
    const input = screen.getByPlaceholderText(/WhatsApp/i);
    expect(input).toBeInTheDocument();
  });

  test('submits form with valid WhatsApp', async () => {
    render(<ScanPage />);
    const input = screen.getByPlaceholderText(/WhatsApp/i);
    const button = screen.getByRole('button', { name: /Confirmar/i });

    fireEvent.change(input, { target: { value: '5491112345678' } });
    fireEvent.click(button);

    // Assertions...
  });
});
```

Ejecutar:
```bash
npm test
```

---

## 5. Pull Request Checklist

Antes de hacer merge, verificar:

```
- [ ] Código sigue convenciones (linting pass)
- [ ] Tests nuevos escritos y pasan
- [ ] Sin console.log() o comentarios de debug
- [ ] Documentación actualizada si es necesario
- [ ] No hay dependencias no usadas
- [ ] Mensaje de commit claro
- [ ] PR tiene descripción clara
- [ ] Otro dev lo revisó y aprobó
```

### **Template de PR Description**

```markdown
## ¿Qué cambio hace este PR?

Descripción breve...

## ¿Por qué?

Problema que resuelve...

## Testing

- [ ] Testeado localmente
- [ ] Casos edge considerados
- [ ] Tests automatizados agregados

## Screenshots (si aplica)

[Agregar aquí]

## Related Issues

Closes #123
```

---

## 6. Code Review

### **Como revisor**

```
✅ Revisar:
- Lógica es correcta
- No hay duplicación
- Nombres son claros
- Handling de errores
- Performance

💬 Feedback constructivo:
- "¿Qué tal si...?"
- "Consideraste...?"
- No: "Está mal", "Cambio esto"
```

### **Como autor**

```
- Responder todos los comentarios
- No tomar personalmente el feedback
- Hacer cambios y re-asignar para review
- Una vez aprobado, mergear
```

---

## 7. Linting & Formatting

### **Backend - .NET**

```bash
# Formato automático
dotnet format

# Revisar style
dotnet format --verify-no-changes
```

Archivo `.editorconfig`:
```ini
[*.cs]
indent_style = space
indent_size = 4
```

### **Frontend - JavaScript**

```bash
# ESLint
npm run lint

# Fix automático
npm run lint:fix

# Prettier (formato)
npm run format
```

Archivo `.eslintrc.json`:
```json
{
  "extends": ["eslint:recommended", "react-app"],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "warn"
  }
}
```

---

## 8. Deployment

### **Staging (develop → staging)**

```bash
git checkout staging
git pull origin develop
# Revisar cambios
# Deploy automático (Vercel/Oracle)
```

### **Production (staging → main)**

```bash
git checkout main
git pull origin staging
# Testing final
# Deploy automático
# Tag de versión: v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

---

## 9. Comunicación

### **Slack/Chat**

- Status diario: "Hoy trabajo en feature X"
- Bloqueadores: "Necesito ayuda con Y"
- Preguntas técnicas: Preguntar en el canal, no DM

### **Documentación Importante**

- [ ] Documentar cambios en README
- [ ] Documentar nuevos endpoints en API.md
- [ ] Documentar cambios en BD en DATABASE.md

---

## 10. Issues & Bugs

### **Reportar un bug**

```markdown
**Descripción**
Qué ocurrió...

**Steps to Reproduce**
1. ...
2. ...
3. ...

**Expected vs Actual**
Esperaba: ...
Pasó: ...

**Environment**
- OS: ...
- Browser/Runtime: ...
- Version: ...
```

### **Crear una feature**

```markdown
**Descripción**
Qué necesitamos...

**Acceptance Criteria**
- [ ] Funcionalidad A
- [ ] Funcionalidad B

**Tasks**
- [ ] Backend endpoint
- [ ] Frontend component
- [ ] Tests
```
