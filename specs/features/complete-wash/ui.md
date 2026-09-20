# Complete Container Washing — UI Contract

**Status:** APPROVED PRODUCT FLOW.

## Entry

Cafetería opens “Pendientes de lavado” or resolves a container whose server state is `RETURNED`.

## Required content

- public container code;
- status “Pendiente de lavado”;
- returned-at;
- explicit “Marcar lavado completado” action;
- cancel/back;
- server-confirmed result.

## State machine

```text
Loading
Returned(container)
Reviewing
Submitting
Succeeded(availableContainer)
Rejected(failure)
ResultUncertain(correlation)
```

## Rules

- no circulation data is edited;
- repeated taps are disabled while submitting;
- only server success shows “Disponible”;
- timeout is uncertain, not success;
- non-returned containers do not display the action.

## Acceptance

- successful command removes the item from pending-wash list after refresh;
- duplicate/concurrent response is deterministic;
- unavailable or in-use container never appears as successfully washed.
