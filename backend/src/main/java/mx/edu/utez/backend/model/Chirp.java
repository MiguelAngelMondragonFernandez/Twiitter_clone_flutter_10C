package mx.edu.utez.backend.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "chirps")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Chirp {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(nullable = false, length = 280)
    @NotBlank(message = "El contenido no puede estar vacío")
    @Size(min = 1, max = 280, message = "El chirp debe tener entre 1 y 280 caracteres")
    private String content;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reply_to_id")
    private Chirp replyTo;
    
    @OneToMany(mappedBy = "replyTo", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Chirp> replies = new ArrayList<>();
    
    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "likes_count")
    private int likesCount = 0;
    
    @Column(name = "replies_count")
    private int repliesCount = 0;
    
    @Column(name = "reposts_count")
    private int repostsCount = 0;
    
    @OneToMany(mappedBy = "chirp", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Like> likes = new ArrayList<>();
    
    @OneToMany(mappedBy = "chirp", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Repost> reposts = new ArrayList<>();
    
    @OneToMany(mappedBy = "chirp", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Notification> notifications = new ArrayList<>();
}
