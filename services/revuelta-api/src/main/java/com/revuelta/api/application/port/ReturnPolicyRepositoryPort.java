package com.revuelta.api.application.port;

import com.revuelta.api.domain.policy.ReturnPolicy;

import java.util.Optional;

public interface ReturnPolicyRepositoryPort {
    Optional<ReturnPolicy> findActivePolicy();
    ReturnPolicy save(ReturnPolicy policy);
}
