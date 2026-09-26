# Role-owned operational queries — acceptance scenarios

## SC-QUERY-001 — Participant isolation

Given two associated participants have circulations,
when one participant lists or opens personal history,
then only that participant's records are returned,
and direct access to the other participant's circulation returns not found.

## SC-QUERY-002 — Multiple active containers

Given one participant has multiple active circulations,
when Inicio loads,
then every active container and its server due-at are returned.

## SC-QUERY-003 — Pending-wash queue

Given returned and non-returned containers exist,
when Cafetería loads pending washes,
then only returned containers are listed with their return time.

## SC-QUERY-004 — Operator activity isolation

Given two Cafetería actors have recorded events,
when one loads recent operations,
then only events performed by that authenticated actor are returned.

## SC-QUERY-005 — Real operations summary

Given persisted containers in multiple states,
when ReVuelta loads the summary,
then each metric is derived from current persisted state,
and no mock metric is returned.

## SC-QUERY-006 — Empty and pagination states

Given a permitted query has no matching rows or more rows than one page,
when it is requested,
then it returns an empty `items` list or `hasNext=true` respectively,
without treating either state as failure.
