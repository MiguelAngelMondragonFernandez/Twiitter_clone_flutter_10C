package mx.edu.utez.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import mx.edu.utez.backend.dto.ChirpDTO;
import mx.edu.utez.backend.dto.UserDTO;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SearchResponse {
    private List<UserDTO> users;
    private List<ChirpDTO> chirps;
}
