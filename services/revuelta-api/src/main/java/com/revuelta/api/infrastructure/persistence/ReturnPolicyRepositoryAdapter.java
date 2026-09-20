package com.revuelta.api.infrastructure.persistence;

import com.revuelta.api.application.port.ReturnPolicyRepositoryPort;
import com.revuelta.api.domain.policy.ReturnPolicy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
@RequiredArgsConstructor
public class ReturnPolicyRepositoryAdapter implements ReturnPolicyRepositoryPort {

    private final SpringDataReturnPolicyRepository repository;

    @Override
    public Optional<ReturnPolicy> findActivePolicy() {
        return repository.findFirstByActiveTrueOrderByCreatedAtDesc().map(this::toDomain);
    }

    @Override
    public ReturnPolicy save(ReturnPolicy policy) {
        ReturnPolicyJpaEntity entity = new ReturnPolicyJpaEntity(
                policy.id(),
                policy.name(),
                policy.version(),
                policy.durationHours(),
                policy.active(),
                policy.createdAt()
        );
        ReturnPolicyJpaEntity saved = repository.save(entity);
        return toDomain(saved);
    }

    private ReturnPolicy toDomain(ReturnPolicyJpaEntity entity) {
        return new ReturnPolicy(
                entity.getId(),
                entity.getName(),
                entity.getVersion(),
                entity.getDurationHours(),
                entity.isActive(),
                entity.getCreatedAt()
        );
    }
}
