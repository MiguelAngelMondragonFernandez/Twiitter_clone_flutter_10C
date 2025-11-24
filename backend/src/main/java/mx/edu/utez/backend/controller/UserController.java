package mx.edu.utez.backend.controller;

import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.UserDTO;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    @GetMapping("/profile")
    public ResponseEntity<UserDTO> getProfile(@AuthenticationPrincipal User user) {
        UserDTO userDTO = userService.getProfile(user);
        return ResponseEntity.ok(userDTO);
    }
    
    @GetMapping("/{userId}")
    public ResponseEntity<UserDTO> getUserById(
            @PathVariable Long userId,
            @AuthenticationPrincipal User currentUser) {
        UserDTO userDTO = userService.getUserById(userId, currentUser);
        return ResponseEntity.ok(userDTO);
    }
    
    @GetMapping("/{userId}/chirps")
    public ResponseEntity<List<ChirpDTO>> getUserChirps(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User currentUser) {
        Pageable pageable = PageRequest.of(page, size);
        List<ChirpDTO> chirps = userService.getUserChirps(userId, currentUser, pageable);
        return ResponseEntity.ok(chirps);
    }
    
    @PostMapping("/follow/{userId}")
    public ResponseEntity<Map<String, Object>> followUser(
            @PathVariable Long userId,
            @AuthenticationPrincipal User currentUser) {
        userService.followUser(userId, currentUser);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Usuario seguido exitosamente");
        response.put("isFollowing", true);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/unfollow/{userId}")
    public ResponseEntity<Map<String, Object>> unfollowUser(
            @PathVariable Long userId,
            @AuthenticationPrincipal User currentUser) {
        userService.unfollowUser(userId, currentUser);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Has dejado de seguir al usuario");
        response.put("isFollowing", false);
        return ResponseEntity.ok(response);
    }
}
