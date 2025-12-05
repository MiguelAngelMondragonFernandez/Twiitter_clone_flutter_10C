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
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.io.IOException;

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
    private FirebaseService firebaseService;

    @Autowired
    private DTOMapper dtoMapper;

    @Transactional(readOnly = true)
    public UserDTO getProfile(User currentUser) {
        return dtoMapper.toUserDTO(currentUser);
    }

    @Transactional(readOnly = true)
    public UserDTO getUserById(Long userId, User currentUser) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Usuario no encontrado"));

        // Verificar si el usuario actual sigue a este usuario
        boolean isFollowing = followRepository.existsByFollowerIdAndFollowingId(
                currentUser.getId(), userId);

        return dtoMapper.toUserDTO(user, isFollowing);
    }

    @Transactional(readOnly = true)
    public List<ChirpDTO> getUserChirps(Long userId, User currentUser, Pageable pageable) {
        // Verificar que el usuario existe
        if (!userRepository.existsById(userId)) {
            throw new ResourceNotFoundException("Usuario no encontrado");
        }

        Page<mx.edu.utez.backend.model.Chirp> chirps = chirpRepository.findByAuthorIdOrderByCreatedAtDesc(userId,
                pageable);

        return chirps.stream()
                .map(chirp -> {
                    boolean isLiked = likeRepository.existsByUserIdAndChirpId(currentUser.getId(), chirp.getId());
                    boolean isReposted = repostRepository.existsByUserIdAndChirpId(currentUser.getId(), chirp.getId());
                    return dtoMapper.toChirpDTO(chirp, isLiked, isReposted);
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public UserDTO followUser(Long userIdToFollow, User currentUser) {
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
        followRepository.flush(); // Force immediate save

        // Actualizar contadores
        currentUser.setFollowingCount(currentUser.getFollowingCount() + 1);
        userToFollow.setFollowersCount(userToFollow.getFollowersCount() + 1);
        userRepository.save(currentUser);
        userRepository.save(userToFollow);
        userRepository.flush(); // Force immediate update

        // Crear notificación
        Notification notification = new Notification();
        notification.setType(NotificationType.FOLLOW);
        notification.setActor(currentUser);
        notification.setUser(userToFollow);
        notificationRepository.save(notification);

        // Enviar push notification
        firebaseService.sendPushNotificationToUser(
                userToFollow,
                "Nuevo seguidor",
                currentUser.getDisplayName() + " comenzó a seguirte");

        // Devolver el usuario actualizado con isFollowing=true
        return dtoMapper.toUserDTO(userToFollow, true);
    }

    @Transactional
    public UserDTO unfollowUser(Long userIdToUnfollow, User currentUser) {
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
        followRepository.flush(); // Force immediate deletion

        // Actualizar contadores
        currentUser.setFollowingCount(Math.max(0, currentUser.getFollowingCount() - 1));
        userToUnfollow.setFollowersCount(Math.max(0, userToUnfollow.getFollowersCount() - 1));
        userRepository.save(currentUser);
        userRepository.save(userToUnfollow);
        userRepository.flush(); // Force immediate update

        // Devolver el usuario actualizado con isFollowing=false
        return dtoMapper.toUserDTO(userToUnfollow, false);
    }

    @Transactional
    public UserDTO updateProfile(mx.edu.utez.backend.dto.request.UpdateProfileRequest request, MultipartFile image,
            User currentUser) {
        if (request.getDisplayName() != null) {
            currentUser.setDisplayName(request.getDisplayName());
        }

        if (request.getBio() != null) {
            currentUser.setBio(request.getBio());
        }

        if (request.getCity() != null) {
            currentUser.setCity(request.getCity());
        }

        if (request.getCountry() != null) {
            currentUser.setCountry(request.getCountry());
        }

        if (image != null && !image.isEmpty()) {
            try {
                String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
                String userDir = System.getProperty("user.dir");
                Path uploadPath = Paths.get(userDir, "uploads");

                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }

                Files.copy(image.getInputStream(), uploadPath.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);

                // Store relative path so frontend can prepend appropriate base URL
                String fileUrl = "/uploads/" + fileName;
                currentUser.setProfileImageUrl(fileUrl);
            } catch (IOException e) {
                throw new RuntimeException("Error al guardar la imagen", e);
            }
        }

        User updatedUser = userRepository.save(currentUser);
        return dtoMapper.toUserDTO(updatedUser);
    }
}
