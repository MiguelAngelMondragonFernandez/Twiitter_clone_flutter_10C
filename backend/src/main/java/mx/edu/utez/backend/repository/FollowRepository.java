package mx.edu.utez.backend.repository;

import mx.edu.utez.backend.model.Follow;
import mx.edu.utez.backend.model.FollowId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FollowRepository extends JpaRepository<Follow, FollowId> {
    
    @Query("SELECT f FROM Follow f WHERE f.follower.id = :followerId AND f.following.id = :followingId")
    Optional<Follow> findByFollowerIdAndFollowingId(@Param("followerId") String followerId, @Param("followingId") String followingId);
    
    @Query("SELECT f.following.id FROM Follow f WHERE f.follower.id = :userId")
    List<String> findFollowingIdsByUserId(@Param("userId") String userId);
    
    boolean existsByFollowerIdAndFollowingId(String followerId, String followingId);
}
