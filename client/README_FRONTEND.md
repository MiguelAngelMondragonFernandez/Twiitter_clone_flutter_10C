# Chirper - Frontend Flutter

Este es el frontend de la aplicación Chirper, un clon de Twitter desarrollado con Flutter siguiendo la arquitectura MVVM.

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── user.dart            # Modelo de usuario
│   └── chirp.dart           # Modelo de chirp (tweet)
├── views/                    # Pantallas de la aplicación
│   ├── login_view.dart      # Pantalla de inicio de sesión
│   ├── register_view.dart   # Pantalla de registro
│   ├── home_view.dart       # Pantalla principal con feed
│   ├── profile_view.dart    # Pantalla de perfil de usuario
│   └── create_chirp_view.dart # Pantalla para crear chirps
├── viewmodels/              # ViewModels (lógica de negocio)
│   ├── auth_viewmodel.dart  # ViewModel para autenticación
│   └── chirp_viewmodel.dart # ViewModel para chirps
├── services/                # Servicios de comunicación con API
│   ├── auth_service.dart    # Servicio de autenticación
│   └── chirp_service.dart   # Servicio de chirps
├── widgets/                 # Widgets reutilizables
│   ├── custom_button.dart   # Botón personalizado
│   ├── custom_textfield.dart # Campo de texto personalizado
│   └── chirp_card.dart      # Tarjeta de chirp
└── utils/                   # Utilidades y constantes
    └── api_constants.dart   # Constantes de API
```

## 🎨 Arquitectura MVVM

El proyecto sigue el patrón **Model-View-ViewModel**:

- **Model**: Clases de datos (`User`, `Chirp`) que representan las entidades del negocio
- **View**: Widgets de Flutter que representan la UI (`LoginView`, `HomeView`, etc.)
- **ViewModel**: Clases que manejan la lógica de negocio y el estado usando Provider (`AuthViewModel`, `ChirpViewModel`)

## 🔧 Tecnologías y Paquetes

- **Flutter**: Framework de desarrollo móvil
- **Provider**: Gestión de estado
- **http**: Comunicación con API REST
- **shared_preferences**: Almacenamiento local persistente
- **intl**: Formato de fechas y horas

## 🚀 Características Implementadas

### Autenticación
- ✅ Login con email y contraseña
- ✅ Registro de nuevos usuarios
- ✅ Persistencia de sesión
- ✅ Logout

### Feed de Chirps
- ✅ Visualización del feed principal
- ✅ Scroll infinito con paginación
- ✅ Pull-to-refresh
- ✅ Like/Unlike chirps
- ✅ Visualización de estadísticas (likes, replies, reposts)

### Gestión de Chirps
- ✅ Crear nuevos chirps (máx. 280 caracteres)
- ✅ Eliminar chirps propios
- ✅ Visualizar chirps de un usuario

### Perfil
- ✅ Visualización de perfil propio
- ✅ Estadísticas de seguidores y seguidos
- ✅ Lista de chirps del usuario

### 🔔 Notificaciones (NUEVO)
- ✅ Sistema completo de notificaciones
- ✅ 5 tipos: like, repost, follow, reply, mention
- ✅ Badge con contador de no leídas
- ✅ Marcar individual o todas como leídas
- ✅ Swipe to dismiss para eliminar
- ✅ Scroll infinito con paginación
- ✅ Diseño con colores por tipo

### 🔍 Búsqueda (NUEVO)
- ✅ Búsqueda de usuarios y chirps
- ✅ Tabs: Todo, Usuarios, Chirps
- ✅ Búsqueda en tiempo real
- ✅ Resultados con paginación
- ✅ Estados vacíos personalizados

## 🔗 Configuración del Backend

Para conectar con tu backend, actualiza la URL base en `lib/utils/api_constants.dart`:

```dart
static const String baseUrl = 'http://tu-servidor:puerto/api';
```

### Endpoints Esperados

El frontend espera los siguientes endpoints en el backend:

**Autenticación:**
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Registro
- `POST /api/auth/logout` - Logout

**Usuarios:**
- `GET /api/users/profile` - Perfil del usuario actual
- `GET /api/users/:id/chirps` - Chirps de un usuario
- `POST /api/users/follow/:id` - Seguir usuario
- `DELETE /api/users/unfollow/:id` - Dejar de seguir

**Chirps:**
- `GET /api/chirps/feed` - Feed de chirps (soporta paginación)
- `POST /api/chirps` - Crear chirp
- `DELETE /api/chirps/:id` - Eliminar chirp
- `POST /api/chirps/like/:id` - Like a chirp
- `DELETE /api/chirps/unlike/:id` - Unlike a chirp
- `POST /api/chirps/repost/:id` - Repostear chirp

**Notificaciones:**
- `GET /api/notifications` - Listar notificaciones
- `GET /api/notifications/unread-count` - Contador de no leídas
- `PUT /api/notifications/read/:id` - Marcar como leída
- `PUT /api/notifications/read/all` - Marcar todas como leídas
- `DELETE /api/notifications/:id` - Eliminar notificación

**Búsqueda:**
- `GET /api/search` - Buscar todo (usuarios + chirps)
- `GET /api/search/users` - Buscar usuarios
- `GET /api/search/chirps` - Buscar chirps

**📄 Para documentación completa del backend, ver:** `/BACKEND_API_DOCUMENTATION.md` en la raíz del proyecto.

## 📱 Ejecutar la Aplicación

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Ejecutar en modo debug:**
   ```bash
   flutter run
   ```

3. **Ejecutar en un dispositivo específico:**
   ```bash
   flutter devices  # Ver dispositivos disponibles
   flutter run -d <device-id>
   ```

4. **Compilar para producción (Android):**
   ```bash
   flutter build apk --release
   ```

5. **Compilar para producción (iOS):**
   ```bash
   flutter build ios --release
   ```

## 🎯 Próximas Características

- [ ] Sistema de replies/respuestas ✅ Modelo listo
- [ ] Sistema de reposts ✅ Endpoint preparado
- [ ] Búsqueda de usuarios y chirps ✅ IMPLEMENTADO
- [ ] Notificaciones push ✅ Sistema base implementado
- [ ] Modo oscuro
- [ ] Edición de perfil
- [ ] Subida de imágenes
- [ ] Hashtags y menciones interactivas
- [ ] Trending topics
- [ ] Mensajes directos

## 🐛 Solución de Problemas

### Error de conexión con el backend
- Verifica que el backend esté ejecutándose
- Asegúrate de que la URL en `api_constants.dart` sea correcta
- Si usas un emulador Android, usa `http://10.0.2.2:puerto` en lugar de `localhost`

### Errores de dependencias
```bash
flutter clean
flutter pub get
```

### Problemas con hot reload
```bash
# Reinicia la aplicación con
flutter run --hot
```

## 📝 Convenciones de Código

- Usar `snake_case` para archivos y directorios
- Usar `PascalCase` para clases
- Usar `camelCase` para variables y métodos
- Mantener widgets pequeños y reutilizables
- Documentar funciones complejas
- Usar const constructors cuando sea posible

## 👥 Equipo de Desarrollo

Proyecto Integrador - Desarrollo Móvil Integrador 10C

## 📄 Licencia

Este proyecto es para fines educativos.
