package com.revuelta.api.infrastructure.time;

import com.revuelta.api.application.port.ServerClockPort;
import java.time.Instant;
import org.springframework.stereotype.Component;

@Component
public class SystemServerClockAdapter implements ServerClockPort {

    @Override
    public Instant now() {
        return Instant.now();
    }
}
