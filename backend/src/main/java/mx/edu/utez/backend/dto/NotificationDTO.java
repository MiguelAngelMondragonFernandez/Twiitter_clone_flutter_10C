package mx.edu.utez.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import mx.edu.utez.backend.model.NotificationType;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {
    private String id;
    private NotificationType type;
    private AuthorDTO actor;
    private ChirpDTO chirp;
    private String content;
    private LocalDateTime createdAt;
    private boolean isRead;
}
