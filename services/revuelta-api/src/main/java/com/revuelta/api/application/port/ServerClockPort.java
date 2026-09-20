package com.revuelta.api.application.port;

import java.time.Instant;

public interface ServerClockPort {

    Instant now();
}
