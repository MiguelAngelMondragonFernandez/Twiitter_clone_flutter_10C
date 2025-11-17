package mx.edu.utez.backend.service;

import mx.edu.utez.backend.dto.NotificationDTO;
import mx.edu.utez.backend.exception.ResourceNotFoundException;
import mx.edu.utez.backend.model.Notification;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.repository.NotificationRepository;
import mx.edu.utez.backend.util.DTOMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NotificationService {
    
    @Autowired
    private NotificationRepository notificationRepository;
    
    @Autowired
    private DTOMapper dtoMapper;
    
    @Transactional(readOnly = true)
    public List<NotificationDTO> getNotifications(User currentUser, Pageable pageable) {
        Page<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(
                currentUser.getId(), pageable);
        
        return notifications.stream()
                .map(dtoMapper::toNotificationDTO)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public long getUnreadCount(User currentUser) {
        return notificationRepository.countByUserIdAndIsReadFalse(currentUser.getId());
    }
    
    @Transactional
    public void markAsRead(String notificationId, User currentUser) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notificación no encontrada"));
        
        // Verificar que la notificación pertenece al usuario actual
        if (!notification.getUser().getId().equals(currentUser.getId())) {
            throw new ResourceNotFoundException("Notificación no encontrada");
        }
        
        notification.setRead(true);
        notificationRepository.save(notification);
    }
    
    @Transactional
    public int markAllAsRead(User currentUser) {
        return notificationRepository.markAllAsRead(currentUser.getId());
    }
    
    @Transactional
    public void deleteNotification(String notificationId, User currentUser) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Notificación no encontrada"));
        
        // Verificar que la notificación pertenece al usuario actual
        if (!notification.getUser().getId().equals(currentUser.getId())) {
            throw new ResourceNotFoundException("Notificación no encontrada");
        }
        
        notificationRepository.delete(notification);
    }
}
