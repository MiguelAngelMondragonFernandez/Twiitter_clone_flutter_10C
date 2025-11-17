package mx.edu.utez.backend.controller;

import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.UserDTO;
import mx.edu.utez.backend.dto.response.SearchResponse;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.service.SearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/search")
public class SearchController {
    
    @Autowired
    private SearchService searchService;
    
    @GetMapping
    public ResponseEntity<SearchResponse> searchAll(
            @RequestParam String q,
            @AuthenticationPrincipal User user) {
        SearchResponse response = searchService.searchAll(q, user);
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/users")
    public ResponseEntity<List<UserDTO>> searchUsers(
            @RequestParam String q,
            @AuthenticationPrincipal User user) {
        List<UserDTO> users = searchService.searchUsers(q, user);
        return ResponseEntity.ok(users);
    }
    
    @GetMapping("/chirps")
    public ResponseEntity<List<ChirpDTO>> searchChirps(
            @RequestParam String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        Pageable pageable = PageRequest.of(page, size);
        List<ChirpDTO> chirps = searchService.searchChirps(q, user, pageable);
        return ResponseEntity.ok(chirps);
    }
}
