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
public interface ChirpRepository extends JpaRepository<Chirp, String> {
    
    Page<Chirp> findByAuthorIdOrderByCreatedAtDesc(String authorId, Pageable pageable);
    
    @Query("SELECT c FROM Chirp c WHERE c.author.id IN :authorIds ORDER BY c.createdAt DESC")
    Page<Chirp> findFeedByAuthorIds(@Param("authorIds") List<String> authorIds, Pageable pageable);
    
    @Query("SELECT c FROM Chirp c WHERE LOWER(c.content) LIKE LOWER(CONCAT('%', :query, '%')) ORDER BY c.createdAt DESC")
    List<Chirp> searchChirps(@Param("query") String query);
    
    @Query("SELECT c FROM Chirp c WHERE LOWER(c.content) LIKE LOWER(CONCAT('%', :query, '%')) ORDER BY c.createdAt DESC")
    Page<Chirp> searchChirpsPage(@Param("query") String query, Pageable pageable);
}
