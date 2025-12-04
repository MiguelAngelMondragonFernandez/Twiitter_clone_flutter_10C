package mx.edu.utez.backend.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileRequest {
    @Size(min = 3, max = 50, message = "El nombre debe tener entre 3 y 50 caracteres")
    private String displayName;

    @Size(max = 160, message = "La biografía no puede exceder los 160 caracteres")
    private String bio;

    @Size(max = 100, message = "La ciudad no puede exceder los 100 caracteres")
    private String city;

    @Size(max = 100, message = "El país no puede exceder los 100 caracteres")
    private String country;

    // Optional: profileImageUrl if we were handling uploads, but for now just text
    // fields
}
