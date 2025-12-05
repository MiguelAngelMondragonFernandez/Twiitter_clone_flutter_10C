package mx.edu.utez.backend.repository;

import mx.edu.utez.backend.model.Chirp;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChirpRepository extends JpaRepository<Chirp, Long> {

    @Query("SELECT c FROM Chirp c WHERE LOWER(c.content) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Chirp> searchChirps(@Param("query") String query);

    @Query("SELECT c FROM Chirp c WHERE c.author.id = :authorId ORDER BY c.createdAt DESC")
    Page<Chirp> findByAuthorIdOrderByCreatedAtDesc(@Param("authorId") Long authorId, Pageable pageable);

    @Query("SELECT c FROM Chirp c WHERE LOWER(c.content) LIKE LOWER(CONCAT('%', :query, '%'))")
    Page<Chirp> searchChirpsPage(@Param("query") String query, Pageable pageable);

    @Query("SELECT c FROM Chirp c WHERE c.author.id IN :authorIds ORDER BY c.createdAt DESC")
    Page<Chirp> findFeedByAuthorIds(@Param("authorIds") List<Long> authorIds, Pageable pageable);

    @Query(value = """
            SELECT * FROM (
                SELECT
                    c.id as id,
                    c.content as content,
                    c.created_at as createdAt,
                    c.likes_count as likesCount,
                    c.replies_count as repliesCount,
                    c.reposts_count as repostsCount,
                    c.reply_to_id as replyToId,
                    c.latitude as latitude,
                    c.longitude as longitude,
                    c.city as city,
                    c.country as country,
                    u.id as authorId,
                    u.username as authorUsername,
                    u.display_name as authorDisplayName,
                    u.profile_image_url as authorProfileImageUrl,
                    NULL as reposterId,
                    NULL as reposterUsername,
                    NULL as reposterDisplayName,
                    c.created_at as sortDate
                FROM chirps c
                JOIN users u ON c.author_id = u.id
                WHERE c.author_id IN :authorIds AND c.reply_to_id IS NULL

                UNION ALL

                SELECT
                    c.id as id,
                    c.content as content,
                    c.created_at as createdAt,
                    c.likes_count as likesCount,
                    c.replies_count as repliesCount,
                    c.reposts_count as repostsCount,
                    c.reply_to_id as replyToId,
                    c.latitude as latitude,
                    c.longitude as longitude,
                    c.city as city,
                    c.country as country,
                    u.id as authorId,
                    u.username as authorUsername,
                    u.display_name as authorDisplayName,
                    u.profile_image_url as authorProfileImageUrl,
                    r_user.id as reposterId,
                    r_user.username as reposterUsername,
                    r_user.display_name as reposterDisplayName,
                    r.created_at as sortDate
                FROM reposts r
                JOIN chirps c ON r.chirp_id = c.id
                JOIN users u ON c.author_id = u.id
                JOIN users r_user ON r.user_id = r_user.id
                WHERE r.user_id IN :authorIds
            ) AS feed
            ORDER BY sortDate DESC
            """, countQuery = """
            SELECT COUNT(*) FROM (
                SELECT c.id FROM chirps c WHERE c.author_id IN :authorIds AND c.reply_to_id IS NULL
                UNION ALL
                SELECT r.id FROM reposts r WHERE r.user_id IN :authorIds
            ) AS count_feed
            """, nativeQuery = true)
    Page<FeedItemProjection> findFeedMixed(@Param("authorIds") List<Long> authorIds, Pageable pageable);

    @Query("SELECT c FROM Chirp c WHERE c.replyTo.id = :chirpId ORDER BY c.createdAt ASC")
    List<Chirp> findRepliesByChirpId(@Param("chirpId") Long chirpId);

    @Query("SELECT i FROM Chirp c JOIN c.imageUrls i WHERE c.id = :chirpId")
    List<String> findImageUrlsByChirpId(@Param("chirpId") Long chirpId);
}
