-- F2 data integrity baseline: policy provenance, optimistic concurrency,
-- lifecycle consistency and request correlation for append-oriented events.

ALTER TABLE return_policies
    ADD COLUMN version INTEGER NOT NULL DEFAULT 1,
    ADD CONSTRAINT return_policies_version_positive CHECK (version > 0),
    ADD CONSTRAINT return_policies_duration_positive CHECK (duration_hours > 0);

ALTER TABLE circulations
    ADD COLUMN return_policy_id UUID,
    ADD COLUMN return_policy_version INTEGER,
    ADD COLUMN lock_version BIGINT NOT NULL DEFAULT 0;

UPDATE circulations
SET return_policy_id = selected_policy.id,
    return_policy_version = selected_policy.version
FROM (
    SELECT id, version
    FROM return_policies
    ORDER BY active DESC, created_at DESC, id
    LIMIT 1
) AS selected_policy
WHERE circulations.return_policy_id IS NULL;

ALTER TABLE circulations
    ALTER COLUMN return_policy_id SET NOT NULL,
    ALTER COLUMN return_policy_version SET NOT NULL,
    ADD CONSTRAINT fk_circulations_return_policy
        FOREIGN KEY (return_policy_id) REFERENCES return_policies(id) ON DELETE RESTRICT,
    ADD CONSTRAINT circulations_policy_version_positive CHECK (return_policy_version > 0),
    ADD CONSTRAINT circulations_due_not_before_delivery CHECK (due_at >= delivered_at),
    ADD CONSTRAINT circulations_return_not_before_delivery
        CHECK (returned_at IS NULL OR returned_at >= delivered_at),
    ADD CONSTRAINT circulations_lifecycle_consistent CHECK (
        (status = 'ACTIVE' AND returned_by IS NULL AND returned_at IS NULL AND punctuality IS NULL)
        OR
        (status = 'COMPLETED' AND returned_by IS NOT NULL AND returned_at IS NOT NULL AND punctuality IS NOT NULL)
    );

ALTER TABLE containers
    ADD COLUMN lock_version BIGINT NOT NULL DEFAULT 0,
    DROP CONSTRAINT containers_status_check,
    ADD CONSTRAINT containers_status_check
        CHECK (status IN ('REGISTERED', 'AVAILABLE', 'IN_USE', 'RETURNED', 'DAMAGED', 'LOST', 'RETIRED'));

ALTER TABLE container_events
    ADD COLUMN correlation_id UUID;

-- Existing events predate request correlation. Their own immutable event ID is
-- retained as a deterministic legacy correlation marker during the migration.
UPDATE container_events
SET correlation_id = id
WHERE correlation_id IS NULL;

ALTER TABLE container_events
    ALTER COLUMN correlation_id SET NOT NULL,
    ADD CONSTRAINT container_events_previous_status_check CHECK (
        previous_status IS NULL OR previous_status IN (
            'REGISTERED', 'AVAILABLE', 'IN_USE', 'RETURNED', 'DAMAGED', 'LOST', 'RETIRED'
        )
    ),
    ADD CONSTRAINT container_events_new_status_check CHECK (
        new_status IN ('REGISTERED', 'AVAILABLE', 'IN_USE', 'RETURNED', 'DAMAGED', 'LOST', 'RETIRED')
    );
