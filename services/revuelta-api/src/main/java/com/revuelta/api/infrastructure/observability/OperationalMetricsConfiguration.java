package com.revuelta.api.infrastructure.observability;

import com.revuelta.api.infrastructure.persistence.SpringDataCirculationRepository;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OperationalMetricsConfiguration {

    public OperationalMetricsConfiguration(
            MeterRegistry registry,
            SpringDataCirculationRepository circulations
    ) {
        Gauge.builder(
                        "revuelta.circulations.active",
                        circulations,
                        repository -> repository.countByStatus("ACTIVE")
                )
                .description("Current active circulation count; operational observation only")
                .register(registry);
    }
}
