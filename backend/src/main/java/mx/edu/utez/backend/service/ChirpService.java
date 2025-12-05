package mx.edu.utez.backend.service;

import mx.edu.utez.backend.dto.AuthorDTO;
import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.request.CreateChirpRequest;
import mx.edu.utez.backend.exception.ConflictException;
import mx.edu.utez.backend.exception.ForbiddenException;
import mx.edu.utez.backend.exception.ResourceNotFoundException;
import mx.edu.utez.backend.model.*;
import mx.edu.utez.backend.repository.*;
import mx.edu.utez.backend.util.DTOMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ChirpService {

    @Autowired
    private ChirpRepository chirpRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FollowRepository followRepository;

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
    public List<ChirpDTO> getFeed(User currentUser, Pageable pageable) {
        // Obtener IDs de usuarios que sigue
        List<Long> followingIds = followRepository.findFollowingIdsByUserId(currentUser.getId());

        // Agregar el propio ID del usuario
        followingIds.add(currentUser.getId());

        // Obtener chirps del feed (mezclado con reposts)
        Page<FeedItemProjection> feedItems = chirpRepository.findFeedMixed(followingIds, pageable);

        // Convertir a DTOs
        return feedItems.stream()
                .map(item -> {
                    boolean isLiked = likeRepository.existsByUserIdAndChirpId(currentUser.getId(), item.getId());
                    boolean isReposted = repostRepository.existsByUserIdAndChirpId(currentUser.getId(), item.getId());

                    ChirpDTO dto = new ChirpDTO();
                    dto.setId(item.getId());
                    dto.setContent(item.getContent());
                    dto.setCreatedAt(item.getCreatedAt());
                    dto.setLikesCount(item.getLikesCount());
                    dto.setRepliesCount(item.getRepliesCount());
                    dto.setRepostsCount(item.getRepostsCount());
                    dto.setReplyToId(item.getReplyToId());
                    dto.setLiked(isLiked);
                    dto.setReposted(isReposted);
                    dto.setLiked(isLiked);
                    dto.setReposted(isReposted);
                    dto.setLatitude(item.getLatitude());
                    dto.setLongitude(item.getLongitude());
                    dto.setCity(item.getCity());
                    dto.setCountry(item.getCountry());
                    dto.setImageUrls(chirpRepository.findImageUrlsByChirpId(item.getId()));

                    AuthorDTO author = new AuthorDTO();
                    author.setId(item.getAuthorId());
                    author.setUsername(item.getAuthorUsername());
                    author.setDisplayName(item.getAuthorDisplayName());
                    author.setProfileImageUrl(item.getAuthorProfileImageUrl());
                    dto.setAuthor(author);

                    if (item.getReposterId() != null) {
                        AuthorDTO reposter = new AuthorDTO();
                        reposter.setId(item.getReposterId());
                        reposter.setUsername(item.getReposterUsername());
                        reposter.setDisplayName(item.getReposterDisplayName());
                        dto.setRepostedBy(reposter);
                    }

                    return dto;
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ChirpDTO> getReplies(Long chirpId, User currentUser) {
        List<Chirp> replies = chirpRepository.findRepliesByChirpId(chirpId);
        return replies.stream()
                .map(chirp -> {
                    boolean isLiked = likeRepository.existsByUserIdAndChirpId(currentUser.getId(), chirp.getId());
                    boolean isReposted = repostRepository.existsByUserIdAndChirpId(currentUser.getId(), chirp.getId());
                    return dtoMapper.toChirpDTO(chirp, isLiked, isReposted);
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public ChirpDTO createChirp(CreateChirpRequest request,
            List<org.springframework.web.multipart.MultipartFile> images, User currentUser) {
        Chirp chirp = new Chirp();
        chirp.setContent(request.getContent());
        chirp.setAuthor(currentUser);

        // Handle images
        if (images != null && !images.isEmpty()) {
            if (images.size() > 5) {
                throw new mx.edu.utez.backend.exception.BadRequestException("No puedes subir más de 5 imágenes");
            }

            List<String> imageUrls = new ArrayList<>();
            try {
                String userDir = System.getProperty("user.dir");
                java.nio.file.Path uploadPath = java.nio.file.Paths.get(userDir, "uploads");
                if (!java.nio.file.Files.exists(uploadPath)) {
                    java.nio.file.Files.createDirectories(uploadPath);
                }

                for (org.springframework.web.multipart.MultipartFile image : images) {
                    if (!image.isEmpty()) {
                        String fileName = System.currentTimeMillis() + "_" + image.getOriginalFilename();
                        java.nio.file.Files.copy(image.getInputStream(), uploadPath.resolve(fileName),
                                java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                        imageUrls.add("/uploads/" + fileName);
                    }
                }
            } catch (java.io.IOException e) {
                throw new RuntimeException("Error al guardar las imágenes", e);
            }
            chirp.setImageUrls(imageUrls);
        }

        // Si es una respuesta, verificar que el chirp padre existe
        if (request.getReplyToId() != null) {
            Chirp replyTo = chirpRepository.findById(request.getReplyToId())
                    .orElseThrow(() -> new ResourceNotFoundException("El chirp al que intentas responder no existe"));

            chirp.setReplyTo(replyTo);

            // Incrementar contador de respuestas del chirp padre
            replyTo.setRepliesCount(replyTo.getRepliesCount() + 1);
            chirpRepository.save(replyTo);

            // Crear notificación de respuesta
            if (!replyTo.getAuthor().getId().equals(currentUser.getId())) {
                Notification notification = new Notification();
                notification.setType(NotificationType.REPLY);
                notification.setActor(currentUser);
                notification.setUser(replyTo.getAuthor());
                notification.setChirp(chirp);
                notification.setContent(request.getContent());
                notificationRepository.save(notification);

                // Enviar push notification
                firebaseService.sendPushNotificationToUser(
                        replyTo.getAuthor(),
                        "Nueva respuesta",
                        currentUser.getDisplayName() + " respondió a tu chirp");
            }
        }

        // Save geolocation data if provided
        if (request.getLatitude() != null && request.getLongitude() != null) {
            chirp.setLatitude(request.getLatitude());
            chirp.setLongitude(request.getLongitude());
        }
        if (request.getCity() != null) {
            chirp.setCity(request.getCity());
        }
        if (request.getCountry() != null) {
            chirp.setCountry(request.getCountry());
        }

        chirp = chirpRepository.save(chirp);

        return dtoMapper.toChirpDTO(chirp, false, false);
    }

    @Transactional
    public void deleteChirp(Long chirpId, User currentUser) {
        Chirp chirp = chirpRepository.findById(chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("Chirp no encontrado"));

        // Verificar que el chirp pertenece al usuario actual
        if (!chirp.getAuthor().getId().equals(currentUser.getId())) {
            throw new ForbiddenException("No puedes eliminar chirps de otros usuarios");
        }

        chirpRepository.delete(chirp);
    }

    @Transactional
    public void likeChirp(Long chirpId, User currentUser) {
        Chirp chirp = chirpRepository.findById(chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("Chirp no encontrado"));

        // Verificar que no le ha dado like ya
        if (likeRepository.existsByUserIdAndChirpId(currentUser.getId(), chirpId)) {
            throw new ConflictException("Ya le diste like a este chirp");
        }

        // Crear like
        Like like = new Like();
        like.setId(new LikeId(currentUser.getId(), chirp.getId()));
        like.setUser(currentUser);
        like.setChirp(chirp);
        likeRepository.save(like);

        // Incrementar contador
        chirp.setLikesCount(chirp.getLikesCount() + 1);
        chirpRepository.save(chirp);

        // Crear notificación (solo si no es el propio autor)
        if (!chirp.getAuthor().getId().equals(currentUser.getId())) {
            Notification notification = new Notification();
            notification.setType(NotificationType.LIKE);
            notification.setActor(currentUser);
            notification.setUser(chirp.getAuthor());
            notification.setChirp(chirp);
            notificationRepository.save(notification);

            // Enviar push notification
            firebaseService.sendPushNotificationToUser(
                    chirp.getAuthor(),
                    "Nuevo like",
                    currentUser.getDisplayName() + " le dio like a tu chirp");
        }
    }

    @Transactional
    public void unlikeChirp(Long chirpId, User currentUser) {
        Chirp chirp = chirpRepository.findById(chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("Chirp no encontrado"));

        Like like = likeRepository.findByUserIdAndChirpId(currentUser.getId(), chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("No le habías dado like a este chirp"));

        // Eliminar like
        likeRepository.delete(like);

        // Decrementar contador
        chirp.setLikesCount(Math.max(0, chirp.getLikesCount() - 1));
        chirpRepository.save(chirp);
    }

    @Transactional
    public void repostChirp(Long chirpId, User currentUser) {
        Chirp chirp = chirpRepository.findById(chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("Chirp no encontrado"));

        // Verificar que no lo ha reposteado ya
        if (repostRepository.existsByUserIdAndChirpId(currentUser.getId(), chirpId)) {
            throw new ConflictException("Ya reposteaste este chirp");
        }

        // Crear repost
        Repost repost = new Repost();
        repost.setUser(currentUser);
        repost.setChirp(chirp);
        repostRepository.save(repost);

        // Incrementar contador
        chirp.setRepostsCount(chirp.getRepostsCount() + 1);
        chirpRepository.save(chirp);

        // Crear notificación (solo si no es el propio autor)
        if (!chirp.getAuthor().getId().equals(currentUser.getId())) {
            Notification notification = new Notification();
            notification.setType(NotificationType.REPOST);
            notification.setActor(currentUser);
            notification.setUser(chirp.getAuthor());
            notification.setChirp(chirp);
            notificationRepository.save(notification);

            // Enviar push notification
            firebaseService.sendPushNotificationToUser(
                    chirp.getAuthor(),
                    "Nuevo repost",
                    currentUser.getDisplayName() + " reposteó tu chirp");
        }
    }

    @Transactional
    public void unrepostChirp(Long chirpId, User currentUser) {
        Chirp chirp = chirpRepository.findById(chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("Chirp no encontrado"));

        Repost repost = repostRepository.findByUserIdAndChirpId(currentUser.getId(), chirpId)
                .orElseThrow(() -> new ResourceNotFoundException("No habías reposteado este chirp"));

        // Eliminar repost
        repostRepository.delete(repost);

        // Decrementar contador
        chirp.setRepostsCount(Math.max(0, chirp.getRepostsCount() - 1));
        chirpRepository.save(chirp);
    }
}
