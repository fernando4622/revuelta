# Mobile UI State Machine Specification

**Status:** APPROVED BASELINE for UI behavior. Business-success transitions remain governed by the feature and domain specs.

## 1. Rule

Each asynchronous interaction MUST represent one coherent state at a time. Independent booleans that allow contradictory combinations are prohibited.

Every state defines:

- renderable content;
- available and unavailable actions;
- transition triggers;
- retry behavior;
- cancellation/recovery behavior.

## 2. Authentication and role-routing state

```text
RestoringSession
Unauthenticated
Authenticating
Authenticated(Participant | Operator | Admin)
AuthenticationFailed(failure)
UnsupportedRole
LoggingOut
```

Transitions:

```text
RestoringSession → Unauthenticated | Authenticated | UnsupportedRole
Unauthenticated → Authenticating
Authenticating → Authenticated | AuthenticationFailed
AuthenticationFailed → Authenticating | Unauthenticated
Authenticated → LoggingOut → Unauthenticated
```

The authenticated role selects the shell. Logout MUST clear navigation history, pending scans, draft forms, mutation results and local credentials. A missing or unknown role MUST NOT open a protected shell.

## 3. Data page state

```text
Initial
Loading
Empty
Success(data)
Failure(failure)
Refreshing(previousData)
```

A refresh failure MAY preserve previously confirmed data, but it MUST indicate that the refresh failed.

## 4. Scan state

```text
Idle
PermissionRequired
PermissionDenied
Ready
Scanning
Resolving(payload)
Resolved(container)
Failed(failure)
```

Rules:

- a repeated camera frame while `Resolving` is ignored;
- malformed QR fails before a network mutation;
- resolution never changes business state;
- leaving the screen releases the camera;
- a retry returns to `Ready` only after the previous resolution completes or is cancelled.

## 5. Student return-information journey

```text
LoadingActiveCirculation
NoActiveCirculation
ActiveCirculation(data)
ScanningContainer
ContainerResolved(data)
ShowingReturnInstructions(data)
AwaitingOperationalReceipt(data)
Returned(serverResult)
Failed(failure)
```

The student journey MUST NOT finalize the circulation. It may identify the container, present the return point and observe a server-confirmed receipt performed by Cafetería.

## 6. Cafeteria delivery command

```text
ReadyToScan
ResolvingContainer
ContainerRejected(failure)
ContainerEligible(container)
CapturingRecipient
ReviewingDelivery(command)
SubmittingDelivery
DeliverySucceeded(result)
DeliveryRejected(failure)
ResultUncertain(correlation)
```

Repeated taps during `SubmittingDelivery` MUST NOT produce duplicate application commands.

## 7. Cafeteria return command

```text
ReadyToScan
ResolvingContainer
ContainerRejected(failure)
ReviewingReturn(activeCirculation)
SubmittingReturn
ReturnSucceeded(result)
ReturnRejected(failure)
ResultUncertain(correlation)
```

Only a server response or a subsequent result query may transition to `ReturnSucceeded`.

## 8. Generic mutation command

```text
Ready
Reviewing
Submitting
Succeeded(result)
Rejected(failure)
ResultUncertain(correlation)
```

Rules:

- controls are disabled while `Submitting`;
- navigation away requires safe cancellation or a warning;
- a timeout does not imply failure or success;
- retry follows the endpoint's idempotency contract;
- server state is refreshed after a conflict or uncertain result.

## 9. Cafeteria washing command

```text
LoadingPendingWash
PendingWash(items)
ReviewingContainer(container)
SubmittingWashCompletion
WashSucceeded(availableContainer)
WashRejected(failure)
ResultUncertain(correlation)
```

Only a server-confirmed transition may remove the item from the pending-wash list.

## 10. Impact and notifications state

Impact:

```text
Unavailable
Loading
Available(methodologyVersion, metrics)
Failure
```

Notifications:

```text
Loading
Empty
Available(items)
Failure
```

Demo values may transition to `Available` only in a demo build and with “Datos de demostración” visible. They MUST NOT do so in a production build.
