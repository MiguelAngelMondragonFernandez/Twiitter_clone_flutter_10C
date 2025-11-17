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
    Optional<Like> findByUserIdAndChirpId(@Param("userId") String userId, @Param("chirpId") String chirpId);
    
    boolean existsByUserIdAndChirpId(String userId, String chirpId);
    
    long countByChirpId(String chirpId);
}
