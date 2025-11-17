package mx.edu.utez.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserDTO {
    private String id;
    private String username;
    private String email;
    private String displayName;
    private String bio;
    private String profileImageUrl;
    private int followersCount;
    private int followingCount;
    private LocalDateTime createdAt;
    private Boolean isFollowing; // Opcional, usado cuando se ve el perfil de otro usuario
}
