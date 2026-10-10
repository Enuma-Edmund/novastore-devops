package com.novastore;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class HealthControllerTest {

    @Test
    void healthEndpointReturnsHealthyMessage() {
        HealthController controller = new HealthController();

        assertEquals(
            "NovaStore application is healthy",
            controller.health()
        );
    }
}
