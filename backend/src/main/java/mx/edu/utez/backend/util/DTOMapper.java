package mx.edu.utez.backend.util;

import mx.edu.utez.backend.dto.AuthorDTO;
import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.NotificationDTO;
import mx.edu.utez.backend.dto.UserDTO;
import mx.edu.utez.backend.model.Chirp;
import mx.edu.utez.backend.model.Notification;
import mx.edu.utez.backend.model.User;
import org.springframework.stereotype.Component;

@Component
public class DTOMapper {
    
    public UserDTO toUserDTO(User user) {
        return toUserDTO(user, null);
    }
    
    public UserDTO toUserDTO(User user, Boolean isFollowing) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setDisplayName(user.getDisplayName());
        dto.setBio(user.getBio());
        dto.setProfileImageUrl(user.getProfileImageUrl());
        dto.setFollowersCount(user.getFollowersCount());
        dto.setFollowingCount(user.getFollowingCount());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setIsFollowing(isFollowing);
        return dto;
    }
    
    public AuthorDTO toAuthorDTO(User user) {
        AuthorDTO dto = new AuthorDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setDisplayName(user.getDisplayName());
        dto.setProfileImageUrl(user.getProfileImageUrl());
        return dto;
    }
    
    public ChirpDTO toChirpDTO(Chirp chirp, boolean isLiked, boolean isReposted) {
        ChirpDTO dto = new ChirpDTO();
        dto.setId(chirp.getId());
        dto.setContent(chirp.getContent());
        dto.setAuthor(toAuthorDTO(chirp.getAuthor()));
        dto.setCreatedAt(chirp.getCreatedAt());
        dto.setLikesCount(chirp.getLikesCount());
        dto.setRepliesCount(chirp.getRepliesCount());
        dto.setRepostsCount(chirp.getRepostsCount());
        dto.setLiked(isLiked);
        dto.setReposted(isReposted);
        dto.setReplyToId(chirp.getReplyTo() != null ? chirp.getReplyTo().getId() : null);
        return dto;
    }
    
    public NotificationDTO toNotificationDTO(Notification notification) {
        NotificationDTO dto = new NotificationDTO();
        dto.setId(notification.getId());
        dto.setType(notification.getType());
        dto.setActor(toAuthorDTO(notification.getActor()));
        if (notification.getChirp() != null) {
            dto.setChirp(toChirpDTO(notification.getChirp(), false, false));
        }
        dto.setContent(notification.getContent());
        dto.setCreatedAt(notification.getCreatedAt());
        dto.setRead(notification.isRead());
        return dto;
    }
}
