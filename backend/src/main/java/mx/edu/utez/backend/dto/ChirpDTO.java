package mx.edu.utez.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChirpDTO {
    private String id;
    private String content;
    private AuthorDTO author;
    private LocalDateTime createdAt;
    private int likesCount;
    private int repliesCount;
    private int repostsCount;
    private boolean isLiked;
    private boolean isReposted;
    private String replyToId;
}
