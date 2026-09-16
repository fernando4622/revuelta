# Mobile State Machine Specification

## 1. Rule

Each asynchronous interaction MUST represent one coherent state at a time.

## 2. Authentication state

```text
Unauthenticated
Authenticating
Authenticated(session)
AuthenticationFailed(failure)
```

Transitions:

```text
Unauthenticated → Authenticating
Authenticating → Authenticated
Authenticating → AuthenticationFailed
AuthenticationFailed → Authenticating
Authenticated → Unauthenticated (logout/session invalidation)
```

## 3. Scan state

```text
Idle
PermissionRequired
Ready
Scanning
Resolving
Resolved(container)
Failed(failure)
```

No mutation operation may start until a valid resolution result exists.

## 4. Mutation command state

```text
Ready
Submitting
Succeeded(result)
Rejected(failure)
```

Repeated user taps while `Submitting` MUST NOT cause duplicate application commands unless the contract explicitly supports concurrent commands.

## 5. Rendering requirements

Every state MUST define:

- renderable content;
- available actions;
- unavailable actions;
- transition triggers;
- retry behavior;
- recovery behavior.
