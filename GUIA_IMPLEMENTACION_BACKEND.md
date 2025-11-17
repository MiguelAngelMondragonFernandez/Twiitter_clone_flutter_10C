# 🎯 Guía Rápida para Implementar el Backend

## 📋 Checklist de Implementación

### Fase 1: Configuración Inicial ⚙️

- [ ] **1.1** Crear proyecto Spring Boot
  - Spring Web
  - Spring Data JPA
  - Spring Security
  - PostgreSQL Driver (o tu BD preferida)
  - Lombok (opcional)

- [ ] **1.2** Configurar `application.properties`
```properties
server.port=8080
spring.datasource.url=jdbc:postgresql://localhost:5432/chirper
spring.datasource.username=tu_usuario
spring.datasource.password=tu_password
spring.jpa.hibernate.ddl-auto=update
jwt.secret=TU_SECRET_KEY_AQUI
jwt.expiration=86400000
```

- [ ] **1.3** Configurar CORS
```java
@Configuration
public class CorsConfig {
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins("*")
                        .allowedMethods("GET", "POST", "PUT", "DELETE");
            }
        };
    }
}
```

---

### Fase 2: Modelos y Base de Datos 📦

- [ ] **2.1** Crear entidades JPA (ver esquema SQL en documentación)
  - `User.java`
  - `Chirp.java`
  - `Follow.java`
  - `Like.java`
  - `Repost.java`
  - `Notification.java`

- [ ] **2.2** Crear repositorios
  - `UserRepository`
  - `ChirpRepository`
  - `FollowRepository`
  - `LikeRepository`
  - `RepostRepository`
  - `NotificationRepository`

**Ejemplo de entidad User:**
```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(unique = true, nullable = false)
    private String username;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String passwordHash;
    
    private String displayName;
    private String bio;
    private String profileImageUrl;
    
    @CreatedDate
    private LocalDateTime createdAt;
    
    // Getters y setters
}
```

---

### Fase 3: Seguridad y JWT 🔐

- [ ] **3.1** Configurar Spring Security
- [ ] **3.2** Implementar JWT Utils
  - Generar token
  - Validar token
  - Extraer claims

- [ ] **3.3** Crear filtros de autenticación
- [ ] **3.4** Configurar endpoints públicos vs protegidos

**Ejemplo de JwtUtil:**
```java
@Component
public class JwtUtil {
    @Value("${jwt.secret}")
    private String secret;
    
    public String generateToken(User user) {
        return Jwts.builder()
            .setSubject(user.getId())
            .claim("username", user.getUsername())
            .claim("email", user.getEmail())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 86400000))
            .signWith(SignatureAlgorithm.HS256, secret)
            .compact();
    }
    
    // Otros métodos...
}
```

---

### Fase 4: Controladores - Autenticación 🔑

- [ ] **4.1** POST /api/auth/register
```java
@PostMapping("/register")
public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
    // 1. Validar que username y email no existan
    // 2. Hashear password con BCrypt
    // 3. Crear usuario en BD
    // 4. Generar token JWT
    // 5. Retornar token + datos de usuario
}
```

- [ ] **4.2** POST /api/auth/login
```java
@PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest request) {
    // 1. Buscar usuario por email
    // 2. Verificar password con BCrypt
    // 3. Generar token JWT
    // 4. Retornar token + datos de usuario
}
```

- [ ] **4.3** POST /api/auth/logout (opcional)

**Formatos esperados:** Ver `BACKEND_API_DOCUMENTATION.md` sección Autenticación

---

### Fase 5: Controladores - Usuarios 👤

- [ ] **5.1** GET /api/users/profile
- [ ] **5.2** GET /api/users/:id
- [ ] **5.3** GET /api/users/:id/chirps
- [ ] **5.4** POST /api/users/follow/:id
- [ ] **5.5** DELETE /api/users/unfollow/:id

**Ejemplo:**
```java
@GetMapping("/profile")
public ResponseEntity<?> getProfile(@AuthenticationPrincipal User user) {
    return ResponseEntity.ok(userMapper.toDTO(user));
}

@PostMapping("/follow/{userId}")
public ResponseEntity<?> followUser(
    @PathVariable String userId,
    @AuthenticationPrincipal User currentUser
) {
    // 1. Verificar que userId existe
    // 2. Verificar que no es el mismo usuario
    // 3. Crear registro en tabla follows
    // 4. Incrementar contadores
    // 5. Crear notificación de tipo "follow"
    return ResponseEntity.ok(Map.of("isFollowing", true));
}
```

---

### Fase 6: Controladores - Chirps 🐦

- [ ] **6.1** GET /api/chirps/feed
```java
@GetMapping("/feed")
public ResponseEntity<?> getFeed(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size,
    @AuthenticationPrincipal User user
) {
    // 1. Obtener IDs de usuarios que sigue
    // 2. Query: chirps de esos usuarios + chirps propios
    // 3. Ordenar por createdAt DESC
    // 4. Paginar con PageRequest.of(page, size)
    // 5. Para cada chirp, calcular isLiked e isReposted
    return ResponseEntity.ok(chirps);
}
```

- [ ] **6.2** POST /api/chirps
```java
@PostMapping
public ResponseEntity<?> createChirp(
    @RequestBody CreateChirpRequest request,
    @AuthenticationPrincipal User user
) {
    // 1. Validar content (1-280 caracteres)
    // 2. Crear chirp
    // 3. Si tiene replyToId, incrementar repliesCount del padre
    // 4. Si es reply, crear notificación tipo "reply"
    return ResponseEntity.status(201).body(chirp);
}
```

- [ ] **6.3** DELETE /api/chirps/:id
- [ ] **6.4** POST /api/chirps/like/:id
- [ ] **6.5** DELETE /api/chirps/unlike/:id
- [ ] **6.6** POST /api/chirps/repost/:id

**Importante:** Al dar like/repost, crear notificación correspondiente

---

### Fase 7: Controladores - Notificaciones 🔔

- [ ] **7.1** GET /api/notifications
```java
@GetMapping
public ResponseEntity<?> getNotifications(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size,
    @AuthenticationPrincipal User user
) {
    // 1. Query: todas las notificaciones del usuario
    // 2. Ordenar por createdAt DESC
    // 3. Incluir datos del actor (usuario que generó la notificación)
    // 4. Incluir chirp si aplica
    return ResponseEntity.ok(notifications);
}
```

- [ ] **7.2** GET /api/notifications/unread-count
```java
@GetMapping("/unread-count")
public ResponseEntity<?> getUnreadCount(@AuthenticationPrincipal User user) {
    long count = notificationRepository.countByUserIdAndIsReadFalse(user.getId());
    return ResponseEntity.ok(Map.of("count", count));
}
```

- [ ] **7.3** PUT /api/notifications/read/:id
- [ ] **7.4** PUT /api/notifications/read/all
- [ ] **7.5** DELETE /api/notifications/:id

**Tipos de notificaciones:**
- `like`: Cuando alguien da like a tu chirp
- `repost`: Cuando alguien repostea tu chirp
- `follow`: Cuando alguien te sigue
- `reply`: Cuando alguien responde a tu chirp
- `mention`: Cuando alguien te menciona

---

### Fase 8: Controladores - Búsqueda 🔍

- [ ] **8.1** GET /api/search
```java
@GetMapping
public ResponseEntity<?> searchAll(
    @RequestParam String q,
    @AuthenticationPrincipal User user
) {
    // Buscar usuarios (username o displayName contiene q)
    List<User> users = userRepository.findByUsernameContainingOrDisplayNameContaining(q, q);
    
    // Buscar chirps (content contiene q)
    List<Chirp> chirps = chirpRepository.findByContentContaining(q);
    
    return ResponseEntity.ok(Map.of(
        "users", users.subList(0, Math.min(10, users.size())),
        "chirps", chirps.subList(0, Math.min(10, chirps.size()))
    ));
}
```

- [ ] **8.2** GET /api/search/users
- [ ] **8.3** GET /api/search/chirps

**Nota:** Usar búsqueda case-insensitive

---

### Fase 9: DTOs y Mappers 🗂️

Crear DTOs para respuestas:

- [ ] **9.1** `UserDTO` - Datos de usuario para respuestas
- [ ] **9.2** `ChirpDTO` - Chirp con autor y contadores
- [ ] **9.3** `NotificationDTO` - Notificación con actor y chirp
- [ ] **9.4** Mappers para convertir entidades a DTOs

**Ejemplo:**
```java
public class ChirpDTO {
    private String id;
    private String content;
    private UserDTO author;
    private LocalDateTime createdAt;
    private int likesCount;
    private int repliesCount;
    private int repostsCount;
    private boolean isLiked;
    private boolean isReposted;
    private String replyToId;
    
    // Constructor, getters, setters
}
```

---

### Fase 10: Servicios 💼

Crear capa de servicios para lógica de negocio:

- [ ] **10.1** `AuthService`
- [ ] **10.2** `UserService`
- [ ] **10.3** `ChirpService`
- [ ] **10.4** `NotificationService`
- [ ] **10.5** `SearchService`

**Ventajas:**
- Separar lógica de negocio de controladores
- Reutilizar código
- Facilitar testing

---

### Fase 11: Validaciones ✅

Implementar validaciones usando Bean Validation:

```java
public class CreateChirpRequest {
    @NotBlank(message = "El contenido no puede estar vacío")
    @Size(min = 1, max = 280, message = "El chirp debe tener entre 1 y 280 caracteres")
    private String content;
    
    private String replyToId;
}

public class RegisterRequest {
    @NotBlank
    @Size(min = 3, max = 30)
    @Pattern(regexp = "^[a-zA-Z0-9_]+$")
    private String username;
    
    @NotBlank
    @Email
    private String email;
    
    @NotBlank
    @Size(min = 6)
    private String password;
}
```

---

### Fase 12: Manejo de Errores 🚨

- [ ] **12.1** Crear `@ControllerAdvice` global
- [ ] **12.2** Manejar excepciones comunes
- [ ] **12.3** Retornar mensajes de error en formato JSON

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<?> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(404)
            .body(Map.of("message", ex.getMessage()));
    }
    
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<?> handleValidation(ValidationException ex) {
        return ResponseEntity.status(400)
            .body(Map.of("message", ex.getMessage()));
    }
}
```

---

## 🧪 Testing

### Con Postman

1. **Importar colección** con todos los endpoints
2. **Configurar variables:**
   - `base_url`: http://localhost:8080/api
   - `token`: (se actualiza al hacer login)

3. **Flujo de prueba:**
```
1. POST /auth/register → Obtener token
2. Guardar token en variable
3. POST /chirps → Crear chirp
4. GET /chirps/feed → Ver feed
5. POST /chirps/like/:id → Dar like
6. GET /notifications → Ver notificación
```

---

## 📊 Queries SQL Útiles

### Contadores

```sql
-- Actualizar followersCount
UPDATE users u SET followers_count = (
    SELECT COUNT(*) FROM follows WHERE following_id = u.id
);

-- Actualizar likesCount de chirps
UPDATE chirps c SET likes_count = (
    SELECT COUNT(*) FROM likes WHERE chirp_id = c.id
);
```

### Feed de chirps

```sql
SELECT c.* FROM chirps c
WHERE c.author_id IN (
    SELECT following_id FROM follows WHERE follower_id = :userId
)
OR c.author_id = :userId
ORDER BY c.created_at DESC
LIMIT 20 OFFSET 0;
```

---

## 🎯 Orden de Implementación Recomendado

1. ✅ **Autenticación** (register + login) - Base del sistema
2. ✅ **Usuarios** (profile, follow) - Gestión de usuarios
3. ✅ **Chirps básicos** (crear, feed, eliminar) - Funcionalidad core
4. ✅ **Likes** - Interacciones básicas
5. ✅ **Notificaciones** - Sistema de avisos
6. ✅ **Búsqueda** - Discovery de contenido
7. ✅ **Replies y Reposts** - Funcionalidades avanzadas

---

## 🐛 Debugging Tips

### Problema: JWT no válido
- Verificar que el secret coincida
- Verificar formato del header: `Bearer <token>`
- Verificar que el token no haya expirado

### Problema: CORS
- Verificar configuración de CORS
- Permitir headers: Authorization, Content-Type
- En desarrollo, permitir origen `*`

### Problema: Lazy Loading
- Usar `@JsonIgnoreProperties` para evitar ciclos
- O usar DTOs sin relaciones bidireccionales

---

## 📝 Datos de Prueba

### Crear usuarios de prueba

```sql
INSERT INTO users (id, username, email, password_hash, created_at) VALUES
('uuid-1', 'alice', 'alice@chirper.com', '$2a$10$...', NOW()),
('uuid-2', 'bob', 'bob@chirper.com', '$2a$10$...', NOW()),
('uuid-3', 'charlie', 'charlie@chirper.com', '$2a$10$...', NOW());
```

### Crear chirps de prueba

```sql
INSERT INTO chirps (id, content, author_id, created_at) VALUES
('chirp-1', 'Hola mundo!', 'uuid-1', NOW()),
('chirp-2', 'Segundo chirp!', 'uuid-1', NOW() - INTERVAL '1 hour');
```

---

## ✅ Checklist Final

### Funcionalidades Básicas
- [ ] Usuario puede registrarse
- [ ] Usuario puede hacer login
- [ ] Token JWT funciona
- [ ] Usuario puede ver su perfil
- [ ] Usuario puede crear chirp
- [ ] Usuario puede ver feed
- [ ] Usuario puede dar like
- [ ] Contadores actualizan correctamente

### Funcionalidades Avanzadas
- [ ] Usuario puede seguir/dejar de seguir
- [ ] Feed muestra chirps de seguidos
- [ ] Notificaciones se crean automáticamente
- [ ] Badge de notificaciones funciona
- [ ] Búsqueda retorna resultados
- [ ] Paginación funciona en todos los endpoints

### Seguridad
- [ ] Passwords hasheados con BCrypt
- [ ] JWT implementado correctamente
- [ ] CORS configurado
- [ ] Validaciones en todos los inputs
- [ ] Solo el autor puede eliminar sus chirps

---

## 🚀 Deploy

### Preparación para producción

1. **Configurar variables de entorno**
```properties
SPRING_DATASOURCE_URL=${DATABASE_URL}
SPRING_DATASOURCE_USERNAME=${DB_USERNAME}
SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}
JWT_SECRET=${JWT_SECRET}
```

2. **Build del proyecto**
```bash
mvn clean package
```

3. **Ejecutar**
```bash
java -jar target/chirper-backend-1.0.0.jar
```

---

## 📚 Recursos

- **Documentación completa:** `/BACKEND_API_DOCUMENTATION.md`
- **Spring Boot Docs:** https://spring.io/projects/spring-boot
- **Spring Security:** https://spring.io/projects/spring-security
- **JWT:** https://jwt.io/

---

**¡Éxito con la implementación del backend!** 🚀

Cualquier duda, referirse a la documentación completa en `BACKEND_API_DOCUMENTATION.md`
