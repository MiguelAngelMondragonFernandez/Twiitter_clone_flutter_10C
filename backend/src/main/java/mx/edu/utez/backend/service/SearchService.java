package mx.edu.utez.backend.service;

import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.UserDTO;
import mx.edu.utez.backend.dto.response.SearchResponse;
import mx.edu.utez.backend.model.Chirp;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.repository.*;
import mx.edu.utez.backend.util.DTOMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SearchService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private ChirpRepository chirpRepository;
    
    @Autowired
    private FollowRepository followRepository;
    
    @Autowired
    private LikeRepository likeRepository;
    
    @Autowired
    private RepostRepository repostRepository;
    
    @Autowired
    private DTOMapper dtoMapper;
    
    @Transactional(readOnly = true)
    public SearchResponse searchAll(String query, User currentUser) {
        // Buscar usuarios (limitar a 10)
        List<User> users = userRepository.searchUsers(query);
        List<UserDTO> userDTOs = users.stream()
                .limit(10)
                .map(user -> {
                    boolean isFollowing = followRepository.existsByFollowerIdAndFollowingId(
                            currentUser.getId(), user.getId());
                    return dtoMapper.toUserDTO(user, isFollowing);
                })
                .collect(Collectors.toList());
        
        // Buscar chirps (limitar a 10)
        List<Chirp> chirps = chirpRepository.searchChirps(query);
        List<ChirpDTO> chirpDTOs = chirps.stream()
                .limit(10)
                .map(chirp -> {
                    boolean isLiked = likeRepository.existsByUserIdAndChirpId(
                            currentUser.getId(), chirp.getId());
                    boolean isReposted = repostRepository.existsByUserIdAndChirpId(
                            currentUser.getId(), chirp.getId());
                    return dtoMapper.toChirpDTO(chirp, isLiked, isReposted);
                })
                .collect(Collectors.toList());
        
        return new SearchResponse(userDTOs, chirpDTOs);
    }
    
    @Transactional(readOnly = true)
    public List<UserDTO> searchUsers(String query, User currentUser) {
        List<User> users = userRepository.searchUsers(query);
        
        return users.stream()
                .map(user -> {
                    boolean isFollowing = followRepository.existsByFollowerIdAndFollowingId(
                            currentUser.getId(), user.getId());
                    return dtoMapper.toUserDTO(user, isFollowing);
                })
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<ChirpDTO> searchChirps(String query, User currentUser, Pageable pageable) {
        Page<Chirp> chirps = chirpRepository.searchChirpsPage(query, pageable);
        
        return chirps.stream()
                .map(chirp -> {
                    boolean isLiked = likeRepository.existsByUserIdAndChirpId(
                            currentUser.getId(), chirp.getId());
                    boolean isReposted = repostRepository.existsByUserIdAndChirpId(
                            currentUser.getId(), chirp.getId());
                    return dtoMapper.toChirpDTO(chirp, isLiked, isReposted);
                })
                .collect(Collectors.toList());
    }
}
