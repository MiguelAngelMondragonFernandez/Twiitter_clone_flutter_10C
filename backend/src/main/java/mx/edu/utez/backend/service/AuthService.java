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

@Service
public class AuthService {
    
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
}
