package mx.edu.utez.backend.service;

import mx.edu.utez.backend.dto.UserDTO;
import mx.edu.utez.backend.dto.request.LoginRequest;
import mx.edu.utez.backend.dto.request.RegisterRequest;
import mx.edu.utez.backend.dto.response.AuthResponse;
import mx.edu.utez.backend.exception.ConflictException;
import mx.edu.utez.backend.exception.UnauthorizedException;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.repository.UserRepository;
import mx.edu.utez.backend.security.JwtUtil;
import mx.edu.utez.backend.util.DTOMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import org.springframework.beans.factory.annotation.Value;
import java.util.List;
import java.util.Collections;

@Service
public class AuthService {

    @Value("${google.client.ids}")
    private List<String> googleClientIds;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private DTOMapper dtoMapper;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Validar que el username no exista
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new ConflictException("El nombre de usuario ya existe");
        }

        // Validar que el email no exista
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ConflictException("El email ya está registrado");
        }

        // Crear nuevo usuario
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setDisplayName(request.getUsername()); // Por defecto, displayName = username

        user = userRepository.save(user);

        // Generar token JWT
        String token = jwtUtil.generateToken(user);

        // Retornar respuesta
        UserDTO userDTO = dtoMapper.toUserDTO(user);
        return new AuthResponse(token, userDTO);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        // Buscar usuario por email
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UnauthorizedException("Email o contraseña incorrectos"));

        // Verificar password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Email o contraseña incorrectos");
        }

        // Generar token JWT
        String token = jwtUtil.generateToken(user);

        // Retornar respuesta
        UserDTO userDTO = dtoMapper.toUserDTO(user);
        return new AuthResponse(token, userDTO);
    }

    @Transactional
    public AuthResponse loginWithGoogle(String idTokenString) {
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(),
                    new GsonFactory())
                    .setAudience(googleClientIds)
                    .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                String email = payload.getEmail();
                String name = (String) payload.get("name");
                String pictureUrl = (String) payload.get("picture");

                User user = userRepository.findByEmail(email).orElse(null);
                if (user == null) {
                    user = new User();
                    user.setEmail(email);
                    // Generate unique username if needed, for now use email prefix
                    String baseUsername = email.split("@")[0];
                    String username = baseUsername;
                    int counter = 1;
                    while (userRepository.existsByUsername(username)) {
                        username = baseUsername + counter++;
                    }
                    user.setUsername(username);

                    user.setDisplayName(name);
                    // user.setProfileImageUrl(pictureUrl); // Assuming User model has this field or
                    // similar logic needed
                    user.setPasswordHash(
                            passwordEncoder.encode("GOOGLE_AUTH_" + java.util.UUID.randomUUID().toString()));
                    user = userRepository.save(user);
                }

                String token = jwtUtil.generateToken(user);
                UserDTO userDTO = dtoMapper.toUserDTO(user);
                return new AuthResponse(token, userDTO);
            } else {
                throw new UnauthorizedException("Token de Google inválido");
            }
        } catch (Exception e) {
            throw new UnauthorizedException("Error al verificar token de Google: " + e.getMessage());
        }
    }
}
