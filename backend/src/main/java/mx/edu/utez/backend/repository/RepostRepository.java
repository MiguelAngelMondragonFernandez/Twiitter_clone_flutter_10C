package mx.edu.utez.backend.repository;

import mx.edu.utez.backend.model.Repost;
import mx.edu.utez.backend.model.RepostId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RepostRepository extends JpaRepository<Repost, RepostId> {
    
    @Query("SELECT r FROM Repost r WHERE r.user.id = :userId AND r.chirp.id = :chirpId")
    Optional<Repost> findByUserIdAndChirpId(@Param("userId") String userId, @Param("chirpId") String chirpId);
    
    boolean existsByUserIdAndChirpId(String userId, String chirpId);
    
    long countByChirpId(String chirpId);
}
