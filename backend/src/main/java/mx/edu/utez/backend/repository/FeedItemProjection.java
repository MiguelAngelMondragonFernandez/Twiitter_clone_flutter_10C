package mx.edu.utez.backend.repository;

import java.time.LocalDateTime;

public interface FeedItemProjection {
    // Chirp details
    Long getId();

    String getContent();

    LocalDateTime getCreatedAt();

    Integer getLikesCount();

    Integer getRepliesCount();

    Integer getRepostsCount();

    // Author details
    Long getAuthorId();

    String getAuthorUsername();

    String getAuthorDisplayName();

    String getAuthorProfileImageUrl();

    // Reposter details (null if not a repost)
    Long getReposterId();

    String getReposterUsername();

    String getReposterDisplayName();

    // Reply details
    Long getReplyToId();

    // Metadata for sorting
    LocalDateTime getSortDate();
}
