package mx.edu.utez.backend.repository;

import mx.edu.utez.backend.model.Like;
import mx.edu.utez.backend.model.LikeId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LikeRepository extends JpaRepository<Like, LikeId> {
    
    @Query("SELECT l FROM Like l WHERE l.user.id = :userId AND l.chirp.id = :chirpId")
    Optional<Like> findByUserIdAndChirpId(@Param("userId") Long userId, @Param("chirpId") Long chirpId);
    
    boolean existsByUserIdAndChirpId(Long userId, Long chirpId);
    
    long countByChirpId(Long chirpId);
}
