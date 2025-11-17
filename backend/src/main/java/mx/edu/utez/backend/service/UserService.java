package mx.edu.utez.backend.service;

import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.UserDTO;
import mx.edu.utez.backend.exception.BadRequestException;
import mx.edu.utez.backend.exception.ConflictException;
import mx.edu.utez.backend.exception.ResourceNotFoundException;
import mx.edu.utez.backend.model.Follow;
import mx.edu.utez.backend.model.Notification;
import mx.edu.utez.backend.model.NotificationType;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.repository.*;
import mx.edu.utez.backend.util.DTOMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private FollowRepository followRepository;
    
    @Autowired
    private ChirpRepository chirpRepository;
    
    @Autowired
    private LikeRepository likeRepository;
    
    @Autowired
    private RepostRepository repostRepository;
    
    @Autowired
    private NotificationRepository notificationRepository;
    
    @Autowired
    private DTOMapper dtoMapper;
    
    @Transactional(readOnly = true)
    public UserDTO getProfile(User currentUser) {
        return dtoMapper.toUserDTO(currentUser);
    }
    
    @Transactional(readOnly = true)
    public UserDTO getUserById(String userId, User currentUser) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
        
        // Verificar si el usuario actual sigue a este usuario
        boolean isFollowing = followRepository.existsByFollowerIdAndFollowingId(
                currentUser.getId(), userId);
        
        return dtoMapper.toUserDTO(user, isFollowing);
    }
    
    @Transactional(readOnly = true)
    public List<ChirpDTO> getUserChirps(String userId, User currentUser, Pageable pageable) {
        // Verificar que el usuario existe
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("Usuario no encontrado");
        }
        
        Page<mx.edu.utez.backend.model.Chirp> chirps = chirpRepository.findByAuthorIdOrderByCreatedAtDesc(userId, pageable);
        
        return chirps.stream()
                .map(chirp -> {
                    boolean isLiked = likeRepository.existsByUserIdAndChirpId(currentUser.getId(), chirp.getId());
                    boolean isReposted = repostRepository.existsByUserIdAndChirpId(currentUser.getId(), chirp.getId());
                    return dtoMapper.toChirpDTO(chirp, isLiked, isReposted);
                })
                .collect(Collectors.toList());
    }
    
    @Transactional
    public void followUser(String userIdToFollow, User currentUser) {
        // No puede seguirse a sí mismo
        if (currentUser.getId().equals(userIdToFollow)) {
            throw new BadRequestException("No puedes seguirte a ti mismo");
        }
        
        // Verificar que el usuario a seguir existe
        User userToFollow = userRepository.findById(userIdToFollow)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
        
        // Verificar que no lo está siguiendo ya
        if (followRepository.existsByFollowerIdAndFollowingId(currentUser.getId(), userIdToFollow)) {
            throw new ConflictException("Ya estás siguiendo a este usuario");
        }
        
        // Crear relación de seguimiento
        Follow follow = new Follow();
        follow.setFollower(currentUser);
        follow.setFollowing(userToFollow);
        followRepository.save(follow);
        
        // Actualizar contadores
        currentUser.setFollowingCount(currentUser.getFollowingCount() + 1);
        userToFollow.setFollowersCount(userToFollow.getFollowersCount() + 1);
        userRepository.save(currentUser);
        userRepository.save(userToFollow);
        
        // Crear notificación
        Notification notification = new Notification();
        notification.setType(NotificationType.FOLLOW);
        notification.setActor(currentUser);
        notification.setUser(userToFollow);
        notificationRepository.save(notification);
    }
    
    @Transactional
    public void unfollowUser(String userIdToUnfollow, User currentUser) {
        // No puede dejar de seguirse a sí mismo
        if (currentUser.getId().equals(userIdToUnfollow)) {
            throw new BadRequestException("No puedes dejar de seguirte a ti mismo");
        }
        
        // Verificar que el usuario existe
        User userToUnfollow = userRepository.findById(userIdToUnfollow)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));
        
        // Buscar la relación de seguimiento
        Follow follow = followRepository.findByFollowerIdAndFollowingId(currentUser.getId(), userIdToUnfollow)
                .orElseThrow(() -> new ResourceNotFoundException("No estás siguiendo a este usuario"));
        
        // Eliminar la relación
        followRepository.delete(follow);
        
        // Actualizar contadores
        currentUser.setFollowingCount(Math.max(0, currentUser.getFollowingCount() - 1));
        userToUnfollow.setFollowersCount(Math.max(0, userToUnfollow.getFollowersCount() - 1));
        userRepository.save(currentUser);
        userRepository.save(userToUnfollow);
    }
}
