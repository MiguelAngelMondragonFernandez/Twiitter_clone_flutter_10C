# Documentación Backend API - Chirper

Esta documentación describe todos los endpoints que el backend debe implementar para funcionar correctamente con el frontend de Flutter.

## 📋 Tabla de Contenidos

- [Autenticación](#autenticación)
- [Usuarios](#usuarios)
- [Chirps](#chirps)
- [Notificaciones](#notificaciones)
- [Búsqueda](#búsqueda)
- [Modelos de Datos](#modelos-de-datos)
- [Códigos de Estado](#códigos-de-estado)

---

## 🔐 Autenticación

Todos los endpoints (excepto login y register) requieren autenticación mediante JWT Bearer Token.

**Header requerido:**
```
Authorization: Bearer <token>
```

### POST /api/auth/register

Registra un nuevo usuario en el sistema.

**Request Body:**
```json
{
  "username": "string (requerido, único, 3-30 caracteres)",
  "email": "string (requerido, único, formato email válido)",
  "password": "string (requerido, mínimo 6 caracteres)"
}
```

**Response 201 Created:**
```json
{
  "token": "string (JWT token)",
  "user": {
    "id": "string",
    "username": "string",
    "email": "string",
    "displayName": "string | null",
    "bio": "string | null",
    "profileImageUrl": "string | null",
    "followersCount": 0,
    "followingCount": 0,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

**Errores:**
- `400 Bad Request`: Datos inválidos o incompletos
- `409 Conflict`: Usuario o email ya existe

---

### POST /api/auth/login

Inicia sesión con credenciales existentes.

**Request Body:**
```json
{
  "email": "string (requerido)",
  "password": "string (requerido)"
}
```

**Response 200 OK:**
```json
{
  "token": "string (JWT token)",
  "user": {
    "id": "string",
    "username": "string",
    "email": "string",
    "displayName": "string | null",
    "bio": "string | null",
    "profileImageUrl": "string | null",
    "followersCount": 0,
    "followingCount": 0,
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

**Errores:**
- `400 Bad Request`: Credenciales inválidas
- `401 Unauthorized`: Email o contraseña incorrectos

---

### POST /api/auth/logout

Cierra la sesión del usuario (opcional, principalmente para invalidar token en backend).

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Sesión cerrada exitosamente"
}
```

---

## 👤 Usuarios

### GET /api/users/profile

Obtiene el perfil del usuario autenticado.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "id": "string",
  "username": "string",
  "email": "string",
  "displayName": "string | null",
  "bio": "string | null",
  "profileImageUrl": "string | null",
  "followersCount": 0,
  "followingCount": 0,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

### GET /api/users/:userId

Obtiene el perfil de un usuario por ID.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "id": "string",
  "username": "string",
  "displayName": "string | null",
  "bio": "string | null",
  "profileImageUrl": "string | null",
  "followersCount": 0,
  "followingCount": 0,
  "isFollowing": true,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

**Nota:** El campo `isFollowing` indica si el usuario autenticado sigue a este usuario.

**Errores:**
- `404 Not Found`: Usuario no existe

---

### GET /api/users/:userId/chirps

Obtiene todos los chirps de un usuario específico.

**Headers:** Authorization Bearer Token requerido

**Query Parameters:**
- `page`: número (opcional, default: 0)
- `size`: número (opcional, default: 20)

**Response 200 OK:**
```json
[
  {
    "id": "string",
    "content": "string (máx 280 caracteres)",
    "author": {
      "id": "string",
      "username": "string",
      "displayName": "string | null",
      "profileImageUrl": "string | null"
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "likesCount": 0,
    "repliesCount": 0,
    "repostsCount": 0,
    "isLiked": false,
    "isReposted": false,
    "replyToId": "string | null"
  }
]
```

---

### POST /api/users/follow/:userId

Sigue a un usuario.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Usuario seguido exitosamente",
  "isFollowing": true
}
```

**Errores:**
- `400 Bad Request`: No puedes seguirte a ti mismo
- `404 Not Found`: Usuario no existe
- `409 Conflict`: Ya estás siguiendo a este usuario

---

### DELETE /api/users/unfollow/:userId

Deja de seguir a un usuario.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Has dejado de seguir al usuario",
  "isFollowing": false
}
```

**Errores:**
- `400 Bad Request`: No puedes dejar de seguirte a ti mismo
- `404 Not Found`: Usuario no existe

---

## 🐦 Chirps

### GET /api/chirps/feed

Obtiene el feed de chirps del usuario (chirps de usuarios que sigue + propios).

**Headers:** Authorization Bearer Token requerido

**Query Parameters:**
- `page`: número (opcional, default: 0)
- `size`: número (opcional, default: 20)

**Response 200 OK:**
```json
[
  {
    "id": "string",
    "content": "string (máx 280 caracteres)",
    "author": {
      "id": "string",
      "username": "string",
      "displayName": "string | null",
      "profileImageUrl": "string | null"
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "likesCount": 0,
    "repliesCount": 0,
    "repostsCount": 0,
    "isLiked": false,
    "isReposted": false,
    "replyToId": "string | null"
  }
]
```

**Nota:** Ordenar por `createdAt` descendente (más recientes primero).

---

### POST /api/chirps

Crea un nuevo chirp.

**Headers:** Authorization Bearer Token requerido

**Request Body:**
```json
{
  "content": "string (requerido, 1-280 caracteres)",
  "replyToId": "string | null (opcional, ID del chirp al que responde)"
}
```

**Response 201 Created:**
```json
{
  "id": "string",
  "content": "string",
  "author": {
    "id": "string",
    "username": "string",
    "displayName": "string | null",
    "profileImageUrl": "string | null"
  },
  "createdAt": "2024-01-01T00:00:00Z",
  "likesCount": 0,
  "repliesCount": 0,
  "repostsCount": 0,
  "isLiked": false,
  "isReposted": false,
  "replyToId": "string | null"
}
```

**Errores:**
- `400 Bad Request`: Contenido vacío o mayor a 280 caracteres
- `404 Not Found`: replyToId no existe (si se proporciona)

---

### DELETE /api/chirps/:chirpId

Elimina un chirp propio.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Chirp eliminado exitosamente"
}
```

**Errores:**
- `403 Forbidden`: No puedes eliminar chirps de otros usuarios
- `404 Not Found`: Chirp no existe

---

### POST /api/chirps/like/:chirpId

Da like a un chirp.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Like agregado",
  "isLiked": true,
  "likesCount": 1
}
```

**Errores:**
- `404 Not Found`: Chirp no existe
- `409 Conflict`: Ya diste like a este chirp

---

### DELETE /api/chirps/unlike/:chirpId

Quita el like de un chirp.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Like eliminado",
  "isLiked": false,
  "likesCount": 0
}
```

**Errores:**
- `404 Not Found`: Chirp no existe o no le habías dado like

---

### POST /api/chirps/repost/:chirpId

Repostea un chirp.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Chirp reposteado",
  "isReposted": true,
  "repostsCount": 1
}
```

**Errores:**
- `404 Not Found`: Chirp no existe
- `409 Conflict`: Ya reposteaste este chirp

---

## 🔔 Notificaciones

### GET /api/notifications

Obtiene las notificaciones del usuario autenticado.

**Headers:** Authorization Bearer Token requerido

**Query Parameters:**
- `page`: número (opcional, default: 0)
- `size`: número (opcional, default: 20)

**Response 200 OK:**
```json
[
  {
    "id": "string",
    "type": "like | repost | follow | reply | mention",
    "actor": {
      "id": "string",
      "username": "string",
      "displayName": "string | null",
      "profileImageUrl": "string | null"
    },
    "chirp": {
      "id": "string",
      "content": "string",
      "author": {...}
    } | null,
    "content": "string | null (para replies y mentions)",
    "createdAt": "2024-01-01T00:00:00Z",
    "isRead": false
  }
]
```

**Tipos de notificaciones:**
- `like`: Alguien dio like a tu chirp
- `repost`: Alguien reposteó tu chirp
- `follow`: Alguien te siguió
- `reply`: Alguien respondió a tu chirp
- `mention`: Alguien te mencionó en un chirp

**Nota:** Ordenar por `createdAt` descendente (más recientes primero).

---

### GET /api/notifications/unread-count

Obtiene el conteo de notificaciones no leídas.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "count": 5
}
```

---

### PUT /api/notifications/read/:notificationId

Marca una notificación como leída.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Notificación marcada como leída",
  "isRead": true
}
```

**Errores:**
- `404 Not Found`: Notificación no existe

---

### PUT /api/notifications/read/all

Marca todas las notificaciones como leídas.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Todas las notificaciones marcadas como leídas",
  "count": 5
}
```

---

### DELETE /api/notifications/:notificationId

Elimina una notificación.

**Headers:** Authorization Bearer Token requerido

**Response 200 OK:**
```json
{
  "message": "Notificación eliminada"
}
```

**Errores:**
- `404 Not Found`: Notificación no existe

---

## 🔍 Búsqueda

### GET /api/search

Busca usuarios y chirps simultáneamente.

**Headers:** Authorization Bearer Token requerido

**Query Parameters:**
- `q`: string (requerido, término de búsqueda)

**Response 200 OK:**
```json
{
  "users": [
    {
      "id": "string",
      "username": "string",
      "displayName": "string | null",
      "bio": "string | null",
      "profileImageUrl": "string | null",
      "followersCount": 0,
      "isFollowing": false
    }
  ],
  "chirps": [
    {
      "id": "string",
      "content": "string",
      "author": {...},
      "createdAt": "2024-01-01T00:00:00Z",
      "likesCount": 0,
      "repliesCount": 0,
      "repostsCount": 0,
      "isLiked": false,
      "isReposted": false
    }
  ]
}
```

**Nota:** Limitar a 10 resultados de cada tipo para búsqueda general.

---

### GET /api/search/users

Busca solo usuarios.

**Headers:** Authorization Bearer Token requerido

**Query Parameters:**
- `q`: string (requerido, término de búsqueda)
- `page`: número (opcional, default: 0)
- `size`: número (opcional, default: 20)

**Response 200 OK:**
```json
[
  {
    "id": "string",
    "username": "string",
    "displayName": "string | null",
    "bio": "string | null",
    "profileImageUrl": "string | null",
    "followersCount": 0,
    "isFollowing": false
  }
]
```

**Criterios de búsqueda:** Buscar en `username` y `displayName` (case-insensitive).

---

### GET /api/search/chirps

Busca solo chirps.

**Headers:** Authorization Bearer Token requerido

**Query Parameters:**
- `q`: string (requerido, término de búsqueda)
- `page`: número (opcional, default: 0)
- `size`: número (opcional, default: 20)

**Response 200 OK:**
```json
[
  {
    "id": "string",
    "content": "string",
    "author": {
      "id": "string",
      "username": "string",
      "displayName": "string | null",
      "profileImageUrl": "string | null"
    },
    "createdAt": "2024-01-01T00:00:00Z",
    "likesCount": 0,
    "repliesCount": 0,
    "repostsCount": 0,
    "isLiked": false,
    "isReposted": false
  }
]
```

**Criterios de búsqueda:** Buscar en `content` (case-insensitive, full-text search recomendado).

---

## 📦 Modelos de Datos

### User
```typescript
{
  id: string;              // UUID o identificador único
  username: string;        // Único, 3-30 caracteres
  email: string;           // Único, formato email
  displayName?: string;    // Nombre para mostrar (opcional)
  bio?: string;            // Biografía (opcional, máx 160 caracteres)
  profileImageUrl?: string; // URL de imagen de perfil
  followersCount: number;  // Contador de seguidores
  followingCount: number;  // Contador de seguidos
  createdAt: Date;         // Fecha de creación
}
```

### Chirp
```typescript
{
  id: string;              // UUID o identificador único
  content: string;         // 1-280 caracteres
  authorId: string;        // ID del autor (FK a User)
  author: User;            // Objeto User completo
  createdAt: Date;         // Fecha de creación
  likesCount: number;      // Contador de likes
  repliesCount: number;    // Contador de respuestas
  repostsCount: number;    // Contador de reposts
  isLiked: boolean;        // Si el usuario actual dio like
  isReposted: boolean;     // Si el usuario actual reposteó
  replyToId?: string;      // ID del chirp padre (si es respuesta)
}
```

### Notification
```typescript
{
  id: string;              // UUID o identificador único
  type: 'like' | 'repost' | 'follow' | 'reply' | 'mention';
  actorId: string;         // ID del usuario que generó la notificación
  actor: User;             // Objeto User del actor
  userId: string;          // ID del usuario que recibe la notificación
  chirpId?: string;        // ID del chirp relacionado (si aplica)
  chirp?: Chirp;           // Objeto Chirp completo (si aplica)
  content?: string;        // Contenido adicional (para replies y mentions)
  isRead: boolean;         // Si fue leída
  createdAt: Date;         // Fecha de creación
}
```

---

## 📊 Códigos de Estado HTTP

### Exitosos
- `200 OK`: Solicitud exitosa
- `201 Created`: Recurso creado exitosamente
- `204 No Content`: Solicitud exitosa sin contenido de respuesta

### Errores del Cliente
- `400 Bad Request`: Datos inválidos o malformados
- `401 Unauthorized`: No autenticado o token inválido
- `403 Forbidden`: Sin permisos para realizar la acción
- `404 Not Found`: Recurso no encontrado
- `409 Conflict`: Conflicto con el estado actual (ej: ya existe)

### Errores del Servidor
- `500 Internal Server Error`: Error interno del servidor
- `503 Service Unavailable`: Servicio temporalmente no disponible

---

## 🔒 Seguridad

### JWT Token

El token debe contener:
```json
{
  "userId": "string",
  "username": "string",
  "email": "string",
  "iat": 1234567890,
  "exp": 1234567890
}
```

**Duración recomendada:** 24 horas

### Validaciones

1. **Username**: 
   - Solo alfanuméricos y guión bajo
   - 3-30 caracteres
   - Único

2. **Email**:
   - Formato email válido
   - Único

3. **Password**:
   - Mínimo 6 caracteres
   - Hashear con bcrypt (salt rounds: 10)

4. **Chirp Content**:
   - 1-280 caracteres
   - No puede estar vacío

5. **Bio**:
   - Máximo 160 caracteres

---

## 🗄️ Base de Datos Recomendada

### Tablas principales:

```sql
-- Usuarios
users (
  id UUID PRIMARY KEY,
  username VARCHAR(30) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  display_name VARCHAR(50),
  bio VARCHAR(160),
  profile_image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
)

-- Chirps
chirps (
  id UUID PRIMARY KEY,
  content VARCHAR(280) NOT NULL,
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  reply_to_id UUID REFERENCES chirps(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW()
)

-- Seguidores (relación muchos a muchos)
follows (
  follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
)

-- Likes
likes (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  chirp_id UUID REFERENCES chirps(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, chirp_id)
)

-- Reposts
reposts (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  chirp_id UUID REFERENCES chirps(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (user_id, chirp_id)
)

-- Notificaciones
notifications (
  id UUID PRIMARY KEY,
  type VARCHAR(20) NOT NULL,
  actor_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  chirp_id UUID REFERENCES chirps(id) ON DELETE CASCADE,
  content TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
)
```

### Índices recomendados:

```sql
CREATE INDEX idx_chirps_author_id ON chirps(author_id);
CREATE INDEX idx_chirps_created_at ON chirps(created_at DESC);
CREATE INDEX idx_follows_follower_id ON follows(follower_id);
CREATE INDEX idx_follows_following_id ON follows(following_id);
CREATE INDEX idx_likes_chirp_id ON likes(chirp_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
```

---

## 🧪 Datos de Prueba

### Usuario de prueba:
```json
{
  "username": "testuser",
  "email": "test@chirper.com",
  "password": "123456"
}
```

### Chirp de prueba:
```json
{
  "content": "¡Hola mundo! Este es mi primer chirp 🐦"
}
```

---

## 📝 Notas Importantes

1. **CORS**: Configurar para permitir solicitudes desde el frontend Flutter
2. **Rate Limiting**: Implementar límites de peticiones para prevenir abuso
3. **Paginación**: Siempre paginar listas largas (chirps, usuarios, notificaciones)
4. **Timestamps**: Usar ISO 8601 format (yyyy-MM-ddTHH:mm:ssZ)
5. **Validación**: Validar todos los inputs en el servidor
6. **Errores**: Siempre devolver mensajes de error descriptivos en formato JSON

---

## 📞 Contacto

Para dudas sobre la implementación del backend, contactar al equipo de desarrollo frontend.

**Versión:** 1.0  
**Última actualización:** Noviembre 2025
