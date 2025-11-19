package mx.edu.utez.backend.controller;

import jakarta.validation.Valid;
import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.request.CreateChirpRequest;
import mx.edu.utez.backend.model.User;
import mx.edu.utez.backend.service.ChirpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chirps")
@CrossOrigin(origins = "*")
public class ChirpController {
    
    @Autowired
    private ChirpService chirpService;
    
    @GetMapping("/feed")
    public ResponseEntity<List<ChirpDTO>> getFeed(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal User user) {
        Pageable pageable = PageRequest.of(page, size);
        List<ChirpDTO> feed = chirpService.getFeed(user, pageable);
        return ResponseEntity.ok(feed);
    }
    
    @PostMapping
    public ResponseEntity<ChirpDTO> createChirp(
            @Valid @RequestBody CreateChirpRequest request,
            @AuthenticationPrincipal User user) {
        ChirpDTO chirp = chirpService.createChirp(request, user);
        return ResponseEntity.status(HttpStatus.CREATED).body(chirp);
    }
    
    @DeleteMapping("/{chirpId}")
    public ResponseEntity<Map<String, String>> deleteChirp(
            @PathVariable String chirpId,
            @AuthenticationPrincipal User user) {
        chirpService.deleteChirp(chirpId, user);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Chirp eliminado exitosamente");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/like/{chirpId}")
    public ResponseEntity<Map<String, Object>> likeChirp(
            @PathVariable String chirpId,
            @AuthenticationPrincipal User user) {
        chirpService.likeChirp(chirpId, user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Like agregado");
        response.put("isLiked", true);
        return ResponseEntity.ok(response);
    }
    
    @DeleteMapping("/unlike/{chirpId}")
    public ResponseEntity<Map<String, Object>> unlikeChirp(
            @PathVariable String chirpId,
            @AuthenticationPrincipal User user) {
        chirpService.unlikeChirp(chirpId, user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Like eliminado");
        response.put("isLiked", false);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/repost/{chirpId}")
    public ResponseEntity<Map<String, Object>> repostChirp(
            @PathVariable String chirpId,
            @AuthenticationPrincipal User user) {
        chirpService.repostChirp(chirpId, user);
        
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Chirp reposteado");
        response.put("isReposted", true);
        return ResponseEntity.ok(response);
    }
}
