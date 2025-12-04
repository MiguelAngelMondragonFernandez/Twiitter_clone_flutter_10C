package mx.edu.utez.backend.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import org.hibernate.annotations.CreationTimestamp;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@ToString(exclude = { "author", "replyTo", "replies", "likes", "reposts", "notifications" })
@Entity
@Table(name = "chirps")
public class Chirp {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 280)
    @NotBlank(message = "El contenido no puede estar vacío")
    @Size(min = 1, max = 280, message = "El chirp debe tener entre 1 y 280 caracteres")
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    @JsonIgnoreProperties({ "chirps", "followers", "following", "likes", "reposts", "notifications" })
    private User author;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reply_to_id")
    private Chirp replyTo;

    @OneToMany(mappedBy = "replyTo", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
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
    @JsonIgnore
    private List<Like> likes = new ArrayList<>();

    @OneToMany(mappedBy = "chirp", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Repost> reposts = new ArrayList<>();

    @OneToMany(mappedBy = "chirp", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Notification> notifications = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "chirp_images", joinColumns = @JoinColumn(name = "chirp_id"))
    @Column(name = "image_url")
    private List<String> imageUrls = new ArrayList<>();

}
