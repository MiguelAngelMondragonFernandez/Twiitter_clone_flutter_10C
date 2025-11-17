# 🚀 Guía Rápida de Ejecución - Backend Chirper

## Prerequisitos

- **Java 17 o superior** instalado
- **MySQL** en ejecución
- **Docker** (opcional, si usas docker-compose)

## Opción 1: Ejecutar con Docker Compose (Recomendado)

### 1. Verificar configuración

El archivo `docker-compose.yaml` ya está en la raíz del proyecto. Verifica que los puertos no estén en uso:
- Puerto 33306 para MySQL
- Puerto 8081 para el backend

### 2. Iniciar servicios

```bash
# Desde la raíz del proyecto
docker-compose up -d
```

Esto iniciará:
- MySQL en el puerto 33306
- Backend Spring Boot en el puerto 8081

### 3. Verificar logs

```bash
# Ver logs del backend
docker-compose logs -f backend

# Ver logs de MySQL
docker-compose logs -f database
```

### 4. Detener servicios

```bash
docker-compose down
```

## Opción 2: Ejecutar Localmente (Sin Docker)

### 1. Configurar MySQL

Asegúrate de tener MySQL corriendo y crea la base de datos:

```sql
CREATE DATABASE twitter_clone;
```

### 2. Configurar application.properties

Edita `backend/src/main/resources/application.properties` si tu configuración de MySQL es diferente:

```properties
db.host=localhost
db.port=3306
db.name=twitter_clone
db.username=tu_usuario
db.password=tu_contraseña
```

### 3. Compilar el proyecto

```bash
cd backend
./mvnw clean compile
```

### 4. Ejecutar el servidor

```bash
./mvnw spring-boot:run
```

El servidor estará disponible en: `http://localhost:8081`

## 🧪 Probar la API

### 1. Registrar un usuario

```bash
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@chirper.com",
    "password": "123456"
  }'
```

### 2. Iniciar sesión

```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@chirper.com",
    "password": "123456"
  }'
```

Guarda el token que recibes en la respuesta.

### 3. Crear un chirp

```bash
curl -X POST http://localhost:8081/api/chirps \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_TOKEN_AQUI" \
  -d '{
    "content": "¡Mi primer chirp!"
  }'
```

### 4. Ver el feed

```bash
curl -X GET http://localhost:8081/api/chirps/feed \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

## 📋 Endpoints Disponibles

### Autenticación (públicos)
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`

### Usuarios (requieren autenticación)
- `GET /api/users/profile`
- `GET /api/users/{userId}`
- `GET /api/users/{userId}/chirps?page=0&size=20`
- `POST /api/users/follow/{userId}`
- `DELETE /api/users/unfollow/{userId}`

### Chirps (requieren autenticación)
- `GET /api/chirps/feed?page=0&size=20`
- `POST /api/chirps`
- `DELETE /api/chirps/{chirpId}`
- `POST /api/chirps/like/{chirpId}`
- `DELETE /api/chirps/unlike/{chirpId}`
- `POST /api/chirps/repost/{chirpId}`

### Notificaciones (requieren autenticación)
- `GET /api/notifications?page=0&size=20`
- `GET /api/notifications/unread-count`
- `PUT /api/notifications/read/{notificationId}`
- `PUT /api/notifications/read/all`
- `DELETE /api/notifications/{notificationId}`

### Búsqueda (requiere autenticación)
- `GET /api/search?q=query`
- `GET /api/search/users?q=query`
- `GET /api/search/chirps?q=query&page=0&size=20`

## 🔍 Verificar Estado del Servidor

```bash
# Verificar que el servidor responde
curl http://localhost:8081/api/auth/login

# Debería devolver un error 400 o 401 si el servidor está corriendo
```

## 🐛 Solución de Problemas

### Error: Puerto 8081 ya en uso

```bash
# Linux/Mac
lsof -i :8081
kill -9 <PID>

# Windows
netstat -ano | findstr :8081
taskkill /PID <PID> /F
```

### Error: No se puede conectar a MySQL

1. Verifica que MySQL está corriendo
2. Verifica usuario y contraseña en `application.properties`
3. Verifica que la base de datos `twitter_clone` existe

### Error: java.lang.ClassNotFoundException

```bash
# Limpiar y recompilar
./mvnw clean install
```

### Ver logs detallados

```bash
# Con Maven
./mvnw spring-boot:run -X

# Ver logs del contenedor Docker
docker logs -f <container_id>
```

## 📊 Herramientas Recomendadas

- **Postman**: Para probar endpoints
- **MySQL Workbench**: Para ver la base de datos
- **DBeaver**: Alternativa a MySQL Workbench
- **curl**: Para pruebas rápidas desde terminal

## 🔐 Configuración de Seguridad

**IMPORTANTE para Producción:**

1. Cambiar el `jwt.secret` en `application.properties`:
```properties
jwt.secret=TU_SECRET_MUY_LARGO_Y_ALEATORIO_AQUI
```

2. Configurar CORS solo para orígenes permitidos en `CorsConfig.java`

3. Usar HTTPS en producción

4. Configurar variables de entorno en lugar de valores hardcodeados

## 📞 Soporte

Para más información, consulta:
- `BACKEND_API_DOCUMENTATION.md` - Documentación completa de la API
- `GUIA_IMPLEMENTACION_BACKEND.md` - Guía de implementación detallada
- `IMPLEMENTACION_COMPLETADA.md` - Resumen de lo implementado

---

**¡Listo para usar!** 🎉
