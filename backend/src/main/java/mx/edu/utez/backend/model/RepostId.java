package mx.edu.utez.backend.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RepostId implements Serializable {
    private Long user;
    private Long chirp;
}
