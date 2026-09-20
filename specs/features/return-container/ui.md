# Return Container — UI Contract

**Status:** PRODUCT UI FLOW APPROVED. Technical implementation remains gated by authentication and API decisions.

## Perspectives

### Alumno

May:

- inspect their active circulation;
- scan their associated container;
- view the return point and instructions;
- wait for and observe a server-confirmed operational receipt.

Must not finalize the circulation.

### Cafetería

Approved operational flow:

- scan/resolve container;
- review active circulation and minimum holder information;
- confirm physical receipt once;
- show server-confirmed `RETURNED` result and “Pendiente de lavado”.

### Operación ReVuelta

May inspect the result and perform separately specified reasoned corrections. It does not receive the normal Cafetería return action.

## Shared rules

- returned-at and punctuality are server-authoritative;
- missing active circulation is a typed failure;
- duplicate taps do not create duplicate client commands;
- timeout produces an uncertain result;
- return success displays `RETURNED/Pendiente de lavado`, never `Disponible`;
- `Disponible` appears only after the separate washing operation succeeds;
- environmental impact is not inferred by the return screen.

## Acceptance

- Student behavior maps to SC-STU-003/004.
- Cafeteria behavior maps to SC-CAF-002..005.
- Domain/API behavior remains SC-RET-001..007.
