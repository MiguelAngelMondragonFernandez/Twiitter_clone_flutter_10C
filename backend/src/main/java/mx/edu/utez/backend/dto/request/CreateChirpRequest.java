package mx.edu.utez.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateChirpRequest {
    
    @NotBlank(message = "El contenido no puede estar vacío")
    @Size(min = 1, max = 280, message = "El chirp debe tener entre 1 y 280 caracteres")
    private String content;
    
    private String replyToId;
}
