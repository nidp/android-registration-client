package io.mosip.registration.clientmanager.dto.http;

import lombok.Data;

@Data
public class SyncRIDResponse {

    private String registrationId;
    private String status;
}
