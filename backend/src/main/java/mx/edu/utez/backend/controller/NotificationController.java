package mx.edu.utez.backend.controller;

import mx.edu.utez.backend.dto.NotificationDTO;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.service.NotificationService;
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
@RequestMapping("/api/notifications")
public class NotificationController {
    
    @Autowired
    private NotificationService notificationService;
    
    @GetMapping
    public ResponseEntity<List<NotificationDTO>> getNotifications(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        Pageable pageable = PageRequest.of(page, size);
        List<NotificationDTO> notifications = notificationService.getNotifications(user, pageable);
        return ResponseEntity.ok(notifications);
    }
    
    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> getUnreadCount(@AuthenticationPrincipal User user) {
        long count = notificationService.getUnreadCount(user);
        Map<String, Long> response = new HashMap<>();
        response.put("count", count);
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/read/{notificationId}")
    public ResponseEntity<Map<String, Object>> markAsRead(
            @PathVariable Long notificationId,
            @AuthenticationPrincipal User user) {
        notificationService.markAsRead(notificationId, user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Notificación marcada como leída");
        response.put("isRead", true);
        return ResponseEntity.ok(response);
    }
    
    @PutMapping("/read/all")
    public ResponseEntity<Map<String, Object>> markAllAsRead(@AuthenticationPrincipal User user) {
        int count = notificationService.markAllAsRead(user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Todas las notificaciones marcadas como leídas");
        response.put("count", count);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/{notificationId}")
    public ResponseEntity<Map<String, String>> deleteNotification(
            @PathVariable Long notificationId,
            @AuthenticationPrincipal User user) {
        notificationService.deleteNotification(notificationId, user);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Notificación eliminada");
        return ResponseEntity.ok(response);
    }
}
