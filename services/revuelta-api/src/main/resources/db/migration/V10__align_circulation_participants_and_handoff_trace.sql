-- F5 aligns circulation ownership with the Participant aggregate and records
-- handoff references on append-only container events.

INSERT INTO participants (id, active, created_at)
SELECT c.borrower_id, TRUE, MIN(c.delivered_at)
FROM circulations c
LEFT JOIN participants p ON p.id = c.borrower_id
WHERE p.id IS NULL
GROUP BY c.borrower_id;

ALTER TABLE circulations
    DROP CONSTRAINT circulations_borrower_id_fkey,
    ADD CONSTRAINT fk_circulations_participant
        FOREIGN KEY (borrower_id) REFERENCES participants(id) ON DELETE RESTRICT;

ALTER TABLE container_events
    ADD COLUMN participant_id UUID,
    ADD COLUMN circulation_id UUID,
    ADD CONSTRAINT fk_container_events_participant
        FOREIGN KEY (participant_id) REFERENCES participants(id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_container_events_circulation
        FOREIGN KEY (circulation_id) REFERENCES circulations(id) ON DELETE RESTRICT,
    ADD CONSTRAINT container_events_handoff_references_consistent CHECK (
        (participant_id IS NULL AND circulation_id IS NULL)
        OR (participant_id IS NOT NULL AND circulation_id IS NOT NULL)
    );

CREATE INDEX idx_container_events_circulation
    ON container_events(circulation_id)
    WHERE circulation_id IS NOT NULL;
