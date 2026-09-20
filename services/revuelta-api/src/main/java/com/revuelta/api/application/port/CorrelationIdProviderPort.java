package com.revuelta.api.application.port;

import java.util.UUID;

public interface CorrelationIdProviderPort {

    UUID current();
}
