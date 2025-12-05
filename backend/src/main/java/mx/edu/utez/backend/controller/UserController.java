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
    public ResponseEntity<UserDTO> followUser(
            @PathVariable Long userId,
            @AuthenticationPrincipal User currentUser) {
        UserDTO updatedUser = userService.followUser(userId, currentUser);
        return ResponseEntity.ok(updatedUser);
    }

    @DeleteMapping("/unfollow/{userId}")
    public ResponseEntity<UserDTO> unfollowUser(
            @PathVariable Long userId,
            @AuthenticationPrincipal User currentUser) {
        UserDTO updatedUser = userService.unfollowUser(userId, currentUser);
        return ResponseEntity.ok(updatedUser);
    }

    @PutMapping(value = "/profile", consumes = { "multipart/form-data" })
    public ResponseEntity<UserDTO> updateProfile(
            @jakarta.validation.Valid @ModelAttribute mx.edu.utez.backend.dto.request.UpdateProfileRequest request,
            @RequestParam(value = "image", required = false) org.springframework.web.multipart.MultipartFile image,
            @AuthenticationPrincipal User user) {
        UserDTO updatedUser = userService.updateProfile(request, image, user);
        return ResponseEntity.ok(updatedUser);
    }
}
