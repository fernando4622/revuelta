package com.revuelta.api.domain.event;

import com.revuelta.api.domain.container.ContainerId;
import com.revuelta.api.domain.user.UserId;

import java.util.List;
import java.util.Optional;
import java.util.Set;

public interface ContainerEventRepositoryPort {
    void save(ContainerEvent event);
    List<ContainerEvent> findByContainerId(ContainerId containerId, int page, int size);
    default Optional<ContainerEvent> findLatestByContainerIdAndType(ContainerId containerId, ContainerEventType type) {
        throw new UnsupportedOperationException("Latest-event query is not implemented");
    }
    default boolean existsByContainerIdAndType(ContainerId containerId, ContainerEventType type) {
        throw new UnsupportedOperationException("Event existence query is not implemented");
    }
    default List<ContainerEvent> findByActorIdAndTypes(UserId actorId, Set<ContainerEventType> types, int page, int size) {
        throw new UnsupportedOperationException("Actor event query is not implemented");
    }
    default List<ContainerEvent> findAll(ContainerEventType type, int page, int size) {
        throw new UnsupportedOperationException("Global event query is not implemented");
    }
}
